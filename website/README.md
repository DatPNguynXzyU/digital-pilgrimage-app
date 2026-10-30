# Website Hành Trình An Nhiên

Website giới thiệu ứng dụng và tải APK, được dựng bằng HTML/CSS/JavaScript tĩnh, hiển thị trên điện thoại và máy tính. Không cần cài npm hoặc kết nối database.

## Nội dung

- Giới thiệu khám phá chùa, đọc kinh, lịch và check-in NFC.
- Hai tab Android/iPhone, hướng dẫn cài APK, câu hỏi thường gặp và cộng đồng Zalo.
- Nút tải Android trỏ đến bản APK có sẵn trong kho dự án, **1.0.0+2**, khoảng 76 MB. Đây không phải APK mới được build từ commit `update feature`.
- Không có liên kết IPA công khai; người dùng iPhone liên hệ nhóm Zalo để nhận bản cài thử và hướng dẫn.

## Chỉnh sửa

`index.html`: nội dung và đường dẫn tải. `styles.css`: giao diện, breakpoint điện thoại. `app.js`: chuyển tab hệ điều hành, hỗ trợ bàn phím. `assets/`: hình minh họa và logo lấy từ app.

Để thay APK: tìm liên kết có class `apk-link` trong `index.html`, đổi URL sang tệp APK công khai thực tế, cập nhật phiên bản và dung lượng bên dưới nút. Xác nhận URL trả về tệp APK, không trả trang đăng nhập. Nên dùng một GitHub Release cho mỗi bản phát hành để giữ đường dẫn và bản tải rõ ràng.

Xem thử bằng Python đang cài trên máy:

```powershell
cd website
python -m http.server 5173
```

Mở `http://localhost:5173`. Website hoạt động không cần JavaScript đối với nút tải Android và các mục FAQ; JavaScript điều khiển tab Android/iPhone.

## Hosting

Đường dẫn công khai đã xuất bản:

https://hanh-trinh-an-nhien-app.starryflute8194.chatgpt.site

Đã kiểm tra trực tiếp trên trình duyệt: giao diện desktop và điện thoại rộng 375 px, tab Android/iPhone, FAQ, ảnh không lỗi và không tràn ngang. Đường dẫn APK trả HTTP 200 với tệp 76.487.610 byte.

Website đã đăng ký trên Sites với project ID:

```text
appgprj_6ae2a3f423dc819183b4bd2dc6ce2a6f
```

Mã trong thư mục này là bản sao để lưu cùng đồ án. Checkout xuất bản của Sites được giữ tại:

```text
C:/Users/DatPNT/.codex/visualizations/2026/10/16/01a1454f-b006-7241-b6ad-e5e4d452724c/hanh-trinh-an-nhien-website
```

Checkout này có `.openai/hosting.json`, thư mục `dist/` và repository riêng do Sites quản lý. Không đưa `.git` hoặc credential của Sites vào repository đồ án. Khi cập nhật, đồng bộ các file website vào `dist/` của checkout đó, đóng gói và xuất bản lại đúng project ID bằng quy trình Sites. Thay đổi trong repository đồ án không tự triển khai lên Sites.

## Phần NFC tiếp theo

Website này là trang tải ứng dụng. Chức năng thẻ HTTPS tự mở app/website chưa được nối trong thay đổi này. Để hoàn thiện cần:

1. Dùng tên miền website cố định và cấu hình Android App Links trong app.
2. Phục vụ `/.well-known/assetlinks.json` công khai, đúng package và SHA-256 của khóa ký APK đang phát hành.
3. Thêm xử lý URI trong app; không cấp tem chỉ từ URL vì URL có thể chia sẻ.
4. Thay nội dung ghi thẻ của admin từ Custom MIME sang bản ghi URI HTTPS đầu tiên và ghi lại thẻ.
5. Thử điện thoại đã cài app và chưa cài app, bao gồm cách xử lý khi đường dẫn chỉ mở trình duyệt.

Không đưa Firebase Admin key, MongoDB URI, token hoặc thông tin người dùng lên website tĩnh.
