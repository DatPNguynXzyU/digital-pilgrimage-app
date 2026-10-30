from pathlib import Path
p=Path('D:/PhamNguyenTuanDat_2380614580')
f=p/'backend/src/app.js';s=f.read_text(encoding='utf8');s=s.replace("  if(u.password)fail(409,'Email đã có tài khoản mật khẩu. Hãy đăng nhập bằng mật khẩu và OTP.');",'  // Exchange requires email OTP for existing password accounts; never issue a session directly.')
old="const u=(await q('SELECT * FROM users WHERE id=$1',[ch.user_id])).rows[0];res.json(session(u));"
new="const u=(await q('SELECT * FROM users WHERE id=$1',[ch.user_id])).rows[0];if(!u)fail(401,'Tài khoản không còn tồn tại');if(u.password){res.json({...await challenge(u,'login'),requiresOtp:true});return;}res.json(session(u));"
assert old in s;s=s.replace(old,new);f.write_text(s,encoding='utf8')
f=p/'frontend/lib/main.dart';s=f.read_text(encoding='utf8');a=s.index('    await enter(',s.index('  Future<void> google()'));b=s.index('\n  });',a)
s=s[:a]+'''    final response = Map<String, dynamic>.from(
      await api.call('POST', '/auth/google/exchange', {'code': c, 'verifier': verifier}),
    );
    if (response['requiresOtp'] == true) {
      if (!mounted) return;
      setState(() { challenge = response['challengeId']; code.clear(); });
      notify(context, response['message']);
      return;
    }
    await enter(response);'''+s[b:];f.write_text(s,encoding='utf8')
f=p/'backend/test/api.test.js';s=f.read_text();s+='''
test('Google exchange for password account requires OTP and preserves account',async()=>{
 const u=await register();const {randomUUID}=await import('node:crypto');const verifier='v'.repeat(40),code='c'.repeat(40);
 await pool.query("INSERT INTO challenges(id,user_id,kind,digest,expires_at,payload) VALUES($1,$2,'oauth-exchange',$3,now()+interval '1 minute',$4)",[randomUUID(),u.user.id,hash(code),JSON.stringify({verifierHash:hash(verifier)})]);
 await request(app).post('/auth/google/exchange').send({code,verifier:'wrong'.repeat(8)}).expect(401);
 const r=await request(app).post('/auth/google/exchange').send({code,verifier}).expect(200);
 assert.equal(r.body.requiresOtp,true);assert.equal(r.body.token,undefined);
 const verified=await request(app).post('/auth/otp').send({challengeId:r.body.challengeId,code:mails.at(-1).code}).expect(200);
 assert.equal(verified.body.user.id,u.user.id);
 await request(app).post('/auth/google/exchange').send({code,verifier}).expect(401);
});
''';f.write_text(s,encoding='utf8')
