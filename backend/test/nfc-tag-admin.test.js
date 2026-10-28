const { test } = require('node:test');
const assert = require('node:assert/strict');
const { uidOf } = require('../src/controllers/nfc-tag-admin.controller');
test('tag UID accepts only physical hex bytes and conventional separators', () => {
  assert.equal(uidOf('04:11:22:33:44:55:ab'), '041122334455AB');
  for (const value of [null, {}, '04?112233', 'ABC', 'http://abc.com', 'AA'.repeat(11)]) assert.equal(uidOf(value), null);
});
