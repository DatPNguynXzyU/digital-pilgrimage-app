# Chạm thẻ để mở app và tự nhận tem — Android

Luồng mới: mở khóa điện thoại → bật NFC → chạm thẻ chùa → Android mở Hành Trình An Nhiên → app kiểm tra phiên đăng nhập → backend kiểm tra UID → ghi nhận lượt viếng và cấp tem nếu chưa có.

Không cần vào tab Chùa hay bấm nút quét trước. Nếu bật khóa sinh trắc học, cần mở khóa app trước khi xử lý lượt chạm. Nếu chưa đăng nhập, màn hình check-in yêu cầu đăng nhập; sau khi quay lại sẽ tiếp tục với UID đã đọc, không cần chạm lại.

## 1. Điều kiện

- Cài APK có bản sửa này; APK cũ không có bộ lọc Android cần thiết.
- Điện thoại Android có NFC, đã bật NFC và màn hình mở khóa.
- Thẻ đã có UID đăng ký với một chùa đang hoạt động trong backend. Viết dữ liệu lên thẻ không tự đăng ký UID trong MongoDB.
- Thẻ chứa NDEF theo một trong các định dạng bên dưới.
- Có kết nối mạng và tài khoản hợp lệ. Tem chỉ được thông báo thành công sau khi backend chấp nhận.

Android có thể yêu cầu chọn ứng dụng hoặc cho phép ứng dụng mở qua NFC. Nếu thiết bị có mục `Settings → Apps → Special app access → Launch via NFC`, cho phép app tại đó. Không thể bỏ qua màn hình khóa hay lựa chọn bắt buộc của hệ điều hành bằng code Flutter.

## 2. Cách ghi thẻ khuyến nghị

Có thể dùng công cụ ghi NDEF như NFC Tools hoặc đầu ghi hỗ trợ NDEF. Sao lưu nội dung thẻ đang dùng trước khi thay dữ liệu. Không khóa thẻ vĩnh viễn trong lúc thử nghiệm.

### Record đầu tiên: Custom MIME

```text
MIME type: application/vnd.hanhtrinhannhien.temple
Encoding: UTF-8
```

Payload ví dụ, thay slug/tên bằng chùa thật:

```json
{"type":"temple","slug":"chua-giac-lam","name":"Chùa Giác Lâm"}
```

### Record thứ hai: Android Application Record (AAR)

```text
Package name: com.example.apptungkinh
```

Giữ record MIME ở vị trí đầu tiên. AAR giúp Android ưu tiên ứng dụng đúng package, nhưng hệ điều hành vẫn có thể yêu cầu xác nhận/cho phép. Không thêm UID hoặc token đăng nhập vào payload để thay thế việc đọc thẻ.

## 3. Thẻ cũ dùng Text NDEF

App cũng đăng ký `text/plain` và nhận các thẻ có text:

```json
{"type":"temple","slug":"chua-giac-lam","name":"Chùa Giác Lâm"}
```

Hoặc định dạng text cũ:

```text
TEMPLE:chua-giac-lam
```

Nếu Android hiện danh sách ứng dụng, chọn Hành Trình An Nhiên. Có thể bổ sung AAR hoặc chuyển sang Custom MIME để giảm việc chọn nhầm ứng dụng. Các thẻ text không liên quan sẽ không được đưa vào luồng nhận tem.

Thẻ chỉ có UID, không chứa NDEF thích hợp, vẫn có thể quét thủ công trong app nhưng chưa đủ để tự mở app bằng luồng này. Thẻ chứa URL web thông thường cũng không thuộc bộ lọc mới; không ghi URL có tham số UID rồi kỳ vọng tự nhận tem.

## 4. Hành vi và bảo mật

- Kotlin nhận `ACTION_NDEF_DISCOVERED`, lấy UID từ `NfcAdapter.EXTRA_TAG`; không nhận UID từ URL hoặc text tự khai báo.
- Flutter gửi UID và token đăng nhập đến endpoint hiện có `POST /api/nfc/scan`. Backend tự tìm chùa theo UID đã đăng ký; slug/tên trong record không được dùng để tự gán thẻ sang chùa khác.
- Thẻ lạ/bị khóa, tài khoản lỗi hoặc mạng lỗi sẽ hiện thông báo; không cấp tem chỉ dựa vào sự kiện mở app.
- Lần chạm được giữ trong khi app chờ backend hoặc sinh trắc học. Lượt chạm chưa đăng nhập được giữ trong màn hình check-in để tiếp tục sau đăng nhập.
- Chống lặp intent cùng UID trong 3 giây tại Activity và cùng event ID trong Flutter. Khi đang xem kết quả, các intent chạm thêm không xếp hàng tạo nhiều lượt viếng; quay lại màn hình trước rồi chạm lại để bắt đầu lượt mới.
- Không tự thử lại POST check-in khi timeout, vì backend có thể đã ghi nhận request trước đó. Kiểm tra lịch sử trước khi chủ động quét lại.
- Đây không phải cơ chế chống sao chép thẻ bằng mật mã. UID/thẻ thường vẫn có các hạn chế bảo mật vốn có.

## 5. Kiểm thử trên điện thoại

1. Cài APK mới, đăng nhập, bật NFC.
2. Đưa app xuống nền hoặc đóng giao diện app, mở khóa điện thoại rồi chạm thẻ đã đăng ký.
3. App phải vào thẳng Check-in NFC, hiện chùa và kết quả tem; mở sổ tem/lịch sử để kiểm tra.
4. Mở app sẵn ở trang chủ/kinh sách rồi chạm thẻ; luồng vẫn phải mở màn hình check-in.
5. Đăng xuất rồi chạm thẻ: không gửi check-in trước đăng nhập; đăng nhập và quay lại phải tiếp tục lượt chạm đã nhận.
6. Bật sinh trắc học và thử lại: chưa mở khóa app thì chưa gửi check-in.
7. Thử thẻ chưa đăng ký, thẻ text không liên quan, mất mạng, giữ thẻ lâu và quay lại app từ màn hình Recent Apps.
8. Kiểm tra không phát sinh lượt viếng lặp do cùng một intent hoặc do khôi phục Activity.

Việc vuốt đóng/force-stop app hoặc chính sách NFC trên từng hãng máy có thể khác nhau. Build thành công và widget test không thay thế kiểm thử thẻ vật lý trên máy thật.

## 6. iPhone

Luồng này được triển khai cho Android. IPA sideload hiện tại của đồ án tắt NFC; chưa bổ sung Universal Links/Associated Domains hoặc mở app từ thẻ trên iOS trong thay đổi này.

## 7. Build

```powershell
cd D:\LTDT\AppTungKinh\apptungkinh\client
flutter build apk --release --dart-define-from-file=firebase-config.json
Copy-Item build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\HanhTrinhAnNhien.apk
```

Tài liệu Android chính thức về intent NDEF/AAR và thiết lập NFC: <https://developer.android.com/develop/connectivity/nfc/nfc>.
