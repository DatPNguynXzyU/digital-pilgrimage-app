# BÀN GIAO NGỮ CẢNH CHO AI TIẾP TỤC DỰ ÁN

**Đồ án:** Hành Trình An Nhiên — AppTungKinh / digital-pilgrimage-app  
**Cập nhật:** 28/10/2026, múi giờ Asia/Saigon  
**Mục đích:** Ngữ cảnh làm việc cho AI tiếp theo; đây là tài liệu vận hành riêng, không phải nội dung báo cáo học thuật. Không tự chèn tài liệu này vào báo cáo Word/PDF.

## 1. Đọc trước khi làm tiếp

Bạn đang tiếp quản ứng dụng đã chạy được trên Android và iOS. Người dùng xác nhận IPA đã cài và chạy thành công. Việc gần nhất là tổ chức lại repository thành `client/` và `backend/`, xử lý xung đột Git, rồi hợp nhất lên `main` qua PR #14.

- Workspace trên laptop: `D:\LTDT\AppTungKinh\apptungkinh`.
- Shell: PowerShell trên Windows.
- Repository public: <https://github.com/DatPNguynXzyU/digital-pilgrimage-app>.
- Nhánh hiện tại lúc bàn giao: `main`, đồng bộ `origin/main`, cây làm việc sạch trước khi thêm file này.
- Commit code mới nhất được xác nhận: `7d43718214fa11489f5acef055fd2fe1b4c24dab` (`7d43718`).
- PR đã squash merge: <https://github.com/DatPNguynXzyU/digital-pilgrimage-app/pull/14>.
- API production được cấu hình trong file mẫu: `https://digital-pilgrimage-api.onrender.com/api`.
- Firebase project: `hanh-trinh-an-nhien`.
- Android application ID: `com.example.apptungkinh`.

**Luôn kiểm tra lại Git, code và môi trường thực tế.** Thông tin trên là ảnh chụp trạng thái lúc viết, không phải bảo đảm trạng thái dịch vụ cloud trong tương lai.

### Nguyên tắc quan trọng của người dùng

1. Tiếp tục xử lý công việc cụ thể, không chỉ đưa kế hoạch hoặc hỏi lại các quyền đã được cấp cho đúng việc đó.
2. Giữ nguyên công việc người dùng/bạn cùng nhóm đang làm. Không reset mất dữ liệu hoặc force push.
3. **Dataset chùa mới chỉ được import vào file để kiểm tra. Chưa được người dùng cho phép seed trong đợt import này. Không tự seed MongoDB.**
4. Không đưa private key, mật khẩu, URI database có credential, token Redis hay khóa ký vào chat/GitHub/tài liệu.
5. Không tự gộp tài liệu bàn giao AI vào báo cáo môn học.
6. Không khẳng định đã test trên điện thoại nếu chỉ chạy unit test hoặc build thành công.
7. Chạy mọi lệnh Flutter từ `client/`. Đây là thay đổi cấu trúc quan trọng nhất so với tài liệu cũ.
8. Đọc `AGENTS.md`. Repository có CodeGraph: dùng `codegraph_explore` hoặc `codegraph explore` trước khi tìm hiểu/chỉnh source đã được index.

## 2. Cấu trúc repository hiện tại

```text
digital-pilgrimage-app/
├── client/
│   ├── android/                 # Gradle, Kotlin, manifest, cấu hình ký Android
│   ├── ios/                     # Xcode, Swift, plist, entitlements
│   ├── lib/
│   │   ├── config/              # API endpoint, theme
│   │   ├── models/              # Model dữ liệu Dart
│   │   ├── services/            # Auth, API, NFC, GPS, lịch, nhắc lịch, âm thanh
│   │   ├── views/               # Các màn hình
│   │   ├── widgets/             # Widget dùng chung
│   │   └── main.dart
│   ├── test/                    # Unit/widget test Flutter
│   ├── images/                  # Ảnh đóng gói cùng ứng dụng
│   ├── assets/audio/mokugyo.wav # Tiếng mõ
│   ├── pubspec.yaml
│   ├── pubspec.lock
│   ├── firebase-config.example.json
│   └── firebase-config.ios.example.json
├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── middleware/
│   │   ├── models/
│   │   ├── routes/
│   │   ├── seed/
│   │   ├── utils/
│   │   ├── app.js
│   │   └── server.js
│   ├── data/                    # JSON dữ liệu nguồn
│   ├── img/                     # Ảnh tĩnh, ảnh chùa, avatar local khi dùng chế độ local
│   ├── test/
│   ├── Dockerfile
│   ├── compose.test.yaml
│   └── package.json
├── .github/workflows/
│   ├── ci.yml
│   ├── cd.yml
│   └── ios-sideload.yml
├── scripts/                     # CD local, chuẩn bị iOS, tạo asset
├── docs/                        # Hướng dẫn kỹ thuật
│   └── reports/                 # Báo cáo/bàn giao lịch sử, Word/PDF
├── releases/
├── tmp/                         # Có một số artifact tài liệu đã được commit trước đó
├── render.yaml
├── codegraph.json
├── AGENTS.md
├── README.md
└── AI_HANDOFF.md                # File này, tách khỏi báo cáo
```

