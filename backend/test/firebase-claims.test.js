const { test } = require('node:test');
const assert = require('node:assert/strict');
const { validateClaims } = require('../src/config/firebase');

test('only verified password/Google identities can enter the application', () => {
  const claims = { uid: 'uid', email: 'user@example.test', email_verified: true,
    firebase: { sign_in_provider: 'google.com' } };
  assert.equal(validateClaims(claims), claims);
  assert.throws(() => validateClaims({ ...claims, email_verified: false }));
  assert.throws(() => validateClaims({ ...claims, email_verified: 'true' }));
  assert.throws(() => validateClaims({ ...claims, email: null }));
  assert.throws(() => validateClaims({ ...claims, firebase: { sign_in_provider: 'anonymous' } }));
  assert.equal(validateClaims({ ...claims, firebase: { sign_in_provider: 'password' } }).uid, 'uid');
});
