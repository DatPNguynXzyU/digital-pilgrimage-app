# BÁO CÁO ĐỒ ÁN LẬP TRÌNH DI ĐỘNG

**Sinh viên:** Phạm Nguyễn Tuấn Đạt — **MSSV:** 2380614580  
**Project:** PhamNguyenTuanDat_2380614580  
**Đề tài:** App quản lý điện thoại trẻ em — ChildGuard

## 1. Mục tiêu

Giúp phụ huynh quản lý hồ sơ trẻ và điện thoại, lên kế hoạch thời gian số, cùng trẻ đặt mục tiêu tích cực và ghi nhận check-in bằng NFC. Giao diện Flutter Material 3, tiếng Việt, bố cục thẻ, tông xanh lá dịu, điều hướng Tổng quan/Tài khoản và xử lý trạng thái trống/tải/lỗi.

## 2. Công nghệ sử dụng

| Thành phần | Công nghệ | Công dụng |
|---|---|---|
| Di động | Flutter SDK, Dart | Toàn bộ giao diện và logic ứng dụng Android |
| UI | Material 3 | Theme, biểu mẫu, dialog, navigation, cards |
| HTTP | package http | Gọi REST API HTTPS trên Render |
| Vân tay | local_auth + Android BiometricPrompt | Mở lại phiên đã được xác thực OTP |
| Lưu phiên | flutter_secure_storage / Android Keystore | Cất token tùy chọn khi bật vân tay |
| NFC | nfc_manager | Đọc UID thẻ NFC, băm SHA-256 trước khi gửi |
| OAuth UI | flutter_web_auth_2 | Mở Google OAuth bằng trình duyệt hệ thống |
| Backend | Node.js 22, Express 5 | REST API tập trung dùng chung cho nhóm |
| Database | PostgreSQL, pg | Lưu người dùng, OTP, trẻ, thiết bị, thỏa thuận, check-in |
| Xác thực | bcryptjs, JSON Web Token, crypto | Băm mật khẩu, token 12 giờ, OTP ngẫu nhiên an toàn |
| OAuth 2.0 | Google Authorization Code, OpenID Connect userinfo | Đăng ký/đăng nhập Google qua backend |
| Email | Nodemailer, SMTP | Gửi email OTP 6 số |
| Bảo vệ API | Helmet, express-rate-limit, Zod | Headers, giới hạn yêu cầu, kiểm tra dữ liệu |
| Hosting | Render Web Service + Render PostgreSQL | API HTTPS công khai, không localhost |
| Kiểm thử | node:test, Supertest, pg-mem; flutter analyze/test | Kiểm thử API và kiểm tra Flutter |
| Quản lý mã | Git, GitHub, pubspec.lock, package-lock.json | Chia sẻ nhóm và cài thư viện nhất quán |

Phiên bản cụ thể của thư viện được khóa trong các lockfile. Kotlin chỉ là lớp khởi động Android do Flutter yêu cầu (`FlutterFragmentActivity` để gọi sinh trắc học); không xây dựng giao diện bằng SDK di động khác.

## 3. Đối chiếu yêu cầu

| Yêu cầu | Cách triển khai | Điều kiện/phạm vi |
|---|---|---|
| Đăng ký email | username, email, mật khẩu, OTP xác minh | Cần SMTP hoạt động |
| Đăng ký bên thứ ba | Google OAuth 2.0 xử lý trên backend | Cần Google client và callback Render |
| Đăng nhập | username/email + mật khẩu + email OTP | OTP 5 phút, tối đa 5 lần thử |
| Phân quyền | admin, staff, parent, child | Backend kiểm tra role và chủ sở hữu |
| CRUD | Hồ sơ trẻ, thiết bị | Tạo/xem/sửa/xóa từ Flutter, lưu PostgreSQL |
| Vân tay | Mở phiên đã xác thực OTP | Thiết bị Android thật, vân tay đã đăng ký |
| NFC | Gắn UID thẻ, check-in, lịch sử | Phần cứng NFC và thẻ hỗ trợ |
| Tính năng đề xuất | Thỏa thuận thời gian số, phụ huynh duyệt phút thưởng | Chưa khẳng định độc quyền trên thị trường |
| Dễ dùng, cả nhóm chạy | Flutter frontend + API backend + Blueprint + hướng dẫn | Cần deploy và cấu hình tài khoản dịch vụ |