Thư mục `.local-cd/` chứa backup, script hỗ trợ và checkout thử nghiệm, bị Git bỏ qua. `.codegraph/` là index cục bộ, cũng bị bỏ qua. Đừng đưa các thư mục này lên GitHub.

## 3. Công nghệ và kiến trúc

### Client

- Flutter/Dart; CI dùng Flutter `3.47.4`, pubspec yêu cầu Dart `^3.13.3`.
- Tên package Dart: `hanh_trinh_an_nhien`.
- Material widgets, Cupertino Icons; Android native bằng Kotlin, Gradle Kotlin DSL; iOS bằng Swift/Xcode.
- State hiện có dùng các cơ chế Flutter như `setState`, `ValueNotifier` và lớp service; không tự mô tả dự án là dùng Bloc/Provider/Riverpod nếu chưa kiểm tra source.
- Gọi REST bằng `http`; multipart avatar dùng `http_parser`, chọn ảnh bằng `image_picker`.
- Lưu trạng thái local bằng `shared_preferences`.
- Firebase: `firebase_core ^4.15.2`, `firebase_auth ^6.7.1`, `google_sign_in ^7.2.0`.
- NFC: `nfc_manager`, `nfc_manager_ndef`; camera/QR: `mobile_scanner`.
- Sinh trắc học: `local_auth`; vị trí: `geolocator`; mở link/bản đồ: `url_launcher`.
- Nhắc lịch cục bộ: `flutter_local_notifications`, `timezone`.
- Tiếng mõ: `audioplayers`; launcher icon: `flutter_launcher_icons`.
- Cấu hình build truyền qua `--dart-define` hoặc `--dart-define-from-file`; thay JSON cấu hình cần build/run lại.

### Backend

- Node.js 22; Docker base image `node:22-alpine`, chạy dưới user `node`.
- Express 5; chuỗi xử lý tổng quát: request → routes → middleware → controller → model/MongoDB.
- MongoDB, Mongoose ODM; dữ liệu check-in cần lưu ý transaction và replica set trong môi trường test.
- Package chính: `express`, `mongoose`, `firebase-admin`, `jsonwebtoken`, `bcryptjs`, `cors`, `dotenv`, `multer`; dev dùng `nodemon`.
- Avatar cloud lưu trên Cloudinary; tích hợp bằng API HTTP/fetch và chữ ký, không suy đoán có package Cloudinary nếu không thấy trong package.json.
- Redis qua Upstash REST, dùng `fetch` của Node, không có yêu cầu cài Redis SDK trong package.json hiện tại.
- Test bằng Node Test Runner (`node --test`), không phải Jest.

### Luồng hệ thống

```text
Flutter Android/iOS
  ├─ Firebase Authentication: email/password, email xác minh, Google
  └─ HTTPS REST API trên Render
       ├─ Firebase Admin / JWT middleware
       ├─ MongoDB: tài khoản và dữ liệu nghiệp vụ
       ├─ Upstash Redis: cache công khai và giới hạn request
       ├─ Cloudinary: avatar
       └─ backend/img: ảnh tĩnh chùa/nhân vật theo dữ liệu
```

## 4. Chức năng và nơi tiếp tục tìm hiểu

