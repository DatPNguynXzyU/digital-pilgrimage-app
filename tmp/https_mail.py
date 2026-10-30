from pathlib import Path
p=Path('D:/PhamNguyenTuanDat_2380614580')
(p/'backend/src/mail.js').write_text('''import nodemailer from 'nodemailer';
export function createMailer(env=process.env, fetchImpl=fetch) {
 const provider=env.MAIL_PROVIDER || 'resend';
 if(provider==='smtp') {
  const transport=nodemailer.createTransport({host:env.SMTP_HOST,port:Number(env.SMTP_PORT||587),secure:env.SMTP_PORT==='465',auth:{user:env.SMTP_USER,pass:env.SMTP_PASSWORD},connectionTimeout:15000});
  return (email,code,kind)=>transport.sendMail(message(env.SMTP_FROM,email,code,kind));
 }
 if(provider!=='resend') throw new Error('MAIL_PROVIDER không hợp lệ');
 return async(email,code,kind)=>{
  if(!env.RESEND_API_KEY||!env.MAIL_FROM)throw Object.assign(new Error('Dịch vụ email chưa được cấu hình'),{status:503});
  try {
   const response=await fetchImpl('https://api.resend.com/emails',{method:'POST',headers:{Authorization:`Bearer ${env.RESEND_API_KEY}`,'Content-Type':'application/json'},body:JSON.stringify(message(env.MAIL_FROM,email,code,kind)),signal:AbortSignal.timeout(15000)});
   if(!response.ok)throw new Error('Email provider rejected request');
   return {accepted:true};
  }catch {throw Object.assign(new Error('Chưa gửi được OTP. Vui lòng thử lại sau hoặc liên hệ quản trị.'),{status:503});}
 };
}
function message(from,email,code,kind){return {from,to:[email],subject:'ChildGuard • Mã xác thực',text:`Mã ${kind==='verify'?'xác minh tài khoản':'đăng nhập'} ChildGuard của bạn: ${code}. Có hiệu lực 5 phút. Không chia sẻ mã này.`};}
''',encoding='utf8')
f=p/'backend/src/server.js';s=f.read_text(encoding='utf8').replace("import nodemailer from 'nodemailer';","import {createMailer} from './mail.js';");a=s.index('const mail=');b=s.index('const server=',a);s=s[:a]+'const sendMail=createMailer();\n'+s[b:];f.write_text(s,encoding='utf8')
f=p/'render.yaml';s=f.read_text();a=s.index('      - key: SMTP_HOST');b=s.index('      - key: GOOGLE_CLIENT_ID',a);s=s[:a]+'''      - key: MAIL_PROVIDER
        value: resend
      - key: RESEND_API_KEY
        sync: false
      - key: MAIL_FROM
        sync: false
'''+s[b:];f.write_text(s)
f=p/'backend/.env.example';f.write_text(f.read_text()+'\nMAIL_PROVIDER=resend\nRESEND_API_KEY=\nMAIL_FROM=ChildGuard <onboarding@resend.dev>\n')
(p/'docs/RESEND.md').write_text('''# OTP qua HTTPS trên Render Free

Backend mặc định dùng Resend API qua HTTPS. SMTP chỉ bật khi MAIL_PROVIDER=smtp; không dùng chế độ này trên Render Free.

1. Tạo tài khoản tại https://resend.com và tạo API key có quyền gửi email.
2. Render Environment: MAIL_PROVIDER=resend, RESEND_API_KEY là key riêng, MAIL_FROM là địa chỉ gửi.
3. Thử nghiệm: MAIL_FROM=ChildGuard <onboarding@resend.dev>. Chỉ gửi được tới email tài khoản Resend của bạn.
4. Để cả nhóm nhận OTP: thêm và xác minh domain của bạn trong Resend, rồi đổi MAIL_FROM thành ChildGuard <otp@domain-da-xac-minh>. Không dùng địa chỉ Gmail làm domain gửi đã xác minh.
5. Push render.yaml mới lên GitHub rồi tải lại trang tạo Blueprint. Các ô SMTP sẽ được thay bằng RESEND_API_KEY và MAIL_FROM. Không nhập secret vào Git/chat.
6. Deploy rồi đăng ký bằng email được phép nhận, kiểm tra OTP thật. API key chưa cấu hình hoặc gửi thất bại trả 503; không trả OTP ra response/log.

Google OAuth vẫn cần cấu hình riêng. Các hướng dẫn SMTP cũ trong DEPLOY_RENDER.md được thay thế bằng tài liệu này khi dùng Render Free. Chưa kiểm chứng gửi thư thật cho đến khi cấu hình key và sender.

Nguồn: https://resend.com/docs/api-reference/emails/send-email và https://resend.com/docs/knowledge-base/403-error-resend-dev-domain
''',encoding='utf8')
f=p/'docs/DEPLOY_RENDER.md';f.write_text('# Cập nhật: Render Free dùng Resend HTTPS\n\nLàm theo [hướng dẫn Resend](RESEND.md) thay cho phần SMTP bên dưới.\n\n'+f.read_text(encoding='utf8'),encoding='utf8')
(p/'backend/test/mail.test.js').write_text('''import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createMailer} from '../src/mail.js';
test('HTTPS mail payload and authorization',async()=>{
 let request;
 const send=createMailer({RESEND_API_KEY:'secret',MAIL_FROM:'otp@example.com'},async(url,options)=>{request={url,...options};return {ok:true};});
 await send('user@example.com','123456','verify');
 assert.equal(request.url,'https://api.resend.com/emails');
 assert.equal(request.headers.Authorization,'Bearer secret');
 assert.deepEqual(JSON.parse(request.body).to,['user@example.com']);
 assert.match(JSON.parse(request.body).text,/123456/);
});
test('provider failures do not leak key or OTP',async()=>{
 const send=createMailer({RESEND_API_KEY:'secret',MAIL_FROM:'otp@example.com'},async()=>({ok:false}));
 await assert.rejects(send('user@example.com','123456','login'),e=>e.status===503&&!e.message.includes('123456')&&!e.message.includes('secret'));
});
test('missing credentials fail closed',async()=>{await assert.rejects(createMailer({})('a@b.com','123456','login'),e=>e.status===503);});
''',encoding='utf8')
