# NFC mở website hoặc ứng dụng Android

URL ghi bằng NFC Tools (URL/URI, bản ghi đầu tiên):

```text
https://hanh-trinh-an-nhien-app.starryflute8194.chatgpt.site/nfc/?temple=chua-giac-lam
```

Thay `chua-giac-lam` bằng slug chính xác từ API `/api/temples`. Chưa cài app: mở trang đích có nút tải. Đã cài APK mới và App Links xác minh thành công: mở trang chi tiết chùa, nhấn nút check-in rồi chạm lại thẻ. Nếu chưa đăng nhập, màn hình quét yêu cầu đăng nhập trước khi tiếp tục. Không cấp tem từ link; backend vẫn kiểm tra UID với chùa đang mở.

## NFC Tools

1. Read: đọc và lưu nội dung thẻ cũ.
2. Write → Add a record → URL/URI → nhập URL chùa.
3. Chỉ để bản ghi URL khi ghi bằng NFC Tools; không thêm Android Application Record vì có thể chuyển tới cửa hàng khi chưa cài app.
4. Write rồi chạm NTAG215. Không khóa thẻ hoặc đặt read-only.
5. Đóng NFC Tools, mở khóa điện thoại rồi chạm lại để thử.

UID vật lý không đổi. Thẻ phải được liên kết với chùa và active trong MongoDB. Luồng quản trị ghi thẻ trong app mới cũng tạo URL đầu tiên, sau đó bản ghi MIME thông tin chùa.

## Khóa ký và xác minh

`website/.well-known/assetlinks.json` chứa SHA-256 của debug.keystore hiện dùng bởi cấu hình release trên laptop. Nếu đổi khóa ký, build trên máy khác hoặc dùng Play App Signing, cập nhật fingerprint tương ứng và xuất bản lại website. Không đưa keystore hay mật khẩu lên website.

Android mới dùng ACTION_VIEW cho URL NFC; bản cũ có ACTION_NDEF_DISCOVERED. Manifest hỗ trợ cả hai. Nếu vẫn mở web: Cài đặt → Ứng dụng → Hành trình an nhiên → Mở theo mặc định → bật mở liên kết được hỗ trợ.

```powershell
adb shell pm verify-app-links --re-verify com.example.apptungkinh
adb shell pm get-app-links com.example.apptungkinh
adb shell am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://hanh-trinh-an-nhien-app.starryflute8194.chatgpt.site/nfc/?temple=chua-giac-lam"
```

Thử: chưa cài; đã cài; cold start; app đang chạy; chưa đăng nhập; khóa sinh trắc; thẻ đúng/sai chùa; slug không tồn tại; mạng chậm. Sau cài APK lần đầu, chạm lại thẻ. iOS chưa được cấu hình Universal Links trong thay đổi này.

Website trên Sites được xuất bản riêng; commit thư mục website lên GitHub không tự triển khai website. APK mới nằm tại client/build/app/outputs/flutter-apk/HanhTrinhAnNhien-NFC.apk; chứng thư đã khớp assetlinks.json. Sites từ chối đưa APK 86 MB vào kho nguồn (pack member exceeds aggregate working-memory limit). Website đang chạy phiên bản 2 với trang NFC và assetlinks; nút tải vẫn là APK cũ. Cần phát hành APK mới qua GitHub Releases rồi thay nút tải. Checkout Sites có commit chưa push b383c8e3da42df4404939e9343f9af6d4b4fd625 chứa APK bị từ chối; phải xử lý commit này trước lần xuất bản tiếp theo, remote vẫn là 60404d2fa130121d347c41f76b4bb2904d854288.
