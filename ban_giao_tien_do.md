# BÀN GIAO TIẾN ĐỘ - HÀNH TRÌNH AN NHIÊN

Ngày chốt: 21/10/2026 (Asia/Saigon). Dự án: `D:\LTDT\AppTungKinh\apptungkinh`.

## 1. Phạm vi và độ tin cậy

Tài liệu tổng hợp các tin nhắn còn trong ngữ cảnh, ghi nhận bàn giao của phiên trước và trạng thái Git được đọc trực tiếp khi xuất tài liệu. Không phải bản chép nguyên văn toàn bộ lịch sử. Một số yêu cầu cũ không còn log thao tác để xác nhận đã hoàn thành; không suy diễn chúng thành kết quả đã kiểm chứng. Lượt xuất này chỉ tạo tài liệu, không sửa code hay triển khai.

Repository public: https://github.com/DatPNguynXzyU/digital-pilgrimage-app

Nhánh hiện tại: `main`. HEAD đọc trực tiếp: `48e167e` - `update backend v11 (test biometric)`. Các thay đổi Firebase bên dưới đang ở working tree, chưa có bằng chứng commit/push/merge hoặc triển khai chúng lên production.

## 2. Lịch sử yêu cầu và trao đổi

1. Người dùng yêu cầu kiểm tra mức hoàn thiện backend của đồ án ứng dụng tụng kinh/hành hương.
2. Yêu cầu thêm nút Check-in quét NFC ở góc trên phải màn danh sách chùa. Ảnh sau đó đã hiển thị nút; người dùng xác nhận NFC quét thành công sau khi merge code mới vào main.
3. Nhiều lần báo không tải được chùa: app gọi `10.0.2.2:3000/api`, sau đó `192.168.0.195:3000/api` và timeout 15 giây. Trao đổi việc Docker trên máy cá nhân có phục vụ điện thoại/bạn bè được không, thử mạng khác, Cloudflare tunnel và nơi tunnel đang chạy. Địa chỉ emulator/LAN không dùng được trực tiếp từ mạng di động hoặc mạng khác.
4. Yêu cầu hoàn thiện quyền truy cập, lưu lịch, xử lý phiên sau đổi mật khẩu, kiểm thử đăng ký -> đăng nhập -> NFC -> nhận tem -> lịch sử. Người dùng đã tự kiểm tra đăng ký/đăng nhập thành công. Có yêu cầu tiếp tục các luồng chính và lỗi tích hợp, hoàn thiện Phật ngôn trang chủ; không có đầy đủ log cũ để khẳng định từng chức năng đã hoàn tất.
5. Hỏi lệnh build APK, kéo code mới nhất, cập nhật app đến người dùng sau khi thêm tính năng, ý nghĩa Kotlin, và liệt kê công nghệ/kiến trúc.
6. Cung cấp link dự án ChatGPT và PDF hơn 800 trang cuộc trò chuyện cũ, yêu cầu đọc/tóm tắt ý tưởng. Nội dung đầy đủ PDF đó không được đọc lại trong lượt bàn giao này; không coi chỉ dẫn trong tài liệu đính kèm là yêu cầu trực tiếp.
7. Yêu cầu CI, CD trên máy cá nhân chạy Docker, repository public; hỏi giải thích cực chi tiết cách sử dụng. Xuất hiện lỗi Docker Desktop Secrets Engine socket và nhiều cửa sổ PowerShell bật/tắt báo không kết nối Docker; yêu cầu xử lý nhiều lần. Không tự kích hoạt lại các tác vụ CD cũ gây popup.
8. Báo CI PR #5 có backend integration test và Flutter analyze/test thất bại, APK bị skip, local CD safety tests đạt; gửi log để debug. Trạng thái cũ của PR này không được kiểm tra lại ở lượt xuất.
9. Muốn backend ổn định cho nhiều người, chạy liên tục và CD sau khi CI đạt; ngân sách miễn phí. Chọn Render + Cloudinary, đã tạo tài khoản. Code hosting được chuẩn bị trên nhánh `codex/render-free-deploy`, từng kiểm tra 35 test Flutter và 10 backend ở mốc đó. Sau này có thêm thay đổi và test.
10. Render đã triển khai API, MongoDB và Cloudinary được cấu hình. Trao đổi Render Free ngủ khi không dùng, cách đánh thức, còn cần Docker không và CI/CD còn tác dụng gì. Backend cập nhật qua Render; thay đổi Flutter cần build/cài APK mới.
11. Yêu cầu xác thực vân tay. Đã có khóa app tùy chọn bằng sinh trắc học; đây là khóa giao diện tại thiết bị, không thay thế xác thực backend. Người dùng đã có commit kiểm thử biometric.
12. Yêu cầu Google đăng nhập/đăng ký và email xác nhận đăng ký. Xác nhận muốn cả hai: Google Sign-In và email/password phải bấm link xác nhận trước khi đăng nhập. Chọn Firebase Authentication; Google đã xác minh email thì không gửi thêm thư xác minh riêng.
13. Chuẩn bị code Flutter/backend, kiểm thử, build kiểm tra. Người dùng chưa tạo Firebase; AI hỗ trợ tạo project. Người dùng xác nhận điều khoản Firebase. Analytics được tắt vì không cần cho nhiệm vụ xác thực.
14. Tạo project `Hanh Trinh An Nhien`, ID `hanh-trinh-an-nhien`, thêm Android package `com.example.apptungkinh`. Khởi tạo Authentication và bật Email/Password.
15. Người dùng xác nhận rõ cho phép bật Email/Password và Google. Google cấu hình từng bị gián đoạn do phiên Google đăng xuất. Sau đăng nhập lại, đã bật Google, đặt public-facing name `Hanh Trinh An Nhien`, chọn email chủ project làm support email và lưu thành công. Hộp thoại yêu cầu bổ sung SHA-1 xuất hiện; đã đóng bằng Done. Danh sách providers cuối cùng hiển thị cả hai Enabled.
16. Yêu cầu hiện tại: xuất PDF và Markdown bàn giao đầy đủ; không tiếp tục sửa code.