Theo chỉ định, chỉ làm vân tay và NFC, không QR/Barcode và không các mục a/b/c/d/f. Yêu cầu “3 trong 6 chức năng” của đề gốc chưa được đáp ứng theo cách đọc chọn ba mục riêng biệt; cần thống nhất với giảng viên. Không tự bổ sung tính năng ngoài lựa chọn của sinh viên.

## 4. Kiến trúc và dữ liệu

Flutter → HTTPS → Express REST API → PostgreSQL. Express gọi SMTP và Google OAuth. Android cung cấp BiometricPrompt và NFC. Dữ liệu lưu ở server, không phụ thuộc máy một thành viên.

Các bảng: `users`, `challenges`, `children`, `devices`, `agreements`, `checkins`, `child_links`. Xóa trẻ cascade thiết bị/thỏa thuận/check-in/liên kết. Email, username và UID đã gắn có ràng buộc duy nhất. Không lưu ảnh hay mẫu vân tay.

## 5. Luồng chính

Đăng ký mặc định phụ huynh → xác minh email → vào trang phụ huynh. Lần đăng nhập sau gửi OTP sau khi mật khẩu đúng. Admin cấp vai trò trên server; không nhận role từ payload đăng ký. Nhân viên xem số liệu tổng hợp. Trẻ chỉ đọc hồ sơ được liên kết, đề xuất thỏa thuận và check-in. Phụ huynh quản lý trẻ thuộc gia đình mình, không truy cập gia đình khác bằng cách đổi ID.

Vân tay là cơ chế mở lại token đã lưu, không thay OTP bằng chứng minh mật mã với server. Khi token hết hạn, cần OTP mới. NFC UID chỉ là định danh check-in, không phải yếu tố đăng nhập an toàn và có thể bị sao chép; không suy luận vị trí của trẻ từ lượt chạm.

## 6. Điểm mới đề xuất

“Thỏa thuận thời gian số”: trẻ tự đề xuất mục tiêu (ví dụ đọc sách 30 phút), phụ huynh duyệt/từ chối phần thưởng thời gian. Hướng tới đối thoại và xây thói quen, thay vì chỉ cấm đoán. Màn hình hiển thị tổng phút thưởng được duyệt. Chưa có cơ chế reset theo ngày hoặc tiêu thụ phần thưởng và chưa tự áp dụng vào hệ điều hành. Đây là điểm khác biệt của đồ án, **không có nghiên cứu thị trường đủ để tuyên bố các app hiện tại chưa từng có**.

## 7. Giới hạn và hướng phát triển

Bản này quản lý hồ sơ/kế hoạch, chưa phải sản phẩm kiểm soát điện thoại hoàn chỉnh. Chưa đo usage thực, chặn package, khóa màn hình, thiết lập Device Owner, foreground service hay đồng bộ lệnh xuống máy trẻ. Không giả lập số liệu sử dụng hoặc tình trạng online. Các phần này cần agent Android có sự đồng ý của phụ huynh và trẻ, quyền hệ thống phù hợp và kiểm thử trên thiết bị thật. Sau này có thể bổ sung migration, phân trang đầy đủ, thu hồi phiên server, phục hồi mật khẩu, nhật ký quản trị và cơ chế NFC chống sao chép nếu cần.

Chưa triển khai lên tài khoản Render của sinh viên theo lựa chọn tự triển khai. SMTP/Google OAuth/vân tay/NFC cần xác nhận end-to-end sau khi cấu hình dịch vụ và có phần cứng. Xem `TEST_PLAN.md` và `VERIFICATION.md` để biết kết quả kiểm tra thực tế.
