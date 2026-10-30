// OpenAPI describes the existing routes; it does not change their permissions.
const string = { type: 'string' };
const date = { type: 'string', format: 'date-time' };
const object = (properties, required = []) => ({ type: 'object', properties, required });
const body = schema => ({ required: true, content: { 'application/json': { schema } } });
const parameter = (name, location = 'path', schema = string) => ({ name, in: location, required: location === 'path', schema });
const paths = {};
function add(path, method, tag, summary, options = {}) {
  const { secured, schema, ...rest } = options;
  const responses = {
    200: { description: 'Thành công; cấu trúc JSON tùy endpoint.' },
    400: { description: 'Dữ liệu không hợp lệ.' },
    404: { description: 'Không tìm thấy dữ liệu.' },
    429: { description: 'Vượt giới hạn gọi API.' },
    500: { description: 'Lỗi máy chủ.' },
  };
  if (secured) {
    responses[401] = { description: 'Thiếu token, token hết hạn hoặc không hợp lệ.' };
    responses[403] = { description: 'Không có quyền, tài khoản khóa hoặc email chưa xác minh.' };
  }
  paths[path] ??= {};
  paths[path][method] = { tags: [tag], summary, responses,
    ...(secured ? { security: [{ bearerAuth: [] }] } : {}),
    ...(schema ? { requestBody: body(schema) } : {}), ...rest };
}
add('/health', 'get', 'Hệ thống', 'Kiểm tra kết nối cơ sở dữ liệu', {
  responses: { 200: { description: 'MongoDB sẵn sàng.' }, 503: { description: 'MongoDB chưa sẵn sàng.' } },
});
for (const [path, tag] of [['temples', 'Chùa'], ['scriptures', 'Kinh sách'], ['buddhist-figures', 'Nhân vật Phật giáo']]) {
  add('/' + path, 'get', tag, 'Lấy danh sách');
  add('/' + path + '/{slug}', 'get', tag, 'Chi tiết theo slug', { parameters: [parameter('slug')] });
}
add('/temples/id/{id}', 'get', 'Chùa', 'Chi tiết chùa theo MongoDB ID', { parameters: [parameter('id')] });
add('/quotes/random', 'get', 'Phật ngôn', 'Lấy câu Phật ngôn ngẫu nhiên', { parameters: [parameter('exclude', 'query')], description: 'exclude là mã câu muốn tránh lặp lại.' });
add('/auth/firebase', 'post', 'Tài khoản', 'Đăng nhập Firebase / tạo hồ sơ MongoDB', {
  schema: object({ idToken: string }, ['idToken']),
  description: 'Gửi Firebase ID token thô sau đăng nhập Google hoặc Email/Password đã xác minh. Nhận token dạng firebase:<ID_TOKEN>; dùng nguyên giá trị trả về trong Authorize. Không gửi Google access token.',
  responses: { 200: { description: 'Trả về success và token.' }, 400: { description: 'Thiếu token.' }, 401: { description: 'Token không hợp lệ.' }, 403: { description: 'Email chưa xác minh hoặc tài khoản khóa.' }, 409: { description: 'Xung đột tài khoản.' }, 503: { description: 'Firebase chưa sẵn sàng.' } },
});
add('/auth/login', 'post', 'Tài khoản', 'Đăng nhập tài khoản legacy', { schema: object({ email: { type: 'string', format: 'email' }, password: { type: 'string', format: 'password' } }, ['email', 'password']), description: 'Chỉ dành cho tài khoản legacy có passwordHash; tài khoản Firebase phải dùng /auth/firebase.' });
add('/auth/register', 'post', 'Tài khoản', 'Đăng ký legacy', { schema: object({ fullName: string, email: string, password: { type: 'string', format: 'password' } }, ['fullName', 'email', 'password']), description: 'Bị chặn khi backend bật Firebase. Luồng đăng ký mới và gửi email xác minh thực hiện qua Firebase SDK trên ứng dụng.', responses: { 201: { description: 'Đã tạo tài khoản legacy.' }, 400: { description: 'Dữ liệu không hợp lệ.' }, 403: { description: 'Firebase đã bật; đăng ký qua ứng dụng.' }, 409: { description: 'Email đã tồn tại.' }, 500: { description: 'Lỗi máy chủ.' } } });
add('/auth/me', 'get', 'Tài khoản', 'Hồ sơ người dùng hiện tại', { secured: true });
add('/auth/profile', 'put', 'Tài khoản', 'Cập nhật họ tên', { secured: true, schema: object({ fullName: { type: 'string', minLength: 2, maxLength: 100 } }, ['fullName']) });
add('/auth/avatar', 'post', 'Tài khoản', 'Tải ảnh đại diện (JPG/PNG/WEBP, tối đa 2 MB)', { secured: true, requestBody: { required: true, content: { 'multipart/form-data': { schema: object({ avatar: { type: 'string', format: 'binary' } }, ['avatar']) } } } });
add('/auth/change-password', 'put', 'Tài khoản', 'Đổi mật khẩu legacy', { secured: true, schema: object({ currentPassword: string, newPassword: string }, ['currentPassword', 'newPassword']) });
add('/auth/firebase/change-password', 'put', 'Tài khoản', 'Đổi mật khẩu Firebase và thu hồi phiên', { secured: true, schema: object({ newPassword: { type: 'string', minLength: 6, maxLength: 128 } }, ['newPassword']), description: 'Cần token Firebase được xác thực lại bằng mật khẩu trong 5 phút gần nhất. Đăng nhập lại sau khi đổi thành công.' });
add('/nfc/temple/{uid}', 'get', 'NFC', 'Tra cứu chùa qua UID', { parameters: [parameter('uid')] });
add('/nfc/tags', 'get', 'NFC', 'Danh sách thẻ đã liên kết');
add('/nfc/scan', 'post', 'NFC', 'Check-in và nhận tem', { secured: true, schema: object({ uid: string, slug: string, templeId: string }, ['uid']), description: 'UID phải thuộc thẻ đã đăng ký và đang hoạt động. slug/templeId nếu gửi phải khớp chùa của thẻ. Gọi API này tạo dữ liệu check-in thực.' });
for (const [path, summary] of [['history', 'Lịch sử viếng chùa'], ['temples', 'Các chùa đã viếng'], ['stats', 'Thống kê hành hương cá nhân'], ['stamps', 'Sổ tem cá nhân']]) {
  add('/pilgrimage/' + path, 'get', 'Hành hương', summary, { secured: true });
}
const calendar = { id: string, title: { type: 'string', maxLength: 200 }, startAt: date, endAt: date, usesLunarDate: { type: 'boolean' }, location: string, description: string, reminderMinutes: { type: 'integer', minimum: 0, maximum: 525600, nullable: true }, repeat: { type: 'string', enum: ['none', 'daily', 'weekly', 'monthly', 'yearly'] } };
add('/calendar-events', 'get', 'Lịch cá nhân', 'Danh sách lịch của tài khoản hiện tại', { secured: true });
add('/calendar-events', 'post', 'Lịch cá nhân', 'Tạo lịch cá nhân', { secured: true, schema: object(calendar, ['title', 'startAt', 'endAt']), responses: { 201: { description: 'Đã tạo lịch.' }, 400: { description: 'Dữ liệu không hợp lệ.' }, 401: { description: 'Chưa xác thực.' }, 409: { description: 'Trùng ID.' }, 500: { description: 'Lỗi máy chủ.' } } });
for (const [method, summary] of [['get', 'Chi tiết lịch'], ['put', 'Cập nhật lịch (cho phép gửi một phần)'], ['delete', 'Xóa lịch']]) {
  add('/calendar-events/{id}', method, 'Lịch cá nhân', summary, { secured: true, parameters: [parameter('id')], ...(method === 'put' ? { schema: object(calendar) } : {}), description: 'Chỉ được truy cập lịch thuộc tài khoản đang đăng nhập.' });
}
const admin = { secured: true, description: 'Yêu cầu user.role = admin trong MongoDB; token không tự cấp quyền quản trị.' };
add('/admin/nfc/statistics', 'get', 'Quản trị NFC', 'Thống kê check-in thành công', { ...admin, parameters: [parameter('from', 'query', { type: 'string', format: 'date' }), parameter('to', 'query', { type: 'string', format: 'date' }), parameter('templeId', 'query')], description: admin.description + ' Ngày theo giờ Việt Nam; tối đa 366 ngày, mặc định 30 ngày. Đếm lượt check-in và người tham gia riêng biệt; sự kiện trùng thời gian có thể đếm chung lượt.' });
add('/admin/nfc/temples', 'get', 'Quản trị NFC', 'Danh sách chùa để quản trị', admin);
add('/admin/nfc/events', 'post', 'Quản trị NFC', 'Tạo khoảng thời gian sự kiện thống kê', { ...admin, schema: object({ title: string, templeId: string, startAt: date, endAt: date }, ['title', 'templeId', 'startAt', 'endAt']), responses: { 201: { description: 'Đã tạo sự kiện.' }, 400: { description: 'Thời gian không hợp lệ; tối đa 366 ngày.' }, 401: { description: 'Chưa xác thực.' }, 403: { description: 'Không phải admin.' }, 404: { description: 'Không tìm thấy chùa.' }, 500: { description: 'Lỗi máy chủ.' } } });
add('/admin/nfc/tags/{uid}', 'get', 'Quản trị NFC', 'Kiểm tra đăng ký UID', { ...admin, parameters: [parameter('uid')] });
add('/admin/nfc/tags', 'post', 'Quản trị NFC', 'Đăng ký thẻ với chùa', { ...admin, schema: object({ uid: string, templeId: string }, ['uid', 'templeId']), description: admin.description + ' UID 4–10 byte hex. Chỉ liên kết chùa active; xung đột trả 409. API chỉ lưu liên kết MongoDB, không ghi vật lý thẻ NFC.' });
add('/admin/nfc/tags/{uid}/status', 'post', 'Quản trị NFC', 'Bật/tắt thẻ NFC', { ...admin, parameters: [parameter('uid')], schema: object({ status: { type: 'string', enum: ['active', 'inactive'] } }, ['status']) });

module.exports = {
  openapi: '3.0.3',
  info: { title: 'Hành Trình An Nhiên API', version: '1.0.0', description: 'Tài liệu API đồ án digital-pilgrimage-app. Authorize: nhập token trả về từ đăng nhập (firebase:<ID_TOKEN> hoặc JWT legacy), không thêm chữ Bearer. Try it out gọi API thật và có thể thay đổi dữ liệu. Quên mật khẩu và gửi email xác minh được thực hiện qua Firebase SDK, không có endpoint Express riêng.' },
  servers: [{ url: '/api', description: 'Máy chủ đang mở Swagger' }],
  components: { securitySchemes: { bearerAuth: { type: 'http', scheme: 'bearer', description: 'firebase:<ID_TOKEN> hoặc JWT legacy; không nhập tiền tố Bearer.' } } },
  paths,
};
