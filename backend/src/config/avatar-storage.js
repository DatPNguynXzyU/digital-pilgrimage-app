const { createHash } = require('node:crypto');

function validateAvatarStorage() {
  const mode = process.env.AVATAR_STORAGE || 'local';
  if (!['local', 'cloudinary'].includes(mode)) throw new Error('Invalid AVATAR_STORAGE');
  if (mode === 'cloudinary') {
    for (const key of ['CLOUDINARY_CLOUD_NAME', 'CLOUDINARY_API_KEY', 'CLOUDINARY_API_SECRET']) {
      if (!process.env[key]) throw new Error(`Missing ${key}`);
    }
  }
}

async function uploadCloudAvatar(file, userId) {
  validateAvatarStorage();
  const timestamp = Math.floor(Date.now() / 1000).toString();
  // One stable asset per account prevents accumulating unused avatar uploads.
  const publicId = `digital-pilgrimage/avatars/${userId}`;
  const signature = createHash('sha256')
    .update(`overwrite=true&public_id=${publicId}&timestamp=${timestamp}${process.env.CLOUDINARY_API_SECRET}`)
    .digest('hex');
  const form = new FormData();
  form.set('file', new Blob([file.buffer], { type: file.mimetype }), 'avatar');
  form.set('public_id', publicId);
  form.set('overwrite', 'true');
  form.set('timestamp', timestamp);
  form.set('api_key', process.env.CLOUDINARY_API_KEY);
  form.set('signature', signature);
  const response = await fetch(
    `https://api.cloudinary.com/v1_1/${encodeURIComponent(process.env.CLOUDINARY_CLOUD_NAME)}/image/upload`,
    { method: 'POST', body: form, signal: AbortSignal.timeout(12000) },
  );
  const body = await response.json();
  if (!response.ok || typeof body.secure_url !== 'string' ||
      !body.secure_url.startsWith('https://')) {
    throw new Error('Cloud avatar upload failed');
  }
  return body.secure_url;
}

module.exports = { validateAvatarStorage, uploadCloudAvatar };
