# Kế hoạch cải thiện và phối hợp nhóm

Hành Trình An Nhiên | Cập nhật 21/10/2026

## 1. Cách sử dụng

Đây là danh sách đề xuất cải thiện và kiểm chứng, không phải kết luận rằng toàn bộ chức năng đang lỗi hoặc chưa tồn tại. Nhóm đọc code và tái hiện trước khi nhận việc. P0 ưu tiên trước, P1 tiếp theo, P2 sau khi luồng chính ổn định.

Mỗi hạng mục tạo một GitHub Issue; ghi người phụ trách, người review, nhánh và PR. Trạng thái dùng: Chưa nhận / Đang làm / Chờ review / Đã hoàn tất. Chỉ đánh dấu hoàn tất khi đạt tiêu chí và có bằng chứng kiểm thử.

Đợt đầu: luồng chính, quyền dữ liệu, Redis, NFC, lưu token và phát hành APK. Không yêu cầu mọi thành viên có quyền Firebase hoặc Render; quyền code và quyền quản trị hạ tầng là hai việc khác nhau.

## 2. Danh sách công việc

### CV-01 | P0 | Kiểm thử luồng chính trên điện thoại

Nội dung: Đăng ký email, xác minh, đăng nhập Google, quét NFC, nhận tem và xem lịch sử. Kiểm tra đổi mật khẩu và phiên cũ.

Khu vực cần rà soát: lib/services; lib/views; backend/test

Tiêu chí hoàn tất: Có bảng kết quả, ảnh bằng chứng; xác minh email bắt buộc; mỗi lần check-in hợp lệ xuất hiện đúng trong lịch sử.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-02 | P0 | Kiểm chứng Redis thật

Nội dung: Đo cache hit/miss, TTL, dữ liệu sau cập nhật và quota theo IP. Kiểm tra mất kết nối Redis.

Khu vực cần rà soát: backend/src/config/redis.js; middleware; docs/REDIS.md

Tiêu chí hoàn tất: Cache hết hạn đúng; 429 có Retry-After; cache lỗi vẫn đọc MongoDB; limiter lỗi trả 503; xác minh proxy trước bật production.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-03 | P0 | Quyền sở hữu dữ liệu

Nội dung: Thử dùng tài khoản A đọc, sửa, xóa lịch và dữ liệu cá nhân của B bằng cách thay ID.

Khu vực cần rà soát: backend/controllers, routes và middleware tương ứng

Tiêu chí hoàn tất: A không truy cập được dữ liệu B; có test cả thành công và bị từ chối; ID người dùng lấy từ phiên xác thực.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-04 | P0 | Lưu token an toàn

Nội dung: Rà soát token trong SharedPreferences; chuyển bí mật phiên sang kho bảo mật của hệ điều hành nếu đang lưu thường.

Khu vực cần rà soát: lib/services; cấu hình Android

Tiêu chí hoàn tất: Đăng xuất xóa phiên; mở lại app và khóa sinh trắc học hoạt động; không có token trong log hoặc bản sao cấu hình.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-05 | P1 | NFC và nhận tem trùng

Nội dung: Kiểm tra thẻ không hợp lệ, phát lại yêu cầu và nhiều yêu cầu đồng thời. UID thẻ tĩnh không tự chứng minh người dùng đang ở chùa.

Khu vực cần rà soát: Luồng NFC Flutter; API check-in; model tem

Tiêu chí hoàn tất: Test đồng thời không tạo tem trùng theo quy tắc nghiệp vụ; ghi rõ giới hạn chống sao chép và phương án xác minh bổ sung.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-06 | P1 | Quên mật khẩu và liên kết tài khoản

Nội dung: Hoàn thiện khôi phục mật khẩu; xử lý email đã tồn tại ở tài khoản cũ khi đăng nhập Google.

Khu vực cần rà soát: Firebase auth; auth controller; màn hình đăng nhập

Tiêu chí hoàn tất: Không gộp tài khoản chỉ dựa vào email; yêu cầu chứng minh quyền sở hữu; thông báo lỗi rõ; kiểm thử trường hợp xung đột 409.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-07 | P1 | Phát hành APK qua CI/CD

Nội dung: Chuẩn hóa versionCode, khóa ký release, artifact và ghi chú phiên bản. CI hiện build APK debug.

Khu vực cần rà soát: .github/workflows; android; docs/RELEASE_SIGNING.md

Tiêu chí hoàn tất: Release ký đúng khóa; cài cập nhật giữ dữ liệu; khóa nằm trong secrets; build PR không nhận secrets phát hành.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-08 | P1 | Bảo vệ nhánh main

Nội dung: Thiết lập PR, review và CI bắt buộc trước merge; kiểm tra ai có quyền triển khai.

Khu vực cần rà soát: GitHub repository settings và workflows

Tiêu chí hoàn tất: PR lỗi không merge được theo quy tắc nhóm; chỉ người có quyền duyệt mới thay cấu hình; có hướng dẫn xử lý khẩn cấp.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-09 | P1 | Môi trường staging

Nội dung: Tách dữ liệu thử khỏi production: MongoDB, Firebase, Redis và lưu ảnh.

Khu vực cần rà soát: Cấu hình triển khai và tài liệu nhóm

Tiêu chí hoàn tất: App test trỏ đúng môi trường; không dùng tài khoản hoặc database thật để chạy test phá dữ liệu.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-10 | P1 | Sao lưu và phục hồi

Nội dung: Lập cách sao lưu MongoDB, khóa ký và cấu hình; diễn tập phục hồi trên môi trường riêng.

Khu vực cần rà soát: Tài liệu vận hành; cấu hình backup