| Nhóm | Hiện trạng trong code / file tiêu biểu |
|---|---|
| Tài khoản | Đăng ký/đăng nhập, Google, email xác minh, quên mật khẩu, hồ sơ/avatar, đổi mật khẩu, quản lý phiên |
| Auth client | `client/lib/services/auth_service.dart`, `firebase_identity.dart` |
| Sinh trắc học | `client/lib/services/biometric_lock.dart`; khóa giao diện dựa vào sinh trắc học máy người dùng |
| Trang chủ | Phật ngôn ngẫu nhiên, ảnh đại diện, ngày âm/dương, hành trình, lễ sắp tới |
| Phật ngôn | `client/lib/models/quote.dart`, `dhammapada_lines.dart`, `client/lib/views/trang_chu/home_dhammapada_card.dart` |
| Chùa | Danh sách/tìm kiếm/sắp xếp, chi tiết, album vuốt nhiều hình, lưu yêu thích, bản đồ/chỉ đường, chùa gần |
| GPS | `client/lib/services/nearby_temples.dart`, các màn hình trong `views/temples/` |
| NFC/tem/lịch sử | `nfc_service.dart`, `pilgrimage_service.dart`, màn hình `views/nfc/`, route/controller backend tương ứng |
| Kinh sách | Danh sách, chi tiết, định dạng đọc, tự cuộn và chỉnh tốc độ ở thanh điều khiển phía trên |
| Tiếng mõ | `mok_audio_service.dart`, `floating_mok_button.dart`, `assets/audio/mokugyo.wav` |
| Nhân vật Phật giáo | Tra cứu, chi tiết, ảnh chữ nhật bo góc theo yêu cầu giao diện |
| Lịch | Âm/dương, sự kiện cá nhân, ngày lễ Phật giáo, cài đặt nhắc lịch |
| Nhắc lịch | `calendar_event_store.dart`, `calendar_festival_service.dart`, `local_reminders.dart`, `reminder_plan.dart` |
| Cộng đồng | Người dùng yêu cầu dùng group Zalo: `https://zalo.me/g/xkofsw6frkf7qrigizmq`; kiểm tra URL trong code khi sửa khu vực này |

Đây là danh mục chức năng hiện có/theo lịch sử triển khai. Mỗi luồng cần được test lại trên bản APK/IPA và backend tương ứng sau thay đổi lớn.

## 5. Xác thực và dữ liệu người dùng

### Firebase

1. Client dùng Firebase SDK để đăng nhập email/password hoặc Google.
2. Luồng email/password yêu cầu xác minh email trước khi chấp nhận phiên ứng dụng.
3. Client gửi Firebase ID token đến `POST /api/auth/firebase`.
4. Backend dùng `backend/src/config/firebase.js`: đọc Firebase Admin JSON từ `FIREBASE_SERVICE_ACCOUNT_FILE`, đối chiếu project ID; gọi `verifyIdToken(token, true)` để kiểm tra cả token đã bị thu hồi.
5. Claims phải có `email_verified === true`, email hợp lệ và provider thuộc `password` hoặc `google.com`.
6. Backend liên kết/tìm người dùng MongoDB qua `firebaseUid`; kiểm tra trạng thái tài khoản.
7. Phiên Firebase được phân biệt bằng chuỗi `firebase:<ID_TOKEN>`; request bảo vệ gửi `Authorization: Bearer firebase:<ID_TOKEN>`.
8. `AuthService.getToken()` lấy ID token mới từ Firebase khi cần; phiên lỗi được dọn và phát thông báo thay đổi phiên.

`firebase:` chỉ là quy ước phân biệt loại token trong ứng dụng, không phải cơ chế mã hóa hoặc thuật toán ký riêng.

### Legacy và đổi mật khẩu

- Code vẫn có đường JWT/bcryptjs để tương thích tài khoản cũ; đăng ký legacy bị chặn khi cấu hình Firebase theo logic auth hiện tại.
- JWT middleware so `tokenVersion` trong token với user để vô hiệu hóa phiên sau đổi mật khẩu.
- Firebase có endpoint đổi mật khẩu và kiểm tra token riêng. Cần test lại: đổi mật khẩu → phiên cũ bị từ chối → đăng nhập lại thành công.
- Quên mật khẩu dùng Firebase gửi email reset. Không cần tự xây mail server để gửi email xác nhận/reset Firebase.
- Không lưu mật khẩu Google vào MongoDB. Không tuyên bố các trường hồ sơ đã được mã hóa ở cấp ứng dụng nếu chưa có code chứng minh.
- Hiện có token/session marker được lưu trong `shared_preferences`; không mô tả nhầm là đã dùng secure storage. Nếu muốn tăng bảo mật lưu trữ, đánh giá và triển khai thành nhiệm vụ riêng.
- `local_auth` xác thực sinh trắc học trên thiết bị, app không thu thập mẫu vân tay để lưu MongoDB.

## 6. Redis và hosting: phân biệt code với trạng thái cloud