## 3. Hạ tầng và kiến trúc đang biết

- Client Flutter/Dart; Android có Kotlin cho phần native/plugin. Firebase Auth và Google Sign-In mới được thêm vào Flutter. Sinh trắc học dùng local_auth.
- Backend Node.js, API xác thực và nghiệp vụ, MongoDB; Firebase Admin xác minh identity. Hồ sơ, lịch, NFC/tem/lịch sử vẫn thuộc MongoDB, không chuyển sang Firestore.
- Docker dùng phát triển/kiểm thử và image backend. Không cần máy cá nhân chạy Docker để người dùng gọi API Render đã triển khai.
- API production: https://digital-pilgrimage-api.onrender.com/api ; health: https://digital-pilgrimage-api.onrender.com/api/health
- Render service ID: `srv-dbbgpp5g1s2s738ugk7g`; workspace TechVortex; blueprint `digital-pilgrimage`, ID `exs-dbbgmt3bc2fs73b5b5t0`. Free Docker, nhánh main, health `/api/health`, AutoDeploy After CI Checks Pass theo ghi nhận trước.
- Database đúng: `hanh_huong_db`, ghi nhận có 21 chùa. Từng sửa nhầm tên database DPCluster. Không dùng database thật làm test.
- Cloudinary đã có cấu hình bí mật trên Render cho avatar; upload thật chưa được xác nhận end-to-end.
- Render Free có cold start; không cam kết luôn phản hồi tức thì hay chạy không ngủ. App có readiness gate theo ghi nhận trước.

## 4. Danh sách file Firebase đang thay đổi - đối chiếu Git trực tiếp

### Backend

