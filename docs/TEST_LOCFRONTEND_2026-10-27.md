# Kết quả kiểm thử locfrontend — 27/10/2026

- Remote: origin/locfrontend; commit 58b95968e9c567674a7884d6298dd84695b6051f (update frontend).
- Checkout riêng: D:/LTDT/AppTungKinh/apptungkinh/.local-cd/test-locfrontend (detached HEAD).
- Nhánh này chính là commit frontend vừa được revert khỏi main. main sau fetch: efe22a6.
- flutter pub get --enforce-lockfile: PASS.
- flutter analyze --no-pub: PASS, No issues found.
- flutter test --no-pub: PASS, 57 tests.
- Log đầy đủ: ../.local-cd/test-locfrontend/analyze.log và test.log.
- Không sửa code nhánh, không merge/push, không seed database. Bản làm việc gốc và dữ liệu chùa chưa commit được bảo toàn.

## Giới hạn

Chưa build APK/IPA của nhánh này, chưa chạy thử trên điện thoại, chưa kiểm chứng giao diện bằng mắt và các dịch vụ production. Test pass không đồng nghĩa các luồng NFC, Google login, GPS, thông báo trên thiết bị đã được xác nhận.

## Lưu ý khi đánh giá

SavedItemsStore mới dùng shared_preferences với key chung theo thiết bị; không có phân vùng theo user trong lớp này. Cần xác nhận yêu cầu sản phẩm nếu muốn mục đã lưu riêng từng tài khoản.

Muốn mở code trong IDE, mở thư mục checkout riêng phía trên. Không checkout đè nhánh gốc đang có dữ liệu chùa và sửa Gradle chưa commit.
