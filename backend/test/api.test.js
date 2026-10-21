const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const mongoose = require('mongoose');
const jwt = require('jsonwebtoken');
const { randomUUID } = require('crypto');
// Never load .env or use the application's database. Every run owns a fresh DB.
const uri = process.env.TEST_MONGODB_URI;
if (!uri) throw new Error('Use docker compose -p apptungkinh-tests -f compose.test.yaml up --build --abort-on-container-exit --exit-code-from test');
const database = 'apptungkinh_test_' + randomUUID().replaceAll('-', '');
process.env.JWT_SECRET = randomUUID();
process.env.JWT_EXPIRES_IN = '1h';
const app = require('../src/app');
const User = require('../src/models/user.model');
const Temple = require('../src/models/temple.model');
const NfcTag = require('../src/models/nfc-tag.model');
const Visit = require('../src/models/pilgrimage-visit.model');
const Stamp = require('../src/models/temple-stamp.model');
const Calendar = require('../src/models/calendar-event.model');
let server, base;
async function start() {
  server = await new Promise(resolve => {
    const instance = app.listen(0, '127.0.0.1', () => resolve(instance));
  });
  base = 'http://127.0.0.1:' + server.address().port + '/api';
}
async function stop() { if (server) await new Promise(resolve => server.close(resolve)); }
before(async () => {
  await mongoose.connect(uri, { dbName: database });
  await Promise.all([User, Temple, NfcTag, Visit, Stamp, Calendar].map(model => model.init()));
  await start();
});
after(async () => {
  await stop();
  if (mongoose.connection.name === database) await mongoose.connection.dropDatabase();
  await mongoose.disconnect();
});
async function request(method, path, token, body) {
  const response = await fetch(base + path, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token ? { Authorization: 'Bearer ' + token } : {}) },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  return { status: response.status, body: await response.json() };
}
async function account() {
  const credentials = { fullName: 'Test User', email: randomUUID() + '@example.test', password: 'Test-password-123' };
  const registered = await request('POST', '/auth/register', null, credentials);
  assert.equal(registered.status, 201);
  const loggedIn = await request('POST', '/auth/login', null, credentials);
  assert.equal(loggedIn.status, 200);
  return { ...credentials, token: loggedIn.body.token, registeredToken: registered.body.token, id: loggedIn.body.user.id };
}
const eventData = () => ({ id: randomUUID(), title: 'Lễ Phật', startAt: '2026-10-16T09:00:00.000', endAt: '2026-10-16T10:00:00.000', repeat: 'monthly', usesLunarDate: true, reminderMinutes: 30 });
test('Firebase verification, legacy collision, blocked users and revoked sessions', async () => {
  const legacy = await account();
  const firebase = require('../src/config/firebase');
  const originalVerify = firebase.verify;
  const originalAuth = firebase.auth;
  const oldProject = process.env.FIREBASE_PROJECT_ID;
  process.env.FIREBASE_PROJECT_ID = 'isolated-test';
  let revoked = false;
  let claims = { uid: randomUUID(), email: randomUUID() + '@example.test',
    email_verified: false, firebase: { sign_in_provider: 'password' } };
  firebase.verify = async () => {
    if (revoked) {
      const error = new Error('revoked');
      error.code = 'auth/id-token-revoked';
      throw error;
    }
    return firebase.validateClaims(claims);
  };
  try {
    assert.equal((await request('POST', '/auth/firebase', null, { idToken: 'test-token' })).status, 403);
    assert.equal(await User.countDocuments({ firebaseUid: claims.uid }), 0);
    assert.equal((await request('POST', '/auth/register', null, {
      fullName: 'Bypass Attempt', email: 'bypass@example.test', password: 'password123',
    })).status, 403);
    claims.email_verified = true;
    let signIn = await request('POST', '/auth/firebase', null, { idToken: 'test-token' });
    assert.equal(signIn.status, 200);
    assert.equal((await request('GET', '/auth/me', signIn.body.token)).status, 200);
    assert.equal((await request('POST', '/auth/firebase', null, { idToken: 'test-token' })).status, 200);
    assert.equal(await User.countDocuments({ firebaseUid: claims.uid }), 1);
    const passwordChanges = [];
    firebase.auth = () => ({
      updateUser: async (uid, patch) => passwordChanges.push({ uid, patch }),
      revokeRefreshTokens: async () => { revoked = true; },
    });
    claims.auth_time = Math.floor(Date.now() / 1000) - 600;
    assert.equal((await request('PUT', '/auth/firebase/change-password', signIn.body.token,
      { newPassword: 'New-password-456' })).status, 403);
    assert.equal(passwordChanges.length, 0);
    claims.auth_time = Math.floor(Date.now() / 1000);
    assert.equal((await request('PUT', '/auth/firebase/change-password', signIn.body.token,
      { newPassword: 'New-password-456' })).status, 200);
    assert.deepEqual(passwordChanges, [{ uid: claims.uid, patch: { password: 'New-password-456' } }]);
    revoked = true;
    assert.equal((await request('GET', '/calendar-events', signIn.body.token)).status, 401);
    revoked = false;
    await User.updateOne({ firebaseUid: claims.uid }, { status: 'blocked' });
    assert.equal((await request('GET', '/auth/me', signIn.body.token)).status, 403);
    assert.equal((await request('POST', '/auth/firebase', null, { idToken: 'test-token' })).status, 403);
    claims = { ...claims, uid: randomUUID(), email: legacy.email,
      firebase: { sign_in_provider: 'google.com' } };
    assert.equal((await request('POST', '/auth/firebase', null, { idToken: 'test-token' })).status, 409);
    assert.equal((await request('POST', '/auth/login', null, {
      email: legacy.email, password: legacy.password,
    })).status, 200);
  } finally {
    firebase.verify = originalVerify;
    firebase.auth = originalAuth;
    if (oldProject === undefined) delete process.env.FIREBASE_PROJECT_ID;
    else process.env.FIREBASE_PROJECT_ID = oldProject;
  }
});
test('calendar requires auth on every route', async () => {
  for (const [method, path] of [['GET',''],['GET','/abc'],['POST',''],['PUT','/abc'],['DELETE','/abc']]) {
    assert.equal((await request(method, '/calendar-events' + path, null, method === 'POST' || method === 'PUT' ? eventData() : undefined)).status, 401);
  }
});
test('calendar persists across app/DB reconnection and isolates owners', async () => {
  const alice = await account(), bob = await account(), event = eventData();
  assert.equal((await request('POST', '/calendar-events', alice.token, event)).status, 201);
  assert.equal((await request('GET', '/calendar-events', bob.token)).body.count, 0);
  for (const method of ['GET','PUT','DELETE']) {
    assert.equal((await request(method, '/calendar-events/' + event.id, bob.token, method === 'PUT' ? { title: 'Attack' } : undefined)).status, 404);
  }
  assert.equal((await request('PUT', '/calendar-events/' + event.id, alice.token, {userId: bob.id})).status, 400);
  assert.equal((await request('PUT', '/calendar-events/' + event.id, alice.token, {title: 'Updated'})).status, 200);
  await stop();
  await mongoose.disconnect();
  await mongoose.connect(uri, {dbName: database});
  await start();
  const saved = await request('GET', '/calendar-events/' + event.id, alice.token);
  assert.equal(saved.body.data.title, 'Updated');
  assert.equal(saved.body.data.startAt, event.startAt);
  assert.equal(saved.body.data.repeat, 'monthly');
  assert.equal(saved.body.data.reminderMinutes, 30);
  assert.equal((await request('DELETE', '/calendar-events/' + event.id, alice.token)).status, 200);
  assert.equal((await request('GET', '/calendar-events/' + event.id, alice.token)).status, 404);
});
test('calendar rejects malformed fields and invalid date ranges', async () => {
  const user = await account();
  for (const change of [{title:' '},{startAt:'2026-02-30T09:00:00'},{endAt:'2026-10-15T10:00:00'}, {repeat:'bad'}, {usesLunarDate:'true'}, {reminderMinutes:-1}, {userId:user.id}, {description:[]}, {id:{$ne:null}}]) {
    assert.equal((await request('POST', '/calendar-events', user.token, {...eventData(), ...change})).status, 400);
  }
});
test('password change revokes every old token including legacy JWTs; fresh login works', async () => {
  const user = await account();
  const legacy = jwt.sign({userId:user.id}, process.env.JWT_SECRET);
  assert.equal((await request('GET','/auth/me',legacy)).status,200);
  assert.equal((await request('PUT','/auth/change-password',user.token,{currentPassword:'wrong',newPassword:'New-password-123'})).status,400);
  assert.equal((await request('GET','/auth/me',user.token)).status,200);
  assert.equal((await request('PUT','/auth/change-password',user.token,{currentPassword:user.password,newPassword:123456})).status,400);
  assert.equal((await request('PUT','/auth/change-password',user.token,{currentPassword:user.password,newPassword:'New-password-123'})).status,200);
  for (const token of [legacy,user.token,user.registeredToken]) {
    for (const path of ['/auth/me','/calendar-events','/pilgrimage/history']) assert.equal((await request('GET',path,token)).status,401);
    assert.equal((await request('POST','/nfc/scan',token,{uid:'04AABBCC',slug:'test'})).status,401);
  }
  assert.equal((await request('POST','/auth/login',null,{email:user.email,password:user.password})).status,401);
  const login = await request('POST','/auth/login',null,{email:user.email,password:'New-password-123'});
  assert.equal(login.status,200);
  assert.equal((await request('GET','/auth/me',login.body.token)).status,200);
});
test('registration → login → NFC → one stamp per temple → private history', async () => {
  const user = await account(), other = await account();
  const temple = await Temple.create({name:'Test Temple',slug:randomUUID()});
  const tag = await NfcTag.create({uid:'04AABBCC',templeId:temple._id});
  const scan = {uid:'04:AA:BB:CC',slug:temple.slug,userId:other.id};
  assert.equal((await request('POST','/nfc/scan',null,scan)).status,401);
  assert.equal((await request('POST','/nfc/scan',user.token,{})).status,400);
  assert.equal((await request('POST','/nfc/scan',user.token,{...scan,slug:'wrong'})).status,400);
  assert.equal((await request('POST','/nfc/scan',user.token,{...scan,uid:'00112233'})).status,404);
  assert.equal(await Visit.countDocuments({userId:user.id}),0);
  const first = await request('POST','/nfc/scan',user.token,scan);
  assert.equal(first.status,200);
  assert.equal(first.body.data.stamp.isNew,true);
  const second = await request('POST','/nfc/scan',user.token,scan);
  assert.equal(second.status,200);
  assert.equal(second.body.data.stamp.isNew,false);
  assert.equal(second.body.data.visit.visitCount,2);
  const history = await request('GET','/pilgrimage/history',user.token);
  assert.equal(history.body.count,2);
  assert.equal(history.body.data[0].temple.slug,temple.slug);
  assert.equal((await request('GET','/pilgrimage/stamps',user.token)).body.count,1);
  assert.equal((await request('GET','/pilgrimage/history',other.token)).body.count,0);
  assert.equal((await request('GET','/pilgrimage/stamps',other.token)).body.count,0);
  assert.equal((await request('GET','/pilgrimage/stats',user.token)).body.data.totalVisits,2);
  await NfcTag.updateOne({_id:tag._id},{$set:{status:'inactive'}});
  assert.equal((await request('POST','/nfc/scan',user.token,scan)).status,404);
  assert.equal(await Visit.countDocuments({userId:user.id}),2);
});
test('NFC transaction rolls back visit if stamp creation fails', async () => {
  const user = await account();
  const temple = await Temple.create({name:'Rollback Temple',slug:randomUUID()});
  await NfcTag.create({uid:'04DDEEFF',templeId:temple._id});
  const original = Stamp.create;
  Stamp.create = async () => { throw new Error('Injected stamp write failure'); };
  try {
    assert.equal((await request('POST','/nfc/scan',user.token,{uid:'04DDEEFF',slug:temple.slug})).status,500);
    assert.equal(await Visit.countDocuments({userId:user.id}),0);
    assert.equal(await Stamp.countDocuments({userId:user.id}),0);
  } finally { Stamp.create = original; }
});
const Quote = require('../src/models/quote.model');
const Scripture = require('../src/models/scripture.model');

