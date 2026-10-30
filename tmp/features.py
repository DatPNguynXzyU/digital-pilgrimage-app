from pathlib import Path
p=Path('D:/PhamNguyenTuanDat_2380614580')
f=p/'backend/src/schema.sql';f.write_text(f.read_text()+'''
CREATE TABLE IF NOT EXISTS shared_locations (
 child_id uuid PRIMARY KEY REFERENCES children(id) ON DELETE CASCADE,
 latitude double precision NOT NULL, longitude double precision NOT NULL,
 accuracy double precision NOT NULL, updated_at timestamptz NOT NULL DEFAULT now()
);
''')
f=p/'backend/src/app.js';s=f.read_text(encoding='utf8');pos=s.index(" app.get('/staff/dashboard'")
s=s[:pos]+''' app.get('/children/:id/location',run(async(req,res)=>{
  await owned(idSchema.parse(req.params.id),req.user);
  const location=(await q('SELECT * FROM shared_locations WHERE child_id=$1',[req.params.id])).rows[0];
  res.json(location || null);
 }));
 const linkedChild=async(id,u)=>{
  if(u.role!=='child')fail(403,'Chỉ tài khoản trẻ được chia sẻ vị trí của mình');
  const link=(await q('SELECT * FROM child_links WHERE child_id=$1 AND user_id=$2',[id,u.id])).rows[0];
  if(!link)fail(404,'Không tìm thấy liên kết');
 };
 app.put('/children/:id/location',run(async(req,res)=>{
  const id=idSchema.parse(req.params.id);await linkedChild(id,req.user);
  const b=z.object({latitude:z.number().min(-90).max(90),longitude:z.number().min(-180).max(180),accuracy:z.number().min(0).max(100000)}).parse(req.body);
  res.json((await q('INSERT INTO shared_locations(child_id,latitude,longitude,accuracy) VALUES($1,$2,$3,$4) ON CONFLICT(child_id) DO UPDATE SET latitude=$2,longitude=$3,accuracy=$4,updated_at=now() RETURNING *',[id,b.latitude,b.longitude,b.accuracy])).rows[0]);
 }));
 app.delete('/children/:id/location',run(async(req,res)=>{
  const id=idSchema.parse(req.params.id);await linkedChild(id,req.user);
  await q('DELETE FROM shared_locations WHERE child_id=$1',[id]);res.status(204).end();
 }));
'''+s[pos:];f.write_text(s,encoding='utf8')
f=p/'frontend/pubspec.yaml';s=f.read_text().replace('  http:','  geolocator: ^14.0.0\n  url_launcher: ^6.3.0\n  http:');f.write_text(s)
f=p/'frontend/android/app/src/main/AndroidManifest.xml';s=f.read_text().replace('<application','<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/><uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/><application',1);f.write_text(s)
f=p/'frontend/lib/fingerprint.dart';s=f.read_text();a=s.index('    return types.contains');b=s.index('\n  }',a);s=s[:a]+'    return types.isNotEmpty;'+s[b:];s=s.replace('Không xác nhận được phương thức chỉ dùng vân tay. Hãy đăng nhập bằng OTP.','Thiết bị chưa có sinh trắc học được ứng dụng hỗ trợ. Hãy đăng nhập bằng OTP.').replace('Dùng vân tay để mở phiên ChildGuard','Dùng khuôn mặt hoặc vân tay để mở ChildGuard');f.write_text(s)
f=p/'frontend/lib/main.dart';s=f.read_text(encoding='utf8').replace("import 'api.dart';","import 'api.dart';\nimport 'location_card.dart';")
s=s.replace('Mở phiên bằng vân tay','Mở bằng khuôn mặt / vân tay').replace('Bật mở phiên bằng vân tay','Bật khuôn mặt / vân tay').replace('Tắt mở phiên bằng vân tay','Tắt khuôn mặt / vân tay').replace('Hãy đăng ký vân tay trong cài đặt Android.','Hãy đăng ký khuôn mặt hoặc vân tay trong cài đặt Android.').replace('Thiết bị cần cảm biến và vân tay đã đăng ký.','Thiết bị cần sinh trắc học đã đăng ký và được Android hỗ trợ.').replace('bật vân tay trong tài khoản trước.','bật sinh trắc học trong tài khoản trước.').replace('Cần đăng nhập OTP trước; không gửi vân tay lên server','Cần đăng nhập trước. Android chọn khuôn mặt hoặc vân tay được hỗ trợ; không gửi mẫu sinh trắc lên server.')
s=s.replace("                const Text(\n                  'Điểm chạm an tâm',","                LocationCard(api: api, childId: id, canShare: !widget.isParent),\n                const SizedBox(height: 24),\n                const Text(\n                  'Điểm chạm an tâm',")
s=s.replace('      scaffoldBackgroundColor:', '''      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size(48, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), iconColor: green),
      navigationBarTheme: const NavigationBarThemeData(backgroundColor: Color(0xFFEAF1EB), indicatorColor: Color(0xFFCBE9DC)),
      scaffoldBackgroundColor:''')
s=s.replace('elevation: 0,\n        color: Colors.white,','elevation: 0,\n        margin: const EdgeInsets.symmetric(vertical: 7),\n        color: Colors.white,')
f.write_text(s,encoding='utf8')
