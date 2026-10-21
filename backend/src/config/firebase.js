const { initializeApp, getApps, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const fs = require('node:fs');

function configured() {
  return Boolean(process.env.FIREBASE_PROJECT_ID);
}

function auth() {
  if (!configured()) throw new Error('Firebase not configured');
  let app = getApps().find((entry) => entry.name === 'identity');
  if (!app) {
    const file = process.env.FIREBASE_SERVICE_ACCOUNT_FILE;
    if (!file) throw new Error('Firebase service account file missing');
    let account;
    try {
      account = JSON.parse(fs.readFileSync(file, 'utf8'));
    } catch (_) {
      throw new Error('Cannot read Firebase service account JSON');
    }
    if (account.project_id !== process.env.FIREBASE_PROJECT_ID) {
      throw new Error('Firebase project mismatch');
    }
    app = initializeApp({
      credential: cert(account),
      projectId: process.env.FIREBASE_PROJECT_ID,
    }, 'identity');
  }
  return getAuth(app);
}

async function verify(token) {
  // Check revocation and disabled accounts, not just the token signature.
  const claims = await auth().verifyIdToken(token, true);
  return validateClaims(claims);
}

function validateClaims(claims) {
  if (claims.email_verified !== true || typeof claims.email !== 'string') {
    const error = new Error('Email chưa được xác nhận.');
    error.code = 'auth/email-not-verified';
    throw error;
  }
  const provider = claims.firebase?.sign_in_provider;
  if (!['google.com', 'password'].includes(provider)) {
    const error = new Error('Unsupported sign-in provider');
    error.code = 'auth/invalid-id-token';
    throw error;
  }
  return claims;
}

module.exports = { auth, configured, verify, validateClaims };
