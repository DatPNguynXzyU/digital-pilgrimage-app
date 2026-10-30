from pathlib import Path
p=Path('D:/PhamNguyenTuanDat_2380614580')
f=p/'frontend/lib/api.dart';s=f.read_text(encoding='utf8');start=s.index('    return uri != null');end=s.index('\n  }',start)
s=s[:start]+'''    return uri != null && uri.host.isNotEmpty &&
        (uri.scheme == 'https' ||
          (const bool.fromEnvironment('ALLOW_LOCAL_HTTP') && uri.scheme == 'http'));
'''.rstrip()+s[end:];s=s.replace('Cần cấu hình API_BASE_URL bằng URL HTTPS của Render.','Cần cấu hình API_BASE_URL; HTTP nội bộ cần ALLOW_LOCAL_HTTP=true.');f.write_text(s,encoding='utf8')
debug=p/'frontend/android/app/src/debug/AndroidManifest.xml';debug.write_text('''<manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:tools="http://schemas.android.com/tools">
<uses-permission android:name="android.permission.INTERNET"/>
<application android:usesCleartextTraffic="true" tools:replace="android:usesCleartextTraffic"/>
</manifest>''',encoding='utf8')
(p/'compose.yaml').write_text('''services:
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: childguard
      POSTGRES_PASSWORD: childguard_local_only
      POSTGRES_DB: childguard
    ports:
      - "127.0.0.1:5432:5432"
    volumes:
      - childguard_db:/var/lib/postgresql/data
volumes:
  childguard_db:
''',encoding='utf8')
(p/'docs/CHAY_LOCAL.md').write_text('''# Chạy backend trước, frontend sau

## 1. Khởi động PostgreSQL
Mở Docker Desktop và đợi engine chạy. Tại thư mục project:
```powershell
docker compose up -d
```
Hoặc cài PostgreSQL riêng, tạo database rồi sửa DATABASE_URL tương ứng.

## 2. Chạy backend (terminal thứ nhất)
```powershell
cd D:\\PhamNguyenTuanDat_2380614580\\backend
npm ci
Copy-Item .env.example .env
```
Sửa `.env`: DATABASE_URL=postgresql://childguard:childguard_local_only@127.0.0.1:5432/childguard, PORT=10000, PUBLIC_URL=http://localhost:10000 và JWT_SECRET là chuỗi ngẫu nhiên ít nhất 32 ký tự. Điền SMTP thật để nhận OTP email. Không ghi đè .env nếu đã có cấu hình.
```powershell
npm start
```
Kiểm tra trình duyệt: http://localhost:10000/health phải trả {"status":"ok"}. Giữ terminal này chạy.

## 3. Chạy frontend (terminal thứ hai)
Máy ảo Android Studio dùng 10.0.2.2 để truy cập máy tính:
```powershell
cd D:\\PhamNguyenTuanDat_2380614580\\frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:10000 --dart-define=ALLOW_LOCAL_HTTP=true
```
Điện thoại thật qua USB: chạy `adb reverse tcp:10000 tcp:10000`, sau đó dùng API_BASE_URL=http://127.0.0.1:10000 cùng ALLOW_LOCAL_HTTP=true.
Điện thoại qua Wi-Fi: dùng địa chỉ IPv4 LAN của máy tính, hai máy cùng mạng; chỉ cho phép cổng 10000 trên mạng riêng khi Windows hỏi.

HTTP chỉ được mở trong bản Android debug và khi bật ALLOW_LOCAL_HTTP. Bản phát hành tiếp tục dùng HTTPS. Không cần Render cho quy trình này. Google OAuth cần callback được Google chấp nhận, cấu hình client riêng; OTP email vẫn cần SMTP thật.
''',encoding='utf8')
f=p/'README.md';f.write_text('# Chạy trên máy tính theo yêu cầu mới\n\nXem [chạy backend trước, frontend sau](docs/CHAY_LOCAL.md). Hướng dẫn này thay thế yêu cầu bắt buộc Render trước đó.\n\n'+f.read_text(encoding='utf8'),encoding='utf8')
