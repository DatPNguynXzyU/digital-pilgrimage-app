# Đọc và ghi thẻ NFC dành cho quản trị viên

## Chuẩn bị

- Backend và app phải có bản cập nhật quản lý thẻ (API bên dưới); iOS cần bản NFC test và quyền ký tương ứng.
- Tài khoản trong MongoDB `users` có `role: "admin"`, trạng thái active.
- Điện thoại Android có NFC, đã bật NFC, có mạng; thẻ NTAG215 đã định dạng NDEF và còn quyền ghi.
- Mục **Cá nhân → Quản lý thẻ NFC** chỉ xuất hiện với admin. Máy chủ kiểm tra vai trò trong MongoDB ở từng request; tự sửa giao diện không cấp được quyền quản lý UID.

## Sử dụng

1. Mở **Cá nhân → Quản lý thẻ NFC**.
2. Nhấn **Đọc thẻ** rồi chạm thẻ. App hiển thị UID vật lý, công nghệ Android nhận diện, hỗ trợ NDEF, dung lượng, quyền ghi, nội dung và liên kết trên máy chủ. Công nghệ không khẳng định chính xác tên chip/nhà sản xuất.
3. Chọn chùa đang hoạt động. Nhấn **Ghi và liên kết thẻ**.
4. Xác nhận thay toàn bộ nội dung NDEF của đúng UID đó, rồi chạm lại **cùng thẻ** và giữ yên. Nếu gặp UID khác, app dừng trước khi ghi.
5. App ghi hai bản ghi NDEF, đọc lại và so sánh byte. Chỉ sau khi kiểm tra khớp mới đăng ký UID với chùa trên MongoDB.
6. Khi hiện thông báo thành công, có thể dùng thẻ để check-in bằng app. Thao tác trong màn hình quản lý không cấp tem, không tạo lượt viếng.

App dùng nội dung tối giản (không chứa thông tin cá nhân):

```json
{"type":"temple","slug":"chua-giac-lam"}
```

Bản ghi đầu có MIME `application/vnd.hanhtrinhannhien.temple`. Bản ghi thứ hai là Android Application Record `android.com:pkg`, payload `com.example.apptungkinh`. Định dạng này tương thích luồng chạm mở app hiện tại. Website fallback qua HTTPS vẫn chưa triển khai.

## Trường hợp cần xử lý

| Trường hợp | Kết quả |
|---|---|
| UID đã thuộc chùa khác | Chặn trước khi ghi; backend cũng chặn gán lại |
| UID thuộc cùng chùa, đang active | Cho phép ghi lại, đăng ký lại không tạo thẻ trùng |
| Thẻ inactive | Bật lại bằng nút riêng trước khi ghi |
| Không có NDEF | Hiển thị UID/công nghệ; chặn ghi, cần chuẩn bị thẻ NDEF trước |
| Chỉ đọc hoặc dung lượng thiếu | Chặn ghi |
| Rút thẻ giữa lúc ghi | Báo lỗi; đọc lại thẻ trước khi thử lại vì nội dung vật lý có thể đã thay đổi một phần |
| Đã ghi nhưng mạng/API lỗi | Báo rõ chưa xác nhận liên kết. Nút **Thử liên kết lại (chạm thẻ)** đọc đúng UID và đúng nội dung rồi mới gửi lại; không ghi lại |
| Thẻ mất/cần ngừng dùng | Đọc thẻ để chọn UID, nhấn **Vô hiệu hóa thẻ**; backend chặn check-in, giữ tem/lịch sử đã có |
| App vào nền | Hủy phiên đọc/ghi; không tự động ghi khi quay lại |

Thời gian chờ mỗi lần chạm là 45 giây. Có nút hủy. Chức năng này chưa có danh sách quản lý từ xa khi không cầm thẻ: muốn vô hiệu hóa qua giao diện cần đọc được UID trước.

## Giới hạn và tính nhất quán

