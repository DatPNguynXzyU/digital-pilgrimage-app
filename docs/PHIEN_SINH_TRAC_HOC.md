# Ghi nhớ tài khoản và khôi phục bằng sinh trắc học

Đăng nhập Google hoặc Email/Password Firebase thành công → Cá nhân → Đăng xuất → Ghi nhớ tài khoản → xác thực sinh trắc học. Ứng dụng bỏ bearer đang hoạt động, giữ Firebase SDK session để khôi phục và chỉ lưu UID làm dấu tài khoản ghi nhớ. Không lưu mật khẩu hoặc tự sao chép Firebase refresh token.

Vào màn hình đăng nhập → Đăng nhập bằng sinh trắc học. Sau xác thực thiết bị, ứng dụng kiểm tra UID, reload Firebase user, force refresh ID token và gọi backend `/auth/firebase` để kiểm tra email, trạng thái và token bị thu hồi. Cần mạng; sinh trắc học không vượt qua hạn chế backend. Phiên bị thu hồi/khóa cần đăng nhập lại. Tính năng này là tạm ngưng phiên app có ghi nhớ, không phải Firebase signOut hoàn toàn.

Đăng xuất hoàn toàn / Quên tài khoản xóa UID ghi nhớ, bearer và gọi Firebase/Google signOut. Đổi mật khẩu cũng dùng đăng xuất hoàn toàn. Đăng nhập bằng tài khoản khác xóa tài khoản ghi nhớ trước. Chỉ ghi nhớ một tài khoản trên thiết bị; tài khoản legacy chưa hỗ trợ khôi phục bằng sinh trắc học.

Firebase SDK quản lý thông tin phiên theo cơ chế lưu trữ sẵn có của SDK; đây không phải triển khai khóa mật mã refresh token bằng Keychain/Keystore yêu cầu sinh trắc cho mỗi lần đọc. Chưa thêm quản lý danh sách thiết bị hoặc thu hồi từng thiết bị phía backend.

Kiểm thử thiết bị: ghi nhớ → tắt/mở app → không được coi là đăng nhập → hủy/sai sinh trắc không vào được → xác thực đúng khôi phục → quên tài khoản mất nút khôi phục → đổi mật khẩu/thu hồi token không khôi phục được → mất mạng hiển thị lỗi → đổi tài khoản không mở nhầm hồ sơ. Kiểm tra Face ID/Touch ID trên iOS và vân tay Android.
