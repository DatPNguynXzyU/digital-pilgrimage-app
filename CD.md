# CD backend trên máy Windows chạy Docker Desktop

Repository public nên không cài self-hosted Actions runner trên máy cá nhân.
GitHub build và publish image; Windows Task Scheduler gọi một script local cố định
để kiểm tra bản đã publish. Không nhận/chạy job từ pull request trên máy này.

## Luồng triển khai

1. Push/merge vào `main`, workflow CI thành công.
2. `CD image` chạy trên GitHub, build đúng SHA đã kiểm thử và đẩy lên
   `ghcr.io/datpnguynxzyu/digital-pilgrimage-app/backend:sha-<commit>`.
3. Script local kiểm tra main và job publish thành công, kéo image, kiểm tra
   nhãn revision, kiểm tra main chưa đổi rồi cập nhật riêng service backend.
4. Gọi `/api/temples` để xác minh API và kết nối database. Nếu không đạt,
   tự khôi phục image trước đó và trả lỗi. Lỗi rollback cũng được báo lỗi.

Không tự chạy migration/seed. Rollback chỉ phục hồi image, không hoàn tác thay đổi
database. Những thay đổi schema tương lai cần tương thích với phiên bản trước.

## Thiết lập một lần

1. Commit/push `.github/workflows/cd.yml`, `backend/compose.cd.yaml` và thư mục
   `scripts`. Workflow `workflow_run` phải có trên nhánh mặc định `main`.
   Chờ một lần push vào main chạy CI và `CD image` thành công.
2. Trên GitHub, mở package `digital-pilgrimage-app/backend` trong Packages của
   tài khoản, vào Package settings và chuyển visibility thành **Public**.
   Repository public không đồng nghĩa package tự public. Image không chứa `.env`;
   quy tắc `.dockerignore` hiện tại loại bỏ bí mật và ảnh upload.
3. Giữ `backend/.env` trên máy (không commit), Docker Desktop chạy Linux containers.
   Script dùng Compose project `backend`, container `hanh-huong-backend`, volume
   ảnh `backend_avatar_data`, đúng với cấu hình đã kiểm tra trên máy hiện tại.
   Nếu đổi tên project/volume, điều chỉnh cấu hình trước khi chạy.
4. Từ thư mục dự án, kiểm tra rồi thử triển khai:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\deploy-local.ps1 -CheckOnly
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\deploy-local.ps1
```

5. Khi triển khai thử thành công, bật kiểm tra tự động mỗi 10 phút:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-local-cd.ps1
```

Task dùng tài khoản Windows hiện tại, chỉ hoạt động khi tài khoản đang đăng nhập.
Máy và Docker Desktop phải bật. Không cần mở thêm cổng để GitHub truy cập máy.
GitHub API/package public được đọc không cần PAT. API bị giới hạn hoặc lỗi mạng
sẽ làm lần chạy thất bại và giữ nguyên backend cho tới lần kiểm tra tiếp theo.
Không cài task trong thư mục tạm; script này phải nằm tại đường dẫn ổn định.

## Dữ liệu và truy cập từ điện thoại

- Volume ảnh là external, không bị tạo nhầm sang volume trống khi đổi checkout.
- MongoDB tiếp tục dùng cấu hình trong `.env`; CD không xóa/chạy lại database.
- Không dùng `docker compose down`, không khởi động lại service tunnel.
  Quick Tunnel vẫn có thể đổi URL nếu máy/tunnel tự restart. Muốn APK dùng ổn định
  cần tên miền/tunnel cố định; CD không tự cập nhật URL trong APK đã cài.
- Image trước đó được giữ ở `hanh-huong-backend:rollback-local-cd`.
- Trạng thái thành công nằm ở `.local-cd/last-deployment.json`.
- Task Scheduler hiển thị Last Run Result; `0` là không có lỗi.

Tắt CD mà không dừng backend:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install-local-cd.ps1 -Remove
```

## Bảo vệ nhánh triển khai

Chỉ người tin cậy được merge vào main; bật branch protection và required CI checks.
CD không publish từ workflow CI của pull request hay chạy thủ công; chỉ nhận CI
thành công từ push main trong chính repository. Script local cần được cập nhật
có chủ đích khi thay đổi quy tắc triển khai, không tự tải script từ main để chạy.

Tham khảo: [GitHub self-hosted runner security](https://docs.github.com/en/actions/reference/security/secure-use),
[workflow_run](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#workflow_run).

