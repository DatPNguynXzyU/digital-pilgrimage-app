# Tạo IPA và thử trên iPhone bằng Sideloadly

## Trạng thái và giới hạn

Workflow `.github/workflows/ios-sideload.yml` dùng máy macOS của GitHub để build bản release cho iPhone, không cần sở hữu Mac. IPA chưa ký sẽ được Sideloadly trên Windows ký và cài bằng tài khoản Apple cá nhân. Đây là bản thử nghiệm, không phải bản phát hành App Store. Chưa kiểm chứng build trên macOS hoặc cài trên iPhone.

Bản sideload tắt quét NFC trên iOS và bỏ entitlement NFC trong bản build để tránh yêu cầu quyền ký đặc biệt. Android giữ nguyên NFC. Xem tem/lịch sử đã đồng bộ vẫn có thể dùng sau đăng nhập. Google login, sinh trắc học, GPS, camera và nhắc lịch cần kiểm thử thiết bị thật; không bảo đảm mọi tính năng tương đương Android.

Tài khoản Apple miễn phí thường cần ký lại sau 7 ngày, giới hạn 3 ứng dụng sideload. Auto refresh cần máy tính và kết nối thiết bị phù hợp. Không đưa tài khoản/mật khẩu Apple vào GitHub.

## 1. Đăng ký iOS trong Firebase

1. Mở https://console.firebase.google.com/project/hanh-trinh-an-nhien/settings/general
2. Trong **Your apps**, chọn **Add app**, chọn biểu tượng **iOS+**.
3. Nhập **Apple bundle ID**: `com.example.apptungkinh` (đúng chữ hoa/thường).
4. App nickname: `Hanh Trinh An Nhien iOS`. Bỏ trống App Store ID.
5. Chọn **Register app**, tải **GoogleService-Info.plist**.
6. Các bước SDK tiếp theo đã được Flutter packages quản lý; không cần cài SDK native lần nữa theo wizard. Tiếp tục về console.
7. Authentication → Sign-in method: kiểm tra Google và Email/Password đã bật trong cùng project. Nếu plist thiếu CLIENT_ID, kiểm tra Google provider rồi tải lại plist.

Không sử dụng `google-services.json` Android thay cho plist iOS. Không cần tạo Firebase project hay MongoDB mới. Backend dùng cùng Firebase project nên không cần tạo Admin private key mới chỉ vì thêm iOS.

## 2. Điền GitHub Actions Variables

Repository → Settings → Secrets and variables → Actions → **Variables** → New repository variable. Các giá trị dưới đây là cấu hình client; không đặt Firebase Admin private key vào đây.

| Tên biến | Giá trị/lấy từ đâu |
|---|---|
| API_BASE_URL | `https://digital-pilgrimage-api.onrender.com/api` |
| FIREBASE_PROJECT_ID | `PROJECT_ID` trong plist, phải là `hanh-trinh-an-nhien` |
| FIREBASE_IOS_API_KEY | `API_KEY` trong plist iOS |
| FIREBASE_IOS_APP_ID | `GOOGLE_APP_ID` trong plist, dạng `1:…:ios:…` |
| FIREBASE_MESSAGING_SENDER_ID | `GCM_SENDER_ID` trong plist |
| GOOGLE_IOS_CLIENT_ID | `CLIENT_ID` trong plist iOS |
| GOOGLE_WEB_CLIENT_ID | OAuth client loại Web đang dùng cho Google login Android, cùng project; không lấy iOS client thay thế |

Kiểm tra `BUNDLE_ID` trong plist trùng `com.example.apptungkinh`. Workflow tự tạo `firebase-config.ios.json`, ánh xạ API key sang `FIREBASE_API_KEY`, và tạo URL scheme đảo từ iOS client ID. Không commit các file cấu hình được sinh tự động. Không chạy `scripts/prepare-ios-sideload.py` trực tiếp trên máy làm việc: script chỉ dành cho checkout tạm của Actions và có chặn chạy ngoài Actions.

## 3. Build trên GitHub

1. Đưa workflow và các thay đổi ứng dụng liên quan lên GitHub qua review/merge bình thường; workflow manual cần có trên nhánh mặc định để xuất hiện trong Actions.
2. Mở Actions → **iOS Sideload IPA** → **Run workflow**, chọn nhánh đã có đủ code.
3. Workflow kiểm tra cấu hình, chạy analyze/test, build iPhone release không ký, kiểm tra arm64 và đóng gói IPA.
4. Khi xanh, tải artifact `ios-sideload-<số run>` ở cuối trang run. Artifact được giữ 7 ngày.
5. Giải nén ZIP để lấy `HanhTrinhAnNhien-sideload.ipa`, `SHA256SUMS.txt` và `BUILD-INFO.txt`.

Thiếu biến: bổ sung đúng tên rồi chạy lại. Lỗi Xcode/plugin: đọc bước build, không coi IPA đã tồn tại khi run còn đỏ. Windows không thể chạy lệnh build iOS này trực tiếp; máy build vẫn là macOS của GitHub.

## 4. Cài trên iPhone

1. Tải Sideloadly từ https://sideloadly.io/ và cài thành phần Apple theo hướng dẫn Windows hiện tại của công cụ.
2. Kết nối iPhone qua USB, mở khóa và chọn tin cậy máy tính.
3. Chọn thiết bị, kéo file IPA vào Sideloadly, nhập Apple ID trực tiếp trong công cụ và bắt đầu ký/cài.
4. Kiểm tra bundle ID sau ký: Google OAuth cần khớp ID đã đăng ký. Nếu công cụ thay đổi ID, cần xử lý đăng ký/cấu hình Firebase cho ID thực tế; không đổi tùy ý rồi mặc định Google login sẽ hoạt động.
5. Nếu được yêu cầu, bật Developer Mode ở Settings → Privacy & Security; tin cậy developer profile trong Settings → General → VPN & Device Management nếu iOS hiển thị yêu cầu.
6. Giữ cùng Apple ID và bundle ID khi cài bản cập nhật/ký lại để tránh tạo ứng dụng khác. Dữ liệu chỉ lưu cục bộ cần sao lưu trước thao tác gỡ app.

## 5. Kiểm thử trước khi kết luận hoàn tất

- Mở app, tải chùa/ảnh/kinh bằng Wi-Fi và dữ liệu di động.
- Đăng nhập Google; đăng ký email mới, xác minh email, đăng nhập, quên mật khẩu và đăng xuất.
- Kiểm tra lịch sử/tem cũ của tài khoản Android trên iPhone.
- Chấp nhận rồi từ chối quyền vị trí/camera/thông báo; app phải báo hướng dẫn phù hợp.
- Gửi thông báo thử, kiểm tra nhắc lịch khi app ở nền; kiểm tra Face ID/Touch ID nếu máy hỗ trợ.
- Nhấn NFC: bản sideload phải hiện thông báo chưa hỗ trợ, không gọi phiên quét NFC.
- Thử ký lại/cập nhật cùng bundle ID sau đó kiểm tra đăng nhập và dữ liệu.

## Tài liệu nguồn

- Firebase Apple setup: https://firebase.google.com/docs/ios/setup
- Flutter iOS deployment: https://docs.flutter.dev/deployment/ios
- Sideloadly và FAQ: https://sideloadly.io/faq.html
