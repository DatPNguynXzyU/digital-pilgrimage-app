# Static Data

Thư mục này chứa dữ liệu nội dung tĩnh của ứng dụng Digital Pilgrimage.

## Cấu trúc

- scriptures/: Kinh và chú
- temples/: Thông tin chùa
- buddhist_holidays/: Các ngày lễ Phật giáo

## Quy tắc chỉnh sửa

1. Không đổi tên `slug` của dữ liệu đã tồn tại.
2. Mỗi `slug` phải duy nhất.
3. JSON phải đúng cú pháp.
4. Không lưu password hoặc thông tin bảo mật trong thư mục này.
5. Sau khi cập nhật dữ liệu cần commit lên GitHub.
6. Người quản lý database chạy seed để cập nhật MongoDB.

## Workflow

Edit JSON
↓
Commit
↓
Push / Pull Request
↓
Merge main
↓
npm run seed
↓
MongoDB Atlas được cập nhật