- Người dùng đã tạo Upstash Redis và báo đã điền cấu hình trước đây.
- Code hỗ trợ cache GET công khai chùa/kinh sách, TTL 60 giây, khóa gồm URL/query; request có Authorization không dùng cache công khai.
- Không cache hồ sơ, lịch cá nhân hoặc token trong cơ chế này. **Chưa có bằng chứng Redis được dùng làm kho phiên/token.**
- Rate limit theo IP: mức tổng API và mức riêng cho nhóm auth; xem source và `docs/REDIS.md` trước khi đổi quota.
- Khi Redis lỗi, cache cho phép đọc lại MongoDB; limiter đã bật có cơ chế từ chối an toàn theo middleware.
- Cần kiểm tra `TRUST_PROXY_HOPS` phù hợp Render trước khi bật rate limit production. Sai cấu hình có thể gom nhiều người dùng vào cùng một IP.
- Một số câu trong `docs/REDIS.md` còn là trạng thái cũ (“chưa có Redis thật”); không lấy đó làm bằng chứng cloud chưa cấu hình.
- Backend được người dùng xác nhận đã triển khai Firebase thành công; Render dashboard từng dùng service `srv-dbbgpp5g1s2s738ugk7g`.
- Render Free có thể ngủ khi không hoạt động; Cloudinary được dùng để avatar tồn tại qua các lần deploy.
- Không cần máy cá nhân chạy Docker để điện thoại truy cập backend Render đang hoạt động.
- Không dùng `10.0.2.2` cho điện thoại thật qua mạng khác; đó là địa chỉ đặc biệt của Android emulator.

## 7. Dataset và ảnh — việc đang chờ người dùng kiểm tra

Số lượng bản ghi trong JSON ở thời điểm viết:

| File | Số lượng |
|---|---:|
| `backend/data/chua/temples.json` | 27 chùa |
| `backend/data/kinh_phat/scriptures.json` | 19 kinh/chú |
| `backend/data/phat/buddhist_figures.json` | 40 nhân vật |
| `backend/data/quotes/quotes.json` | 350 câu |

Số này là **file trong Git**, không phải số lượng vừa xác minh trong MongoDB production. Tài liệu cũ nói “21 chùa” đã không còn phản ánh dataset file hiện tại.

### Đợt import gần nhất

- Nguồn người dùng cung cấp: `D:/data chua/tọa độ chùa đã có format.txt` và `D:/data chua/Hình chùa 123/`.
- Đã nhập tọa độ và ảnh vào file dữ liệu chùa; có 83 ảnh mới từ đợt import được đưa vào repository.
- Người dùng yêu cầu “import nhưng đừng seed, để tôi kiểm tra trước”. Yêu cầu này vẫn cần tôn trọng.
- Preview: `docs/XEM_TRUOC_DU_LIEU_CHUA.html`.
- Biên bản: `docs/KIEM_TRA_IMPORT_CHUA_2026-10-26.md`.
- Hướng dẫn thêm nhiều ảnh: `docs/THEM_ANH_CHUA.md`.
- `thumbnail` là ảnh bìa; `images` là danh sách ảnh album. Dùng `/img/chua/ten-file.png` hoặc HTTPS URL, không dùng đường dẫn Windows trong API.
- Render chạy Linux nên phải đúng chữ hoa/thường trong tên ảnh.
- Đưa file JSON/ảnh lên GitHub không tự làm MongoDB đổi dữ liệu. Chỉ seed/migrate khi người dùng yêu cầu, đã xác nhận đúng database và có backup phù hợp.

### Phật ngôn

- Dataset quote đang lưu nhiều câu ở dạng đoạn văn; client `Quote.displayContent` khôi phục xuống dòng từ bản đồ trong `dhammapada_lines.dart` khi code/source và nội dung chuẩn hóa khớp.
- Bản đồ này có 330 câu khớp văn bản nguồn; các câu không khớp được giữ nguyên để tránh đoán/sửa nội dung kinh.
- Nếu API đã trả newline, client giữ nguyên.
- `backend/src/utils/quote-content.js` xử lý nội dung demo cũ bằng cách chọn câu từ catalog đang active và loại trừ câu trước.
- Trong lần CI của PR #14 phát hiện `quote-196` vẫn là mẫu “Nội dung câu kệ 196”. Đã sửa resolver để nhận diện/bỏ qua mẫu `Nội dung câu kệ <số>`, chưa thay nội dung JSON/DB bằng câu kinh tự suy đoán.
- `backend/test/quote-content.test.js` đã cập nhật hợp đồng test theo dataset hiện tại: nội dung trả về phải khớp catalog, có nội dung, không là demo và không lặp mã loại trừ.

## 8. Build Android, iOS và khóa ký

### Android trên laptop

```powershell
cd D:\LTDT\AppTungKinh\apptungkinh\client
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --release --dart-define-from-file=firebase-config.json

# Đổi tên file để gửi cho người dùng, giữ cả bản gốc:
Copy-Item build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\HanhTrinhAnNhien.apk
```

Flutter không có tham số build trực tiếp tên APK theo yêu cầu trên. Đổi tên file không làm đổi package ID hoặc khóa ký.