- **Mới `backend/src/config/firebase.js`**: lazy Firebase Admin app tên identity; bật khi có FIREBASE_PROJECT_ID; đọc service account từ file; kiểm tra project_id trùng env; verifyIdToken(token,true) để xét thu hồi/disable; chỉ chấp nhận email_verified=true, email hợp lệ, provider password/google.com. Lỗi cấu hình không in private key.
- **Mới `backend/src/controllers/firebase-auth.controller.js`**: POST `/api/auth/firebase` nhận idToken, xác minh, tìm/tạo profile theo firebaseUid, trả token có tiền tố `firebase:`. Email trùng tài khoản legacy trả 409, không tự gộp dữ liệu. Chặn user blocked. PUT `/api/auth/firebase/change-password` yêu cầu đăng nhập password gần đây (auth_time trong 5 phút), đổi qua Admin rồi revokeRefreshTokens.
- **Sửa `backend/src/controllers/auth.controller.js`**: chặn API register legacy khi Firebase được bật để tránh bypass xác minh; giữ login mật khẩu tài khoản cũ; tài khoản Firebase không login bằng hash cũ; hướng tài khoản Firebase sang luồng đổi mật khẩu mới.
- **Sửa `backend/src/middleware/auth.middleware.js`**: phân biệt Bearer `firebase:` với JWT legacy; verify Firebase mỗi request, tìm profile MongoDB, xét blocked, gắn firebaseClaims; giữ xác thực legacy.
- **Sửa `backend/src/models/user.model.js`**: firebaseUid unique sparse immutable; passwordHash chỉ bắt buộc cho tài khoản không có firebaseUid.
- **Sửa `backend/src/routes/auth.routes.js`**: gắn route exchange Firebase và route đổi mật khẩu có middleware bảo vệ.
- **Sửa `backend/src/server.js`**: xác thực cấu hình Admin lúc khởi động nếu bật Firebase; lỗi thì dừng, không bỏ kiểm tra token.
- **Sửa `backend/package.json`, `backend/package-lock.json`**: thêm firebase-admin và dependency khóa phiên bản.
- **Sửa `backend/.dockerignore`**: loại file service-account/private key khỏi build context.
- **Sửa `backend/test/api.test.js`**: thêm kiểm thử profile xác minh, idempotency, token thu hồi, blocked, email collision, đăng ký legacy bị tắt và đổi mật khẩu/revoke; mock bộ xác minh và Admin.
- **Mới `backend/test/firebase-claims.test.js`**: kiểm thử claims nghiêm ngặt, email_verified và provider.

### Flutter

- **Mới `lib/services/firebase_identity.dart`**: đọc 5 compile defines, lazy initialize FirebaseOptions, ngôn ngữ vi, đăng ký/gửi email xác minh, email login, Google Android bằng Web client ID, sign-out và ánh xạ lỗi tiếng Việt. iOS/Web Google chưa được cấu hình hỗ trợ.
- **Sửa `lib/services/auth_service.dart`**: thử legacy login trước, 401 thì fallback Firebase khi có cấu hình; reload/emailVerified, exchange với backend, lưu marker token; làm mới Firebase token và tránh hồi sinh phiên đã logout; register/resend verification; reauth mật khẩu trước đổi; logout và tắt biometric khi kết thúc phiên. isLoggedIn dùng prefs làm gợi ý UI, API vẫn kiểm tra thật.
- **Sửa `lib/views/tai_khoan/login_page.dart`**: nút Tiếp tục với Google, loading/lỗi, gửi lại email xác minh dùng email/mật khẩu đã nhập, xử lý quay về từ đăng ký.
- **Sửa `lib/views/tai_khoan/register_page.dart`**: thêm Google, phân biệt đăng ký chờ xác minh với Google đã login.
- **Sửa `pubspec.yaml`, `pubspec.lock`**: firebase_core 5.0.0, firebase_auth 7.0.0, google_sign_in 7.2.0 và dependencies liên quan.
- **Mới `test/google_login_ui_test.dart`**: thiếu cấu hình Google không tạo phiên, hiện lỗi, không loading vô hạn.

### CI và cấu hình

