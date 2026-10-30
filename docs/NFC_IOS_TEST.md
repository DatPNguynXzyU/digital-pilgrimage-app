# Kiểm thử NFC trên iPhone

## Đã mở trong mã nguồn

- Quét thẻ trong app để check-in, dùng UID vật lý MiFare/ISO mà Core NFC cung cấp.
- Admin đọc UID, đọc NDEF, ghi NDEF lên NTAG215 còn quyền ghi, đọc lại xác nhận và liên kết UID với chùa qua API quản trị hiện có.
- Dùng cửa sổ Core NFC của iOS và giữ phiên mở qua bước ghi/đọc kiểm tra.
- Không nhầm cửa sổ NFC tạm thời với việc đưa app về nền: app vẫn khóa sinh trắc học khi thực sự vào nền.
- Gắn `Runner/Runner.entitlements` vào cấu hình ký Debug/Profile/Release; entitlement có `com.apple.developer.nfc.readersession.formats = ["TAG"]`.
- Bản build có thể giữ NFC hoặc tắt NFC qua tùy chọn workflow; thông báo lỗi nhắc kiểm tra quyền ký khi iOS từ chối.

## Điều kiện bắt buộc để test phần cứng

iPhone thật có Core NFC, bản iOS phù hợp với ứng dụng và IPA được ký đúng. Profile ký cuối cùng phải cho phép **Near Field Communication Tag Reading** và khớp App ID/bundle ID. Thêm entitlement vào source hoặc IPA unsigned **không cấp quyền** nếu profile không có quyền đó. Khi ký lại bằng công cụ sideload, quyền NFC có thể bị loại bỏ hoặc iOS có thể từ chối cài/chạy phiên NFC.

Với Apple ID miễn phí và luồng Sideloadly cũ, không coi NFC là được hỗ trợ. Cần xác minh capability trong profile ký; thông thường phải dùng team Apple Developer có hỗ trợ NFC. Không có bước đổi cờ Dart nào thay thế quyền ký do Apple cấp. Không cần đưa Apple ID, mật khẩu hoặc chứng chỉ vào chat.

Tài liệu Apple:

- https://developer.apple.com/documentation/corenfc/building-an-nfc-tag-reader-app
- https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.developer.nfc.readersession.formats
- https://developer.apple.com/help/account/reference/supported-capabilities-ios

## Build qua GitHub Actions

Sau khi các thay đổi này được push lên GitHub:

1. Vào **Actions → iOS Sideload IPA → Run workflow**.
2. Chọn nhánh chứa mã NFC iOS mới.
3. Chọn **Enable NFC test** (`enable_nfc = true`, mặc định đã chọn).
4. Chạy workflow rồi tải artifact `ios-sideload-<run number>`.
5. Artifact gồm IPA unsigned, SHA256SUMS, BUILD-INFO và `NFC.entitlements.plist` cho biết các quyền yêu cầu.
6. Ký IPA bằng profile có NFC Tag Reading và giữ entitlement TAG khi ký. Build không tự tạo/chọn profile hoặc đăng ký quyền với Apple.

Nếu chỉ muốn IPA sideload không dùng NFC với luồng cũ, bỏ chọn `enable_nfc`. Script sẽ xóa riêng quyền NFC trong bản CI tạm và đặt `IOS_NFC_ENABLED=false`.

Script được thiết kế chỉ chạy trong checkout CI dùng một lần. Không chạy nó để sửa cấu hình ký trên máy đang phát triển.

## Build trên macOS có Xcode

Mở project iOS bằng Xcode, chọn đúng team và App ID, bật **Signing & Capabilities → Near Field Communication Tag Reading**, tạo hoặc cập nhật provisioning profile hỗ trợ quyền đó. Với cấu hình Firebase iOS đã có:

```bash
cd client
flutter build ios --release --no-codesign \
  --dart-define-from-file=firebase-config.ios.json \
  --dart-define=IOS_NFC_ENABLED=true
```

Đây vẫn là build chưa ký; cần ký bằng profile hợp lệ để cài/test. Windows không có Xcode nên không xác nhận build IPA hoặc chữ ký iOS ngay trên máy này.

## Test trên iPhone

### Người dùng

1. Mở app, đăng nhập, vào **Chùa → Check-in**.
2. Khi cửa sổ NFC xuất hiện, đưa thẻ NTAG215 sát **phần trên iPhone** và giữ yên.
3. Kiểm tra UID được nhận, check-in thành công, tem và lịch sử đồng bộ.

### Admin

1. Vào **Cá nhân → Quản lý thẻ NFC** bằng tài khoản admin.
2. Chọn Đọc thẻ → chạm thẻ.
3. Chọn chùa → Ghi và liên kết thẻ → xác nhận → chạm lại đúng thẻ.
4. Chờ đọc kiểm tra và xác nhận máy chủ. Thử thẻ khác UID để kiểm tra chặn ghi nhầm.
5. Thử hủy cửa sổ NFC, chuyển app ra nền, thẻ chỉ đọc và mất mạng sau khi ghi.

Nếu báo `Missing required entitlement`, `Security Violation` hoặc không mở được phiên: kiểm tra chữ ký/profile NFC trước; không seed MongoDB hoặc đổi dữ liệu thẻ để sửa lỗi quyền ký.

Phiên bản này hỗ trợ thao tác NFC **trong app**. Tự mở app từ thẻ HTTPS khi app chưa chạy vẫn cần Universal Links/Associated Domains; không được triển khai trong thay đổi này.

## Kiểm thử tự động

```powershell
python scripts/test_prepare_ios_sideload.py
cd client
flutter analyze --no-pub
flutter test --no-pub --dart-define=IOS_SIDELOAD_BUILD=true --dart-define=IOS_NFC_ENABLED=true test/nfc_ios_test.dart
flutter test --no-pub --dart-define=IOS_SIDELOAD_BUILD=true --dart-define=IOS_NFC_ENABLED=false test/nfc_ios_disabled_test.dart
flutter test --no-pub
```

Các kiểm thử kênh iOS dùng dữ liệu Pigeon giả lập của plugin để xác minh UID, cấu hình phiên, ghi/đọc kiểm tra và xử lý lỗi quyền. Chúng không chứng minh IPA có chữ ký hợp lệ hoặc phần cứng iPhone đọc được thẻ thật.
