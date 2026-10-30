# Swagger API

- Local: http://localhost:3000/api-docs/
- Render (sau khi triển khai code này): https://digital-pilgrimage-api.onrender.com/api-docs/
- OpenAPI JSON: `/api-docs.json` trên cùng máy chủ; có thể nhập vào Postman.

Chạy backend như bình thường: vào `backend`, chạy `npm ci`, cấu hình môi trường và `npm start`. Swagger không cần biến môi trường mới. Các tài nguyên UI được phục vụ từ thư viện trong backend, không phụ thuộc CDN.

## Thử API

1. Mở nhóm API, chọn endpoint rồi chọn **Try it out** → **Execute**.
2. API công khai không cần đăng nhập.
3. Với Firebase: đăng nhập bằng ứng dụng/SDK, lấy Firebase ID token mới, gửi token thô trong `idToken` tới `POST /api/auth/firebase`.
4. Sao chép trường `token` trả về (bao gồm `firebase:`), nhấn **Authorize** và dán nguyên giá trị. Không nhập thêm chữ `Bearer`. Tài khoản legacy có thể dùng token từ `/api/auth/login`.
5. API quản trị yêu cầu tài khoản có role `admin` trong MongoDB. Swagger không cấp thêm quyền.

Try it out gọi API thật: tạo lịch, đổi mật khẩu, check-in, đăng ký hoặc vô hiệu hóa thẻ đều có thể thay đổi dữ liệu. Dùng tài khoản/thẻ thử nghiệm. Token không được lưu bền trong Swagger khi tải lại trang. Không chia sẻ token hoặc private key.

Đăng ký Firebase, gửi lại email xác minh và quên mật khẩu thực hiện qua Firebase SDK, không phải qua các endpoint legacy. Không nhập mật khẩu Google vào Swagger.

## Bảo trì

Định nghĩa OpenAPI: `backend/src/config/openapi.js`. Khi thay đổi routes hoặc payload, cập nhật tài liệu cùng thay đổi đó. Kiểm tra bằng `node --test test/openapi.test.js` từ thư mục backend. Render chỉ có đường dẫn Swagger sau khi bản code này được đưa lên nhánh triển khai và deploy thành công.
