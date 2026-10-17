# Thử app qua 4G hoặc Wi-Fi khác

Chạy trong thư mục backend:

```powershell
docker compose -f compose.yaml -f compose.tunnel.yaml up -d --build
docker compose -f compose.yaml -f compose.tunnel.yaml logs --tail 30 tunnel
```

Lấy URL `https://....trycloudflare.com` từ log và kiểm tra `/api/temples`.
Tại thư mục gốc Flutter, build APK với URL vừa lấy:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://YOUR-TUNNEL.trycloudflare.com/api
```

Gửi `build/app/outputs/flutter-apk/app-release.apk` cho người thử cài.
Giữ máy tính thức, có Internet và Docker chạy trong lúc thử.
Quick Tunnel là URL công khai tạm thời, có thể đổi khi tunnel khởi động lại.
Nếu URL đổi, cần build/cài APK mới với URL mới.

Tắt truy cập Internet mà vẫn giữ backend chạy:

```powershell
docker compose -f compose.yaml -f compose.tunnel.yaml stop tunnel
```

Tài liệu: https://developers.cloudflare.com/tunnel/get-started/quick-tunnels/