Thẻ vật lý và MongoDB không cùng một transaction. Ghi thành công không đảm bảo liên kết máy chủ thành công. App giữ riêng trạng thái đọc xác nhận và trạng thái đăng ký; khi lỗi mạng cần kiểm tra và thử liên kết lại. Backend lấy UID làm khóa duy nhất và không cho chuyển UID sang chùa khác. Nếu quản trị viên khác đăng ký cùng UID ở thời điểm đang ghi, bước liên kết có thể bị từ chối; đọc lại và kiểm tra liên kết trước khi dùng.

Backend không thể chứng minh điện thoại thực sự ghi NDEF chỉ từ request HTTP; chỉ tài khoản admin được phép đăng ký UID. Chức năng không thay đổi cơ chế chống giả mạo của check-in hiện có.

Không đổi UID, không khóa vĩnh viễn, không format thẻ và không cấu hình mật khẩu NTAG215 trong phiên bản này. Quyền admin bảo vệ app/API; thẻ vật lý chưa bảo vệ ghi vẫn có thể bị phần mềm NFC khác ghi đè. Đây không phải tính năng chống sao chép thẻ.

Hỗ trợ quản trị đọc/ghi trên Android; đã bổ sung đường kiểm thử iOS có `IOS_NFC_ENABLED=true` và chữ ký/profile có NFC Tag Reading. Bản sideload tắt NFC vẫn chặn trước khi gọi phần cứng. Xem `docs/NFC_IOS_TEST.md` để build và kiểm tra quyền ký; Apple ID miễn phí/Sideloadly không tự cấp quyền NFC. Web không hỗ trợ đọc/ghi trong app này.

## API

Tất cả endpoint yêu cầu Bearer token hiện tại và tài khoản admin:

```text
GET  /api/admin/nfc/tags/:uid
POST /api/admin/nfc/tags                 {"uid":"04112233445566","templeId":"..."}
POST /api/admin/nfc/tags/:uid/status     {"status":"inactive"} hoặc {"status":"active"}
GET  /api/admin/nfc/temples              trả thêm slug để tạo nội dung thẻ
```

UID phải là 4–10 byte hex; cho phép dấu hai chấm, khoảng trắng hoặc gạch nối làm dấu phân cách. UID được chuẩn hóa thành chữ hoa. Backend từ chối chùa ngừng hoạt động, UID thuộc chùa khác, dữ liệu sai và tài khoản bị thu hồi quyền. Không tự tạo tem hay lịch sử khi đăng ký.

## Kiểm thử và bàn giao

- Kiểm thử phần ghi bằng NDEF giả lập: sai UID, thẻ khóa, dung lượng thiếu, hủy, nội dung đọc lại sai.
- Kiểm thử màn hình với API/đầu đọc giả lập: tài khoản không đủ quyền, UID xung đột và mất mạng sau ghi rồi thử liên kết lại.
- Backend integration test trong `backend/test/api.test.js`: phân quyền, đăng ký lặp, không chuyển chùa, vô hiệu hóa/bật lại, check-in và giữ lịch sử. Chạy trên MongoDB riêng bằng Docker Compose test, không dùng database thật.
- Trước khi đưa vào sử dụng cần thử thẻ NTAG215 thật trên Android: đọc → ghi → đọc lại → check-in; thẻ khác UID; ngắt mạng sau ghi; vào nền; thẻ chỉ đọc. Kiểm thử giả lập không xác nhận độ ổn định kết nối vô tuyến của điện thoại/thẻ.

```powershell
cd client
flutter analyze --no-pub
flutter test --no-pub test/nfc_tag_writer_test.dart test/nfc_tag_admin_test.dart test/nfc_launch_test.dart
flutter build apk --release --dart-define-from-file=firebase-config.json
```

Triển khai backend mới trước khi dùng màn hình ghi thẻ trong APK mới. Không cần thêm biến môi trường hoặc seed database. Việc ghi thẻ thật và thay đổi UID đăng ký trên production chỉ xảy ra khi admin chủ động thao tác trong app.
