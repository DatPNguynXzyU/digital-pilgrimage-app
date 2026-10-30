# Kịch bản kiểm thử và thuyết trình

## Tự động

```powershell
cd backend
npm ci
npm test
npm run check
cd ../frontend
flutter pub get
flutter analyze
flutter test
```

API tests dùng PostgreSQL emulator pg-mem trong bộ nhớ, không gửi email thật và không gọi Google. Cần smoke test lại với Render PostgreSQL thật sau deploy; test thay thế không chứng minh tương thích SQL hoàn toàn.

## Kiểm tra trên điện thoại + Render

1. Đăng ký email mới; OTP sai bị từ chối, đúng được vào phụ huynh. Dùng lại mã bị từ chối. Đợi 5 phút mã hết hạn. Kiểm tra khóa sau 5 lần sai.
2. Đăng nhập username + password sai không gửi OTP; đúng gửi email. Kiểm tra tên trùng/email trùng và lỗi mạng.
3. Google consent → callback → vào phụ huynh. Hủy trình duyệt không tạo phiên. Email tài khoản mật khẩu không tự được liên kết Google.
4. Bootstrap admin, cấp staff/child. Đăng nhập từng tài khoản, kiểm tra chuyển trang đúng vai trò.
5. Phụ huynh A tạo/sửa/xóa trẻ và thiết bị; phụ huynh B dùng ID A bị 404. Staff không được đọc dữ liệu riêng. Xóa cần xác nhận.
6. Liên kết email trẻ; trẻ chỉ thấy hồ sơ đã liên kết, không sửa/xóa trẻ hoặc thiết bị.
7. Trẻ đề xuất mục tiêu +15 phút; phụ huynh duyệt, trẻ thấy trạng thái mới. Trẻ không tự duyệt được.
8. Sau OTP, bật vân tay. Đóng app rồi mở lại, dùng vân tay. Sai/hủy không vào. Tắt vân tay xóa token; đăng xuất cũng xóa. Sau 12 giờ cần OTP.
9. Android NFC bật, gắn thẻ, chạm đúng → có lịch sử, chạm khác → từ chối; hủy đóng phiên NFC; máy không hỗ trợ báo phù hợp.
10. Hai máy/cùng gia đình đọc dữ liệu server nhất quán sau refresh. Đổi mạng Wi-Fi sang 4G vẫn gọi HTTPS Render được.
11. Không có API_BASE_URL: hiển thị nhắc cấu hình, không chuyển sang localhost và không tạo dữ liệu giả.

## Trình tự demo 6–8 phút

Giới thiệu vấn đề → Flutter + Render architecture → đăng nhập OTP → CRUD trẻ/thiết bị → đăng nhập admin/staff/child → phụ huynh duyệt mục tiêu → vân tay → NFC check-in → giới hạn và hướng phát triển. Chuẩn bị hai tài khoản và thẻ trước giờ demo, không chiếu secret/email OTP thật lên video công khai.
