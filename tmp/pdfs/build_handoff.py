from pathlib import Path
import re
from xml.sax.saxutils import escape
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Preformatted
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib import colors
import pypdfium2 as pdfium
from pypdf import PdfReader

root=Path('D:/LTDT/AppTungKinh/apptungkinh')
old=(root/'ban_giao_tien_do.md').read_text(encoding='utf-8')
def section(a,b):
 return old.split(a,1)[1].split(b,1)[0].strip()
history=section('## 2. Lịch sử yêu cầu và trao đổi','## 3.')
changes=section('## 4. Danh sách file Firebase đang thay đổi - đối chiếu Git trực tiếp','## 5.')
changes=changes.split('Đây là toàn bộ danh sách')[0]
changes=changes.replace('Bản thật firebase-config.json chưa được tạo theo ghi nhận hiện tại.', 'Bản thật firebase-config.json đã được tạo và cập nhật sau đó; xem phần 4 và 5.')
changes='\n'.join(line for line in changes.splitlines() if not line.startswith('- **`README.md`'))
content='''# BÀN GIAO ĐỒ ÁN - HÀNH TRÌNH AN NHIÊN

Ngày chốt ngữ cảnh: 21/10/2026. Thư mục dự án: `D:\\LTDT\\AppTungKinh\\apptungkinh`.
Repository public: https://github.com/DatPNguynXzyU/digital-pilgrimage-app

Tài liệu dựa trên lịch sử còn trong hội thoại, ghi nhận phiên trước và kiểm tra mã nguồn trực tiếp. Các kết quả cũ chưa kiểm tra lại được ghi rõ. Không có log đầy đủ để khẳng định mọi yêu cầu trong lịch sử đã hoàn thành. Lượt này chỉ xuất tài liệu, không sửa code, merge hay deploy.

## 1. Công nghệ và kiến trúc

### 1.1 Mobile/Frontend

Ứng dụng Flutter/Dart, tên package Dart `hanh_trinh_an_nhien`, version `1.0.0+1`, yêu cầu Dart `^3.13.3`. CI pin Flutter `3.47.4`. Android applicationId/namespace `com.example.apptungkinh`, Gradle Kotlin DSL, Java/JVM 17. Kotlin phục vụ tích hợp native Android/plugin; phần giao diện và nghiệp vụ client chủ yếu viết Dart.

UI sử dụng Material, Cupertino icons, theme riêng tại lib/config/app_theme.dart, assets images/ và flutter_localizations. Không khai báo Provider, Riverpod, Bloc hay GetX trong pubspec. State dùng cơ chế Flutter trực tiếp: StatefulWidget/setState, notifier/listenable và các service/store trong lib/services. Không nên mô tả dự án là Clean Architecture hay MVVM chuẩn khi chưa có bằng chứng.

Các dependency trực tiếp trong pubspec.yaml (ràng buộc phiên bản; lockfile là nguồn phiên bản giải quyết chính xác):

- cupertino_icons ^1.0.8: icon kiểu iOS.
- mobile_scanner ^7.4.2: quét mã QR/barcode.
- http ^1.6.0: gọi HTTP API; http_parser ^4.1.2 hỗ trợ kiểu nội dung multipart.
- shared_preferences ^2.5.6: lưu trạng thái/cấu hình và token ứng dụng cục bộ.
- nfc_manager ^4.2.1, nfc_manager_ndef ^1.1.0: phiên quét NFC và dữ liệu NDEF.
- image_picker ^1.2.4: chọn/chụp ảnh đại diện.
- url_launcher ^6.3.3: mở liên kết bằng nền tảng.
- local_auth ^3.0.2: xác thực sinh trắc học cho khóa app.
- firebase_core ^5.0.0, firebase_auth ^7.0.0: khởi tạo Firebase, tài khoản và token.
- google_sign_in ^7.2.0: chọn tài khoản Google trên Android.
- flutter_test SDK, flutter_lints ^6.0.0: kiểm thử và phân tích Dart; flutter_launcher_icons ^0.13.1: sinh icon app.

Cấu trúc lib: config (API/theme), models (đối tượng dữ liệu), services (API/session/NFC/calendar/biometric), views (trang chủ, chùa, kinh sách, lịch, tài khoản, QR/NFC), widgets (các thành phần dùng lại), utils (lịch âm). main.dart và main_nav.dart ghép màn hình/điều hướng.

ApiConfig đọc API_BASE_URL qua String.fromEnvironment, loại dấu / cuối. Nếu thiếu, Web dùng localhost:3000/api và nền tảng còn lại dùng 10.0.2.2:3000/api. Điện thoại dùng mạng ngoài phải build với HTTPS Render. Các dart-define là cấu hình lúc build, đổi trên Render không tự cập nhật APK đã cài.

### 1.2 Backend và dữ liệu

Backend Node.js 22 trong Docker Alpine; JavaScript CommonJS; Express ^5.2.1. Kiến trúc phân lớp thực dụng: request -> routes -> middleware -> controller -> Mongoose model -> MongoDB. Config chứa database, avatar storage và Firebase Admin. app.js ghép Express; server.js khởi động/kết nối. seed/ chứa dữ liệu mẫu và script seed, bind-nfc.

Các package trực tiếp: bcryptjs ^3.0.3 (hash mật khẩu legacy), cors ^2.8.6 (CORS), dotenv ^18.0.3 (env local), express ^5.2.1, firebase-admin ^14.5.0, jsonwebtoken ^9.0.3 (JWT legacy), mongoose ^9.10.2 (ODM MongoDB), multer ^2.4.0 (upload multipart). Dev: nodemon ^3.1.14. npm start chạy src/server.js; npm run dev dùng nodemon.

MongoDB là CSDL nghiệp vụ; Mongoose là ODM, không dùng SQL ORM. Kết nối bằng MONGODB_URI và dbName=MONGODB_DATABASE. Database production được ghi nhận là hanh_huong_db, 21 chùa ở mốc trước. Test dùng mongo:7 replica set rs0 và tmpfs, tách DB thật. Không chuyển hồ sơ/nghiệp vụ sang Firestore.

Các model hiện có: user, temple, temple-stamp, scripture, quote, pilgrimage-visit, nfc-tag, calendar-event, buddhist-figure. Routes/controllers tương ứng các nhóm auth/profile, chùa, kinh sách, Phật ngôn, nhân vật Phật giáo, hành hương, NFC, lịch. Cần đọc model cụ thể trước khi đổi schema; danh mục này không thay cho schema đầy đủ.

Avatar hỗ trợ local/cloudinary. Cloudinary được gọi bằng fetch/FormData/Blob tích hợp Node và node:crypto tạo SHA-256 signature; không có dependency cloudinary SDK trong package.json. public_id cố định theo user để ghi đè ảnh; timeout 12 giây; kiểm tra secure_url HTTPS.

### 1.3 Xác thực và bảo mật

Luồng email mới: Flutter tạo Firebase user -> cập nhật tên -> gửi email verification -> sign out -> người dùng bấm link -> đăng nhập -> reload user và kiểm tra emailVerified -> lấy ID token -> POST /api/auth/firebase -> backend xác minh và tạo/tìm profile MongoDB.

Luồng Google: Google Sign-In Android trả Google ID token -> Firebase credential -> Firebase ID token -> cùng endpoint exchange. Google đã xác minh email thì không gửi thêm email xác minh riêng. API yêu cầu email_verified=true và provider password/google.com.

Token backend trả dạng firebase:<Firebase ID token>. Middleware nhận Bearer, phân biệt marker này với JWT legacy; Firebase Admin verifyIdToken(token,true) kiểm tra chữ ký, project/hạn và revocation/disable. Tìm profile theo firebaseUid, chặn blocked, đặt req.user/firebaseClaims. Frontend làm mới token bằng Firebase SDK; không dùng client email hoặc role làm bằng chứng quyền.

Tài khoản cũ vẫn có bcrypt/JWT. Khi bật FIREBASE_PROJECT_ID, đăng ký legacy bị chặn; login cũ vẫn hoạt động. Firebase email trùng user cũ trả 409, không tự gộp dữ liệu. Firebase password change cần reauth và auth_time trong 5 phút, Admin updateUser rồi revokeRefreshTokens. Google-only dùng quản lý mật khẩu Google.

Biometric là khóa UI thiết bị bằng local_auth, không thay token backend. Token hiện lưu SharedPreferences, không phải hardware-backed secure vault. Logout/đổi mật khẩu/xóa phiên tắt biometric. Android dùng FlutterFragmentActivity, USE_BIOMETRIC và AppCompat; iOS có FaceID description theo ghi nhận trước.

### 1.4 Test và DevOps

Backend dùng Node test runner: node --test --test-concurrency=1 test/*.test.js; test tích hợp chạy Docker Compose với MongoDB replica set riêng. Kiểm thử Firebase mock verifier/Admin để kiểm tra logic, chưa chứng minh OAuth/email thật. Flutter dùng flutter analyze và flutter test, CI xuất coverage.

Dockerfile: FROM node:22-alpine, WORKDIR /app, NODE_ENV=production, npm ci --omit=dev, copy dưới quyền node, tạo thư mục avatar, USER node, EXPOSE 3000, node src/server.js. .dockerignore loại node_modules, .env/.env.*, service-account/adminsdk JSON, Git/editor/log/cache, ảnh upload và compose.yaml. Ngoại lệ !.env.example có trong ignore nhưng file backend/.env.example hiện không tồn tại.

CI .github/workflows/ci.yml chạy PR vào main, push main và manual. Quyền contents:read, hủy run cùng nhóm cũ. Bốn job: local CD safety tests trên Windows; Flutter analyze/test/coverage trên Ubuntu; backend Docker tests và thu log/cleanup; Android debug APK cần Flutter+backend đạt. APK giữ 7 ngày, coverage 14 ngày; Java17; flutter pub get --enforce-lockfile. CI Android đọc API_BASE_URL và 5 biến Firebase từ repository variables.

CD .github/workflows/cd.yml chạy sau CI completed trên main, chỉ khi success, event push và cùng repository. Checkout đúng head_sha đã test, build/push ghcr.io/<repository-lowercase>/backend:sha-<commit> bằng GITHUB_TOKEN, quyền packages:write. Đây là publish image; không có bước đẩy APK tới điện thoại.

Render deploy riêng qua render.yaml: web Docker Free, branch main, Dockerfile/backend context, autoDeployTrigger checksPass, health /api/health. API: https://digital-pilgrimage-api.onrender.com/api. Render Free có cold start. Cloudflare tunnel từng phục vụ thử từ máy cá nhân; hosting Render thay nhu cầu giữ máy cá nhân mở cho API công khai.

## 2. Lịch sử yêu cầu và xử lý

'''+history+'''

17. Sau mốc tài liệu bàn giao cũ, người dùng hỏi lệnh build và báo thiếu firebase-config.json. AI tạo file ignored, sau đó đọc D:/google-services.json người dùng gửi và điền đủ client values. File đầu thiếu Android OAuth client.
18. Người dùng yêu cầu hoàn thiện; đã xác nhận thêm SHA-1 và SHA-256. Cả hai được lưu thành công trong Firebase. Tải file qua automation bị timeout; người dùng tải lại và file D:/google-services.json mới được xác minh có 1 Android OAuth client.
19. Đã cập nhật firebase-config.json bằng UTF-8 không BOM; build debug APK với Firebase config thành công. Đây là APK mới có Firebase, khác APK release cũ chỉ có URL Render.
20. Người dùng chưa có Admin key, được hướng dẫn Firebase Service accounts -> Generate new private key, đặt Render Secret Files và 2 env. Người dùng báo đã điền trên Render; chưa có kiểm chứng Save/deploy thành công.
21. Đã tạo nhánh codex/firebase-auth, stage riêng 23 file, commit 7729570 và push origin thành công. README và tài liệu bàn giao không nằm trong commit. Chưa tạo PR thực tế, chỉ đưa link compare; chưa có bằng chứng CI/merge/production deploy cho commit này.
22. Người dùng hỏi đã xong chưa; trả lời chưa, còn PR/CI/merge, Render deploy và test hai luồng trên điện thoại. Yêu cầu hiện tại là tài liệu bàn giao đầy đủ 5 phần, không tiếp tục sửa code.

## 3. Thay đổi mã nguồn

Danh mục dưới đây là 23 file trong commit 7729570 đã push, không còn là thay đổi uncommitted. Các mô tả mới/sửa chỉ quan hệ với commit trước 48e167e.

'''+changes+'''

### 3.1 File bổ sung ngoài commit

- firebase-config.json: file local ignored đã điền đầy đủ từ file config mới; chứa API_BASE_URL và 5 client values, không chứa Admin key.
- D:/google-services.json: file do người dùng cung cấp bên ngoài repo; bản mới có Android OAuth. Không sửa file nguồn này.
- build/app/outputs/flutter-apk/app-debug.apk: APK debug build thành công với Firebase config mới; artifact không phải source commit.
- ban_giao_tien_do.md/pdf: tài liệu mốc cũ, thông tin thiếu SHA/uncommitted trong đó đã lỗi thời; ưu tiên bản bàn giao này.
- README.md: vẫn modified, không được gộp vào commit Firebase. git diff --check thấy trailing whitespace ở các dòng 348,352,356,359,364; chưa sửa vì không thuộc tác vụ.
- tmp/: file tạm xuất/render tài liệu; không tự commit.

### 3.2 Các file giai đoạn trước cần biết

render.yaml và docs/RENDER_DEPLOY.md mô tả hosting; .github/workflows/cd.yml publish image; scripts/deploy-local.ps1, install-local-cd.ps1, test-local-cd.ps1 phục vụ CD local; docs/BIOMETRIC_LOCK.md và widgets/services biometric mô tả khóa app; docs/dependency-inventory.csv là inventory cũ cần đối chiếu pubspec/package hiện tại. Không có đầy đủ diff toàn lịch sử để quy mọi file này cho AI hoặc khẳng định từng sửa đổi chi tiết. Có commit hosting 6c1e920 và mốc 48e167e biometric trước Firebase.

## 4. Tiến độ và điểm dừng chính xác

Nhánh local: codex/firebase-auth; HEAD 7729570, upstream origin/codex/firebase-auth đã push. Working tree còn README modified và ban_giao_tien_do.md/pdf, tmp/ untracked ở lần kiểm tra; tài liệu mới sẽ thêm 2 file. Không fetch/merge/deploy trong lượt xuất.

Firebase project Hanh Trinh An Nhien, ID hanh-trinh-an-nhien, project number 1017604128767, Android app ID 1:1017604128767:android:a94d724d34eda07234f1ca. Package com.example.apptungkinh. Email/Password và Google đều Enabled. Public-facing name đã đặt; support email đã chọn tài khoản chủ project. Analytics tắt. Không còn chờ điền tên/email Google hoặc thêm fingerprint.

Fingerprints đã lưu cho khóa debug local:

```text
SHA-1: 20:D6:0E:83:5D:06:04:DD:2B:A7:BA:9F:80:1F:9F:1E:16:4F:08:38
SHA-256: 37:B4:C3:C4:94:DF:21:81:6A:FD:6E:8D:D9:C3:ED:65:02:CE:8D:41:DA:CA:E2:7F:13:0E:77:43:DD:93:56:A1
```

Cách lấy lại cấu hình: Firebase Project settings -> General -> Your apps -> Android -> Download google-services.json. Mapping project_info.project_id, project_number; client đúng package: client_info.mobilesdk_app_id, api_key.current_key; oauth_client client_type=3 là Web OAuth client ID. Không dùng Android client ID làm GOOGLE_WEB_CLIENT_ID. App khởi tạo FirebaseOptions tường minh nên không thêm Google Services Gradle plugin ở phiên này.

Render service srv-dbbgpp5g1s2s738ugk7g, workspace TechVortex, blueprint digital-pilgrimage (exs-dbbgmt3bc2fs73b5b5t0). Người dùng nói đã điền Admin Secret File và env; AI chưa kiểm chứng file tồn tại/JSON đúng/đã lưu/đã deploy. Không đưa private key vào tài liệu, APK hoặc Git.

Điểm dừng: cần tạo PR từ codex/firebase-auth vào main, chờ CI đạt, merge rồi triển khai đúng commit trên Render cùng Admin secret. Link: https://github.com/DatPNguynXzyU/digital-pilgrimage-app/compare/main...codex/firebase-auth . Không nói PR đã tồn tại hay CI đã xanh. Sau deploy kiểm tra health và test điện thoại thật.

Kết quả test đã ghi nhận: Flutter analyze đạt; 39 tests cũ + 1 Google UI test riêng đạt; backend 12 test Docker đạt; firebase-claims test chạy lại trước commit đạt. Debug APK với config thật build thành công sau 90,2 giây; chưa xác nhận login thực tế. Các test này không được chạy lại trong lượt xuất. Docker test đã cleanup, không tác động DB thật.

Các hạn chế còn lại: CI debug signing khác máy local, chưa thiết lập signing key cố định; release hiện cũng ký debug. Firebase Google chỉ triển khai Android; iOS/Web cần cấu hình riêng. Chưa kiểm thử email thật, chọn/hủy Google, đổi mật khẩu/revoke thật, NFC/tem/lịch sử với user Firebase, upload Cloudinary thật. Token vẫn SharedPreferences. npm audit từng báo dev dependency high, production omit-dev báo 0 ở mốc cũ, không phải kết quả audit mới.

Trình tự tiếp tục: kiểm tra git và PR/CI live; bảo toàn README; xác minh Render Secret File và env; deploy đúng commit; cài APK mới và test đăng ký chưa xác minh bị chặn, xác minh xong đăng nhập được, resend, Google, collision legacy, blocked/revoked, lịch riêng/NFC/tem/history. Không kích hoạt lại script CD cũ gây PowerShell popup; Start-Process phải hidden khi chạy nền.

## 5. Biến môi trường và GitHub Secrets

### 5.1 Backend runtime / Render

- NODE_ENV: production trong Docker/Render.
- PORT: cổng server (Render cấp); Docker expose 3000.
- MONGODB_URI: chuỗi kết nối MongoDB, bí mật; đã có từ deployment cũ, không in giá trị.
- MONGODB_DATABASE: hanh_huong_db theo cấu hình đã sửa ở phiên trước.
- JWT_SECRET: bí mật ký JWT tài khoản legacy; Render blueprint generateValue=true, giữ ổn định khi deploy.
- JWT_EXPIRES_IN: thời hạn JWT legacy, blueprint 7d.
- AVATAR_STORAGE: local hoặc cloudinary; Render cloudinary.
- CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET: cấu hình upload; secret không vào repo.
- FIREBASE_PROJECT_ID: hanh-trinh-an-nhien; bật Firebase backend/khóa đăng ký legacy.
- FIREBASE_SERVICE_ACCOUNT_FILE: /etc/secrets/firebase-service-account.json; file JSON Admin phải có project_id khớp. Thiếu/sai file thì startup fail.
- TEST_MONGODB_URI: chỉ kiểm thử; compose.test.yaml đặt mongodb://mongo:27017/?replicaSet=rs0. Không dùng URI production.

Secret File Render: firebase-service-account.json. Người dùng đã báo điền, chưa xác minh đã lưu. Nội dung file có private_key/service account, tuyệt đối không nhúng vào mobile config. render.yaml hiện chưa khai báo hai biến Firebase; chúng được hướng dẫn thêm thủ công trong Render Environment.

### 5.2 Mobile compile-time và GitHub repository Variables

```text
API_BASE_URL=https://digital-pilgrimage-api.onrender.com/api
FIREBASE_PROJECT_ID=hanh-trinh-an-nhien
FIREBASE_API_KEY=<đọc từ firebase-config.json>
FIREBASE_APP_ID=1:1017604128767:android:a94d724d34eda07234f1ca
FIREBASE_MESSAGING_SENDER_ID=1017604128767
GOOGLE_WEB_CLIENT_ID=<Web OAuth client_type 3 trong config>
```

Cả 6 giá trị đã có trong firebase-config.json local. Không công bố lại API key/client ID trong tài liệu vì AI sau có thể đọc file local khi cần. Đây là client config, không phải Firebase Admin private key. CI dùng vars.<TÊN> (repository Variables), không dùng secrets cho 5 giá trị client. API_BASE_URL từng được đặt trên GitHub; chưa có bằng chứng 5 variables Firebase đã được điền trên GitHub. Vì vậy APK CI không mặc nhiên tương đương APK local mới.

```powershell
cd D:\\LTDT\\AppTungKinh\\apptungkinh
flutter build apk --debug --dart-define-from-file=firebase-config.json
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

Có thể truyền từng --dart-define=TEN=GIA_TRI như workflow CI. Chỉ truyền API_BASE_URL sẽ thiếu Firebase. Không commit firebase-config.json (đã ignore), không dùng service account thay google-services.json.

### 5.3 GitHub Actions và CD

- FLUTTER_VERSION=3.47.4: env cố định workflow CI.
- GITHUB_TOKEN: secret tự cấp của Actions, dùng quyền packages:write để push GHCR.
- GH_TOKEN: alias env của secrets.GITHUB_TOKEN trong CD; GH_USER=github.actor; REPOSITORY=github.repository; COMMIT_SHA=workflow_run.head_sha. Đây là env workflow, không yêu cầu tự tạo 4 secrets tương ứng.
- Chưa có release signing secrets được cấu hình trong workflow hiện tại. Không bịa tên KEYSTORE_PASSWORD/KEY_ALIAS là biến đã sử dụng; chỉ thêm nếu thiết kế signing sau này.
- Không có Render deploy hook secret trong cd.yml hiện tại; Render dùng checksPass riêng. Không có Firebase Admin key trong GitHub Actions.

### 5.4 Hướng dẫn AI tiếp nhận

Đọc tài liệu này, git status và docs/FIREBASE_AUTH.md trước thao tác. Ưu tiên xác nhận PR/CI/Render live, không lặp lại cấu hình Google đã xong. Không kết luận hoàn thành cho tới khi hai luồng chạy trên điện thoại với backend mới. Người dùng muốn chủ động làm tiếp, không hỏi lại quyền đã cấp; chỉ dừng ở bước thật sự cần thông tin/credential hoặc phê duyệt. Trong lượt bàn giao này người dùng chỉ cho phép tổng hợp tài liệu.
'''
(root/'ban_giao_do_an.md').write_text(content,encoding='utf-8')
pdfmetrics.registerFont(TTFont('Arial', 'C:/Windows/Fonts/arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialBold', 'C:/Windows/Fonts/arialbd.ttf'))
pdfmetrics.registerFont(TTFont('Mono', 'C:/Windows/Fonts/consola.ttf'))
styles={k:ParagraphStyle(k,fontName='ArialBold' if k!='body' else 'Arial',fontSize=s,leading=s*1.45,spaceAfter=8,keepWithNext=k!='body',wordWrap='CJK') for k,s in [('title',20),('h2',15),('h3',12),('body',10)]}
code_style=ParagraphStyle('code',fontName='Mono',fontSize=8,leading=11,backColor=colors.HexColor('#eef2f5'),spaceAfter=10)
story=[]; code=False; buf=[]
for line in content.splitlines():
 if line.startswith('```'):
  if code:
   import textwrap
   wrapped='\n'.join('\n'.join(textwrap.wrap(t,96,replace_whitespace=False,drop_whitespace=False)) if len(t)>96 else t for t in buf)
   story.append(Preformatted(wrapped,code_style));buf=[]
  code=not code;continue
 if code:buf.append(line);continue
 if not line.strip():story.append(Spacer(1,4));continue
 kind='title' if line.startswith('# ') else 'h2' if line.startswith('## ') else 'h3' if line.startswith('### ') else 'body'
 story.append(Paragraph(escape(line.lstrip('# ').replace('**','').replace('`','')),styles[kind]))
