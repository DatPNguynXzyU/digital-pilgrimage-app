// Upstash Redis REST: credentials stay on the backend.
function enabled() { return Boolean(process.env.UPSTASH_REDIS_REST_URL); }
function validate() {
  const url = process.env.UPSTASH_REDIS_REST_URL;
  const token = process.env.UPSTASH_REDIS_REST_TOKEN;
  if (!url && !token) return;
  if (!url || !token || new URL(url).protocol !== 'https:') {
    throw new Error('Redis requires HTTPS REST URL and token');
  }
  if (process.env.REDIS_RATE_LIMIT_ENABLED === 'true' && process.env.TRUST_PROXY_HOPS === undefined) {
    throw new Error('Set verified TRUST_PROXY_HOPS before enabling Redis rate limiting');
  }
}
async function command(args) {
  validate();
  const response = await fetch(process.env.UPSTASH_REDIS_REST_URL, {
    method: 'POST',
    headers: { Authorization: `Bearer ${process.env.UPSTASH_REDIS_REST_TOKEN}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(args), signal: AbortSignal.timeout(1500),
  });
  if (!response.ok) throw new Error('Redis unavailable');
  const body = await response.json();
  if (body.error) throw new Error('Redis command failed');
  return body.result;
}
module.exports = { enabled, validate, command };