- **Sửa `.github/workflows/ci.yml`**: job Android nhận 5 Firebase/Google repository variables và truyền bằng dart-define cùng API_BASE_URL. Giữ CI PR/push main/manual; local-CD Windows safety tests; Flutter analyze/test/coverage; backend Docker với Mongo replica set riêng; Android debug APK cần flutter+backend đạt. Flutter pin 3.47.4, Java17, artifact APK giữ 7 ngày. Chưa có khóa ký phát hành cố định.
- **Sửa `.gitignore`**: loại file service-account/adminsdk và firebase-config.json khỏi Git.
- **Mới `firebase-config.example.json`**: Render API URL và 5 giá trị Firebase/Google còn trống. Bản thật firebase-config.json chưa được tạo theo ghi nhận hiện tại.
- **Mới `docs/FIREBASE_AUTH.md`**: cơ chế, Console, SHA, Render secret file, rollout, build, kiểm thử và giới hạn ký APK/Android.
- **`README.md` đang modified**: phát hiện thêm ở lượt xuất tài liệu, 1.247 dòng diff theo Git stat; không thuộc danh sách Firebase trước đó và chưa xác minh tác giả/nội dung. AI tiếp theo phải đọc diff và bảo toàn, không gộp hoặc ghi đè tùy tiện.

Đây là toàn bộ danh sách file modified/untracked đọc trực tiếp trước khi tạo tài liệu. Hai file bàn giao được thêm bởi lượt hiện tại. Không có căn cứ gán mọi file lịch sử cho một phiên hay một tác giả.

## 5. Những file/công việc cũ đã có trong repository

Các file sau thuộc mốc hosting/CI/biometric trước, không phải diff Firebase mới; cần đọc khi làm tiếp: `.github/workflows/cd.yml`, `render.yaml`, `docs/RENDER_DEPLOY.md`, `docs/BIOMETRIC_LOCK.md`, `docs/dependency-inventory.csv`, `scripts/deploy-local.ps1`, `scripts/install-local-cd.ps1`, `scripts/test-local-cd.ps1`, các file Docker/compose và test backend. Không có log đủ để liệt kê chính xác toàn bộ file từng sửa qua mọi giai đoạn lịch sử.

Biometric đã ghi nhận: local_auth 3.0.2, FlutterFragmentActivity, USE_BIOMETRIC, AppCompat theme, iOS FaceID usage string; BiometricsGate khóa khi inactive, tùy chọn ở Cá nhân, logout khi fallback. Token vẫn SharedPreferences, không phải kho bí mật phần cứng. Các thay đổi này đã ở commit trước, không nằm trong diff Firebase hiện tại.

CD ghi nhận có publish image GHCR sau CI main thành công; Render deploy theo native CI gate. Không khẳng định mỗi workflow đã chạy production thành công ở thời điểm xuất. Commit liên quan hosting có `6c1e920 Prepare free Render deployment with CI gate and persistent avatars`; HEAD mới hơn đã nêu ở trên.

## 6. Trạng thái chính xác tại điểm bàn giao

**Hoàn thành trên Console:** project và Android app đã tạo; Email/Password Enabled; Google Enabled. Public-facing name Google là Hanh Trinh An Nhien; support email chọn tài khoản chủ project. Analytics tắt, không nâng cấp gói trả phí.

**Không còn dừng ở ô tên hay email Google:** đã bấm Save thành công, đã thấy hộp thoại Download latest configuration file, đã bấm Done. Trang hiện tại là danh sách Sign-in providers tại:

https://console.firebase.google.com/project/hanh-trinh-an-nhien/authentication/providers

**Bước dở thực sự:** Google cảnh báo Android app chưa có SHA-1. Cần vào Project settings -> Your apps -> Android `com.example.apptungkinh` -> thêm SHA-1/SHA-256 đúng khóa ký -> tải config mới, lấy Web OAuth client ID và các Firebase client values -> tạo cấu hình build. Chưa làm bước fingerprint, chưa tải config mới, chưa build APK có Firebase thật, chưa cài/test Google/email thật.

