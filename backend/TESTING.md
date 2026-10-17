# Backend: lịch, phiên đăng nhập và kiểm thử

## Lịch cá nhân

Mọi endpoint `/api/calendar-events` yêu cầu `Authorization: Bearer <token>`.
GET danh sách, GET /:id, POST, PUT /:id, DELETE /:id chỉ truy cập lịch của chủ token.
Truy cập ID của tài khoản khác trả 404. Không nhận userId từ client.

Payload POST (PUT hỗ trợ cập nhật một phần):
```json
{
  "id": "client-generated-id",
  "title": "Lễ Phật",
  "startAt": "2026-10-16T09:00:00.000",
  "endAt": "2026-10-16T10:00:00.000",
  "usesLunarDate": false,
  "location": "Chùa",
  "description": "",
  "reminderMinutes": 30,
  "repeat": "none"
}
```
`id` có thể bỏ qua khi tạo (server tạo UUID); repeat: none/daily/weekly/monthly/yearly.
Thời gian giữ nguyên chuỗi ISO của Flutter để bảo toàn giờ địa phương của lịch lặp/lịch âm.
GET trả toàn bộ lịch của tài khoản; Flutter tính ngày xuất hiện của lịch lặp.
Dữ liệu được lưu trong collection calendarevents. API RAM cũ với date/time/type được thay thế.

Flutter: đăng nhập thì dùng API; khách thì giữ lịch local cũ. Không tự động tải lịch khách lên tài khoản.
Lỗi mạng/401 không được chuyển ngầm sang lưu local. Lịch tài khoản cần kết nối backend.
Nhắc lịch hệ điều hành chưa được triển khai.

## Đổi mật khẩu

Đổi thành công cập nhật passwordHash và tăng tokenVersion trong cùng một thao tác.
Tất cả JWT cũ (kể cả token chưa có tokenVersion) bị từ chối sau khi đổi; cần đăng nhập lại.
Flutter xóa token trên thiết bị sau khi đổi thành công. User cũ không cần migration:
version thiếu được xem là 0 cho đến lần đổi mật khẩu đầu tiên.

## Kiểm thử tích hợp

Trong thư mục backend:
```powershell
docker compose -p apptungkinh-tests -f compose.test.yaml up --build --abort-on-container-exit --exit-code-from test
docker compose -p apptungkinh-tests -f compose.test.yaml down
```
Bộ test dùng MongoDB replica set trong Docker, dữ liệu RAM riêng và database ngẫu nhiên.
Không đọc .env, không seed/xóa database thật. Không publish cổng MongoDB ra host.
Kiểm tra quyền lịch, validation, dữ liệu sau reconnect, thu hồi JWT cũ, đăng ký/đăng nhập
hồi quy, NFC/tem/lịch sử theo tài khoản và rollback transaction khi ghi tem thất bại.
Quét được mô phỏng bằng HTTP payload UID/slug; vẫn cần thử NFC vật lý trên điện thoại.
Có thể chạy `npm test` với TEST_MONGODB_URI trỏ tới replica set dành riêng cho test.

## Áp dụng

```powershell
docker compose up -d --build
```
Build/cài lại Flutter để sử dụng API lịch và đăng xuất sau đổi mật khẩu.

## Phật ngôn và luồng giao diện

GET /api/quotes/random trả về một câu đang hoạt động, hoặc data: null khi chưa có dữ liệu.
Tham số exclude là code câu hiện tại để tránh lặp ngay nếu có câu khác.
Tám câu seed trích từ phần Kinh Pháp Cú có sẵn trong data/kinh_phat/scriptures.json,
Phẩm Song Yếu kệ 1–8; thay hai câu mẫu chưa đầy đủ trước đây.
Sau khi build backend, nạp riêng dữ liệu này (không cần chạy lại toàn bộ seed):

```powershell
docker compose exec backend npm run seed:quotes
```

Trang chủ cập nhật thống kê khi đăng nhập/đăng xuất và check-in thành công.
Nút Xem chùa từ trang chủ và lịch chuyển đúng tab Chùa.
NFC yêu cầu đăng nhập, khóa quét trong lúc gửi API, có timeout 15 giây,
và có nút mở sổ tem/lịch sử sau thành công. Không tự gửi lại yêu cầu khi timeout;
kiểm tra lịch sử trước khi quét lại vì máy chủ có thể đã ghi nhận lượt viếng.
API kinh sách chỉ trả nội dung đang active.

Kiểm tra thủ công trên Android: đăng nhập, quét thẻ đã đăng ký, xem tem/lịch sử,
quay về trang chủ xem số liệu, thử tắt NFC, mất mạng và rời màn hình khi đang quét.
Các thay đổi mã nguồn cần build/cài lại APK; APK đã build trước đó không chứa cập nhật này.
