# REST API v1 (đường dẫn không có tiền tố /api)

Base URL là HTTPS Render của nhóm. JSON request/response. Sau đăng nhập gửi `Authorization: Bearer TOKEN`. Lỗi: `{"message":"..."}`; dữ liệu sai trả 400, chưa đăng nhập 401, thiếu quyền 403, không sở hữu/không tồn tại 404, trùng 409. OTP không trả ra response.

| Method | Path | Dữ liệu / quyền |
|---|---|---|
| GET | /health | Kiểm tra DB, không cần token |
| POST | /auth/register | email, username, name, password → challengeId |
| POST | /auth/login | username (hoặc email), password → challengeId |
| POST | /auth/otp | challengeId, code → token, user |
| GET | /auth/google/start | query verifierHash = SHA256(verifier) |
| GET | /auth/google/callback | Google redirect, không gọi thủ công |
| POST | /auth/google/exchange | code, verifier → token, user |
| GET | /me | Thông tin user hiện tại |
| GET, POST | /children | List gia đình; POST: name, age (1–17), daily_limit (15–1440), parent |
| PUT, DELETE | /children/:id | Sửa đầy đủ name/age/daily_limit hoặc xóa, parent sở hữu |
| POST | /children/:id/link | email trẻ đã verified và role child, parent sở hữu |
| GET, POST | /children/:id/devices | GET chủ sở hữu/trẻ liên kết; POST name, parent |
| PUT, DELETE | /devices/:id | PUT name, DELETE; parent sở hữu |
| GET, POST | /children/:id/agreements | POST title, reward (1–120); parent/trẻ liên kết |
| PATCH | /agreements/:id | status: approved/rejected; parent sở hữu |
| DELETE | /agreements/:id | parent sở hữu |
| PUT | /children/:id/nfc | tagHash (SHA256 UID bytes), parent sở hữu |
| POST | /children/:id/checkins | tagHash; parent/trẻ liên kết; phải khớp thẻ đã gắn |
| GET | /children/:id/checkins | 50 lượt gần nhất, chủ sở hữu/trẻ liên kết |
| GET | /staff/dashboard | users, children, devices (count); staff/admin |
| GET | /admin/users | Tối đa 200 user; admin |
| PATCH | /admin/users/:id/role | role: parent/child/staff; admin; không tự đổi mình hoặc admin khác |

Ví dụ tạo trẻ sau khi lấy token:

```http
POST /children HTTP/1.1
Authorization: Bearer TOKEN
Content-Type: application/json

{"name":"An","age":9,"daily_limit":90}
```

Token không chứa mật khẩu. Backend đọc role hiện tại từ database nên thay quyền có hiệu lực trên yêu cầu tiếp theo. Đăng xuất Flutter xóa token tại máy; token sao chép trước đó còn hiệu lực đến hết hạn (chưa có revocation server). Staff không có endpoint đọc danh sách trẻ hoặc dữ liệu riêng của phụ huynh khác.
