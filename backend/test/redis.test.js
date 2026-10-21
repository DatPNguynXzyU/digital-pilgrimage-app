const { test } = require('node:test');
const assert = require('node:assert/strict');
const redis = require('../src/config/redis');
const { cache, rateLimit } = require('../src/middleware/redis.middleware');
function response() {
  return { statusCode: 200, headers: {}, set(k,v) { this.headers[k]=v; return this; },
    status(n) { this.statusCode=n; return this; }, json(body) { this.body=body; return this; } };
}
test('Redis cache boundaries and limiter failure behaviour', async () => {
  const originalEnabled=redis.enabled, originalCommand=redis.command;
  const oldFlag=process.env.REDIS_RATE_LIMIT_ENABLED;
  process.env.REDIS_RATE_LIMIT_ENABLED='true';
  try {
    redis.enabled=()=>true;
    const req={ method:'GET', originalUrl:'/api/temples?search=a', headers:{}, ip:'127.0.0.1' };
    let calls=[];
    redis.command=async args=>{calls.push(args);return null;};
    let res=response();
    await cache()(req,res,()=>res.json({success:true,data:[]}));
    assert.equal(calls[1][0],'SET'); assert.equal(calls[1][4],60);
    const key=calls[0][1];calls=[];
    await cache()({...req,originalUrl:'/api/temples?search=b'},response(),()=>{});
    assert.notEqual(calls[0][1],key);
    calls=[];await cache()({...req,headers:{authorization:'Bearer secret'}},response(),()=>{});
    assert.equal(calls.length,0);
    redis.command=async()=>JSON.stringify({success:true,data:[1]});res=response();
    await cache()(req,res,()=>assert.fail('cache hit must skip database'));
    assert.deepEqual(res.body.data,[1]);
    redis.command=async()=>{throw new Error('offline');};
    let passed=false;await cache()(req,response(),()=>{passed=true;});assert.ok(passed);
    res=response();await rateLimit('test',2,60)(req,res,()=>assert.fail());assert.equal(res.statusCode,503);
    redis.command=async()=>[3,40];res=response();
    await rateLimit('test',2,60)(req,res,()=>assert.fail());assert.equal(res.statusCode,429);assert.equal(res.headers['Retry-After'],'40');
    redis.command=async()=>[2,40];passed=false;
    await rateLimit('test',2,60)(req,response(),()=>{passed=true;});assert.ok(passed);
    redis.enabled=()=>false;passed=false;
    await rateLimit('test',2,60)(req,response(),()=>{passed=true;});assert.ok(passed);
  } finally {
    redis.enabled=originalEnabled;redis.command=originalCommand;
    if(oldFlag===undefined) delete process.env.REDIS_RATE_LIMIT_ENABLED;
    else process.env.REDIS_RATE_LIMIT_ENABLED=oldFlag;
  }
});
