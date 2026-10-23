# Chạy Hành Trình An Nhiên trên iOS

## Trạng thái port

Đã bổ sung quyền camera, thư viện ảnh, Face ID và NFC; mở Google Sign-In và NFC cho iOS; thêm đọc UID qua API Core NFC của plugin. Backend Render, MongoDB, Cloudinary và Redis dùng chung API với Android. Chưa build Xcode hoặc thử iPhone: máy hiện tại là Windows.

## 1. Công cụ và tài khoản

- Mac có Xcode và Flutter tương thích (tham khảo phiên bản trong CI).
- Chạy `flutter doctor -v`, xử lý iOS toolchain và dependency manager theo Flutter/Xcode hiện hành.
- iPhone thật hỗ trợ Core NFC để kiểm thử thẻ. Simulator dùng kiểm tra giao diện, không chứng minh NFC hoạt động.
- Apple signing team và provisioning profile có quyền NFC Tag Reading. Xác nhận entitlement được tài khoản/team cấp; TestFlight/App Store cần Apple Developer Program.
- APK/keystore Android không dùng để ký iOS.

## 2. Đăng ký Firebase iOS

Trong project `hanh-trinh-an-nhien`, thêm Apple app với bundle ID khớp Runner. ID trong repo đang là `com.example.apptungkinh`; trước phát hành chọn ID do nhóm sở hữu, cập nhật Runner và đăng ký đúng ID đó.

Tải `GoogleService-Info.plist` của Apple app để lấy cấu hình. Không dùng Android App ID hoặc Android OAuth client ID cho iOS. App khởi tạo Firebase bằng FirebaseOptions nên hướng dẫn này truyền thông tin tường minh qua Dart và xcconfig, không yêu cầu thêm plist vào bundle.

Tại gốc repo trên Mac:

```bash
cp firebase-config.ios.example.json firebase-config.ios.json
cp ios/Flutter/Firebase.local.xcconfig.example ios/Flutter/Firebase.local.xcconfig
```

Điền JSON:

| Biến | Giá trị |
|---|---|
| API_BASE_URL | Backend HTTPS, ví dụ https://digital-pilgrimage-api.onrender.com/api |
| FIREBASE_PROJECT_ID | PROJECT_ID trong plist |
| FIREBASE_API_KEY | API_KEY trong plist |
| FIREBASE_IOS_APP_ID | GOOGLE_APP_ID của Apple app, chứa `:ios:` |
| FIREBASE_MESSAGING_SENDER_ID | GCM_SENDER_ID trong plist |
| GOOGLE_IOS_CLIENT_ID | CLIENT_ID của OAuth iOS |
| GOOGLE_WEB_CLIENT_ID | Web OAuth client ID cùng project, hiện dùng cho serverClientId |

Trong `ios/Flutter/Firebase.local.xcconfig`, đặt `GOOGLE_REVERSED_CLIENT_ID` bằng REVERSED_CLIENT_ID từ plist. Info.plist lấy URL scheme từ biến này để Google quay lại ứng dụng. Thay toàn bộ giá trị mẫu; đừng thêm dấu nháy quanh giá trị xcconfig.

Email/Password và Google phải được bật trong Firebase Authentication. Không cần thay Firebase Admin trên Render nếu cùng project. Không đưa Admin JSON hoặc khóa bí mật backend vào iOS.

## 3. Build và ký

```bash
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build ios --simulator --debug --dart-define-from-file=firebase-config.ios.json
open ios/Runner.xcworkspace
```

Trong Xcode chọn Runner → Signing & Capabilities, chọn Team, kiểm tra Bundle Identifier và Automatically manage signing. Xác nhận Near Field Communication Tag Reading capability và profile chứa `com.apple.developer.nfc.readersession.formats` với TAG. Cấu hình entitlement đã được nối vào Debug/Release/Profile qua xcconfig; kiểm tra lại sau khi đổi dependency manager hoặc cấu hình Xcode.

Kết nối iPhone, bật Developer Mode khi hệ thống yêu cầu, tin cậy máy Mac và chọn thiết bị:

```bash
flutter devices
flutter run -d <iphone-device-id> --dart-define-from-file=firebase-config.ios.json
```

Khi đã ký hợp lệ và có quyền phân phối:

```bash
flutter build ipa --release --dart-define-from-file=firebase-config.ios.json
```

Archive ở build/ios/archive, IPA ở build/ios/ipa. Upload qua Xcode Organizer/App Store Connect và TestFlight. Chưa bổ sung phát hành iOS vào CI; workflow hiện tại vẫn phục vụ Android/backend.

## 4. Kiểm thử bắt buộc

1. Email mới chưa xác minh bị chặn; xác minh và đăng nhập thành công.
2. Google: đăng nhập, hủy, logout, đăng nhập lại; URL scheme hoạt động trên bản ký thật.
3. NFC: thẻ MiFare/ISO15693/ISO7816 tương thích, hủy phiên, hết thời gian, quét lại, nhận tem và lịch sử. Đối chiếu UID cùng thẻ giữa Android/iOS; không tự đảo byte hoặc đăng ký lại thẻ khi chưa xác minh, đặc biệt ISO15693.
4. iPhone không hỗ trợ loại thẻ sẽ không đọc được dù Android đọc được; không coi mọi thẻ Android là tương thích Core NFC.
5. Face ID/Touch ID, khóa khi quay lại app; camera QR, chụp và chọn ảnh; kiểm tra cả quyền bị từ chối.
6. Render cold start, mất mạng, đăng xuất/đổi người dùng, layout Safe Area và cỡ chữ lớn.

Trước App Store, rà soát App Review Guidelines mục 4.8 về dịch vụ đăng nhập, mục 5.1.1 về xóa tài khoản, khai báo quyền riêng tư và privacy manifest. Repo chưa triển khai Sign in with Apple; không khẳng định đã đủ điều kiện duyệt App Store.

## Nguồn kỹ thuật

- https://docs.flutter.dev/deployment/ios
- https://firebase.google.com/docs/ios/setup
- https://firebase.google.com/docs/auth/ios/google-signin
- https://pub.dev/packages/nfc_manager
- https://developer.apple.com/app-store/review/guidelines/