**Lưu ý thực tế rất quan trọng:** `client/android/app/build.gradle.kts` hiện định nghĩa signing config release nhưng trong `buildTypes.release` đang chọn `signingConfigs.getByName("debug")`. Đây là hiện trạng source đã kiểm tra, không được ghi rằng APK release hiện chắc chắn ký khóa release riêng. Nếu người dùng yêu cầu phát hành chính thức, cần xử lý việc chọn khóa và xác minh chữ ký thực tế trước.

- Khóa release cũ và `client/android/key.properties` vẫn được giữ trên laptop, bị Git bỏ qua; không tạo lại/ghi đè khóa.
- Lịch sử từng tạo keystore RSA 3072 và thêm fingerprint Firebase; phải lấy fingerprint từ khóa thực sự dùng để ký bản đang test.
- Đổi khóa ký có thể khiến không cài đè APK cũ hoặc Google Sign-In lỗi.
- `client/android/gradle.properties`: heap 3G, metaspace 1G, workers 2, tắt parallel; tắt Kotlin incremental, compiler in-process để xử lý lỗi cache/build Windows từng gặp.
- Build gần nhất trong lần PR #14: **APK debug thành công**, tại `client/build/app/outputs/flutter-apk/app-debug.apk`.
- Gradle cảnh báo plugin Firebase/NFC còn áp dụng KGP; chưa nâng dependency hàng loạt vì cảnh báo này.

### iOS và Sideloadly

- Người dùng không có Mac và không muốn mua Apple Developer; đã chọn build qua GitHub Actions macOS, tạo IPA chưa ký rồi ký/cài bằng Sideloadly.
- Người dùng xác nhận IPA đã chạy thành công trước đợt tái cấu trúc.
- Workflow `.github/workflows/ios-sideload.yml` chạy thủ công, dùng macOS runner, thư mục làm việc `client/`.
- `scripts/prepare-ios-sideload.py` chỉ dành cho checkout CI tạm: tạo cấu hình iOS trong `client/`, tạo URL scheme Google và bỏ NFC entitlements cho bản sideload.
- Bản sideload này **tắt NFC**; không hứa rằng Apple ID miễn phí có thể dùng toàn bộ NFC như Android.
- Source iOS thông thường vẫn có entitlement NFC; không tự xóa nó trong source để giải quyết lỗi ký bản thường.
- Xung đột đã gặp: Firebase iOS SDK 13 yêu cầu GTMSessionFetcher >=4, GoogleSignIn iOS 9 yêu cầu <4. Đã giữ nhánh `firebase_core 4.x` và `firebase_auth 6.x` để dùng Firebase iOS SDK 12 tương thích. Không tự nâng `firebase_core` lên 5.x mà chưa kiểm tra dependency native.
- Khi dùng máy Mac mới, chạy lại `flutter pub get` sau khi đổi vị trí dự án để sinh cấu hình đúng đường dẫn.
- Không có kết quả build IPA mới sau chuyển `client/` trong lần kiểm tra PR #14; mới xác nhận script iOS test và cập nhật workflow.

## 9. Biến môi trường và cấu hình cần biết

Không chèn giá trị bí mật vào file bàn giao. Lấy cấu hình qua chủ dự án hoặc màn hình môi trường được cấp quyền.

### Backend

| Biến | Vai trò |
|---|---|
| `NODE_ENV` | development/production |
| `PORT` | Cổng server, thường 3000; hosting có thể cấp |
| `MONGODB_URI` | URI database, thường có credential bí mật |
| `MONGODB_DATABASE` | Tên database |
| `JWT_SECRET` | Bí mật ký token legacy |
| `JWT_EXPIRES_IN` | Hạn JWT, cấu hình Render mẫu là `7d` |
| `FIREBASE_PROJECT_ID` | Project Firebase backend xác minh |
| `FIREBASE_SERVICE_ACCOUNT_FILE` | Đường dẫn JSON Firebase Admin |
| `AVATAR_STORAGE` | `local` hoặc `cloudinary` |
| `CLOUDINARY_CLOUD_NAME` | Tên cloud |
| `CLOUDINARY_API_KEY` | API key |
| `CLOUDINARY_API_SECRET` | Secret ký upload |
| `UPSTASH_REDIS_REST_URL` | REST endpoint Redis |
| `UPSTASH_REDIS_REST_TOKEN` | Token Redis, chỉ backend |
| `REDIS_RATE_LIMIT_ENABLED` | Bật limiter khi đã kiểm tra proxy |
| `TRUST_PROXY_HOPS` | Số proxy tin cậy; local trực tiếp thường 0 |
| `TEST_MONGODB_URI` | URI MongoDB test, dùng trong Compose/test |

