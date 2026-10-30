# Triển khai Render và chia sẻ cho nhóm

## 1. Chuẩn bị repository

Tạo repository GitHub riêng mang tên `PhamNguyenTuanDat_2380614580`. Đẩy **nội dung thư mục này** lên root repository: `frontend`, `backend`, `docs`, `render.yaml`. Không đẩy `.env`, mật khẩu SMTP, khóa Google hay `node_modules`.

```powershell
git init
git add .
git commit -m "Initial ChildGuard Flutter and API"
git branch -M main
git remote add origin https://github.com/TAI-KHOAN/PhamNguyenTuanDat_2380614580.git
git push -u origin main
```

Các giá trị `TAI-KHOAN`, `TEN-SERVICE-THAT` là chỗ cần thay, không phải tài nguyên đã tạo sẵn.

## 2. Render Blueprint

1. Đăng nhập Render, chọn **New → Blueprint**, kết nối repo GitHub vừa tạo.
2. Render đọc `render.yaml`, tạo PostgreSQL và Node Web Service. Nếu tên service đã tồn tại, đổi tên trong YAML trước khi tạo.
3. Nhập các biến bí mật khi Render yêu cầu. `DATABASE_URL` được liên kết từ PostgreSQL; `JWT_SECRET` tự sinh. Không dùng giá trị trong `.env.example` làm khóa thật.
4. `PUBLIC_URL`: URL HTTPS Render cấp cho Web Service, không có `/` cuối. Có thể cập nhật lại sau lần deploy đầu.
5. Backend tự tạo các bảng khi khởi động; `GET /health` phải trả `{"status":"ok"}`.
6. Dùng URL này để chạy/build Flutter; mọi thành viên trỏ về cùng một backend.

**SMTP và Render free:** các gói miễn phí có thể chặn outbound cổng SMTP 25/465/587. Kiểm tra chính sách hiện hành trước khi chọn gói. Để dùng SMTP của mã nguồn này, chọn gói Web Service có hỗ trợ outbound SMTP (ví dụ Starter), hoặc thay adapter `sendMail` bằng dịch vụ email qua HTTPS. Không tắt OTP để “chạy demo”. PostgreSQL free cũng có giới hạn thời hạn/lưu trữ; xem dashboard và nâng gói khi cần. Nếu `free` không còn được cấp cho tài khoản, đổi plan trong YAML sang gói khả dụng.

Nguồn chính thức: [Node trên Render](https://render.com/docs/deploy-node-express-app), [Blueprint](https://render.com/docs/blueprint-spec), [giới hạn free](https://render.com/docs/free).

## 3. Email OTP

Ví dụ Gmail: bật xác minh 2 bước và tạo App Password cho địa chỉ gửi; không dùng mật khẩu đăng nhập Gmail.

| Biến | Giá trị |
|---|---|
| SMTP_HOST | smtp.gmail.com hoặc nhà cung cấp của nhóm |
| SMTP_PORT | 587 (STARTTLS) hoặc 465 (TLS) |
| SMTP_USER | Email gửi |
| SMTP_PASSWORD | App Password/SMTP credential |
| SMTP_FROM | ChildGuard <email-gui@example.com> |

Kiểm tra thư rác; nếu SMTP lỗi, sửa cấu hình rồi đăng nhập lại để nhận mã mới. Tài khoản đăng ký nhưng gửi email thất bại vẫn có thể dùng đăng nhập mật khẩu để nhận OTP xác minh mới. Backend không trả mã OTP ra API/log.

## 4. Google OAuth 2.0

1. Google Cloud Console → tạo project → cấu hình OAuth consent screen, thêm test users nếu ứng dụng ở chế độ Testing.
2. Tạo OAuth client loại **Web application**, dùng phía backend.
3. Authorized redirect URI: `https://TEN-SERVICE-THAT.onrender.com/auth/google/callback`.
4. Điền `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`, `PUBLIC_URL` trên Render rồi redeploy.
5. Flutter mở trình duyệt hệ thống → Google → callback backend → one-time code về `childguard://auth`. Flutter đổi code lấy phiên bằng verifier được tạo trước khi mở trình duyệt. Access token của Google không được lưu ở điện thoại.
6. Nếu email đã có tài khoản mật khẩu, API yêu cầu dùng mật khẩu + OTP; không tự động liên kết tài khoản để tránh chiếm quyền qua liên kết email.

Không cần đặt Google client secret trong Flutter. Nếu Google từ chối callback, kiểm tra URL chính xác, consent test user và chế độ public/testing.

## 5. Quản trị đầu tiên

Đặt `BOOTSTRAP_ADMIN_EMAIL` thành email của người quản trị. Đăng ký/xác minh email qua ứng dụng, rồi restart service. Khi khởi động backend chỉ nâng quyền nếu email đã xác minh. Đăng nhập lại để vào trang admin. Xóa biến bootstrap sau khi thiết lập. Admin cấp quyền nhân viên hoặc trẻ cho các tài khoản đã đăng ký. Không có mật khẩu admin mặc định.

## 6. Máy nhóm

Cùng clone repository, dùng `flutter pub get` và chạy với cùng `--dart-define=API_BASE_URL=...`. Mỗi thành viên dùng tài khoản email riêng; dữ liệu các gia đình được tách theo tài khoản. Dùng điện thoại Android có vân tay đã đăng ký và NFC đã bật để thử hai tính năng. Android emulator thông thường không thể kiểm chứng NFC vật lý.

## 7. Xử lý sự cố

- Khởi động chậm: free service có thể ngủ; app đợi tối đa 60 giây, nhấn thử lại khi cần.
- OTP không đến: xem Render logs về SMTP và chính sách mạng của plan; không dán secret vào báo cáo.
- 401: phiên 12 giờ hết hạn; đăng nhập lại bằng mật khẩu + OTP.
- NFC không đọc: bật NFC, tháo ốp, thử thẻ ISO14443A có UID cố định; UID ngẫu nhiên không phù hợp.
- Vân tay không có: kiểm tra phần cứng và đăng ký vân tay trong Android Settings.
- Migration: schema hiện tại chỉ bootstrap; khi phát triển tiếp phải viết migration có phiên bản trước khi thay cấu trúc bảng có dữ liệu.