Tiêu chí hoàn tất: Khôi phục được dữ liệu mẫu; người giữ bản sao và thời gian phục hồi được ghi rõ; không commit backup chứa dữ liệu cá nhân.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-11 | P2 | Mạng yếu và khởi động chậm

Nội dung: Xử lý timeout, retry có giới hạn, hiển thị backend đang khởi động; cache nội dung công khai trên máy nếu cần.

Khu vực cần rà soát: API client Flutter; trạng thái màn hình

Tiêu chí hoàn tất: Mất mạng không treo màn hình; retry không nhân đôi check-in; không hiển thị nhầm dữ liệu người trước sau đăng xuất.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-12 | P2 | Phân trang và chỉ mục

Nội dung: Đo truy vấn danh sách chùa, kinh sách và lịch sử; bổ sung phân trang, index theo kết quả đo.

Khu vực cần rà soát: Controllers; Mongoose models; danh sách Flutter

Tiêu chí hoàn tất: Không tải toàn bộ dữ liệu lớn; thứ tự ổn định giữa các trang; có so sánh trước/sau với dữ liệu thử.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-13 | P2 | Theo dõi lỗi và hiệu năng

Nội dung: Thêm request ID, log có cấu trúc và số liệu latency/error/cache; phân loại lỗi client và server.

Khu vực cần rà soát: Backend middleware; hạ tầng log

Tiêu chí hoàn tất: Tra cứu được một yêu cầu xuyên luồng; không ghi token, mật khẩu, private key hoặc dữ liệu cá nhân không cần thiết.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-14 | P2 | Chuẩn hóa validation

Nội dung: Rà soát ID, ngày, độ dài chuỗi, loại/kích thước ảnh và định dạng lỗi API.

Khu vực cần rà soát: Routes/controllers; upload; API client

Tiêu chí hoàn tất: Input sai có phản hồi thống nhất; không lộ stack trace; Flutter hiển thị lỗi có thể xử lý.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-15 | P2 | Lịch và nhắc nhở

Nội dung: Kiểm tra lưu lịch, lặp lại, âm/dương lịch, múi giờ và thông báo sau khởi động lại máy.

Khu vực cần rà soát: Màn hình lịch; lưu lịch; notification

Tiêu chí hoàn tất: Có test quyền bị từ chối, đổi múi giờ, khởi động lại và hủy lịch; màn hình cài đặt không được coi là bằng chứng đã gửi thông báo.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-16 | P2 | Quản trị nội dung

Nội dung: Rà soát nhu cầu giao diện quản lý chùa, kinh, câu Phật ngôn và thẻ NFC; phân quyền quản trị và nhật ký thay đổi.

Khu vực cần rà soát: Admin API/UI nếu triển khai

Tiêu chí hoàn tất: Người thường không quản trị được; thao tác quan trọng ghi người thực hiện; có validation và quy trình cập nhật nội dung.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-17 | P2 | Quyền riêng tư và xóa tài khoản

Nội dung: Giải thích dữ liệu lưu; xác định cách xóa tài khoản cùng ảnh, lịch và liên kết Firebase.

Khu vực cần rà soát: Hồ sơ; backend; Firebase; Cloudinary

Tiêu chí hoàn tất: Có xác thực lại trước xóa; xác định xử lý tem/lịch sử theo chính sách; thông báo quyền thiết bị rõ ràng.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

### CV-18 | P2 | Trải nghiệm và hồ sơ bảo vệ đồ án

Nội dung: Kiểm tra cỡ chữ lớn, máy nhỏ, trạng thái rỗng/loading; cập nhật sơ đồ kiến trúc, API, báo cáo và minh chứng test.

Khu vực cần rà soát: lib/views; docs; tài liệu bàn giao

Tiêu chí hoàn tất: Không tràn giao diện; có checklist demo, hướng dẫn clone chạy và sơ đồ phản ánh hệ thống hiện hành.

Phụ trách: __________ | Review: __________ | Trạng thái: Chưa nhận

Issue / Nhánh / PR: __________________________________________

## 3. Quy trình đóng góp

1. Nhận Issue, mô tả cách tái hiện và thống nhất tiêu chí với người review.

2. Cập nhật main sạch, tạo nhánh riêng, sửa đúng phạm vi. Không sửa cấu hình production để thử nghiệm.

3. Chạy kiểm tra phù hợp; ghi lệnh, kết quả và ảnh/video nếu thay giao diện hoặc NFC.

4. Commit các file cụ thể, push nhánh, mở PR vào main. Chờ CI và review. Merge có thể kích hoạt CD lên backend thật.

5. Sau merge, kiểm tra bản triển khai, cập nhật Issue và tài liệu. Không đồng thời sửa cùng một file Word; cập nhật Markdown rồi đồng bộ Word khi cần.

## 4. Mẫu nội dung Pull Request

Issue: CV-__ / #__
Vấn đề và cách tái hiện: ...
Thay đổi và tác động người dùng: ...
Đã kiểm tra: lệnh + kết quả + bằng chứng
Cấu hình/migration cần bổ sung: ...
Cách quay lại phiên bản trước: ...

## 5. Điều kiện bàn giao

Không commit .env, token Upstash, Firebase Admin private key, mật khẩu keystore hoặc dữ liệu người dùng. Cấu hình client Firebase không thay thế khóa Admin. Chỉ chủ dự án hoặc người được cấp quyền mới thao tác hạ tầng.

Tài liệu setup đi kèm mô tả cách chạy máy cá nhân và test tách biệt. Không tự chạy seed hoặc test xóa dữ liệu trên database production.