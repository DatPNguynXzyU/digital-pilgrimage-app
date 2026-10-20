# CI trên GitHub Actions

Workflow: `.github/workflows/ci.yml`. Chạy khi push vào `main`, mở/cập nhật
pull request vào `main`, hoặc chọn Actions → CI → Run workflow.

## Các bước kiểm tra

1. **Flutter analyze and test**: dùng Flutter 3.47.4 (Dart 3.13.3), cài dependency
   theo `pubspec.lock`, phân tích toàn dự án, chạy test và lưu coverage.
2. **Backend integration tests**: build Docker với `npm ci`, chạy test trên
   MongoDB 7 replica set tạm. Không cần `.env`, JWT secret hay database thật.
   Log được lưu và container được dọn kể cả khi test lỗi.
3. **Android test APK**: chỉ chạy sau khi cả hai job trên thành công; build
   APK debug bằng Java 17, lưu artifact `android-debug-<run number>` trong 7 ngày.

Workflow chỉ cần quyền đọc repository, không triển khai backend hay phát hành lên store.
Các lần chạy cũ trên cùng PR/nhánh được hủy khi có commit mới.

## Kích hoạt và tải APK

- Commit và push workflow cùng các bản sửa lỗi merge trong lần thay đổi này.
- Vào tab **Actions → CI**, mở lần chạy để xem kết quả từng job.
- Khi thành công, tải `android-debug-...` trong **Artifacts**, giải nén lấy APK.
- GitHub Actions phải được bật; nếu tổ chức giới hạn action, cần cho phép
  `actions/checkout`, `actions/setup-java`, `actions/upload-artifact` và
  `subosito/flutter-action`.

Để APK dùng được trên điện thoại qua mạng khác, vào repository **Settings →
Secrets and variables → Actions → Variables**, thêm repository variable:

```text
API_BASE_URL=https://<ten-mien-backend>/api
```

Đây là địa chỉ công khai, không phải secret. Không đưa mật khẩu/token vào URL.
Khi chưa cấu hình, APK dùng `http://10.0.2.2:3000/api` dành cho Android Emulator.
Đổi biến chỉ áp dụng cho APK build ở lần chạy tiếp theo. Tunnel tạm đổi URL thì
phải cập nhật biến và chạy lại workflow. CI build không tự khởi động backend cho điện thoại.

APK debug dành cho thử nghiệm. Khóa ký tạm trên runner có thể khác APK đang cài;
nếu Android báo chữ ký không khớp, cần dùng khóa ký ổn định hoặc gỡ bản cũ trước
khi cài (gỡ app sẽ xóa dữ liệu local). Chưa cấu hình phát hành production.

## Chặn merge khi kiểm tra thất bại

Sau lần CI đầu tiên, cấu hình ruleset/branch protection cho `main` và yêu cầu:

- `Flutter analyze and test`
- `Backend integration tests`
- `Android test APK`

File workflow tự chạy kiểm tra; việc bắt buộc các check trước merge cần được bật
trong Settings của repository bởi người có quyền quản trị.

## Chạy tương đương trên máy

```powershell
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub --coverage
flutter build apk --debug --no-pub --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Trong thư mục `backend`:

```powershell
docker compose -p apptungkinh-tests -f compose.test.yaml up --build --attach test --abort-on-container-exit --exit-code-from test
docker compose -p apptungkinh-tests -f compose.test.yaml down --volumes --remove-orphans
```

Khi nâng Flutter, cập nhật `FLUTTER_VERSION` trong workflow cùng constraint SDK
và lockfile nếu cần. Cấu hình action dựa trên tài liệu của
[Flutter action](https://github.com/subosito/flutter-action),
[setup-java](https://github.com/actions/setup-java) và
[upload-artifact](https://github.com/actions/upload-artifact).
