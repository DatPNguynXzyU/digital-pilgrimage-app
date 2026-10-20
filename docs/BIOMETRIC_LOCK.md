# Khóa ứng dụng bằng sinh trắc học

Đăng nhập bằng email/mật khẩu, vào Cá nhân và bật “Khóa bằng vân tay /
sinh trắc học”. Điện thoại phải có sinh trắc học đã đăng ký. Cần xác thực
thành công để bật hoặc tắt công tắc. Hệ điều hành chọn phương thức khả dụng
(vân tay hoặc khuôn mặt); ứng dụng không đọc hay gửi mẫu sinh trắc học.

Đây là khóa giao diện cục bộ, không phải phương thức đăng nhập mới trên
backend, không gia hạn JWT và không thay thế kiểm tra quyền tại API.
Cơ chế lưu JWT hiện có vẫn dùng SharedPreferences, chưa phải kho khóa
phần cứng gắn với sinh trắc học. Không coi lớp khóa này là bảo vệ dữ liệu
trước thiết bị bị root hoặc việc trích xuất dữ liệu ứng dụng.

Đăng xuất, đổi mật khẩu thành công hoặc phiên bị vô hiệu hóa sẽ tắt tùy chọn.
Nếu không xác thực được, chọn “Đăng xuất để dùng mật khẩu” để xóa phiên,
sau đó đăng nhập lại trong Cá nhân.

## Kiểm thử trên điện thoại

1. Cài APK mới; đăng nhập rồi bật công tắc và quét vân tay đúng.
2. Ra màn hình chính rồi mở lại app: nội dung phải bị che.
3. Hủy hộp thoại hoặc dùng ngón tay sai: nội dung vẫn bị khóa.
4. Dùng vân tay đúng: nội dung xuất hiện, điều hướng hoạt động bình thường.
5. Tắt hẳn tiến trình app và mở lại: phải yêu cầu mở khóa.
6. Thử tùy chọn đăng xuất trên màn hình khóa: không còn phiên cũ.
7. Thử máy chưa đăng ký vân tay: bật công tắc thất bại với thông báo.
8. Đổi mật khẩu: phiên cũ và tùy chọn khóa được xóa.
9. Sau khi chuyển Activity Android, kiểm tra lại NFC và chọn ảnh đại diện.

Android dùng FlutterFragmentActivity, USE_BIOMETRIC và theme AppCompat.
iOS có mô tả quyền Face ID nhưng cần build và kiểm thử riêng trên macOS/iPhone.