test('quotes handle empty data, inactive entries, exclusion and single-entry fallback', async () => {
  assert.equal((await request('GET', '/quotes/random')).body.data, null);
  await Quote.create({code:'hidden',content:'Hidden',isActive:false});
  assert.equal((await request('GET', '/quotes/random')).body.data, null);
  await Quote.create({code:'one',content:'First',source:'Source'});
  assert.equal((await request('GET', '/quotes/random?exclude=one')).body.data.code, 'one');
  await Quote.create({code:'two',content:'Second'});
  const result = await request('GET', '/quotes/random?exclude=one');
  assert.equal(result.status, 200);
  assert.equal(result.body.data.code, 'two');
  assert.equal(result.body.data._id, undefined);
  assert.equal((await request('GET', '/quotes/random?exclude=a&exclude=b')).status, 400);
});

test('scripture listing and detail do not expose inactive content', async () => {
  await Scripture.create([
    {title:'Published',slug:'published',type:'Kinh',content:'Text'},
    {title:'Draft',slug:'draft',type:'Kinh',content:'Draft text',status:'inactive'},
  ]);
  const list = await request('GET', '/scriptures');
  assert.equal(list.status, 200);
  assert.deepEqual(list.body.data.map(item => item.slug), ['published']);
  assert.equal((await request('GET', '/scriptures/draft')).status, 404);
  assert.equal((await request('GET', '/scriptures/published')).status, 200);
});


