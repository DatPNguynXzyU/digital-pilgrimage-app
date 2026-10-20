# Deploy miễn phí: Render + Atlas + Cloudinary

## Giới hạn

Render Free ngủ sau 15 phút không truy cập; lần gọi tiếp theo có thể mất khoảng
một phút. Không có cam kết chạy liên tục hay chịu tải lớn. App chờ health check
khi mở hoặc quay lại từ nền (tối đa khoảng 100 giây), có nút thử lại.
Không tự gửi lại đăng ký, check-in hay các thao tác ghi dữ liệu.

## 1. Chuẩn bị tài khoản

- Render: https://dashboard.render.com — đăng nhập bằng GitHub.
- Cloudinary: https://cloudinary.com/users/register/free — chọn gói Free.
- Giữ MongoDB Atlas hiện có. Không seed/reset database khi deploy.
- Không đưa `.env`, JWT secret, URI database hoặc Cloudinary secret lên GitHub/chat.

## 2. Đưa bản sửa đã kiểm tra lên main

Các thay đổi phải được commit, push và merge sau khi CI đạt. Repo đang có
các sửa lỗi NFC và các thay đổi khác chưa commit; kiểm tra `git diff` trước khi
chọn file. Không dùng `git reset --hard` để cập nhật.

## 3. Tạo dịch vụ bằng Blueprint

Trong Render chọn New > Blueprint, liên kết tài khoản GitHub, chọn repository
`DatPNguynXzyU/digital-pilgrimage-app`, nhánh `main`, file `render.yaml`.
Phải liên kết repository bằng GitHub integration, không chỉ dán public Git URL,
để Render nhận sự kiện CI.

Blueprint dùng Docker backend, gói Free, cổng từ PORT của Render và health check
`/api/health`. Nhập các biến được yêu cầu:

| Biến | Giá trị |
|---|---|
| MONGODB_URI | URI Atlas từ cấu hình backend hiện có |
| MONGODB_DATABASE | Tên database hiện đang dùng |
| CLOUDINARY_CLOUD_NAME | Cloud name trong Cloudinary |
| CLOUDINARY_API_KEY | API key trong Cloudinary |
| CLOUDINARY_API_SECRET | API secret trong Cloudinary |

JWT_SECRET được sinh riêng. Người dùng sẽ cần đăng nhập lại khi chuyển sang
server mới. AVATAR_STORAGE=cloudinary được cấu hình sẵn. Thiếu thông tin Cloudinary
sẽ làm server dừng khởi động thay vì âm thầm lưu ảnh vào ổ đĩa tạm.

Trong Atlas Network Access, cho phép các outbound IP/range được Render hiển thị
cho service. Nếu Atlas báo lỗi kết nối, kiểm tra mục này và thông tin DB user.
Không mặc định mở toàn bộ IP. Theo dõi hạn mức miễn phí của cả ba dịch vụ.

## 4. CD sau CI

`autoDeployTrigger: checksPass` yêu cầu Render đợi CI của commit trên main đạt.
Kiểm tra Settings > Auto-Deploy hiển thị After CI Checks Pass.
Lần tạo service đầu tiên và deploy thủ công không được coi là đã qua cổng CI;
chỉ tạo từ main đã xanh. Không dùng deploy hook song song hoặc tự deploy mọi commit.

Workflow `.github/workflows/cd.yml` hiện vẫn publish image GHCR sau CI;
Render build Dockerfile từ source commit đã được kiểm tra, không dùng image GHCR.
Task CD trên máy cá nhân có thể tiếp tục để Disabled; Render không cần máy bạn.

## 5. Kiểm tra và cài APK

Copy URL thật trong Render (không dùng nguyên ví dụ bên dưới):

- `https://TEN-SERVICE.onrender.com/api/health` phải trả HTTP 200 và success=true.
- `https://TEN-SERVICE.onrender.com/api/temples` phải có danh sách chùa.
- Đăng nhập, upload avatar, check-in NFC, xem sổ tem và lịch sử.
- Thử trên 4G khi Docker máy cá nhân đã tắt.

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://TEN-SERVICE.onrender.com/api
```

App tự bật màn hình chờ cho domain `.onrender.com`. Nếu dùng domain riêng, thêm
`--dart-define=BACKEND_WARMUP=true`.
Đặt GitHub repository variable API_BASE_URL bằng cùng URL có `/api` để APK của CI
dùng đúng backend. Không đưa JWT/Cloudinary secret vào dart-define.

## 6. Ảnh và dữ liệu cũ

Avatar upload mới được gửi từ backend sang Cloudinary, URL HTTPS lưu vào Atlas.
Mỗi tài khoản ghi đè một asset riêng để hạn chế tích lũy ảnh không dùng.
Ảnh avatar cũ dạng `/img/avatars/...` vẫn nằm trong volume Docker trên máy:
KHÔNG xóa volume. Chúng chưa được tự chuyển lên Cloudinary. Trước khi chuyển hẳn
cho người dùng thật, cần di chuyển ảnh cũ hoặc yêu cầu người dùng tải lại avatar.
Các ảnh tĩnh đã commit trong backend/img vẫn được đóng gói trong Docker image.

## Tài liệu

- https://render.com/docs/free
- https://render.com/docs/blueprint-spec
- https://render.com/docs/deploys
- https://cloudinary.com/documentation/image_upload_api_reference