def footer(c,d):
 c.setFont('Arial',8);c.setFillColor(colors.HexColor('#667788'));c.drawString(42,25,'Hành Trình An Nhiên | Bàn giao 21/10/2026');c.drawRightString(553,25,str(d.page))
SimpleDocTemplate(str(root/'ban_giao_do_an.pdf'),pagesize=(595,842),rightMargin=42,leftMargin=42,topMargin=42,bottomMargin=45,title='Bàn giao đồ án Hành Trình An Nhiên').build(story,onFirstPage=footer,onLaterPages=footer)
doc=pdfium.PdfDocument(str(root/'ban_giao_do_an.pdf'))
from PIL import Image,ImageDraw
thumbs=[]
for i in range(len(doc)):
 im=doc[i].render(scale=.6).to_pil().convert('RGB');thumbs.append(im)
sheet=Image.new('RGB',(thumbs[0].width*3, (len(thumbs)+2)//3*(thumbs[0].height+20)), 'gray')
for i,im in enumerate(thumbs):sheet.paste(im,((i%3)*im.width,(i//3)*(im.height+20)))
sheet.save(root/'tmp/pdfs/do_an_contact.png')
reader=PdfReader(root/'ban_giao_do_an.pdf'); text='\n'.join(p.extract_text() for p in reader.pages)
assert 'FIREBASE_SERVICE_ACCOUNT_FILE' in text and 'BÀN GIAO' in text
print('PDF pages:',len(doc),'Markdown characters:',len(content))