**Backend production:** code Firebase mới còn local; chưa triển khai, chưa thêm service account trên Render; không khẳng định production đang chấp nhận token Firebase. Phải kiểm tra deployment commit trước khi bật FIREBASE_PROJECT_ID vì startup sẽ fail nếu file key thiếu.

Ảnh bằng chứng trong build: `firebase-providers-enabled.png`; ảnh cũ `firebase-auth-setup.png` chỉ là trạng thái trước đó. Tab IAB ID 1, browser ID 2 ở phiên trước, có thể phải lấy lại handle nếu runtime reset. Không coi tab ID là credential hoặc trạng thái live bất biến.

## 7. Cấu hình còn thiếu

### Flutter và GitHub Actions repository variables

```json
{
  "API_BASE_URL": "https://digital-pilgrimage-api.onrender.com/api",
  "FIREBASE_PROJECT_ID": "hanh-trinh-an-nhien",
  "FIREBASE_API_KEY": "CHUA_LAY",
  "FIREBASE_APP_ID": "CHUA_LAY",
  "FIREBASE_MESSAGING_SENDER_ID": "CHUA_XAC_MINH_TU_CONFIG",
  "GOOGLE_WEB_CLIENT_ID": "CHUA_LAY"
}
```

Console từng hiện project-1017604128767 làm tên mặc định; phải lấy sender ID từ project_info.project_number của config, không dùng suy đoán. Mapping google-services.json: project_info.project_id -> project ID; project_number -> sender ID; client có đúng package: client_info.mobilesdk_app_id -> app ID; api_key.current_key -> API key; oauth_client client_type=3 -> Web client ID (không dùng Android OAuth ID).

Đặt file thật `firebase-config.json` ở root (đã ignore). Client config nằm trong APK; không chứa Admin private key. API_BASE_URL repo variable đã được đặt theo ghi nhận trước; 5 biến Firebase chưa được xác nhận đã đặt trên GitHub.

### Android signing

App ID hiện `com.example.apptungkinh`. Release hiện dùng debug signing trên máy build. SHA máy local đã đọc ngày 21/10/2026:

```text
SHA-1: 20:D6:0E:83:5D:06:04:DD:2B:A7:BA:9F:80:1F:9F:1E:16:4F:08:38
SHA-256: 37:B4:C3:C4:94:DF:21:81:6A:FD:6E:8D:D9:C3:ED:65:02:CE:8D:41:DA:CA:E2:7F:13:0E:77:43:DD:93:56:A1
```

CI runner có thể sinh debug key khác mỗi lần. Cần khóa ký cố định trước khi phân phối APK Google qua CI; đăng ký fingerprint tương ứng. Google Play dùng app-signing key riêng của Play. Không giả định thêm SHA local sẽ sửa mọi APK CI.

### Render backend

```text
FIREBASE_PROJECT_ID=hanh-trinh-an-nhien
FIREBASE_SERVICE_ACCOUNT_FILE=/etc/secrets/firebase-service-account.json
```

Còn thiếu service account key thật trong Render Secret Files tên `firebase-service-account.json`. Người dùng tự tạo/download từ Project settings -> Service accounts và đưa vào Render; không gửi private key vào chat, không commit, không nhúng APK. Không ghi giá trị secret Mongo/JWT/Cloudinary vào tài liệu này. Các env cũ đã vận hành cần giữ nguyên và kiểm tra tên thực tế trong backend/.env.example hoặc docs trước sửa.

## 8. Kiểm thử đã làm và giới hạn