Render Secret File được hướng dẫn đặt tên `firebase-service-account.json`; biến đường dẫn thường trỏ `/etc/secrets/firebase-service-account.json`. Kiểm tra lại dashboard thực tế. `render.yaml` không khai báo đầy đủ Firebase/Redis, nên không suy ra chúng không tồn tại trong Render Environment.

**Hiện không có `backend/.env.example` trong checkout đã kiểm tra.** Một số README cũ có thể nói có; đọc docs và code, không hướng dẫn copy file không tồn tại.

### Flutter và GitHub Actions Variables

| Biến | Nơi dùng |
|---|---|
| `API_BASE_URL` | Android/iOS/web; dùng endpoint HTTPS thật cho điện thoại |
| `FIREBASE_PROJECT_ID` | Firebase client |
| `FIREBASE_API_KEY` | API key client Android; cũng là tên field trong JSON build iOS |
| `FIREBASE_APP_ID` | Firebase app ID Android |
| `FIREBASE_IOS_APP_ID` | Firebase app ID iOS |
| `FIREBASE_MESSAGING_SENDER_ID` | Sender/project number |
| `GOOGLE_WEB_CLIENT_ID` | Google server/web OAuth client ID |
| `GOOGLE_IOS_CLIENT_ID` | OAuth client ID iOS |
| `FIREBASE_IOS_API_KEY` | Tên variable riêng trong workflow iOS; script ánh xạ sang `FIREBASE_API_KEY` trong JSON |

File riêng hiện có trên laptop: `client/firebase-config.json`, `client/firebase-config.ios.json`. File mẫu nằm cùng thư mục. Các giá trị `--dart-define` đi vào binary, tuyệt đối không đặt Firebase Admin JSON, JWT secret hay Redis token ở đây.

Các file native cần đối chiếu khi thay Firebase/Google: `client/android/app/google-services.json`, `client/ios/Runner/GoogleService-Info.plist`, `client/ios/Flutter/Firebase.local.xcconfig`, URL scheme trong iOS plist và SHA fingerprint Android. Kiểm tra sự tồn tại thực tế, không suy ra tất cả được commit.

CD GHCR dùng `secrets.GITHUB_TOKEN` do GitHub cấp. Không cần tạo personal token đưa vào Flutter để build app.

## 10. CI/CD và quy tắc Git đã được xác nhận

### CI

`.github/workflows/ci.yml` chạy khi PR vào `main`, push `main` hoặc chạy thủ công:

1. Windows: test an toàn script CD local.
2. Ubuntu: Flutter pub get theo lockfile, analyze, 64 test ở lần xác nhận gần nhất, coverage.
3. Ubuntu: backend chạy Docker Compose test, MongoDB 7 replica set `rs0` trên tmpfs; test không dùng database production.
4. Android debug APK chạy sau Flutter/backend thành công; artifact từ `client/build/`.

### CD

- `.github/workflows/cd.yml`: sau CI push main thành công, build image backend đúng SHA, push GHCR.
- `render.yaml`: Docker context `./backend`, Dockerfile `./backend/Dockerfile`, branch main, free plan, `/api/health`, `autoDeployTrigger: checksPass`.
- GitHub xanh không tự chứng minh Render đã deploy/health/DB đúng; kiểm tra deployment khi cần.
- Còn script CD local Windows trong `scripts/`; không tự cài lại Scheduled Task hay runner. Người dùng từng bị cửa sổ PowerShell bật liên tục do kiểm tra Docker và rất khó chịu.
- Khi cần background process Windows, dùng chế độ ẩn phù hợp; không tạo task lặp nếu chưa được yêu cầu.

### Branch protection

Push trực tiếp `main` đã bị GitHub từ chối với hai quy tắc:

1. Thay đổi phải qua Pull Request.
2. Nhánh không được chứa merge commit mới.

Vì vậy dùng nhánh làm việc → PR → CI xanh → squash merge. Không tắt rule hoặc force push để vượt qua.

### Sự cố Git vừa xử lý

- Người dùng đổi nhánh local thành main và chạy `pull --rebase` khi lịch sử còn PR frontend/revert, gây xung đột.
- Đã sao lưu xung đột trong `.local-cd/before-rebase-recovery/`, abort rebase, giữ commit cleanup `d9fc9ab`.
- Đã tạo merge local giữ nội dung mới, nhưng GitHub chặn merge commit/direct push.
- Đã tạo nhánh `codex/client-layout-publish` từ `origin/main`, đưa nội dung đã kiểm thử sang, mở PR #14.
- Sau sửa test Phật ngôn và bộ lọc demo, cả bốn job CI đều thành công trên head `3af025900c5154289793f89a8a7b53ef43139cf5`.
- PR được squash merge thành `7d43718`.
- Local main đã đồng bộ với origin/main; đã sửa cấu hình upstream bị lặp.
- Nhánh dự phòng `codex/backup-main-before-pr14` giữ lịch sử main local trước squash. Còn các checkout/backup cũ trong `.local-cd/`; không tự xóa nếu chưa biết mục đích.
- Từng có PR không cập nhật head sau push. Đóng/mở lại chính PR đã làm GitHub nhận commit mới và chạy CI. Chỉ dùng khi đã đối chiếu refs thật, không làm thành quy trình mặc định.

