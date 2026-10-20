const { test } = require('node:test');
const assert = require('node:assert/strict');
const { createHash } = require('node:crypto');
const { validateAvatarStorage, uploadCloudAvatar } = require('../src/config/avatar-storage');

test('cloud avatar upload signs server-side and rejects failed provider responses', async () => {
  const keys = ['AVATAR_STORAGE', 'CLOUDINARY_CLOUD_NAME', 'CLOUDINARY_API_KEY', 'CLOUDINARY_API_SECRET'];
  const saved = Object.fromEntries(keys.map(key => [key, process.env[key]]));
  const originalFetch = global.fetch;
  try {
    process.env.AVATAR_STORAGE = 'cloudinary';
    delete process.env.CLOUDINARY_API_SECRET;
    assert.throws(validateAvatarStorage, /Missing/);
    process.env.CLOUDINARY_CLOUD_NAME = 'test-cloud';
    process.env.CLOUDINARY_API_KEY = 'test-key';
    process.env.CLOUDINARY_API_SECRET = 'test-secret';
    global.fetch = async (url, options) => {
      assert.equal(url, 'https://api.cloudinary.com/v1_1/test-cloud/image/upload');
      const data = options.body;
      assert.equal(data.get('public_id'), 'digital-pilgrimage/avatars/user123');
      const expected = createHash('sha256').update(
        `overwrite=true&public_id=digital-pilgrimage/avatars/user123&timestamp=${data.get('timestamp')}test-secret`
      ).digest('hex');
      assert.equal(data.get('signature'), expected);
      assert.equal(data.get('api_secret'), null);
      return { ok: true, json: async () => ({secure_url:'https://res.cloudinary.com/test/avatar.png'}) };
    };
    assert.equal(await uploadCloudAvatar({buffer:Buffer.from('image'),mimetype:'image/png'}, 'user123'),
      'https://res.cloudinary.com/test/avatar.png');
    global.fetch = async () => ({ok:false,json:async () => ({error:'upload failed'})});
    await assert.rejects(uploadCloudAvatar({buffer:Buffer.from('image'),mimetype:'image/png'}, 'user123'));
  } finally {
    global.fetch = originalFetch;
    for (const key of keys) {
      if (saved[key] === undefined) delete process.env[key];
      else process.env[key] = saved[key];
    }
  }
});
