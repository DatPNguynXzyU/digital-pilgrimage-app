from pathlib import Path
root=Path('D:/LTDT/AppTungKinh/apptungkinh')
p=root/'ban_giao_do_an.md'
s=p.read_text(encoding='utf-8')
update='''## Cập nhật mới nhất - ưu tiên khi đọc bàn giao

Cập nhật ngày 21/10/2026, sau khi hoàn thiện khóa ký release. Các mục lịch sử phía dưới mô tả diễn biến ở từng mốc; trạng thái trong mục này là mốc mới nhất.

### Mã nguồn và triển khai

- Git đọc trực tiếp: nhánh codex/firebase-auth, HEAD fc6539c (update backend v13), sau commit Firebase 7729570. Chưa kiểm tra remote/PR/CI mới nhất trong lượt cập nhật tài liệu.
- Người dùng xác nhận: “backend firebase đã triển khai thành công”. Ghi nhận backend đã triển khai theo xác nhận của người dùng; AI chưa kiểm tra lại deploy commit/log Render hoặc test tài khoản thật. Không tiếp tục coi việc triển khai backend là chắc chắn chưa làm.
- Working tree hiện chỉ có android/app/build.gradle.kts modified; docs/RELEASE_SIGNING.md, tài liệu ban_giao_do_an và một số file tạo PDF còn untracked. README không còn modified ở lần đọc mới nhất. Không tự commit những thay đổi này.

### Ký release và APK

- android/app/build.gradle.kts đã thêm đọc java.util.Properties từ android/key.properties, tạo signingConfigs.release, dùng khóa release thay debug. Khi thiếu file khóa, release không tự fallback sang debug. Debug build vẫn dùng khóa debug như trước.
- Đã tạo android/release-keystore.jks (PKCS12, RSA 3072, alias release, hiệu lực 10.000 ngày) và android/key.properties chứa mật khẩu ngẫu nhiên. Cả hai được android/.gitignore bỏ qua. Không đưa nội dung mật khẩu hoặc private key vào tài liệu/Git.
- Phải sao lưu cả hai file riêng vào nơi an toàn; giữ cùng khóa cho các lần cập nhật. docs/RELEASE_SIGNING.md mới ghi quy trình build, fingerprint, lưu ý tương thích cài đặt và CI.
- Đã build build/app/outputs/flutter-apk/app-release.apk khoảng 72,8 MB với firebase-config.json; apksigner verify bằng JDK22 thành công và certificate khớp khóa release mới.
- APK này không cài đè APK ký debug cũ. Gỡ app cũ sẽ xóa dữ liệu cục bộ; dữ liệu đã lưu backend vẫn thuộc tài khoản. Không tự gỡ app của người dùng.
- Người dùng xác nhận thêm fingerprint release; SHA-1/SHA-256 mới đều đã lưu thành công trong Firebase cùng fingerprint debug cũ.

```text
Release SHA-1: C8:29:BF:90:DA:E0:6B:07:A4:4C:04:20:D7:55:62:DB:E0:24:C7:3E
Release SHA-256: 04:E2:81:4F:3B:76:74:80:B7:64:E4:F1:52:16:E5:B3:7A:52:87:21:8C:FB:BD:FD:29:72:6D:26:B4:FC:37:48
```

```powershell
cd D:\\LTDT\\AppTungKinh\\apptungkinh
flutter build apk --release --dart-define-from-file=firebase-config.json
```

CI hiện vẫn build debug; chưa thêm keystore release/password vào GitHub Secrets. Cấu hình ký release ở máy local không tự làm CI ký release. Khi dùng Google Play App Signing cần fingerprint của Play riêng.

### Những trao đổi mới về dữ liệu và quyền truy cập

- Người dùng hỏi vân tay có dựa trên máy không: sinh trắc học do hệ điều hành đối chiếu với dữ liệu đã đăng ký trên thiết bị, app chỉ nhận kết quả; không gửi/lưu ảnh vân tay ở MongoDB/Firebase. Đây là khóa UI sau đăng nhập; mọi vân tay hợp lệ đã đăng ký trên máy có thể được hệ điều hành chấp nhận.
- Người dùng hỏi tài khoản Google có lưu/mã hóa trong MongoDB không: backend xác minh token rồi tạo/tìm profile firebaseUid, email, fullName, role/status/timestamps. Mật khẩu Google không qua backend và không lưu trong MongoDB; tài khoản Firebase không cần passwordHash.
- Tên/email hiện chưa mã hóa riêng từng trường; người có quyền đọc database xem được. API HTTPS bảo vệ truyền tải. Chưa kiểm chứng cấu hình mã hóa ổ đĩa của dịch vụ MongoDB. Không nhầm hash bcrypt cho tài khoản cũ với mã hóa email/tên.
- Người dùng hỏi bạn cùng nhóm sửa code có ảnh hưởng Firebase/Render không: sửa local đơn thuần không đổi deployment; code vào main có thể kích hoạt CD. Code local dùng credentials production/API thật vẫn có thể tác động dữ liệu thật. Quyền dashboard khác quyền API hoặc quyền merge. Chưa kiểm tra danh sách thành viên Firebase/Render nên không khẳng định chỉ chủ dự án có quyền quản trị.
- Đã giải thích bảo vệ main, PR review và môi trường thử riêng; chưa thao tác cấu hình branch protection hay thay quyền thành viên.

### Công việc còn lại

Không lặp lại bước bật providers, thêm SHA hoặc tạo lại khóa release. Cần xác minh luồng thật trên điện thoại: Google login/logout không trùng profile, email chưa xác minh bị chặn và link xác minh hoạt động, NFC -> nhận tem -> lịch sử/lịch đúng tài khoản. Người dùng chưa xác nhận hoàn tất những kiểm thử này. Nếu cần phát hành tự động, tiếp tục cấu hình signing CI và versionCode, bảo toàn khóa hiện tại. Các tài liệu bàn giao được cập nhật ở lượt này, không sửa thêm code.

'''
s=s.replace('## 1. Công nghệ và kiến trúc',update+'## 1. Công nghệ và kiến trúc',1)
s=s.replace('release hiện cũng ký debug.', 'release ở mốc cũ ký debug; nay đã dùng khóa release riêng (xem cập nhật đầu tài liệu).')
s=s.replace('Điểm dừng: cần tạo PR từ codex/firebase-auth vào main, chờ CI đạt, merge rồi triển khai đúng commit trên Render cùng Admin secret.', 'Điểm dừng tại mốc trước: cần PR/CI/merge/deploy. Hiện người dùng đã xác nhận backend Firebase triển khai thành công; cần kiểm chứng luồng thực tế như cập nhật đầu tài liệu.')
s=s.replace('Nhánh local: codex/firebase-auth; HEAD 7729570, upstream origin/codex/firebase-auth đã push. Working tree còn README modified và ban_giao_tien_do.md/pdf, tmp/ untracked ở lần kiểm tra; tài liệu mới sẽ thêm 2 file.', 'Mốc Git khi làm Firebase: codex/firebase-auth, commit 7729570 đã push. Mốc hiện tại: HEAD fc6539c, trạng thái working tree nêu ở đầu tài liệu.')
p.write_text(s,encoding='utf-8')
renderer=(root/'tmp/pdfs/build_handoff.py').read_text(encoding='utf-8').split("pdfmetrics.registerFont(TTFont('Arial',",1)[1]
prefix="from pathlib import Path\nfrom xml.sax.saxutils import escape\nfrom reportlab.pdfbase import pdfmetrics\nfrom reportlab.pdfbase.ttfonts import TTFont\nfrom reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Preformatted\nfrom reportlab.lib.styles import ParagraphStyle\nfrom reportlab.lib import colors\nimport pypdfium2 as pdfium\nfrom pypdf import PdfReader\n"
exec(prefix+"\npdfmetrics.registerFont(TTFont('Arial',"+renderer,dict(root=root,content=s))
