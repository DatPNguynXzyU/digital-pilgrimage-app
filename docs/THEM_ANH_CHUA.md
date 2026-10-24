# Thêm nhiều ảnh cho một chùa

## 1. Đặt file ảnh

Lưu ảnh trong `backend/img/chua/`. Ví dụ:
- `chua-giac-lam-cong.jpg`
- `chua-giac-lam-chanh-dien.jpg`
- `chua-giac-lam-san.jpg`

Nên dùng tên không dấu, không khoảng trắng; tên file phải đúng cả chữ hoa/thường vì Render chạy Linux. Nén ảnh trước khi đưa lên Git.

## 2. Khai báo album

Mở `backend/data/chua/temples.json`, tìm đối tượng theo `slug` của chùa (ví dụ `chua-giac-lam`). Chỉ sửa hai trường sau, giữ nguyên các trường khác:

```json
"thumbnail": "/img/chua/chuagiaclam.png",
"images": [
  "/img/chua/chua-giac-lam-cong.jpg",
  "/img/chua/chua-giac-lam-chanh-dien.jpg",
  "/img/chua/chua-giac-lam-san.jpg"
]
```

Tên ảnh trên chỉ là ví dụ: bạn phải có file thật tương ứng. `thumbnail` là ảnh bìa; app hiển thị ảnh bìa trước, rồi các ảnh trong `images`, và bỏ URL trùng. Không chèn đường dẫn Windows như `D:/...` vào JSON. Có thể dùng URL HTTPS công khai (ví dụ Cloudinary).

## 3. Đưa ảnh lên Render, rồi seed

Từ thư mục gốc, kiểm tra thay đổi và đưa đúng các ảnh/dataset lên GitHub theo quy trình PR/CI của nhóm:

```powershell
git diff -- backend/data/chua/temples.json
git add backend/img/chua backend/data/chua/temples.json
git commit -m "Update temple photo albums"
git push
```

Nếu đang làm trên nhánh riêng, tạo PR và merge sau khi CI đạt. Đợi Render deploy thành công đúng commit trên main. Mở URL ảnh thật, ví dụ `https://digital-pilgrimage-api.onrender.com/img/chua/chua-giac-lam-cong.jpg`. Chỉ seed sau khi URL trả ảnh để tránh app nhận URL chưa tồn tại.

```powershell
cd backend
npm run seed:temples
cd ..
```

Lệnh seed dùng `backend/.env`. Đảm bảo MongoDB trỏ đúng database app đang sử dụng. Seed cập nhật toàn bộ các chùa trong JSON theo slug; đừng đổi slug của chùa đã có lịch sử. Nên sao lưu trước khi thay đổi dữ liệu lớn. Nếu sửa trực tiếp album trong MongoDB, hãy cập nhật cả JSON để lần seed tiếp theo không ghi đè album bằng mảng rỗng.

## 4. Kiểm tra trong app

Mở lại trang chùa để tải dữ liệu; cache backend có thể cần thời gian hết hạn. Vuốt ngang ảnh trên đầu trang; bộ đếm sẽ đổi từ 1/N sang 2/N. Sau khi đã cài APK hỗ trợ album, thêm ảnh/dữ liệu không cần build APK lại.

## Chẩn đoán ảnh trống

- URL ảnh trả 404: thiếu file trong commit đang chạy trên Render, sai đường dẫn hoặc sai chữ hoa/thường.
- URL ảnh mở được nhưng app trống: kiểm tra API trả đúng thumbnail/images và APK đã hỗ trợ URL tương đối.
- images rỗng: album chỉ có ảnh bìa, không có ảnh thứ hai để vuốt.

Kiểm tra ngày 24/10/2026: Render trả 404 cho chuavanphat.png, chuanghiaan.png, chuahachuong.png, chuabuuda.png, chuanamthienmotcot.png, chuaquanam.png, chuaphuoctuong.png. Cả 7 file đã có trong backend/img/chua trên máy, cần commit/push và deploy lên Render.
