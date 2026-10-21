const { createHash } = require('node:crypto');
const redis = require('../config/redis');
const digest = value => createHash('sha256').update(value).digest('hex');
// INCR and expiry must be atomic, including the first request in a window.
const counterScript = `local n=redis.call('INCR',KEYS[1]); if n==1 then redis.call('EXPIRE',KEYS[1],ARGV[1]) end; return {n,redis.call('TTL',KEYS[1])}`;

function cache(ttl = 60) {
  return async (req, res, next) => {
    if (!redis.enabled() || req.method !== 'GET' || req.headers.authorization) return next();
    const key = `dp:v1:cache:${digest(req.originalUrl)}`;
    try {
      const hit = await redis.command(['GET', key]);
      if (hit !== null) return res.json(JSON.parse(hit));
    } catch (_) { /* Cache is optional: use MongoDB if Redis is unavailable. */ }
    const json = res.json.bind(res);
    res.json = body => {
      if (res.statusCode === 200 && body?.success === true) {
        const value = JSON.stringify(body);
        if (Buffer.byteLength(value) <= 512000) {
          void redis.command(['SET', key, value, 'EX', ttl]).catch(() => {});
        }
      }
      return json(body);
    };
    next();
  };
}

function rateLimit(scope, limit, seconds) {
  return async (req, res, next) => {
    if (!redis.enabled() || process.env.REDIS_RATE_LIMIT_ENABLED !== 'true') return next();
    const key = `dp:v1:limit:${scope}:${digest(req.ip || req.socket.remoteAddress || 'unknown')}`;
    try {
      const result = await redis.command(['EVAL', counterScript, '1', key, String(seconds)]);
      if (!Array.isArray(result) || !Number.isFinite(Number(result[0]))) throw new Error('Invalid counter');
      if (Number(result[0]) > limit) {
        res.set('Retry-After', String(Math.max(1, Number(result[1]) || seconds)));
        return res.status(429).json({ success: false, message: 'Bạn thao tác quá nhanh. Vui lòng thử lại sau.' });
      }
      next();
    } catch (_) {
      // Do not silently disable abuse protection during an outage.
      res.set('Retry-After', '5');
      return res.status(503).json({ success: false, message: 'Dịch vụ đang bận. Vui lòng thử lại sau.' });
    }
  };
}
module.exports = { cache, rateLimit };
