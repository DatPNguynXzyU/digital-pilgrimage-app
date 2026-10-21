  # 🪷 Hành Trình An Nhiên (Digital Pilgrimage)

  <p align="center">
    <b>Ứng dụng tra cứu chùa, kinh chú, nhân vật Phật giáo và trải nghiệm hành hương số hóa</b>
  </p>

  <p align="center">
    Một giải pháp công nghệ toàn diện hỗ trợ Phật tử và những người yêu mến văn hóa Phật giáo: tra cứu danh lam cổ tự, học hỏi kinh pháp, theo dõi lịch âm dương và ngày lễ, check-in viếng chùa qua QR / NFC và lưu giữ hành trình với Sổ tem điện tử độc bản.
  </p>

  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white" alt="Node.js" />
    <img src="https://img.shields.io/badge/Express-5.x-black?logo=express&logoColor=white" alt="Express" />
    <img src="https://img.shields.io/badge/MongoDB-Atlas-47A248?logo=mongodb&logoColor=white" alt="MongoDB" />
    <img src="https://img.shields.io/badge/Firebase-Auth-FFCA28?logo=firebase&logoColor=black" alt="Firebase" />
    <img src="https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker&logoColor=white" alt="Docker" />
    <img src="https://img.shields.io/badge/Render-Deployable-46E3B7?logo=render&logoColor=black" alt="Render" />
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Web-orange" alt="Platform" />
  </p>

  ---

  ## 📖 Mục lục

  - [Giới thiệu](#-giới-thiệu)
  - [Tính năng nổi bật](#-tính-năng-nổi-bật)
  - [Kiến trúc hệ thống](#-kiến-trúc-hệ-thống)
  - [Công nghệ sử dụng](#-công-nghệ-sử-dụng)
  - [Cấu trúc mã nguồn](#-cấu-trúc-mã-nguồn)
  - [Mô hình dữ liệu](#-mô-hình-dữ-liệu-database)
  - [Danh sách RESTful API](#-danh-sách-restful-api)
  - [Hướng dẫn cài đặt & Khởi chạy](#-hướng-dẫn-cài-đặt--khởi-chạy)
  - [Kiểm thử (Testing)](#-kiểm-thử-testing)
  - [Triển khai & CI/CD](#-triển-khai--cicd)
  - [Quy trình làm việc nhóm](#-quy-trình-làm-việc-nhóm)
  - [Bảo mật & Biến môi trường](#-bảo-mật--biến-môi-trường)
  - [Lộ trình phát triển](#-lộ-trình-phát-triển-roadmap)
  - [Tài liệu tham khảo](#-tài-liệu-tham-khảo-chuyên-sâu)

  ---

  ## 📖 Giới thiệu

  **Hành Trình An Nhiên (Digital Pilgrimage)** là ứng dụng di động kết hợp nền tảng backend hiện đại, được thiết kế để kết nối giữa giá trị tâm linh truyền thống và công nghệ số tiện ích.

  Dự án mang đến cho người dùng một công cụ tra cứu văn hóa Phật giáo đáng tin cậy, đồng thời tạo ra trải nghiệm viếng chùa hiện đại và ý nghĩa: lưu giữ dấu ấn chuyến đi bằng tem điện tử, thống kê các cột mốc hành hương, xem lịch âm dương cùng các ngày đại lễ, đọc kinh chú mọi lúc mọi nơi và bảo vệ thông tin cá nhân với khóa sinh trắc học an toàn.

  > 🪷 **Triết lý sản phẩm:** *Công nghệ hỗ trợ trải nghiệm hành hương — không thay thế trải nghiệm tôn giáo thực tế.*

  ---

  ## ✨ Tính năng nổi bật

  ### 🏠 1. Trang chủ & Khám phá
  - **Lịch tuần & Ngày âm lịch:** Hiển thị trực quan ngày dương, ngày âm, can chi và sự kiện trong ngày.
  - **Phật ngôn mỗi ngày (Daily Quote):** Hiển thị câu trích dẫn Phật pháp, lời dạy của Đức Phật ngẫu nhiên mỗi lần mở ứng dụng với API chuyên biệt.
  - **Kinh Pháp Cú (Dhammapada):** Thẻ giới thiệu và đọc nhanh các câu kệ Pháp Cú chọn lọc.
  - **Gợi ý chùa nổi bật:** Danh sách các ngôi chùa tiêu biểu giúp người dùng dễ dàng lên kế hoạch viếng thăm.

  ### 📅 2. Lịch âm dương & Sự kiện Phật giáo
  - **Lịch vạn niên & Âm lịch:** Chuyển đổi chính xác ngày âm/dương theo múi giờ Việt Nam.
  - **Danh mục đại lễ Phật giáo:** Tra cứu chi tiết ý nghĩa và ngày diễn ra các dịp lễ lớn trong năm (Phật Đản, Vu Lan, Vu Lan Báo Hiếu, Thành Đạo, Quan Thế Âm, v.v.).
  - **Quản lý sự kiện tu tập cá nhân:** Thêm, sửa, xóa các ngày tụng kinh, cúng bái, ăn chay hoặc nhắc nhở hành hương cá nhân, đồng bộ trực tiếp với backend.
  - **Nhắc nhở thông minh:** Tùy chọn cấu hình nhắc trước các ngày rằm, mùng một và ngày lễ.

  ### 📖 3. Kho tàng Kinh sách & Bài chú
  - **Phân loại rõ ràng:** Tách biệt giữa các bài **Kinh** (Kinh Dược Sư, Kinh Phổ Môn, Kinh A Di Đà, v.v.) và các bài **Chú** (Chú Đại Bi, Chú Dược Sư, Chú Lăng Nghiêm, v.v.).
  - **Tìm kiếm tức thì:** Tìm kiếm theo tên kinh, nội dung hoặc phân loại.
  - **Giao diện đọc tối ưu:** Trình đọc kinh thiết kế thanh tịnh, rõ ràng, tối ưu cho việc tụng đọc trên thiết bị di động.

  ### 🛕 4. Tra cứu danh lam & Thông tin chùa
  - **Thông tin chi tiết:** Tên chùa, hệ phái, địa chỉ, năm thành lập, trụ trì, lịch sử hình thành và nét đặc sắc kiến trúc.
  - **Bộ sưu tập hình ảnh:** Khám phá khuôn viên, chánh điện và tượng Phật qua hình ảnh sắc nét.
  - **Định vị & Bản đồ:** Mở bản đồ dẫn đường trực tiếp đến chùa qua `url_launcher`.

  ### 🧘 5. Nhân vật Phật giáo (Phật & Bồ Tát)
  - **Danh sách tôn kính:** Giới thiệu chư Phật, chư Đại Bồ Tát (Đức Phật Thích Ca Mâu Ni, Phật A Di Đà, Bồ Tát Quán Thế Âm, Bồ Tát Địa Tạng, v.v.).
  - **Hạnh nguyện & Lịch sử:** Đọc tiểu sử, đại nguyện, ngày vía và hình tượng đặc trưng của từng vị.

  ### 📷 6. Quét mã QR tại chùa
  - Hỗ trợ quét mã QR đặt tại các khuôn viên chùa đối tác (ví dụ định dạng: `TEMPLE:chua-giac-lam`).
  - Ứng dụng giải mã payload, tự động điều hướng đến trang chi tiết chùa tương ứng.

  ### 📱 7. Chạm thẻ NFC Check-in
  - **Tương tác chạm một chạm:** Đọc thẻ NFC (chuẩn NDEF / UID) được tích hợp tại các điểm đón tiếp ở chùa.
  - **Check-in tự động:** Xác thực vị trí và nhận tem viếng chùa tức thì sau khi chạm thẻ.
  - **Công cụ liên kết thẻ (`bind-nfc`):** Hỗ trợ ban quản trị dễ dàng gán UID của thẻ NFC vật lý vào chùa trên hệ thống.

  ### 🏮 8. Sổ tem viếng chùa (Digital Temple Stamps)
  - **Tem điện tử độc bản:** Mỗi lần check-in thành công tại chùa, người dùng sẽ nhận được một con tem số ghi nhận địa danh và thời khắc viếng thăm.
  - **Trang trưng bày Sổ tem:** Trình bày bộ sưu tập tem đẹp mắt, lưu giữ kỷ niệm cho từng chặng đường tâm linh.

  ### 📊 9. Lịch sử & Thống kê hành hương
  - **Nhật ký hành hương:** Danh sách chi tiết các lần viếng chùa, ghi nhận ngày giờ và phương thức check-in (QR / NFC).
  - **Thống kê tổng quan:** Tổng số chùa đã đi, tổng số lần viếng, biểu đồ hành hương theo thời gian.

  ### 👤 10. Tài khoản & Xác thực an toàn
  - **Xác thực đa dạng:**
    - Đăng ký & Đăng nhập bằng Email / Mật khẩu (JWT).
    - Tích hợp **Firebase Authentication**: Hỗ trợ đăng nhập bằng tài khoản Google (Google Sign-In) và đăng ký email kèm xác thực qua email.
  - **Hồ sơ cá nhân:** Cập nhật họ tên, đổi mật khẩu an toàn.
  - **Ảnh đại diện linh hoạt:** Hỗ trợ tải ảnh đại diện lên bộ lưu trữ đám mây **Cloudinary** hoặc lưu trữ cục bộ.

  ### 🔒 11. Khóa ứng dụng bằng Sinh trắc học (Biometric Lock)
  - Khóa app bằng **Vân tay / Face ID** cục bộ qua `local_auth`.
  - Tự động che giấu màn hình ứng dụng khi thoát ra nền hoặc khóa máy.
  - Hỗ trợ tùy chọn đăng xuất khẩn cấp để mở lại bằng mật khẩu nếu vân tay không nhận diện được.

  ### ⚡ 12. Cơ chế sẵn sàng Backend (Cold Start Gate)
  - Tích hợp màn hình chờ thông minh tự động kiểm tra `GET /api/health` khi ứng dụng khởi chạy.
  - Khắc phục triệt để độ trễ "ngủ đông" (cold start) của các gói máy chủ miễn phí (như Render Free Tier), có thông báo trực quan và nút thử lại khi kết nối mạng chập chờn.

  ---

  ## 🏗️ Kiến trúc hệ thống

  ```mermaid
  flowchart TD
      subgraph Client["📱 Flutter Mobile & Web Client"]
          UI["Flutter Views & Widgets"]
          Gate["BiometricGate & BackendReadyGate"]
          AuthSvc["AuthService & FirebaseIdentity"]
          TempleSvc["TempleService & PilgrimageService"]
          Scan["QR Scanner & NFC Manager"]
      end

      subgraph Security["🔐 Identity & Storage Providers"]
          FA["Firebase Authentication\n(Google Sign-In & Email Verify)"]
          CL["Cloudinary Media CDN\n(Avatar Storage)"]
      end

      subgraph Backend["⚙️ Node.js + Express REST API"]
          MW["Auth Middleware (JWT / Firebase Admin)"]
          Ctrl["Controllers:\nAuth, Temple, Scripture, NFC,\nPilgrimage, Calendar, Figures, Quote"]
          Health["Health Check Route (/api/health)"]
      end

      subgraph Database["🗄️ MongoDB Atlas Cloud"]
          ColUsers[("users")]
          ColTemples[("temples")]
          ColScriptures[("scriptures")]
          ColFigures[("buddhist_figures")]
          ColVisits[("pilgrimage_visits")]
          ColStamps[("temple_stamps")]
          ColNfc[("nfc_tags")]
          ColCal[("calendar_events")]
          ColQuotes[("quotes")]
      end

      UI --> Gate
      Gate --> AuthSvc
      Gate --> TempleSvc
      Scan --> TempleSvc

      AuthSvc -.->|OAuth Token / Verify| FA
      AuthSvc -->|REST API / Bearer JWT| MW
      TempleSvc -->|REST API Request| MW
      UI -->|Direct Upload Avatar| CL

      MW --> Ctrl
      Ctrl --> Database
  ```

  ---

  ## 🛠️ Công nghệ sử dụng

  | Tầng | Công nghệ / Thư viện | Vai trò |
  |---|---|---|
  | **Mobile App (Frontend)** | **Flutter 3.x** & **Dart 3.x** | Xây dựng ứng dụng đa nền tảng (Android, Web, iOS) |
  | **State & Local Storage** | `shared_preferences` | Lưu trữ token JWT, cài đặt khóa vân tay, cờ onboarding |
  | **Quét mã & NFC** | `mobile_scanner`, `nfc_manager` | Quét QR Code qua camera và đọc thẻ NFC NDEF / UID |
  | **Sinh trắc học** | `local_auth` | Xác thực vân tay / Face ID trên thiết bị |
  | **Xác thực mạng xã hội** | `firebase_auth`, `google_sign_in` | Đăng nhập tài khoản Google và xác minh email |
  | **Backend API** | **Node.js** & **Express 5.x** | RESTful API server xử lý logic nghiệp vụ |
  | **Database & ODM** | **MongoDB Atlas** & **Mongoose 9.x** | Lưu trữ dữ liệu NoSQL trên đám mây |
  | **Bảo mật Backend** | `jsonwebtoken`, `bcryptjs`, `firebase-admin` | Mã hóa mật khẩu, cấp phát JWT, xác thực token Firebase |
  | **Xử lý Upload Ảnh** | `multer`, `cloudinary` | Tiếp nhận và đẩy ảnh đại diện người dùng lên CDN Cloudinary |
  | **Container & Deploy** | **Docker**, **Render Blueprint**, **GHCR** | Đóng gói container ứng dụng, deploy tự động khi CI pass |
  | **CI/CD** | **GitHub Actions** | Tự động phân tích lint, chạy kiểm thử và build APK |

  ---

  ## 📂 Cấu trúc mã nguồn

  ```text
  digital-pilgrimage-app/
  ├── .github/
  │   └── workflows/
  │       ├── ci.yml                     # Pipeline CI: test Backend, test Flutter, build APK
  │       └── cd.yml                     # Pipeline CD: build & push Docker image GHCR
  ├── android/                           # Cấu hình dự án Android (Gradle, permissions)
  ├── assets/                            # Tài nguyên tĩnh
  ├── images/                            # Logo, biểu tượng ứng dụng launcher
  ├── docs/                              # Tài liệu kỹ thuật chi tiết
  │   ├── BIOMETRIC_LOCK.md              # Hướng dẫn cơ chế khóa sinh trắc học
  │   ├── FIREBASE_AUTH.md               # Hướng dẫn cấu hình Firebase Auth & Google Sign-In
  │   └── RENDER_DEPLOY.md               # Hướng dẫn triển khai miễn phí trên Render
  ├── backend/                           # Mã nguồn Backend Node.js
  │   ├── data/                          # Dữ liệu hạt giống dạng JSON (chùa, kinh sách)
  │   ├── img/                           # Thư mục lưu ảnh tĩnh cục bộ
  │   ├── src/
  │   │   ├── config/                    # Cấu hình DB, Firebase Admin, Cloudinary
  │   │   ├── controllers/               # Bộ điều khiển xử lý logic từng domain
  │   │   ├── middleware/                # Middleware xác thực JWT, validate form
  │   │   ├── models/                    # Mongoose Schemas (User, Temple, Stamp, v.v.)
  │   │   ├── routes/                    # Định tuyến API Express
  │   │   ├── seed/                      # Script nạp dữ liệu ban đầu và gán thẻ NFC
  │   │   ├── app.js                     # Cấu hình ứng dụng Express
  │   │   └── server.js                  # Điểm khởi động server
  │   ├── test/                          # Kiểm thử backend (API test, avatar storage, claims)
  │   ├── Dockerfile                     # Dockerfile tối ưu cho backend
  │   ├── compose.yaml                   # Docker Compose chạy cục bộ
  │   ├── package.json                   # Dependencies backend
  │   └── .env.example                   # Mẫu biến môi trường backend
  ├── lib/                               # Mã nguồn ứng dụng Flutter
  │   ├── config/                        # Cấu hình API endpoint, AppTheme
  │   ├── models/                        # Data models (Temple, Scripture, User, v.v.)
  │   ├── services/                      # Tầng gọi API và dịch vụ nền (NFC, Auth, Gate)
  │   ├── utils/                         # Tiện ích chuyển đổi âm lịch (lunar calendar)
  │   ├── views/                         # Giao diện màn hình ứng dụng
  │   │   ├── startup/                   # Màn hình Splash & Onboarding
  │   │   ├── trang_chu/                 # Màn hình Trang chủ & Daily Quote
  │   │   ├── lich/                      # Lịch âm dương, ngày lễ & sự kiện tu tập
  │   │   ├── kinh_sach/                 # Danh sách & chi tiết tụng kinh
  │   │   ├── temples/                   # Danh sách & chi tiết chùa
  │   │   ├── buddhist_figures/          # Danh mục chư Phật & Bồ Tát
  │   │   ├── qr/                        # Trình quét mã QR
  │   │   ├── nfc/                       # Trình quét thẻ NFC
  │   │   ├── tai_khoan/                 # Cá nhân, đăng nhập, sổ tem, lịch sử viếng
  │   │   └── main_nav.dart              # Thanh điều hướng chính (Bottom Navigation)
  │   ├── widgets/                       # Thành phần giao diện tái sử dụng
  │   └── main.dart                      # Điểm vào ứng dụng Flutter
  ├── test/                              # Kiểm thử Flutter (unit test, widget test)
  ├── firebase-config.example.json       # Mẫu biến cấu hình Firebase client cho Flutter
  ├── render.yaml                        # Bản thiết kế triển khai tự động trên Render
  ├── pubspec.yaml                       # Quản lý thư viện Flutter
  └── README.md                          # Tài liệu hướng dẫn chính của dự án
  ```

  ---

  ## 🗄️ Mô hình dữ liệu (Database)

  Hệ thống sử dụng cơ sở dữ liệu MongoDB Atlas (tên database mặc định: `hanh_huong_db`). Các collection chính bao gồm:

  | Collection | Mục đích | Các trường tiêu biểu |
  |---|---|---|
  | `users` | Tài khoản người dùng | `email`, `password` (hashed), `fullName`, `avatarUrl`, `firebaseUid`, `authProvider` |
  | `temples` | Danh bạ các chùa | `name`, `slug`, `address`, `description`, `history`, `images`, `qrCode` |
  | `scriptures` | Kho kinh và bài chú | `title`, `slug`, `type` (*Kinh*/*Chú*), `content`, `description`, `order`, `featured` |
  | `buddhist_figures` | Chư Phật & Bồ Tát | `name`, `slug`, `title`, `biography`, `vows`, `feastDays`, `avatarUrl` |
  | `calendar_events` | Sự kiện tu tập cá nhân | `userId`, `title`, `eventDate`, `isLunar`, `reminderMinutes`, `notes` |
  | `quotes` | Phật ngôn mỗi ngày | `code`, `content`, `author`, `source`, `isActive` |
  | `nfc_tags` | Ánh xạ thẻ NFC với chùa | `uid` (mã hex thẻ), `templeId`, `assignedAt`, `status` |
  | `pilgrimage_visits` | Nhật ký các lần viếng chùa | `userId`, `templeId`, `visitedAt`, `checkInMethod` (*QR*/*NFC*), `note` |
  | `temple_stamps` | Sổ tem hành hương điện tử | `userId`, `templeId`, `stampCode`, `issuedAt`, `visitCount` |

  ---

  ## 🌐 Danh sách RESTful API

  Server backend chạy mặc định tại cổng `3000` (hoặc URL Render khi triển khai).

  ### 1. Kiểm tra trạng thái hệ thống
  - `GET /` — Kiểm tra server hoạt động.
  - `GET /api/health` — Kiểm tra kết nối MongoDB phục vụ cho cơ chế khởi động (Health check).

  ### 2. Xác thực & Tài khoản (`/api/auth`)
  - `POST /api/auth/register` — Đăng ký tài khoản bằng email & mật khẩu (JWT).
  - `POST /api/auth/login` — Đăng nhập bằng email & mật khẩu, trả về JWT.
  - `POST /api/auth/firebase` — Đăng nhập hoặc tạo mới người dùng qua Firebase ID Token.
  - `GET /api/auth/me` *(Cần Bearer Token)* — Lấy thông tin tài khoản hiện tại.
  - `PUT /api/auth/profile` *(Cần Bearer Token)* — Cập nhật họ tên người dùng.
  - `POST /api/auth/avatar` *(Cần Bearer Token)* — Tải lên và cập nhật ảnh đại diện (Cloudinary/Local).
  - `PUT /api/auth/change-password` *(Cần Bearer Token)* — Đổi mật khẩu tài khoản native.
  - `PUT /api/auth/firebase/change-password` *(Cần Bearer Token)* — Cập nhật mật khẩu tài khoản Firebase.

  ### 3. Tra cứu chùa (`/api/temples`)
  - `GET /api/temples` — Lấy danh sách chùa (hỗ trợ phân trang, tìm kiếm).
  - `GET /api/temples/:slug` — Lấy chi tiết thông tin chùa theo đường dẫn slug.
  - `GET /api/temples/id/:id` — Lấy chi tiết thông tin chùa theo ObjectId.

  ### 4. Kinh sách & Chú (`/api/scriptures`)
  - `GET /api/scriptures` — Lấy danh sách kinh và chú (lọc theo `type`, `featured`).
  - `GET /api/scriptures/:slug` — Lấy chi tiết bài kinh theo slug kèm nội dung đầy đủ.

  ### 5. Nhân vật Phật giáo (`/api/buddhist-figures`)
  - `GET /api/buddhist-figures` — Lấy danh sách chư Phật, Bồ Tát.
  - `GET /api/buddhist-figures/:slug` — Lấy chi tiết tiểu sử và hạnh nguyện theo slug.

  ### 6. Phật ngôn mỗi ngày (`/api/quotes`)
  - `GET /api/quotes/random?exclude=<code_cu>` — Lấy ngẫu nhiên một câu danh ngôn Phật giáo.

  ### 7. Thẻ NFC (`/api/nfc`)
  - `GET /api/nfc/temple/:uid` — Tra cứu thông tin chùa tương ứng với UID của thẻ NFC (công khai).
  - `GET /api/nfc/tags` — Lấy danh sách thẻ NFC đã liên kết trên hệ thống.
  - `POST /api/nfc/scan` *(Cần Bearer Token)* — Check-in chùa bằng thẻ NFC và ghi nhận tem.

  ### 8. Hành hương & Sổ tem (`/api/pilgrimage`) *(Yêu cầu Bearer Token)*
  - `GET /api/pilgrimage/history` — Lấy lịch sử từng lần viếng chùa của người dùng.
  - `GET /api/pilgrimage/temples` — Lấy danh sách các ngôi chùa độc nhất đã từng ghé thăm.
  - `GET /api/pilgrimage/stats` — Thống kê tổng số lần viếng, số chùa đã viếng, chuỗi ngày viếng.
  - `GET /api/pilgrimage/stamps` — Lấy danh sách các con tem viếng chùa đã thu thập được.

  ### 9. Lịch & Sự kiện tu tập (`/api/calendar-events`) *(Yêu cầu Bearer Token)*
  - `GET /api/calendar-events` — Lấy danh sách sự kiện tu tập cá nhân của người dùng.
  - `GET /api/calendar-events/:id` — Lấy chi tiết một sự kiện.
  - `POST /api/calendar-events` — Tạo mới một sự kiện tu tập/nhắc nhở.
  - `PUT /api/calendar-events/:id` — Cập nhật thông tin sự kiện.
  - `DELETE /api/calendar-events/:id` — Xóa sự kiện tu tập.

  ---

  ## 🚀 Hướng dẫn cài đặt & Khởi chạy

  ### Yêu cầu tiên quyết
  - **Node.js:** phiên bản `18.x` hoặc `20.x` LTS trở lên.
  - **Flutter SDK:** phiên bản `3.13.x` trở lên (Dart SDK `^3.13.3`).
  - **MongoDB:** Database MongoDB Atlas (hoặc MongoDB Community cục bộ).
  - **Git** đã cài đặt trên máy.

  ---

  ### Bước 1: Clone kho mã nguồn

  ```bash
  git clone https://github.com/DatPNguynXzyU/digital-pilgrimage-app.git
  cd digital-pilgrimage-app
  ```

  ---

  ### Bước 2: Cài đặt và cấu hình Backend

  1. Di chuyển vào thư mục backend và cài đặt thư viện:
    ```bash
    cd backend
    npm install
    ```

  2. Tạo file cấu hình môi trường `.env` trong thư mục `backend/`:
    ```env
    PORT=3000
    NODE_ENV=development
    
    # Kết nối MongoDB
    MONGODB_URI=mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net
    MONGODB_DATABASE=hanh_huong_db
    
    # JWT Authentication
    JWT_SECRET=your_super_secret_jwt_key_at_least_32_chars
    JWT_EXPIRES_IN=7d
    
    # Lưu trữ ảnh đại diện (chọn 'local' khi chạy máy cá nhân, hoặc 'cloudinary' khi deploy)
    AVATAR_STORAGE=local
    
    # (Tùy chọn) Cấu hình Cloudinary nếu dùng AVATAR_STORAGE=cloudinary
    CLOUDINARY_CLOUD_NAME=your_cloud_name
    CLOUDINARY_API_KEY=your_api_key
    CLOUDINARY_API_SECRET=your_api_secret
    
    # (Tùy chọn) Cấu hình Firebase Admin nếu kích hoạt xác thực Firebase
    FIREBASE_PROJECT_ID=your_firebase_project_id
    # FIREBASE_SERVICE_ACCOUNT_FILE=/path/to/service-account.json
    ```

  3. Khởi tạo dữ liệu mẫu (Seed Database):
    ```bash
    # Nạp toàn bộ dữ liệu: Chùa, Kinh sách, Phật/Bồ Tát, Lời dạy
    npm run seed
    ```
    *(Ngoài ra có thể seed lẻ từng phần bằng: `npm run seed:temples`, `npm run seed:scriptures`, `npm run seed:figures`, `npm run seed:quotes`)*

  4. *(Tùy chọn)* Gán thẻ NFC vật lý cho một ngôi chùa:
    ```bash
    # Cú pháp: node src/seed/bind-nfc.js <UID_THE_HEX> <SLUG_HOAC_TEN_CHUA>
    node src/seed/bind-nfc.js 04A1B2C3D4E5 chua-giac-lam
    ```

  5. Khởi động Backend ở chế độ phát triển:
    ```bash
    npm run dev
    ```
    Server sẽ lắng nghe tại `http://localhost:3000`. Kiểm tra đường dẫn `http://localhost:3000/api/health` trả về `{ "success": true }`.

  ---

  ### Bước 3: Cài đặt và chạy ứng dụng Flutter

  Mở một cửa sổ dòng lệnh mới tại thư mục gốc của dự án (`digital-pilgrimage-app`):

  1. Cài đặt các gói phụ thuộc:
    ```bash
    flutter pub get
    ```

  2. Kiểm tra tính tương thích thiết bị:
    ```bash
    flutter doctor
    ```

  3. **Chọn môi trường chạy phù hợp:**

    - **Chạy trên trình duyệt Chrome (Web):**
      ```bash
      flutter run -d chrome
      ```

    - **Chạy trên Android Emulator:**
      Trong môi trường giả lập Android, địa chỉ `localhost` của máy host được đại diện bởi `10.0.2.2`:
      ```bash
      flutter run -d <emulator-id> --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
      ```

    - **Chạy trên điện thoại Android thật (qua cùng mạng Wi-Fi LAN):**
      Thay `192.168.1.X` bằng địa chỉ IP mạng nội bộ của máy tính đang chạy backend:
      ```bash
      flutter run --dart-define=API_BASE_URL=http://192.168.1.X:3000/api
      ```

    - **Chạy kèm cấu hình Firebase & Google Sign-In:**
      Tạo file `firebase-config.json` từ mẫu `firebase-config.example.json` và chạy:
      ```bash
      flutter run --dart-define-from-file=firebase-config.json
      ```

  ---

  ### Bước 4: Chạy bằng Docker Compose (Tùy chọn)

  Để chạy toàn bộ backend trong môi trường container chuẩn hóa:

  ```bash
  cd backend
  docker compose up -d --build
  ```
  Dịch vụ sẽ tự động ánh xạ cổng `3000:3000` và bảo toàn thư mục ảnh avatar thông qua Docker Volume `avatar_data`.

  ---

  ## 🧪 Kiểm thử (Testing)

  Dự án áp dụng quy chuẩn kiểm thử tự động ở cả 2 đầu Backend và Frontend:

  ### Kiểm thử Backend (Node.js Native Test Runner)
  Backend sử dụng trình kiểm thử tích hợp sẵn của Node.js không cần cài đặt thêm thư viện nặng:
  ```bash
  cd backend
  npm test
  ```
  Bộ kiểm thử bao gồm:
  - `test/api.test.js`: Kiểm thử toàn diện các route API (auth, temples, scriptures, nfc, pilgrimage, calendar).
  - `test/avatar-storage.test.js`: Kiểm thử xác thực cấu hình lưu trữ ảnh (local vs cloudinary).
  - `test/firebase-claims.test.js`: Kiểm tra kiểm định chữ ký và phân quyền token Firebase.

  ### Kiểm thử Flutter (Flutter Test & Linter)
  ```bash
  # Phân tích tĩnh cú pháp mã nguồn
  flutter analyze

  # Chạy toàn bộ test suites
  flutter test
  ```
  Bộ kiểm thử Flutter bao gồm:
  - `test/widget_test.dart`: Kiểm thử hiển thị widget và luồng điều hướng màn hình.
  - `test/biometric_gate_test.dart`: Kiểm thử trạng thái khóa và mở khóa sinh trắc học.
  - `test/backend_readiness_test.dart`: Kiểm thử cơ chế chờ sẵn sàng của máy chủ.
  - `test/calendar_features_test.dart` & `calendar_sync_test.dart`: Kiểm thử xử lý âm dương và đồng bộ sự kiện.
  - `test/google_login_ui_test.dart`: Kiểm thử giao diện nút đăng nhập Google.

  ---

  ## 🚢 Triển khai & CI/CD

  ### 1. Quy trình CI (GitHub Actions)
  Mỗi commit hoặc Pull Request vào nhánh `main` sẽ kích hoạt quy trình `.github/workflows/ci.yml`:
  1. Kiểm tra mã nguồn Backend với các phiên bản Node.js quy định và chạy `npm test`.
  2. Kiểm tra mã nguồn Flutter bằng `flutter analyze` và `flutter test`.
  3. Biên dịch thử nghiệm gói Android APK (`flutter build apk --debug`).

  ### 2. Triển khai tự động lên Render (Blueprint CD)
  Dự án được cấu hình sẵn file [render.yaml](file:///d:/LTDT/AppTungKinh/apptungkinh/render.yaml) để triển khai dịch vụ Web Service Docker miễn phí trên **Render**:
  - Tự động kích hoạt khi các bước kiểm thử CI đạt (`autoDeployTrigger: checksPass`).
  - Thiết lập sẵn đường dẫn kiểm tra sức khỏe tại `/api/health`.
  - Tích hợp trực tiếp với MongoDB Atlas và CDN Cloudinary để lưu ảnh avatar bền vững.
  - Chi tiết từng bước triển khai xem tại [docs/RENDER_DEPLOY.md](file:///d:/LTDT/AppTungKinh/apptungkinh/docs/RENDER_DEPLOY.md).

  ---

  ## 👥 Quy trình làm việc nhóm

  Để đảm bảo an toàn cho nhánh chính và thuận tiện cộng tác, nhóm áp dụng Git Flow đơn giản:

  1. **Không commit trực tiếp lên `main`**.
  2. **Tạo nhánh chức năng mới:**
    ```bash
    git checkout -b feature/ten-tinh-nang
    # hoặc: git checkout -b fix/loi-can-sua
    ```
  3. **Commit mã nguồn theo quy chuẩn rõ ràng:**
    ```bash
    git add .
    git commit -m "feat: Tích hợp quét mã NFC check-in chùa"
    ```
  4. **Đẩy nhánh lên GitHub và mở Pull Request (PR):**
    ```bash
    git push -u origin feature/ten-tinh-nang
    ```
  5. Đợi GitHub Actions CI chạy kiểm thử màu xanh trước khi tiến hành Review và Merge vào `main`.

  ---

  ## 🔒 Bảo mật & Biến môi trường

  - **Tuyệt đối không commit lên Git:**
    - File cấu hình chứa khóa bí mật: `.env`, `firebase-config.json`, file service account private key (`*.json`).
    - Thư mục thư viện mã nguồn: `node_modules/`, `.dart_tool/`, thư mục build `build/`.
  - **Mật khẩu người dùng:** Luôn được băm (hash) bằng `bcryptjs` với salt rounds an toàn trước khi lưu vào MongoDB.
  - **Khóa sinh trắc học thiết bị:** Sử dụng API hệ điều hành chuẩn (`FlutterFragmentActivity` trên Android, LocalAuthentication framework trên iOS); ứng dụng không thu thập hay truyền tải dữ liệu vân tay/khuôn mặt qua mạng.
  - **Ủy quyền API:** Mọi tài nguyên nhạy cảm (Sổ tem, Lịch sử hành hương, Sự kiện cá nhân, Đổi mật khẩu) đều được bảo vệ bởi middleware xác thực Bearer JWT hợp lệ.

  ---

  ## 🗺️ Lộ trình phát triển (Roadmap)

  - [x] **Khởi tạo nền tảng:** Kiến trúc Flutter kết hợp Node.js & MongoDB Atlas.
  - [x] **Giao diện cốt lõi:** Thanh điều hướng 5 mục, Trang chủ thanh tịnh, Lịch âm dương & Ngày lễ.
  - [x] **Kho Kinh sách:** API & Giao diện đọc kinh, bài chú, tìm kiếm thời gian thực.
  - [x] **Tra cứu Chùa:** Danh lam cổ tự, hình ảnh, thông tin lịch sử và mở bản đồ dẫn đường.
  - [x] **Nhân vật Phật giáo:** Tra cứu tiểu sử, hạnh nguyện của chư Phật và Bồ Tát.
  - [x] **Check-in thông minh:**
    - [x] Quét mã QR tại chùa (`TEMPLE:<slug>`).
    - [x] Quét thẻ NFC (NDEF / UID) một chạm.
  - [x] **Hành hương số hóa:**
    - [x] Cấp tem điện tử độc bản sau mỗi chuyến viếng.
    - [x] Trang Sổ tem (Stamp Book) cá nhân.
    - [x] Lịch sử viếng chùa và bảng thống kê số liệu hành hương.
  - [x] **Xác thực & Bảo mật:**
    - [x] Đăng nhập/Đăng ký native bằng JWT.
    - [x] Đăng nhập tài khoản Google & Xác thực Email bằng Firebase Auth.
    - [x] Khóa bảo vệ ứng dụng bằng vân tay / Face ID (Biometric Lock).
  - [x] **DevOps & Triển khai:**
    - [x] Đóng gói Docker & Docker Compose.
    - [x] Tự động hóa CI/CD với GitHub Actions.
    - [x] Triển khai Backend lên Render với Cloudinary Storage.
  - [ ] **Kế hoạch tương lai:**
    - [ ] Hỗ trợ phát âm thanh tụng kinh trực tiếp (Audio Chant Player).
    - [ ] Bản đồ Phật giáo tương tác trực tiếp (Interactive Pilgrimage Map).
    - [ ] Bộ nhớ đệm ngoại tuyến (Offline mode) cho kinh sách khi không có mạng.

  ---

  ## 📄 Tài liệu tham khảo chuyên sâu

  Dự án cung cấp tài liệu chi tiết cho từng phân hệ trong thư mục `docs/`:

  - 🔒 **[Hướng dẫn Khóa Sinh Trắc Học (docs/BIOMETRIC_LOCK.md)](file:///d:/LTDT/AppTungKinh/apptungkinh/docs/BIOMETRIC_LOCK.md):** Nguyên lý hoạt động của `local_auth`, vòng đời mở khóa và kịch bản kiểm thử trên máy thật.
  - 🔑 **[Hướng dẫn Firebase Auth & Google Sign-In (docs/FIREBASE_AUTH.md)](file:///d:/LTDT/AppTungKinh/apptungkinh/docs/FIREBASE_AUTH.md):** Các bước lấy SHA-1/SHA-256 Android, tạo Web OAuth Client ID và cấu hình biến môi trường.
  - ☁️ **[Hướng dẫn Triển Khai Render Miễn Phí (docs/RENDER_DEPLOY.md)](file:///d:/LTDT/AppTungKinh/apptungkinh/docs/RENDER_DEPLOY.md):** Hướng dẫn kết nối Blueprint, MongoDB Atlas, Cloudinary và xử lý cold start.
  - 🧪 **[Quy Chuẩn Kiểm Thử Backend (backend/TESTING.md)](file:///d:/LTDT/AppTungKinh/apptungkinh/backend/TESTING.md):** Chi tiết cấu trúc test suite của backend và cách chạy test cô lập.

  ---

  ## 🪷 Lời kết

  <p align="center">
    <b>Hành Trình An Nhiên — Digital Pilgrimage</b><br />
    <i>"Nơi công nghệ đồng hành cùng từng bước chân an lạc trên con đường hướng thiện."</i>
  </p>

  <p align="center">
    Được xây dựng với niềm kính ngưỡng và tình yêu công nghệ 💙
  </p>