## 11. Lịch sử yêu cầu theo nhóm để không mất ngữ cảnh

1. Đánh giá backend và hoàn thiện luồng chính, quyền truy cập/lưu lịch, phiên đăng nhập sau đổi mật khẩu, test đăng ký → đăng nhập → NFC → tem → lịch sử.
2. Thêm nút Check-in NFC ở góc trên phải màn hình chùa; người dùng xác nhận NFC Android quét thành công.
3. Sửa truy cập API giữa emulator, điện thoại thật, Wi-Fi khác/4G; ban đầu dùng Docker local/Cloudflare Tunnel, sau chuyển Render.
4. Thiết lập CI rồi CD; giải thích quy trình dùng; repository public nên tránh self-hosted runner nhận code PR không tin cậy.
5. Khắc phục Docker Desktop và PowerShell tự bật; cần tránh tái tạo vấn đề này.
6. Deploy backend miễn phí Render, Cloudinary avatar, MongoDB; thiết lập Firebase Admin trên Render.
7. Thêm sinh trắc học, Google login, email đăng ký phải xác minh, quên mật khẩu; xử lý tính tương thích legacy và token.
8. Tạo khóa release/fingerprint Firebase và các hướng dẫn build APK; hiện trạng chọn signing config cần kiểm tra như mục 8.
9. Thêm Upstash Redis cho cache và chống spam API; người dùng đã báo tạo/điền cấu hình.
10. Tạo hướng dẫn clone/setup, góp code, báo cáo tổng kết và tài liệu bàn giao nhiều lần. Báo cáo cũ hiện ở `docs/reports/`.
11. Sửa ảnh avatar trang chủ, random Phật ngôn và xuống dòng đúng văn bản; chỉnh UI card, nội dung bo góc, ảnh nhân vật chữ nhật.
12. Import dataset/ảnh mới, album chùa vuốt nhiều ảnh; sửa ảnh mất sau seed và hướng dẫn khai báo ảnh.
13. Trang trí trang đọc kinh; thêm tự cuộn chỉnh tốc độ, đưa điều khiển lên trên; PR frontend có thêm tiếng mõ.
14. Lịch/ngày lễ: dựa vào nội dung `Lịch.docx`, không sao chép nguyên bố cục Word; người dùng yêu cầu bỏ sự kiện cũ và dùng nội dung mới chính xác.
15. Cộng đồng dùng group Zalo của nhóm; thêm GPS chùa gần, thông báo ngoài app và lễ sắp tới; người dùng từng bỏ hạng mục giao diện khỏi nhóm ba việc đó.
16. Port iOS miễn phí bằng GitHub macOS/Sideloadly, cấu hình Firebase iOS, sửa xung đột Firebase/Google native; người dùng xác nhận IPA chạy được.
17. Import tọa độ/ảnh chùa mới chỉ vào file, không seed; sửa build Android; revert nhầm push; kéo/test nhánh `locfrontend`, tích hợp PR #13.
18. Cài CodeGraph vào dự án để AI tìm hiểu code nhanh; đã có `AGENTS.md`, `.codex/config.toml`, index cục bộ và cấu hình loại trừ bí mật.
19. Tổ chức `client/`, giữ backend và CI ở gốc, đưa báo cáo vào docs; push/merge lên main qua PR #14 sau CI xanh.
20. Người dùng muốn tên APK `HanhTrinhAnNhien.apk`: đã hướng dẫn build rồi Copy-Item đổi tên.
21. Yêu cầu hiện tại: tạo **một file bàn giao cho AI khác, không đưa vào báo cáo**. File này đáp ứng yêu cầu đó; chưa có nhiệm vụ tính năng mới được giao sau lần merge main.

## 12. Kết quả xác nhận và giới hạn