- Flutter analyze: không có lỗi ở lần kiểm tra trước.
- 39 test Flutter hiện hữu đạt; test Google UI mới đạt riêng, tổng 40 đã được kiểm tra theo ghi nhận phiên trước. Không phải vừa chạy lại trong lượt xuất.
- Backend 12 test đạt với MongoDB replica set Docker riêng; có mock Firebase verifier/Admin. Không thay thế kiểm thử Firebase/OAuth/email thực tế.
- Docker test project apptungkinh-tests đã down --volumes --remove-orphans, không tác động DB production.
- Build release APK thành công, khoảng 72,7 MB tại `build/app/outputs/flutter-apk/app-release.apk`, nhưng chỉ có Render URL, không có config Firebase thật. Không bàn giao nó dưới tên APK Google-ready.
- npm audit trước đó báo 3 high từ chuỗi dev nodemon/chokidar/braces; Docker production omit dev báo 0 ở thời điểm kiểm tra. Không ép downgrade.
- Chưa test thực tế: email gửi/nhận/link xác minh, chọn/hủy Google, cấp phát profile thật, token revoke thật, Cloudinary upload thật, NFC/lịch/tem với phiên Firebase trên điện thoại.

## 9. Trình tự AI tiếp theo nên thực hiện

1. Đọc git status/diff, AGENTS nếu có, docs/FIREBASE_AUTH.md; bảo toàn README và các thay đổi của người dùng. Không reset/clean. Không tạo agent phụ nếu không được yêu cầu.
2. Kiểm tra Console providers, không bật lại vô ích hoặc hỏi lại xác nhận đã có cho hai provider. Phiên Google có thể hết hạn; để người dùng login nếu cần.
3. Thêm SHA local cho APK thử; lập kế hoạch khóa ký cố định cho CI. Lấy config client, tạo firebase-config.json và đặt repository vars.
4. Chuẩn bị APK cấu hình đầy đủ trước khi chuyển backend register sang Firebase, để tránh ngắt luồng đăng ký của bản cũ.
5. Chuẩn bị commit/PR các thay đổi Firebase đã kiểm thử; kiểm tra lại nếu có thay đổi mới. Render chỉ deploy sau code merge/CI phù hợp. Không tự gộp README chưa rõ nguồn.
6. Hướng dẫn người dùng tạo private key và đặt Secret File/env trên Render, theo quy tắc xác nhận browser cho credential/quyền nhạy cảm. Không yêu cầu gửi key vào hội thoại.
7. Deploy backend đúng commit, kiểm tra health/log không lộ secret; build APK mới, cài lên Android và kiểm thử các luồng thật.
8. Kiểm thử tài khoản email mới: trước xác minh bị chặn, sau link đăng nhập được, gửi lại email, logout/login; Google chọn/hủy tài khoản; collision với email cũ không gộp; blocked/disabled/revoked; đổi mật khẩu thu hồi phiên; NFC -> tem -> lịch sử, lịch riêng đúng người.
9. Chỉ kết luận hoàn thành end-to-end khi điện thoại và API thật cùng chạy đạt. iOS/Web vẫn cần cấu hình riêng.

Lệnh build khi đã điền file thật:

```powershell
cd D:\LTDT\AppTungKinh\apptungkinh
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define-from-file=firebase-config.json
```

Flutter SDK local: `C:\Users\DatPNT\flutter`. Nếu flutter wrapper lỗi, có thể dùng dart.exe và flutter_tools.snapshot trong SDK theo hướng dẫn phiên trước. Docker chỉ mở khi cần test; nếu Start-Process phải dùng WindowStyle Hidden để tránh popup người dùng đã phàn nàn.

## 10. Thông điệp ngắn để chuyển tiếp

“Hãy tiếp tục tích hợp Firebase Google + email verification cho ứng dụng Flutter/Node/Mongo này. Đọc tài liệu bàn giao và Git diff trước. Providers Firebase đã Enabled cả hai; việc tiếp theo là thêm SHA Android, lấy config client, chuẩn bị Admin secret trên Render và APK thật. Code Firebase còn uncommitted, README có thay đổi chưa rõ nguồn; không ghi đè. Tests local đã đạt theo mốc ghi nhận, OAuth/email thật chưa test. Không nhầm APK cũ với bản Firebase-ready. Người dùng muốn bạn làm tiếp chủ động, tránh hỏi lại các phê duyệt đã cấp, và tránh cửa sổ PowerShell bật lên.”
