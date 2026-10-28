> Cấu trúc mới (27/10/2026): ứng dụng Flutter nằm trong `client/`. Chạy các lệnh `flutter`, thao tác `android/`, `ios/`, `lib/`, `test/`, `images/` và `firebase-config*.json` từ thư mục `client/`. Backend và script vận hành vẫn ở gốc repository. Xem [cấu trúc dự án](CAU_TRUC_DU_AN.md).

# Ký APK release

Gradle đọc `android/key.properties`, dùng keystore `android/release-keystore.jks`, alias `release`. Hai file được android/.gitignore loại khỏi Git. Sao lưu riêng cả hai vào nơi an toàn; cần cùng khóa để phát hành cập nhật. Không tạo lại hoặc ghi đè khóa này.

```powershell
flutter build apk --release --dart-define-from-file=firebase-config.json
```

Output: `build/app/outputs/flutter-apk/app-release.apk`.

Khóa release khác debug: APK mới không cài đè bản debug đã cài. Gỡ app cũ sẽ xóa dữ liệu cục bộ; cân nhắc trước khi gỡ. Dữ liệu đã lưu backend thuộc tài khoản vẫn ở server.

Thêm fingerprints sau vào Firebase Project settings -> Android com.example.apptungkinh -> Add fingerprint trước khi test Google trên bản release:

```text
SHA-1: C8:29:BF:90:DA:E0:6B:07:A4:4C:04:20:D7:55:62:DB:E0:24:C7:3E
SHA-256: 04:E2:81:4F:3B:76:74:80:B7:64:E4:F1:52:16:E5:B3:7A:52:87:21:8C:FB:BD:FD:29:72:6D:26:B4:FC:37:48
```

CI hiện build debug, chưa cung cấp keystore release. Nếu triển khai build release trong CI phải lưu key/password bằng GitHub Secrets và tạo key.properties lúc build. Không commit private key/password. Google Play App Signing có fingerprint riêng cần đăng ký thêm khi phát hành qua Play.
