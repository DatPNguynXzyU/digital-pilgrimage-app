# Cấu trúc dự án và cách làm việc

Cập nhật ngày 27/10/2026. Repository được chia theo thành phần; việc di chuyển không seed hoặc thay đổi MongoDB.

```text
digital-pilgrimage-app/
├── client/                 # Toàn bộ ứng dụng Flutter
│   ├── lib/                # Mã nguồn Dart
│   ├── test/               # Kiểm thử Flutter
│   ├── android/            # Gradle, Android native, khóa ký cục bộ
│   ├── ios/                # Xcode, cấu hình iOS
│   ├── images/             # Hình ảnh Flutter
│   ├── assets/             # Tài nguyên Flutter
│   ├── pubspec.yaml
│   ├── pubspec.lock
│   └── firebase-config*.json
├── backend/                # API, dữ liệu, hình chùa, Docker và test backend
├── .github/workflows/      # CI Android, iOS sideload, CD backend
├── scripts/                # Script vận hành và chuẩn bị iOS
├── docs/                   # Hướng dẫn kỹ thuật
│   └── reports/            # Báo cáo Word/PDF và tài liệu bàn giao cũ
├── releases/               # Tài nguyên phát hành hiện có
├── render.yaml             # Cấu hình triển khai backend
└── README.md
```

## Chạy và build ứng dụng

Mở terminal tại gốc repository, sau đó:

```powershell
cd client
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
flutter run --dart-define-from-file=firebase-config.json
```

Build APK từ cùng thư mục `client/`:

```powershell
flutter build apk --release --dart-define-from-file=firebase-config.json
```

APK nằm tại `client/build/app/outputs/flutter-apk/app-release.apk` tính từ gốc repository. Bản APK cũ được giữ trong thư mục build đã chuyển, không phải bản build từ cấu trúc mới.

Khi clone mới, sao chép `client/firebase-config.example.json` thành `client/firebase-config.json` rồi điền cấu hình client được nhóm cung cấp. Không đưa Firebase Admin key vào Flutter. Các file cấu hình riêng, khóa ký và thư mục build tiếp tục bị Git bỏ qua.

Android Studio: mở thư mục `client/`. VS Code: có thể mở cả repository và chọn cấu hình chạy **Flutter client**; cấu hình này dùng file `client/firebase-config.json`.

## Backend và CI/CD

Từ gốc repository:

```powershell
cd backend
npm ci
npm run dev
```

Backend cần biến môi trường và database theo [hướng dẫn setup](HUONG_DAN_SETUP.md). Khi đang ở `client/`, dùng `cd ../backend` để chuyển sang backend.

- Job Flutter và Android trong CI chạy tại `client/`; artifact được lấy từ `client/build/` và `client/coverage/`.
- Workflow iOS chạy tại `client/`, gọi `../scripts/prepare-ios-sideload.py`. Script này chỉ chạy trong checkout CI tạm.
- Docker backend, Render và các script CD cục bộ vẫn dùng đường dẫn `backend/` từ gốc. Không cần đổi biến môi trường production do việc tổ chức lại này.
- Trên macOS hoặc runner GitHub, chạy lại `flutter pub get` trước build iOS để cập nhật file sinh tự động theo vị trí mới.

## Quy tắc đóng góp

- Sửa ứng dụng trong `client/`, API trong `backend/`, hướng dẫn trong `docs/`.
- Chạy Git từ gốc repository để xem toàn bộ thay đổi.
- Không commit `build/`, `.dart_tool/`, khóa ký, mật khẩu, Firebase Admin JSON hoặc `.env`.
- Hình chùa và dữ liệu seed vẫn ở `backend/img/` và `backend/data/`; không nhầm với tài nguyên đóng gói trong `client/images/`.
- Báo cáo trong `docs/reports/` là bản lưu lịch sử, có thể nhắc đường dẫn cũ. Khi chạy lệnh, dùng cấu trúc trong hướng dẫn này.