| Kiểm tra | Kết quả đã có |
|---|---|
| Flutter analyze local sau chuyển client | Không có issue |
| Flutter test local | 64 test đạt |
| Python test chuẩn bị iOS | 3 test đạt |
| Android debug APK local | Build thành công sau chuyển client |
| CI head PR #14 cuối cùng | Flutter, backend, local CD, Android APK đều success |
| PR #14 | Đã squash merge vào main |
| main laptop và origin/main | Cùng `7d43718`, sạch trước khi thêm file bàn giao này |
| Seed dataset chùa mới | Chưa thực hiện trong đợt import này |
| IPA sau tái cấu trúc client | Chưa build/xác nhận lại trong lần này |
| Render/Redis production ở thời điểm đọc file | Cần kiểm tra cloud, không suy ra từ code/test mock |
| Luồng thực tế nhiều người dùng | Cần test máy thật và môi trường backend đang deploy |

Không cần chạy lại toàn bộ kiểm thử chỉ để đọc file Markdown. Khi sửa code, chọn kiểm thử phù hợp với thay đổi.

## 13. Đề xuất công việc tiếp theo — chỉ làm khi được yêu cầu

1. Nếu người dùng muốn phát hành release: sửa lựa chọn khóa release, xác minh fingerprint/chữ ký và khả năng cài đè; backup khóa trước, không tạo lại.
2. Kiểm tra Render đã deploy commit main mới, health/API và ảnh trả đúng; kiểm tra Redis/proxy thật trước tăng mức bảo vệ.
3. Cho người dùng xem preview dataset 27 chùa; chỉ sau khi duyệt mới lập kế hoạch seed/migrate và backup DB.
4. Build lại IPA từ cấu trúc `client/` bằng workflow để xác nhận toàn bộ đường dẫn iOS; test Google login/email/QR/sinh trắc học trên iPhone.
5. Test end-to-end hai tài khoản: đăng ký → xác minh → login → NFC Android → tem → lịch sử → đổi mật khẩu/đăng xuất → phiên cũ bị từ chối.
6. Kiểm tra đủ ảnh chùa/nhân vật, không còn placeholder Phật ngôn trong dữ liệu hiển thị, giữ nguyên bản dịch kinh.
7. Cập nhật tài liệu kỹ thuật cũ có đường dẫn/trạng thái lỗi thời; không tự viết lại báo cáo môn học.
8. Nếu cần gọn repository hơn, đề xuất loại artifact tạm `tmp/docx-report/` khỏi tracking nhưng giữ bản cần thiết; không xóa âm thầm tài liệu đã commit.

## 14. Tài liệu kỹ thuật nên đọc đúng nhiệm vụ

- `docs/CAU_TRUC_DU_AN.md`: cấu trúc mới và lệnh chạy.
- `docs/HUONG_DAN_SETUP.md`: clone/setup nhóm.
- `docs/FIREBASE_AUTH.md`, `docs/PASSWORD_RESET.md`, `docs/BIOMETRIC_LOCK.md`.
- `docs/IOS_SIDELOAD.md`, `docs/IOS_SETUP.md`, `docs/RELEASE_SIGNING.md`.
- `docs/CI.md`, `docs/CD.md`, `docs/RENDER_DEPLOY.md`, `docs/REDIS.md`.
- `docs/GPS_VA_NHAC_LICH.md`, `docs/THEM_ANH_CHUA.md`.
- `docs/KIEM_TRA_IMPORT_CHUA_2026-10-26.md`, `docs/XEM_TRUOC_DU_LIEU_CHUA.html`.
- `docs/reports/`: chỉ dùng tham khảo lịch sử; source hiện tại và kết quả xác minh mới hơn được ưu tiên khi có mâu thuẫn.

## 15. Prompt để người dùng dùng với AI mới

```text
Hãy đọc AI_HANDOFF.md ở gốc repository trước khi làm việc. Đây là ngữ cảnh bàn giao
kỹ thuật, không phải báo cáo học thuật. Sau đó đọc AGENTS.md, kiểm tra nhánh Git,
thay đổi chưa commit và source liên quan đến yêu cầu mới của tôi.

Ứng dụng Flutter nằm trong client/, backend trong backend/. Main đã tích hợp
PR #14 và từng qua CI. Không tự seed MongoDB, không force push, không làm mất
khóa ký hoặc công việc chưa commit. Dùng PR + squash merge theo rule của repo.
Không đưa private key/token vào chat, client hoặc GitHub. Những trạng thái cloud
và kiểm thử máy thật phải được xác minh, không đoán từ tài liệu cũ.

Yêu cầu tiếp theo của tôi là: [ghi việc muốn thực hiện ở đây].
Hãy thực hiện và kiểm thử phần liên quan, rồi báo ngắn gọn kết quả và điểm chưa xác minh.
```

---

File bàn giao này được tạo riêng theo yêu cầu ngày 28/10/2026. Không chỉnh mã ứng dụng, không seed và không tự commit/push chỉ để tạo tài liệu này.
