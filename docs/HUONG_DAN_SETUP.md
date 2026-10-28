> Cấu trúc mới (27/10/2026): ứng dụng Flutter nằm trong `client/`. Chạy các lệnh `flutter`, thao tác `android/`, `ios/`, `lib/`, `test/`, `images/` và `firebase-config*.json` từ thư mục `client/`. Backend và script vận hành vẫn ở gốc repository. Xem [cấu trúc dự án](CAU_TRUC_DU_AN.md).

# Hướng dẫn clone, setup và đóng góp
Hành Trình An Nhiên | Windows PowerShell | Cập nhật 21/10/2026
## 1. Chọn cách chạy
- Chỉ làm giao diện hoặc test app: dùng backend HTTPS do chủ dự án cung cấp. Không cần Docker, MongoDB hay Firebase Admin key trên máy.
- Sửa backend: chạy Node.js và MongoDB riêng; dùng Firebase/Redis thử nghiệm nếu kiểm tra các chức năng đó.
- Kiểm thử tự động backend: dùng compose.test.yaml, không dùng database production.
Repository: https://github.com/DatPNguynXzyU/digital-pilgrimage-app
API đang được cấu hình trong file mẫu: https://digital-pilgrimage-api.onrender.com/api. Đây có thể là môi trường thật; chỉ dùng tài khoản thử được thống nhất. Render Free có thể khởi động chậm khi không hoạt động.
## 2. Chuẩn bị công cụ
Cài Git, Flutter, Android Studio cùng Android SDK và JDK 17. Phiên bản Flutter trong CI hiện là 3.47.4; nên dùng cùng phiên bản và giữ lockfile. Nếu nhóm cập nhật CI thì lấy phiên bản mới từ .github/workflows/ci.yml.
Chỉ khi sửa backend: cài Node.js 22 và npm. Cài Docker Desktop nếu chạy MongoDB/test bằng container. VS Code hoặc Android Studio đều dùng được.
```powershell
git --version
flutter --version
flutter doctor -v
flutter doctor --android-licenses
flutter devices
```
Chấp nhận giấy phép sau khi đọc. Khắc phục các mục Android toolchain còn thiếu trước khi build. Điện thoại bật Developer options và USB debugging, chấp nhận kết nối máy tính. Test NFC cần máy thật có NFC; emulator không chứng minh được luồng quét thẻ vật lý.
## 3. Clone và tạo nhánh
```powershell
git clone https://github.com/DatPNguynXzyU/digital-pilgrimage-app.git
cd digital-pilgrimage-app
git status
git switch main
git pull --ff-only origin main
git switch -c feature/ten-cong-viec
cd client
flutter pub get --enforce-lockfile
```
Chạy lệnh ở thư mục có pubspec.yaml. Nếu đã clone và có thay đổi chưa lưu, commit hoặc lưu công việc trước khi chuyển nhánh; không dùng reset --hard để xử lý tùy tiện. Nếu chức năng nằm trong PR chưa merge, hỏi người phụ trách nhánh chính xác.
## 4. Cấu hình Flutter và Firebase
```powershell
Copy-Item firebase-config.example.json firebase-config.json
```
Mở firebase-config.json và điền các trường sau bằng cấu hình client của môi trường nhóm cho phép:
```json
{
  "API_BASE_URL": "https://digital-pilgrimage-api.onrender.com/api",
  "FIREBASE_PROJECT_ID": "hanh-trinh-an-nhien",
  "FIREBASE_API_KEY": "<client API key>",
  "FIREBASE_APP_ID": "<Android Firebase app ID>",
  "FIREBASE_MESSAGING_SENDER_ID": "<project number>",
  "GOOGLE_WEB_CLIENT_ID": "<Web OAuth client ID>"
}
```
Không giữ nguyên các giá trị trong dấu <...>. Xin bộ cấu hình client từ chủ dự án hoặc lấy trong Firebase Project settings của môi trường được cấp quyền. GOOGLE_WEB_CLIENT_ID là OAuth client loại Web, không phải Android client ID. Android application ID hiện là com.example.apptungkinh. File google-services.json không thay thế các giá trị Dart mà app đang nhận qua --dart-define-from-file.
Không đưa Firebase Admin JSON, JWT secret hoặc Upstash token vào Flutter. firebase-config.json là cấu hình máy cá nhân, không thêm vào commit. Khi đổi cấu hình, build/run lại vì dart-define được đưa vào lúc biên dịch.
Google Sign-In trên máy bạn có thể cần SHA-1/SHA-256 của khóa debug riêng. Sau lần build debug đầu, lấy fingerprint bằng JDK keytool nếu công cụ có trong PATH:
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android
```
Gửi fingerprint cho chủ dự án để thêm vào Firebase Android app, không gửi file khóa hoặc mật khẩu release. Đối chiếu đúng keystore mà bản build đang dùng. Firebase cần bật Google và Email/Password; khi kiểm tra đăng ký email, bấm link xác minh trước đăng nhập theo luồng ứng dụng.
## 5. Chạy và build APK test
```powershell
flutter run --dart-define-from-file=firebase-config.json
flutter build apk --debug --dart-define-from-file=firebase-config.json
```
APK ở build/app/outputs/flutter-apk/app-debug.apk. Chọn thiết bị bằng -d <device-id> khi có nhiều thiết bị. Bản debug phù hợp cho cộng tác viên; không cần xin khóa release. APK ký khác khóa có thể không cài đè bản cũ; gỡ bản cũ làm mất dữ liệu cục bộ, nên dùng thiết bị test hoặc sao lưu trước.
Chủ dự án phát hành release theo docs/RELEASE_SIGNING.md; không yêu cầu mọi thành viên tự tạo lại khóa phát hành. Sau khi sửa code Flutter cần build/cài bản mới; cập nhật backend không tự thay APK đã cài.
## 6. Chạy backend cục bộ khi cần
Lựa chọn dưới đây dùng MongoDB riêng trong Docker và backend chạy Node trên máy. MongoDB bật replica set để hỗ trợ các luồng có transaction. Không dùng URI production.
```powershell
docker run -d --name pilgrimage-dev-mongo -p 127.0.0.1:27017:27017 mongo:7 --replSet rs0 --bind_ip_all
docker exec pilgrimage-dev-mongo mongosh --quiet --eval 'rs.initiate({_id:"rs0",members:[{_id:0,host:"localhost:27017"}]})'
cd ../backend
npm ci
```
Lệnh tạo container và rs.initiate chỉ chạy lần đầu. Chờ Mongo sẵn sàng nếu exec báo chưa kết nối; lần sau dùng docker start pilgrimage-dev-mongo. Container này là dữ liệu dev, cần kế hoạch lưu trữ riêng nếu muốn giữ lâu dài.
Tạo backend/.env (không commit) với nội dung tối thiểu:
```dotenv
NODE_ENV=development
PORT=3000
MONGODB_URI=mongodb://127.0.0.1:27017/?replicaSet=rs0&directConnection=true
MONGODB_DATABASE=pilgrimage_dev
JWT_SECRET=<thay bằng chuỗi ngẫu nhiên riêng>
JWT_EXPIRES_IN=7d
AVATAR_STORAGE=local
REDIS_RATE_LIMIT_ENABLED=false
```
Có thể tạo JWT secret cục bộ bằng lệnh sau, rồi tự điền vào .env; không gửi lên chat hay GitHub:
```powershell
node -e "console.log(require('node:crypto').randomBytes(48).toString('hex'))"
npm run dev
```
Kiểm tra từ cửa sổ PowerShell khác:
```powershell
Invoke-RestMethod http://localhost:3000/api/health
```
API khỏe chưa có nghĩa database đã có dữ liệu chùa. Chỉ seed sau khi xác nhận MONGODB_URI và MONGODB_DATABASE là database dev riêng. Đọc seed script trước khi chạy npm run seed vì có thể thay thế dữ liệu hiện có.
Nếu kiểm tra Firebase backend, chủ dự án cấp môi trường thử; bổ sung FIREBASE_PROJECT_ID và FIREBASE_SERVICE_ACCOUNT_FILE trỏ tới Admin JSON cục bộ ngoài Git. Client và server phải dùng cùng Firebase project. Thiếu Admin credential không thể coi Google login local đã hoàn chỉnh. Không khai báo Firebase khi chỉ kiểm tra các API legacy không cần Firebase.
backend/compose.yaml chỉ tạo API, không tự tạo MongoDB hay mount Admin key. Vì vậy docker compose up riêng file đó chưa đủ cho toàn bộ môi trường mới.
## 7. Địa chỉ kết nối theo thiết bị
- Emulator Android tới backend trên PC: http://10.0.2.2:3000/api.
- Điện thoại cùng Wi-Fi: http://<IPv4-cua-PC>:3000/api; cho phép cổng 3000 trên mạng riêng, backend phải đang chạy.
- Điện thoại dùng 4G hoặc Wi-Fi khác: dùng backend HTTPS công khai được cấp. 10.0.2.2 và 192.168.x.x không phải địa chỉ truy cập từ Internet.
Sửa API_BASE_URL rồi chạy/build lại. Không mở MongoDB ra Internet để điện thoại kết nối trực tiếp; app gọi API backend.
## 8. Redis và lưu ảnh tùy chọn
Redis local/staging: đặt cả UPSTASH_REDIS_REST_URL và UPSTASH_REDIS_REST_TOKEN trong backend/.env. Có một mà thiếu một sẽ bị từ chối cấu hình. Không cần Redis để bắt đầu chạy app.
Giữ REDIS_RATE_LIMIT_ENABLED=false khi chưa xác minh proxy. Muốn test limiter khi gọi trực tiếp server local thì khai báo TRUST_PROXY_HOPS=0 và bật true. Trên Render cần xác minh số proxy, không sao chép số hop tùy ý. Cache công khai hiện TTL 60 giây; request có Authorization không dùng cache. Xem docs/REDIS.md để kiểm tra chi tiết.
Cloudinary chỉ cần khi test lưu ảnh cloud: AVATAR_STORAGE=cloudinary, CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET. Dùng tài khoản test; chạy local có thể giữ AVATAR_STORAGE=local.
## 9. Kiểm thử trước khi mở PR
Tại thư mục `client/`:
```powershell
flutter analyze --no-pub
flutter test --no-pub --coverage
```
Kiểm thử backend với MongoDB tạm, từ thư mục gốc chuyển vào backend:
```powershell
cd backend
docker compose -p apptungkinh-tests -f compose.test.yaml up --build --attach test --abort-on-container-exit --exit-code-from test
docker compose -p apptungkinh-tests -f compose.test.yaml down --volumes --remove-orphans
cd ..
```
Lệnh down ở đây chỉ dọn project test apptungkinh-tests; không thay bằng compose production. Ghi lại kết quả test trước khi dọn. Khi sửa scripts CD, chạy thêm ./scripts/test-local-cd.ps1 từ gốc theo CI.
Test thủ công: đăng ký email → xác minh → đăng nhập; Google login; NFC → nhận tem → lịch sử; logout → đổi người dùng; mất mạng. Đánh dấu chức năng chưa test trên máy thật, không coi unit test là bằng chứng NFC đã chạy thực tế.
## 10. Commit, push và review
```powershell
git status
git diff
git add <duong-dan-file-da-sua>
git commit -m "feat: mo ta thay doi"
git push -u origin feature/ten-cong-viec
```
Thay phần <...> bằng đường dẫn thật. Mở Pull Request vào main, điền Issue, thay đổi, kết quả test và ảnh. Người không có quyền push tạo fork rồi mở PR từ fork. Đợi CI xanh và review trước merge. Merge main có thể kích hoạt CD và ảnh hưởng backend Render đang chạy.
Không push .env, Admin JSON, Redis token, keystore, key.properties hoặc dữ liệu khách hàng. Không cần cấp quyền Render/Firebase cho người chỉ sửa code. Người sửa cấu hình hạ tầng cần được chủ dự án cấp quyền riêng.
## 11. Xử lý lỗi thường gặp
- Không tải danh sách chùa: kiểm tra API_BASE_URL, health, mạng và thời gian khởi động Render; không tiếp tục dùng 10.0.2.2 trên điện thoại thật.
- Google lỗi cấu hình: kiểm tra Web client ID, package, SHA của đúng khóa ký, Firebase project và provider Google đã bật.
- Thiếu firebase-config: tạo từ file example, điền đủ và truyền --dart-define-from-file khi run/build.
- Backend không chạy: kiểm tra JWT_SECRET, MongoDB, cặp biến Redis và đường dẫn Admin key nếu bật Firebase. Không đăng log chứa secret lên Issue.
- Không có chùa ở local: database mới có thể rỗng; dùng dữ liệu mẫu đã thống nhất, không sao chép dữ liệu cá nhân production.
- Build release lỗi ký: cộng tác viên dùng debug; chủ dự án cấu hình release theo tài liệu riêng.
- Port 3000/27017 đang dùng hoặc container trùng tên: kiểm tra tiến trình/container hiện có, không xóa bừa dữ liệu để chạy lệnh mẫu.
## 12. Checklist bàn giao của thành viên
Ghi hệ điều hành, phiên bản Flutter/Node, nhánh/commit, môi trường API, thiết bị đã thử, kết quả analyze/test, luồng thủ công và link PR. Không ghi secret. Tài liệu tham khảo trong repo: docs/FIREBASE_AUTH.md, docs/REDIS.md, docs/RENDER_DEPLOY.md, docs/RELEASE_SIGNING.md và .github/workflows/ci.yml.