test('NFC UID lookup and UID-only check-in preserve registered temple ownership', async () => {
  const user = await account();
  const temple = await Temple.create({name:'UID Temple',slug:randomUUID()});
  const other = await Temple.create({name:'Other Temple',slug:randomUUID()});
  const tag = await NfcTag.create({uid:'04ABCDEF',templeId:temple._id});
  const lookup = await request('GET', '/nfc/temple/04:AB:CD:EF');
  assert.equal(lookup.status,200);
  assert.equal(lookup.body.data.temple.slug,temple.slug);
  assert.equal((await request('POST','/nfc/scan',user.token,{uid:tag.uid})).status,200);
  for (const extra of [{slug:other.slug},{templeId:other.id},{slug:''},{templeId:'invalid'}]) {
    assert.equal((await request('POST','/nfc/scan',user.token,{uid:tag.uid,...extra})).status,400);
  }
  assert.equal((await NfcTag.findById(tag._id)).templeId.toString(),temple.id);
  assert.equal(await Visit.countDocuments({userId:user.id}),1);
  assert.equal((await request('POST','/nfc/scan',user.token,{uid:'04FFFF00',slug:temple.slug})).status,404);
  assert.equal(await NfcTag.countDocuments({uid:'04FFFF00'}),0);
  await Temple.updateOne({_id:temple._id},{$set:{status:'inactive'}});
  assert.equal((await request('GET','/nfc/temple/'+tag.uid)).status,404);
  assert.equal((await request('POST','/nfc/scan',user.token,{uid:tag.uid})).status,404);
});
