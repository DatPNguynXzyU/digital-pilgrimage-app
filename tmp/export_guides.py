from pathlib import Path
p=Path('D:/PhamNguyenTuanDat_2380614580/docs')
(p/'BAO_CAO_LUONG_HOAT_DONG.md').write_text('''# BÁO CÁO LUỒNG HOẠT ĐỘNG — CHILDGUARD

**Sinh viên:** Phạm Nguyễn Tuấn Đạt  
**MSSV:** 2380614580  
**Project:** PhamNguyenTuanDat_2380614580  
**Ngày lập:** 29/10/2026  
**Đề tài:** Ứng dụng quản lý điện thoại trẻ em

## 1. Mục tiêu và kiến trúc

ChildGuard hỗ trợ phụ huynh quản lý hồ sơ trẻ, thiết bị, kế hoạch thời gian số, thỏa thuận tích cực, NFC check-in và vị trí được trẻ chủ động chia sẻ.

```mermaid
flowchart LR
    U[Người dùng] --> F[Flutter Android]
    F -->|HTTPS REST API| B[Node.js / Express trên Render]
    B --> D[(Render PostgreSQL)]
    B --> E[Resend HTTPS API: email OTP]
    F --> G[Trình duyệt Google OAuth]
    G --> B
    F --> H[Sinh trắc học / NFC / GPS của Android]
```

Giao diện và logic ứng dụng được viết bằng Dart/Flutter; các package Flutter gọi phần cứng Android. Android SDK phục vụ biên dịch APK. Backend là dịch vụ độc lập dùng chung cho các thành viên.

## 2. Vai trò

| Vai trò | Quyền chính |
|---|---|
| Admin | Xem tài khoản, đổi vai trò parent/child/staff, xem thống kê |
| Nhân viên | Xem số liệu tổng hợp; không đọc hồ sơ gia đình khác |
| Phụ huynh | CRUD hồ sơ trẻ, thiết bị; liên kết trẻ; duyệt thỏa thuận; gắn NFC; xem vị trí |
| Trẻ em | Xem hồ sơ liên kết; đề xuất thỏa thuận; NFC check-in; gửi/xóa vị trí của mình |

Backend kiểm tra quyền trên từng yêu cầu, không chỉ ẩn nút trên giao diện. Role được lấy từ database. Đăng ký mới mặc định parent; admin cấp role khác. Admin không đổi quyền chính mình hoặc admin khác qua chức năng hiện tại.

## 3. Đăng ký email

1. Người dùng nhập họ tên, username, email, mật khẩu.
2. Flutter gửi POST /auth/register.
3. Backend kiểm tra dữ liệu và tính duy nhất, băm mật khẩu bằng bcrypt, lưu tài khoản chưa xác minh.
4. Backend sinh OTP 6 số bằng bộ sinh ngẫu nhiên an toàn, chỉ lưu SHA-256 của OTP.
5. Resend gửi email. OTP có hiệu lực 5 phút, tối đa 5 lần sai.
6. Flutter gửi challengeId và OTP đến POST /auth/otp.
7. Backend kiểm tra, tiêu thụ mã một lần, xác minh email và trả token cùng thông tin user.
8. Flutter điều hướng theo role.

Mật khẩu không lưu dạng rõ. OTP không trả ra API hoặc ghi log. Nếu gửi email thất bại sau khi tài khoản đã tạo, người dùng đăng nhập bằng mật khẩu để yêu cầu OTP mới.

## 4. Đăng nhập mật khẩu + OTP

```mermaid
flowchart TD
    A[Nhập username/email và mật khẩu] --> B{Mật khẩu đúng?}
    B -->|Không| C[Báo lỗi]
    B -->|Có| D[Gửi OTP email]
    D --> E[Nhập OTP]
    E --> F{Mã đúng, chưa hết hạn và chưa khóa?}
    F -->|Không| G[Từ chối; nhập lại hoặc yêu cầu mã mới]
    F -->|Có| H[Cấp token 12 giờ]
    H --> I[Điều hướng theo vai trò]
```

Token được gửi trong Authorization: Bearer ở các API có bảo vệ. Khi user đã bị xóa hoặc token hết hạn, backend từ chối truy cập. Đăng xuất xóa token tại thiết bị; chưa có cơ chế thu hồi mọi token phía server.

## 5. Google OAuth 2.0

1. Flutter tạo verifier ngẫu nhiên, gửi SHA-256 verifier đến /auth/google/start.
2. Backend lưu state một lần, chuyển tới Google với scope openid email profile.
3. Người dùng chọn tài khoản và đồng ý; Google trả code về callback HTTPS trên Render.
4. Backend kiểm tra state, đổi code và lấy email đã xác minh từ Google.
5. Nếu email mới, tạo user parent. Nếu email đã tồn tại, giữ nguyên user và role.
6. Backend chuyển one-time exchange code về childguard://auth, không đưa token phiên vào URL.
7. Flutter gửi exchange code và verifier tới backend.
8. Với tài khoản có mật khẩu: backend gửi OTP; Flutter yêu cầu OTP trước khi cấp phiên. Với tài khoản Google không có mật khẩu: backend cấp phiên.

Callback: https://phamnguyentuandat-2380614580-api.onrender.com/auth/google/callback

Đây là verifier bảo vệ đoạn trao đổi giữa ứng dụng và backend; không mô tả là Google PKCE nếu chưa triển khai code_challenge cho đoạn Google. Client Secret chỉ đặt ở Render. Google Testing cần thêm người thử khi áp dụng. Client loại Web application vì backend xử lý trao đổi mã.

## 6. Mở phiên bằng khuôn mặt/vân tay

Đăng nhập thành công → vào Tài khoản → bật sinh trắc học → xác thực Android → lưu token trong flutter_secure_storage. Lần mở app sau, người dùng chọn mở bằng khuôn mặt/vân tay → local_auth gọi hộp thoại Android → nếu thành công đọc token đã lưu → gọi /me → vào màn hình tương ứng.

Không lưu ảnh mặt hoặc mẫu vân tay vào database. Đây là mở lại phiên đã xác thực, không phải nhận diện khuôn mặt bằng camera/AI riêng hay xác thực danh tính khuôn mặt trên server. Android quyết định phương thức sinh trắc khả dụng. Một số máy có mở khóa mặt nhưng không cho ứng dụng dùng; cần kiểm chứng trên thiết bị mục tiêu trước khi khẳng định đạt mục a. Token hết hạn sau 12 giờ cần đăng nhập mới. Đăng xuất/tắt sinh trắc xóa token lưu trên máy.

## 7. CRUD trẻ và thiết bị

Phụ huynh tạo trẻ (tên, tuổi 1–17, giới hạn 15–1440 phút/ngày) → backend gắn parent_id theo người đăng nhập → lưu PostgreSQL. Danh sách chỉ trả hồ sơ thuộc phụ huynh hoặc trẻ đã liên kết. Sửa/xóa cần parent sở hữu. Xóa trẻ cascade thiết bị, thỏa thuận, check-in, vị trí và liên kết.

Thiết bị hỗ trợ tạo/xem/đổi tên/xóa trong hồ sơ trẻ. Đây là hồ sơ thiết bị, chưa phải ghép nối phần cứng hay điều khiển điện thoại từ xa.

## 8. Liên kết trẻ và thỏa thuận

Trẻ đăng ký/xác minh → admin cấp role child → phụ huynh nhập email trẻ tại Liên kết trẻ → backend tạo child_links. Mỗi tài khoản trẻ gắn một hồ sơ theo ràng buộc hiện tại.

Trẻ/phụ huynh nhập mục tiêu và phút thưởng 1–120 → lưu trạng thái pending → phụ huynh duyệt approved hoặc rejected. Trẻ không được tự duyệt. Giao diện cộng các phần thưởng approved để hiển thị; chưa có reset theo ngày, tiêu thụ hoặc áp dụng phần thưởng vào hệ điều hành.

## 9. NFC check-in

Phụ huynh chọn Gắn thẻ → NFC đọc UID → Flutter băm SHA-256 → server lưu nfc_hash duy nhất. Khi check-in, app đọc và băm lại UID, server kiểm tra quyền gia đình và hash khớp → thêm bản ghi checkins → trả lịch sử.

UID thẻ có thể bị sao chép; NFC check-in không phải chứng minh danh tính hoặc vị trí. Không triển khai QR/Barcode.

## 10. Chia sẻ vị trí chủ động

```mermaid
flowchart TD
    A[Trẻ đã liên kết mở hồ sơ] --> B[Chọn chia sẻ vị trí]
    B --> C{Đồng ý và cấp quyền?}
    C -->|Không| D[Không gửi vị trí]
    C -->|Có| E[Lấy GPS hiện tại và độ chính xác]
    E --> F[PUT vị trí qua HTTPS]
    F --> G[Kiểm tra child_links; lưu tọa độ mới nhất]
    G --> H[Phụ huynh làm mới và xem bản đồ]
    G --> I[Trẻ chọn ngừng và xóa]
    I --> J[Xóa tọa độ trên server]
```

Chỉ tài khoản child đã liên kết được gửi/xóa vị trí. Chỉ phụ huynh sở hữu hoặc trẻ liên kết được đọc. Admin/staff không có quyền đọc vị trí gia đình chỉ nhờ role. Chưa có theo dõi nền hoặc cập nhật liên tục. Bản đồ thể hiện vị trí lần gửi cuối, thời điểm server nhận và độ chính xác; không mặc định là vị trí hiện tại.

API GET/PUT/DELETE /children/:id/location; dữ liệu lưu ở shared_locations. Mỗi lần gửi thay bản trước; không có lịch sử hành trình. Google Maps mở qua url_launcher khi người dùng chủ động chọn xem.

## 11. Dữ liệu và xử lý lỗi

Các bảng: users, challenges, children, devices, agreements, checkins, child_links, shared_locations. API trả 400 khi dữ liệu sai, 401 khi chưa đăng nhập, 403 khi thiếu quyền, 404 khi không có tài nguyên thuộc quyền, 409 khi trùng và 503 khi dịch vụ email chưa sẵn sàng.

Flutter hiển thị trạng thái đang tải, dữ liệu trống, lỗi và thao tác làm mới. GPS bị từ chối hoặc tắt sẽ báo nguyên nhân; không tự gửi tọa độ giả. Render Free có thể khởi động chậm sau thời gian không hoạt động.

## 12. Công nghệ và phạm vi kiểm chứng

Flutter/Dart, Material 3, http, flutter_secure_storage, local_auth, nfc_manager (bản vá build nội bộ), flutter_web_auth_2, crypto, geolocator, url_launcher; Node.js/Express, PostgreSQL/pg, bcryptjs, JWT, Zod, Helmet, express-rate-limit, Resend HTTPS; Git/GitHub và Render.

Phiên bản cụ thể xem pubspec.lock và package-lock.json. Backend hiện đạt 10 kiểm thử tự động (PostgreSQL emulator pg-mem, không phải DB Render thật); Flutter analyze cho lib/test không báo lỗi, widget test đạt, APK debug build thành công. Chưa kiểm chứng toàn bộ Google/OTP/GPS/NFC/khuôn mặt trên thiết bị thật sau các thay đổi mới nhất. Chia sẻ vị trí cần deploy backend mới; không suy ra rằng mã trên máy đã tự có trên Render.

Ứng dụng chưa đo usage, chặn ứng dụng, khóa máy từ xa hoặc quản lý Device Owner. Giới hạn thời gian là kế hoạch. Báo cáo không khẳng định thỏa thuận là tính năng chưa từng tồn tại trên thị trường.
''',encoding='utf8')
(p/'HUONG_DAN_SU_DUNG.md').write_text('''# HƯỚNG DẪN SỬ DỤNG CHILDGUARD

**Project:** PhamNguyenTuanDat_2380614580  
**Cập nhật:** 29/10/2026

## 1. Chuẩn bị

Cài APK mới trên Android 7 trở lên, có Internet. NFC cần điện thoại hỗ trợ NFC và thẻ phù hợp. Sinh trắc cần đã đăng ký trong cài đặt Android. Chia sẻ vị trí cần bật dịch vụ vị trí và cấp quyền khi app yêu cầu. Backend mới phải được deploy trước khi dùng tính năng mới.

Backend: https://phamnguyentuandat-2380614580-api.onrender.com  
Kiểm tra: thêm /health; kết quả mong đợi {"status":"ok"}. Backend Free có thể cần thời gian khởi động; thử lại nếu lần đầu chậm.

## 2. Tạo tài khoản email

1. Mở app → Chưa có tài khoản? Đăng ký.
2. Nhập họ tên, email thật, username 3–32 ký tự chữ/số/gạch dưới, mật khẩu tối thiểu 10 ký tự.
3. Bấm Đăng ký, kiểm tra hộp thư và thư rác.
4. Nhập OTP 6 số trong 5 phút → Xác thực & tiếp tục.
5. Tài khoản mới vào vai trò phụ huynh.

Không chia sẻ OTP. Sau 5 lần sai cần mã mới. Nếu đăng ký đã tạo tài khoản nhưng email gửi lỗi, quay lại đăng nhập bằng username/mật khẩu để xin OTP mới.

**Resend thử nghiệm:** sender onboarding@resend.dev chỉ gửi tới email tài khoản Resend. Muốn các thành viên nhận OTP cần cấu hình domain gửi đã xác minh. Không thể xử lý giới hạn này chỉ bằng đổi email trong app.

## 3. Đăng nhập

### Username/email + mật khẩu
Nhập thông tin → Đăng nhập với OTP → nhận email → nhập OTP → vào app. Mật khẩu đúng chưa đủ để hoàn tất đăng nhập.

### Google
Bấm Tiếp tục với Google → chọn tài khoản → hoàn tất Google → app mở lại. Tài khoản Google mới được tạo phụ huynh. Nếu email đã có tài khoản mật khẩu, phiên bản mới chuyển về nhập OTP để vào tài khoản cũ, giữ nguyên role và dữ liệu.

Nếu trang trình duyệt báo “Email đã có tài khoản mật khẩu”, Render đang chạy phiên bản cũ; cập nhật backend và APK tương ứng. Nếu redirect_uri_mismatch, kiểm tra callback Google đúng URL /auth/google/callback. Google thử nghiệm có thể yêu cầu email thuộc Test users.

### Khuôn mặt/vân tay
1. Đăng nhập bằng phương thức bình thường.
2. Tài khoản → Bật khuôn mặt / vân tay → xác thực trên hộp thoại Android.
3. Lần sau mở app → Mở bằng khuôn mặt / vân tay.
4. Android chọn phương thức hỗ trợ; app kiểm tra phiên server trước khi vào.

Không phải Android nào cũng hỗ trợ khuôn mặt cho app; mở khóa mặt của màn hình khóa không bảo đảm tính năng này. Chưa có nhận diện camera riêng. Nếu không hỗ trợ/hủy/hết phiên, dùng Google hoặc mật khẩu + OTP. Tắt sinh trắc hoặc Đăng xuất sẽ xóa token lưu. Token có hiệu lực 12 giờ.

## 4. Vai trò và màn hình

| Vai trò | Màn hình và thao tác |
|---|---|
| Phụ huynh | Tổng quan gia đình, thêm trẻ và mở hồ sơ |
| Trẻ em | Hồ sơ được phụ huynh liên kết |
| Nhân viên | Thống kê tổng hợp |
| Admin | Thống kê, danh sách tài khoản và quản lý vai trò |

Tab Tài khoản hiển thị người dùng, role, thiết lập sinh trắc và đăng xuất. Nút làm mới cập nhật dữ liệu server; không cần đóng app.

## 5. Dành cho phụ huynh

### Thêm/sửa/xóa trẻ
Tổng quan → Thêm trẻ → nhập tên, tuổi 1–17 và giới hạn 15–1440 phút/ngày → Lưu. Bấm thẻ trẻ để vào chi tiết, chọn Sửa hồ sơ để đổi thông tin. Xóa hồ sơ trẻ cần xác nhận và xóa theo thiết bị, thỏa thuận, check-in, vị trí, liên kết.

Giới hạn là kế hoạch gia đình, chưa chặn ứng dụng hoặc đo thời gian thực.

### Quản lý thiết bị
Trong hồ sơ → Thiết bị của con → dấu + → nhập tên điện thoại. Bấm thiết bị để đổi tên, bấm thùng rác để xóa và xác nhận. Đây là hồ sơ điện thoại, chưa điều khiển được máy trẻ.

### Liên kết trẻ
1. Trẻ đăng ký và xác minh tài khoản.
2. Admin đổi vai trò tài khoản đó thành Trẻ em.
3. Phụ huynh mở đúng hồ sơ → Liên kết trẻ → nhập email tài khoản trẻ.
4. Trẻ đăng nhập/làm mới để thấy hồ sơ liên kết.

### Duyệt thỏa thuận
Mở Thỏa thuận tích cực → dấu + → nhập mục tiêu và phút thưởng. Khi có đề xuất, phụ huynh chọn Duyệt hoặc Từ chối. Có thể xóa thỏa thuận sau xác nhận. Tổng phút thưởng hiển thị từ các thỏa thuận đã duyệt; chưa tự cộng vào quyền sử dụng hệ điều hành.

### Gắn thẻ NFC
Bật NFC → vào hồ sơ → Gắn thẻ → đưa thẻ sát mặt sau điện thoại → đợi thông báo thành công. Thẻ đã gắn gia đình khác sẽ bị từ chối. Dùng Hủy để đóng phiên đọc.

### Xem vị trí
Trẻ gửi vị trí trước. Trong hồ sơ → Vị trí an tâm → Làm mới → xem thời gian/độ chính xác → Xem trên bản đồ. Đây là lần gửi gần nhất, không phải giám sát trực tiếp. Nếu chưa có chia sẻ, app hiển thị trạng thái trống.

## 6. Dành cho trẻ

Đăng nhập tài khoản role Trẻ em đã liên kết → mở hồ sơ:

- Đề xuất mục tiêu tại Thỏa thuận tích cực; phụ huynh quyết định duyệt.
- Chọn Check-in NFC và chạm thẻ đã gắn. Thẻ sai bị từ chối; lượt hợp lệ xuất hiện trong lịch sử.
- Chọn Chia sẻ vị trí hiện tại → đọc thông báo → Đồng ý chia sẻ → cấp quyền vị trí nếu muốn. App gửi tọa độ của **điện thoại đang thao tác**.
- Khi muốn gửi điểm mới, bấm chia sẻ lại. Không có theo dõi nền.
- Chọn Ngừng & xóa vị trí để xóa điểm đã chia sẻ khỏi server. Tắt quyền GPS đơn thuần không xóa điểm đã gửi trước đó.

Trẻ không được sửa/xóa hồ sơ hoặc thiết bị, tự duyệt phần thưởng hoặc xem hồ sơ gia đình khác.

## 7. Admin và nhân viên

Admin → Tổng quan → bấm tài khoản/biểu tượng quản lý → xem thông tin → chọn Phụ huynh, Trẻ em hoặc Nhân viên → xác nhận. Admin được bảo vệ khỏi đổi quyền tại đây. Không có chức năng xóa user trong app hiện tại; xóa trực tiếp DBeaver là thay đổi database thật và có thể cascade dữ liệu.

Nhân viên chỉ xem số lượng users/children/devices để hỗ trợ vận hành; không có quyền mặc định đọc vị trí hoặc hồ sơ riêng tư của gia đình khác.

## 8. Sự cố thường gặp

| Hiện tượng | Cách xử lý |
|---|---|
| OTP không tới | Kiểm tra spam, cấu hình Resend và giới hạn email thử nghiệm |
| Google kẹt trình duyệt | Cài APK mới, kiểm tra backend mới và callback Google |
| Vị trí báo API không tồn tại | Deploy backend có shared_locations rồi thử lại |
| Vị trí bị từ chối | Kiểm tra role child và liên kết hồ sơ; phụ huynh không được giả gửi vị trí của trẻ |
| Quyền GPS bị khóa | Mở cài đặt ứng dụng Android để cấp lại quyền |
| Không có khuôn mặt | Thiết bị có thể không cung cấp face biometric cho app; dùng vân tay/OTP |
| NFC không đọc | Bật NFC, kiểm tra phần cứng và thẻ, thay vị trí chạm |
| Không thấy dữ liệu mới | Bấm làm mới; kiểm tra đúng tài khoản và liên kết |
| Phiên hết hạn | Đăng nhập lại; token hết hạn sau 12 giờ |

## 9. Kịch bản demo

Chuẩn bị tài khoản admin, phụ huynh, trẻ; hai thiết bị nếu có; thẻ NFC; email được phép nhận OTP. Demo: đăng nhập → CRUD trẻ/thiết bị → admin cấp role → liên kết trẻ → trẻ đề xuất mục tiêu → phụ huynh duyệt → bật/thử sinh trắc trên máy hỗ trợ → NFC check-in → trẻ đồng ý chia sẻ vị trí → phụ huynh xem → trẻ ngừng/xóa → phụ huynh làm mới kiểm tra điểm biến mất.

Không quay mật khẩu, OTP, API key hoặc vị trí riêng tư thật trong video công khai. Có thể dùng tài khoản và địa điểm demo được các thành viên đồng ý.
''',encoding='utf8')
for name in ['BAO_CAO_LUONG_HOAT_DONG.md','HUONG_DAN_SU_DUNG.md']:
 text=(p/name).read_text(encoding='utf8')
 print(name, len(text), 'characters')
