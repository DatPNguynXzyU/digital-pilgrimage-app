# Chùa gần bạn và thông báo nhắc lịch

## Sử dụng

- Mở tab Chùa → Chùa gần bạn → cấp quyền vị trí. App chỉ lấy vị trí khi nhấn nút, không theo dõi nền và không gửi vị trí GPS đến backend.
- Chùa có tọa độ được sắp xếp theo khoảng cách đường thẳng; đây không phải quãng đường đi xe. Chùa thiếu tọa độ ở cuối danh sách.
- Nút Tìm quanh đây trên Maps mở Google Maps với vị trí hiện tại. Khi nhấn nút này, tọa độ được đưa vào đường link gửi tới Google Maps.
- Trang chủ hiển thị ba lễ gần nhất (bao gồm hôm nay), ngày dương/âm và số ngày còn lại. Nhấn để xem chi tiết; Tất cả mở danh sách lễ.
- Vào Lịch → Cài đặt nhắc lịch hoặc biểu tượng chuông tại mục Lễ sắp tới. Bật loại nhắc, cấp quyền rồi Lưu nhắc lịch.
- Gửi thông báo thử kiểm tra thông báo hệ thống ngay lập tức.
- Với lịch cá nhân, chọn Nhắc trước khi tạo/sửa từng sự kiện. Không nhắc nghĩa là sự kiện đó không được lên lịch dù đã bật nhắc lịch cá nhân.

## Bổ sung tọa độ chùa

Dataset `backend/data/chua/temples.json` hiện không có tọa độ. Lấy vị trí đúng của từng chùa trên Google Maps (nhấn giữ/nhấp phải vào vị trí), rồi thêm vào chính đối tượng chùa:

```json
"location": {
  "latitude": 10.0,
  "longitude": 106.0
}
```

Đây chỉ là ví dụ cấu trúc, không phải tọa độ của một chùa thực tế. Thay bằng giá trị đã xác minh. Latitude là vĩ độ [-90,90]; longitude là kinh độ [-180,180]. Không thay slug hoặc ID.

Sau khi cập nhật và kiểm tra dữ liệu, chạy trong thư mục backend với môi trường MongoDB đúng:

```powershell
npm run seed:temples
```

Seed này cập nhật toàn bộ nội dung chùa trong dataset. Kiểm tra các thay đổi khác trong JSON trước khi chạy. Cache danh sách có thể cần hết TTL rồi tải lại. Khi APK đã có tính năng GPS, thêm tọa độ không cần build lại APK.

## Cách nhắc lịch hoạt động

Đây là thông báo cục bộ, không phải push từ máy chủ/FCM. Không cần Firebase Messaging hay APNs cho lịch đã lập trên thiết bị.

- Ngày lễ lấy từ danh mục đã đối chiếu Word, mốc 08:00 theo giờ điện thoại trừ thời gian nhắc trước.
- Lịch cá nhân nhắc theo giờ bắt đầu và số phút nhắc của từng sự kiện. Sự kiện nhiều ngày không lặp chỉ nhắc một lần trước khi bắt đầu.
- Các sự kiện lặp được tính trước trong 366 ngày. Chỉ giữ 60 thông báo gần nhất của cả hai loại, bổ sung khi mở/quay lại app hoặc thay đổi lịch.
- Đổi tài khoản/xóa/sửa lịch sẽ hủy hàng đợi cũ và lập lại. Nếu không tải được lịch cá nhân từ server sau thao tác này, mở app khi có mạng để cập nhật.
- Thay đổi lịch trên thiết bị khác được cập nhật khi mở/quay lại ứng dụng và tải thành công.
- Android dùng nhắc không chính xác tuyệt đối (`inexactAllowWhileIdle`), không đòi quyền exact alarm. Hệ điều hành hoặc chế độ tiết kiệm pin có thể trì hoãn.
- Android có receiver khôi phục lịch sau khởi động lại/cập nhật ứng dụng. Nếu người dùng buộc dừng ứng dụng, cần mở lại.
- Các thời điểm đã lên lịch là thời điểm tuyệt đối; mở lại app sau khi đổi múi giờ để tính lại theo giờ thiết bị.
- Quyền thông báo, chế độ Không làm phiền, cài đặt từng kênh và hạn chế pin có thể làm thông báo không hiện/không phát âm thanh.

## Kiểm thử thiết bị

1. Từ chối quyền vị trí, tắt GPS, rồi cấp lại: tìm tên chùa vẫn hoạt động.
2. Với dữ liệu tọa độ thật, đối chiếu thứ tự gần/xa và chỉ đường.
3. Bật thông báo, gửi thông báo thử; thử cả từ chối và thu hồi quyền.
4. Tạo lịch bắt đầu sau vài phút, chọn nhắc trước phù hợp, đưa app xuống nền và kiểm tra thông báo (có thể chậm do Android).
5. Sửa/xóa lịch, đổi tài khoản: không nhận thông báo của lịch/tài khoản cũ.
6. Khởi động lại điện thoại rồi kiểm tra lịch đã đặt.
7. Kiểm tra lễ hôm nay, ngày cuối năm và sự kiện ngày 30 trong tháng thiếu.

Cấu hình iOS đã được thêm nhưng cần máy macOS/iPhone để xác minh build và hành vi thực tế. Không cần thay đổi backend cho logic tính khoảng cách và nhắc cục bộ.
