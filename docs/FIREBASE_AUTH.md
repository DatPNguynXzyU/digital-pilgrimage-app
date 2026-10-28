> Cấu trúc mới (27/10/2026): ứng dụng Flutter nằm trong `client/`. Chạy các lệnh `flutter`, thao tác `android/`, `ios/`, `lib/`, `test/`, `images/` và `firebase-config*.json` từ thư mục `client/`. Backend và script vận hành vẫn ở gốc repository. Xem [cấu trúc dự án](CAU_TRUC_DU_AN.md).

# Google và xác nhận email (Android)

## Cơ chế

- Tài khoản mới dùng Firebase Authentication. Email/mật khẩu được gửi cho
  Firebase; mật khẩu không lưu trong MongoDB.
- Đăng ký bằng mật khẩu gửi email xác nhận do Firebase quản lý. Người dùng
  bấm liên kết trong email, quay lại app và đăng nhập. Có nút gửi lại email.
- Google Sign-In dùng tài khoản Google và không gửi thêm email xác nhận nếu
  Google đã xác minh email.
- Backend kiểm tra chữ ký, project, hạn token, trạng thái xác minh email,
  tài khoản bị khóa và token bị thu hồi qua Firebase Admin.
- Hồ sơ và dữ liệu nghiệp vụ vẫn nằm trong MongoDB. UID Firebase ánh xạ tới
  một hồ sơ MongoDB. Không tự gộp với email của tài khoản cũ.
- Tài khoản cũ tiếp tục dùng mật khẩu cũ. Khi bật FIREBASE_PROJECT_ID,
  API đăng ký cũ bị tắt để tránh bỏ qua bước xác minh.

## Firebase Console

1. Tạo project, vào Authentication → Get started → Sign-in method.
2. Bật Email/Password (không cần email-link/passwordless).
3. Bật Google, chọn email hỗ trợ và lưu.
4. Authentication → Templates → Email address verification: đặt tên app
   và nội dung phù hợp. Dùng action handler mặc định của Firebase.
5. Project settings → Your apps → thêm Android:
   package `com.example.apptungkinh`.
6. Đăng ký SHA-1 và SHA-256 của **đúng khóa ký APK**. Có thể xem bằng:

   ```powershell
   cd android
   .\gradlew.bat signingReport
   cd ..
   ```

   Hiện release đang dùng khóa debug của máy build. CI dùng máy mới nên có
   thể có khóa debug khác. Trước khi phát hành APK Google qua CI, phải
   cấu hình một khóa ký cố định rồi đăng ký SHA tương ứng trong Firebase.
   APK Google Play dùng SHA của app-signing key trong Play Console.

   Fingerprint khóa debug hiện tại trên máy này (đã đọc ngày 21/10/2026):

   ```text
   SHA-1: 20:D6:0E:83:5D:06:04:DD:2B:A7:BA:9F:80:1F:9F:1E:16:4F:08:38
   SHA-256: 37:B4:C3:C4:94:DF:21:81:6A:FD:6E:8D:D9:C3:ED:65:02:CE:8D:41:DA:CA:E2:7F:13:0E:77:43:DD:93:56:A1
   ```

7. Tải `google-services.json` để tra cấu hình Android; không cần thêm Gradle
   Google Services vì app khởi tạo Firebase bằng FirebaseOptions tường minh.
   Từ file đó:
   - `project_info.project_id` → FIREBASE_PROJECT_ID
   - `project_info.project_number` → FIREBASE_MESSAGING_SENDER_ID
   - client có đúng Android package:
     `client_info.mobilesdk_app_id` → FIREBASE_APP_ID
   - `api_key[].current_key` → FIREBASE_API_KEY
   - `oauth_client[]` có `client_type: 3` → GOOGLE_WEB_CLIENT_ID
     (Web OAuth client ID, không phải Android OAuth client ID).
8. Từ Project settings → Service accounts tạo private key cho Firebase Admin.
   **Không gửi file này vào chat, không commit GitHub, không đưa vào APK.**

## Render

Chuẩn bị APK mới trước khi bật chế độ Firebase ở backend, để người dùng
còn có đường đăng ký hoạt động khi chuyển phiên bản.

- Environment → Secret Files: tạo file `firebase-service-account.json`,
  người quản trị tự dán nội dung private key vào Render.
- Environment Variables:
  - `FIREBASE_PROJECT_ID`: đúng project ID.
  - `FIREBASE_SERVICE_ACCOUNT_FILE`: `/etc/secrets/firebase-service-account.json`.
- Save/redeploy sau khi code mới đã merge và CI đạt.
- Nếu cấu hình thiếu hoặc project không khớp, backend không khởi động.
  Không tự bỏ kiểm tra token để vượt qua lỗi.

## Build máy cá nhân

Copy `firebase-config.example.json` thành `firebase-config.json`; điền các
giá trị client ở trên. File này không được dùng để chứa service-account key.

```powershell
flutter pub get
flutter analyze
flutter test
flutter build apk --release --dart-define-from-file=firebase-config.json
```

`API_BASE_URL` cũng đã có trong file mẫu. Chỉ chạy lệnh build với mỗi
API_BASE_URL sẽ tạo APK **không được cấu hình Firebase**.

CI đọc 5 giá trị Firebase/Google từ Repository Variables cùng tên. Các giá
trị cấu hình client này sẽ nằm trong APK; đây không phải private key.
Private key Firebase Admin chỉ ở Render. CI hiện chỉ build debug để test,
chưa thiết lập khóa ký cố định cho phát hành Google Sign-In.

## Kiểm thử với project thật

1. Email mới → đăng ký → chưa xác nhận: đăng nhập bị chặn.
2. Bấm liên kết xác nhận → đăng nhập: hồ sơ được tạo đúng một lần.
3. Gửi lại email: thử thư rác, giới hạn gửi và lỗi mạng.
4. Google: chọn tài khoản, hủy chọn, đăng nhập lại, đăng xuất.
5. Email Google trùng tài khoản cũ: không gộp; mật khẩu cũ vẫn hoạt động.
6. Quét NFC, xem lịch và lịch sử: dữ liệu đúng người dùng.
7. Đổi mật khẩu tài khoản Firebase: cần mật khẩu hiện tại, sau đó mọi
   token cũ bị thu hồi. Tài khoản chỉ dùng Google quản lý mật khẩu tại Google.
8. Disable user trong Firebase hoặc blocked trong MongoDB: API bị chặn.

Kiểm thử tự động dùng mock bộ xác minh và database MongoDB riêng; không thay
thế kiểm thử OAuth, email và cấu hình khóa ký với Firebase thật.
Luồng Google hiện chỉ hỗ trợ Android; iOS/Web cần cấu hình riêng trước khi dùng.
