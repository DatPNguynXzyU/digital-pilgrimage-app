# Thống kê hoạt động NFC — hướng dẫn quản trị

## Mở màn hình

Sau khi triển khai backend mới và cài bản app mới: đăng nhập tài khoản có `role: "admin"` trong collection `users`, vào **Cá nhân → Thống kê NFC**. Tài khoản thông thường không thấy mục này; gọi API trực tiếp cũng bị từ chối (403). Backend lấy vai trò từ MongoDB mỗi request, không tin vai trò do client gửi.

Chủ dự án cần kiểm tra đúng tài khoản trong MongoDB trước khi cấp vai trò admin. Thay đổi này không tự cấp quyền cho bất cứ ai. Không cần thêm Firebase custom claims hoặc biến môi trường. Chưa thay đổi quyền trên production trong tác vụ này.

## Cách đọc số liệu

| Chỉ số | Cách tính | Ví dụ |
|---|---|---|
| Lượt check-in | Số bản ghi `PilgrimageVisit` trong bộ lọc | A quét 3 lần, B quét 2 lần → 5 lượt |
| Người duy nhất | Số `userId` khác nhau trong toàn bộ bộ lọc | A và B → 2 người |
| Chùa có lượt | Số chùa có ít nhất một check-in trong bộ lọc | A ghé 2 chùa → 2 chùa |
| Theo ngày | Lượt và người duy nhất từng ngày theo UTC+7 | A quét hôm nay và hôm sau → mỗi ngày 1 người, tổng vẫn 1 |
| Theo chùa | Lượt và người duy nhất tại từng chùa | A quét ở 2 chùa → mỗi chùa 1 người, tổng vẫn 1 |
| Theo sự kiện | Check-in ở đúng chùa, trong giờ tổ chức và trong khoảng ngày báo cáo | Một lễ từ 08:00 đến 10:00: tính 08:00, không tính đúng 10:00 |

Các thanh ngang biểu diễn **lượt check-in**; số người được ghi ngay dưới thanh. Cùng một biểu đồ dùng chung thang đo, nhưng các biểu đồ có thang đo riêng. Có thể cuộn bên trong biểu đồ dài. Ngày không có lượt được điền 0. Danh sách chùa chỉ hiển thị chùa có lượt.

Mặc định 30 ngày gần nhất, gồm hôm nay theo Việt Nam; cho phép tối đa 366 ngày. Lọc một chùa sẽ áp dụng cho tất cả chỉ số, kể cả sự kiện. Không cộng số người ở các nhóm để suy ra tổng người. Một người có nhiều tài khoản vẫn được tính là nhiều người.

## Thêm sự kiện

Nhấn **Thêm sự kiện thống kê**, nhập tên, chọn chùa, chọn ngày và giờ bắt đầu/kết thúc theo **giờ Việt Nam**, rồi lưu. Có thể nhập sự kiện quá khứ để thống kê lại dữ liệu check-in đã có. Sự kiện được lưu trong collection riêng `nfcevents`; không thay đổi lịch cá nhân, lịch lễ Phật giáo, tem hay lịch sử người dùng. Phiên bản này hỗ trợ tạo và xem, chưa có sửa/xóa sự kiện trên giao diện.

Thống kê suy ra từ **địa điểm và thời gian**, không chứng minh người dùng thực sự tham gia nghi lễ. Hai sự kiện trùng giờ tại một chùa có thể cùng tính một lượt. Tổng toàn hệ thống vẫn tính lượt đó một lần. Sự kiện vượt ngoài bộ lọc ngày chỉ đếm phần giao nhau. Tối đa 100 sự kiện gần nhất giao với khoảng ngày được hiển thị; giao diện báo khi vượt giới hạn.

## Giới hạn cần hiểu

- Đây là thống kê **check-in đã được backend lưu thành công**, không phải mọi lần điện thoại đọc NFC. Lỗi thẻ, mất mạng, chưa đăng nhập hoặc transaction thất bại không được tính.
- Lượt quét lặp đã được lưu vẫn tính là nhiều lượt; chỉ chỉ số người được loại trùng. Không thay đổi quy tắc cấp tem hay tự xóa dữ liệu lặp.
- Không đồng nghĩa số khách thực tế đến chùa; khách không sử dụng app không được đếm.
- Dùng dữ liệu MongoDB hiện có; không seed, không gửi dữ liệu cá nhân ra biểu đồ. API chỉ trả số tổng hợp, tên chùa và sự kiện, không trả email, UID NFC hoặc danh sách người.
- Chùa ngừng hoạt động hoặc bị xóa vẫn giữ số liệu lịch sử; chùa đã xóa hiện nhãn thay thế.
- API không cache thống kê; nút tải lại lấy dữ liệu mới. Phạm vi tối đa 366 ngày và giới hạn thời gian truy vấn 15 giây giúp tránh báo cáo quá lớn; cần kiểm thử tải thực tế nếu số lượt tăng mạnh.

## API và mã nguồn

Tất cả endpoint bên dưới yêu cầu token đăng nhập hiện có và tài khoản admin:

```text
GET  /api/admin/nfc/statistics?from=2026-10-01&to=2026-10-28&templeId=<optional ObjectId>
GET  /api/admin/nfc/temples
POST /api/admin/nfc/events
```

Body tạo sự kiện:

```json
{
  "title": "Lễ tại chùa",
  "templeId": "ObjectId thực tế của chùa",
  "startAt": "2026-10-28T08:00:00+07:00",
  "endAt": "2026-10-28T10:00:00+07:00"
}
```

Backend: `nfc-admin.controller.js`, `nfc-admin.routes.js`, `nfc-event.model.js`; index bổ sung `{templeId:1, visitDate:1, userId:1}`. Mobile: `nfc_admin_service.dart`, `nfc_statistics_page.dart` và mục truy cập trong `tai_khoan.dart`. Không thêm thư viện biểu đồ: dùng Flutter để vẽ thanh ngang, có nhãn số và hỗ trợ trình đọc màn hình.

## Kiểm thử

Backend integration test trong `backend/test/api.test.js`: 401/403, thu hồi vai trò, người duy nhất qua nhiều chùa, mốc nửa đêm UTC+7, ngày trống, sự kiện trùng nhau và giới hạn ngày. Test chạy trên MongoDB tạm riêng, không dùng production.

```powershell
cd backend
docker compose -p apptungkinh-tests -f compose.test.yaml up --build --abort-on-container-exit --exit-code-from test
cd ../client
flutter analyze --no-pub
flutter test --no-pub test/nfc_statistics_test.dart
```

Trên điện thoại: thử một tài khoản admin và một tài khoản thường; tạo sự kiện có thời gian bao phủ hiện tại tại chùa thử; quét thành công rồi tải lại. Đối chiếu 2 lần quét của cùng tài khoản → 2 lượt, 1 người; tem vẫn theo quy tắc cũ.
