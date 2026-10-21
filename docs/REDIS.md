# Redis cache và rate limiting

Backend dùng Upstash Redis REST qua fetch Node22, không đưa Redis token vào Flutter. Tài liệu API: https://upstash.com/docs/redis/features/restapi

Render Environment cần:

```text
UPSTASH_REDIS_REST_URL=https://<endpoint>
UPSTASH_REDIS_REST_TOKEN=<token có quyền ghi>
TRUST_PROXY_HOPS=<số proxy tin cậy đã xác minh>
REDIS_RATE_LIMIT_ENABLED=false
```

Tạo database Redis trong tài khoản Upstash, lấy REST URL/token từ console. Không commit hoặc gửi token vào chat. Không có URL/token thì tính năng tắt, giữ tương thích deployment cũ. Có một biến mà thiếu biến còn lại thì startup từ chối cấu hình.

Triển khai theo hai giai đoạn: điền URL/token để bật cache trước, giữ REDIS_RATE_LIMIT_ENABLED=false (mặc định). Chỉ đặt true sau khi đã xác minh TRUST_PROXY_HOPS với hạ tầng thật. Khi bật limiter bắt buộc khai báo TRUST_PROXY_HOPS; dùng 0 chỉ khi chạy trực tiếp không proxy. Không đoán số hop trên Render, vì có thể gom mọi người vào một quota. Tham khảo https://expressjs.com/en/guide/behind-proxies/.

TRUST_PROXY_HOPS mặc định 0 (local). Trước bật production phải xác minh chuỗi proxy và địa chỉ req.ip trên Render; không đặt trust proxy=true hoặc tin tùy ý X-Forwarded-For. Sai cấu hình có thể gom tất cả khách vào IP proxy hoặc cho giả mạo IP. Cấu hình này chưa được xác minh trên Render.

Cache GET công khai chùa/kinh sách: TTL60 giây, khóa hash toàn originalUrl bao gồm query; chỉ cache response200 success=true <=512KB, bỏ qua request Authorization, không cache hồ sơ/lịch/tem/token. Seed/cập nhật chùa có thể mất tối đa60giây để thấy dữ liệu mới. Redis lỗi thì đọc MongoDB.

Rate limit theo IP:120request/phút toàn API, thêm20request/5phút gộp login/register/Firebase exchange/đổi mật khẩu. Đếm tất cả lần gọi, Lua INCR+EXPIRE nguyên tử, trả429+Retry-After. Redis lỗi khi đã bật trả503 để không mất bảo vệ. /api/health và OPTIONS CORS không chịu limiter. Người cùng NAT dùng chung quota. Request đăng nhập trực tiếp Firebase SDK vẫn chịu quota Firebase riêng.

Chưa có Redis thật được cấp hoặc cấu hình production. Không tự thay Render env, không deploy. Test mock xác minh middleware; trước phát hành phải test Redis thật và proxy trên hosting. API quota cần điều chỉnh theo tải thực tế; backend ngủ do Render Free vẫn có cold start.
