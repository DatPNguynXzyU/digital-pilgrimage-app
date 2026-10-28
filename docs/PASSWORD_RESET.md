> Cấu trúc mới (27/10/2026): ứng dụng Flutter nằm trong `client/`. Chạy các lệnh `flutter`, thao tác `android/`, `ios/`, `lib/`, `test/`, `images/` và `firebase-config*.json` từ thư mục `client/`. Backend và script vận hành vẫn ở gốc repository. Xem [cấu trúc dự án](CAU_TRUC_DU_AN.md).

# Quên mật khẩu

Màn hình đăng nhập có nút Quên mật khẩu, điền sẵn email đang nhập. Người dùng gửi yêu cầu; Firebase gửi liên kết mở trang đặt lại mật khẩu mặc định trên trình duyệt. Sau khi lưu mật khẩu mới, quay lại app đăng nhập. Không tạo phiên đăng nhập khi gửi email và không yêu cầu mật khẩu cũ.

Ứng dụng gọi Firebase `sendPasswordResetEmail`, giữ thông báo chung cho địa chỉ không tồn tại và chặn gửi lại 60 giây trên màn hình sau yêu cầu thành công. Đây là giới hạn giao diện, không thay thế quota Firebase. Các lời gọi trực tiếp Firebase không đi qua Redis/backend limiter.

## Cấu hình

- Build với firebase-config.json của môi trường đang dùng; không cần backend endpoint hoặc biến môi trường mới.
- Firebase Authentication phải bật Email/Password. Templates → Password reset: kiểm tra tên app, sender, tiêu đề, nội dung và action handler mặc định. Không thay cấu hình live trong lần triển khai mã này.
- Tài khoản chỉ nằm ở MongoDB legacy chưa có Firebase identity không đặt lại mật khẩu bằng Firebase được; cần quy trình di chuyển/khôi phục legacy riêng. Không tự tạo hoặc gộp tài khoản dựa vào email.
- Google: người dùng vẫn có thể tiếp tục đăng nhập bằng Google; reset của ứng dụng không đổi mật khẩu Google.

## Kiểm thử thực tế trước phát hành

1. Email không hợp lệ bị chặn; email có khoảng trắng được chuẩn hóa.
2. Tài khoản Firebase mật khẩu nhận thư, mở link trên trình duyệt, đặt mật khẩu mới; mật khẩu cũ thất bại, mật khẩu mới đăng nhập được.
3. Dùng lại link đã dùng hoặc link hết hạn: Firebase từ chối, yêu cầu gửi link mới.
4. Kiểm tra thư rác, lỗi mạng, gửi quá nhiều, email không tồn tại; không công bố địa chỉ có tồn tại hay không.
5. Gửi đang chờ không gửi trùng; rời màn hình không lỗi; sau 60 giây gửi lại được.
6. Phiên trên thiết bị khác sau reset bị backend từ chối theo xác minh Firebase revoked tokens; người dùng phải đăng nhập lại. Xác minh với project thật, không chỉ mock UI.

Kiểm thử tự động: `flutter test test/forgot_password_test.dart`. Test giao diện dùng callback giả, không gửi email thật. Tham khảo https://firebase.google.com/docs/auth/flutter/manage-users#send_a_password_reset_email.
