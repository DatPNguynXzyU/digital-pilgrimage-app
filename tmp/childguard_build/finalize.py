from pathlib import Path
import shutil
src=Path(__file__).parent
dst=Path('D:/PhamNguyenTuanDat_2380614580')
p=src/'frontend/lib/main.dart'
s=p.read_text(encoding='utf8').replace("import 'package:local_auth/local_auth.dart';","import 'fingerprint.dart';").replace('LocalAuthentication()','FingerprintAuth()').replace('!(await auth.getAvailableBiometrics()).contains(BiometricType.fingerprint)','!await auth.available()')
s=s.replace("auth.authenticate(localizedReason:'Dùng vân tay mở phiên ChildGuard',options:const AuthenticationOptions(biometricOnly:true,stickyAuth:true))",'auth.authenticate(context)').replace("auth.authenticate(localizedReason:'Xác nhận bật mở phiên bằng vân tay',options:const AuthenticationOptions(biometricOnly:true))",'auth.authenticate(context)')
p.write_text(s,encoding='utf8')
for folder in ['frontend/lib','frontend/test','backend','docs']:
 shutil.copytree(src/folder,dst/folder,dirs_exist_ok=True,ignore=shutil.ignore_patterns('node_modules'))
for file in ['README.md','render.yaml','.gitignore','frontend/pubspec.yaml']:
 shutil.copy2(src/file,dst/file)
android=dst/'frontend/android/app/src/main'
shutil.copy2(src/'frontend/MainActivity.kt',android/'kotlin/vn/edu/hutech/phamnguyentuandat_2380614580/MainActivity.kt')
p=android/'AndroidManifest.xml'
s=p.read_text().replace('<application','<uses-permission android:name="android.permission.INTERNET"/><uses-permission android:name="android.permission.NFC"/><uses-permission android:name="android.permission.USE_FINGERPRINT"/><uses-permission android:name="android.permission.USE_BIOMETRIC"/><uses-feature android:name="android.hardware.nfc" android:required="false"/><application',1).replace('android:label="phamnguyentuandat_2380614580"','android:label="ChildGuard" android:allowBackup="false" android:usesCleartextTraffic="false"')
s=s.replace('</application>','<activity android:name="com.linusu.flutter_web_auth_2.CallbackActivity" android:exported="true"><intent-filter><action android:name="android.intent.action.VIEW"/><category android:name="android.intent.category.DEFAULT"/><category android:name="android.intent.category.BROWSABLE"/><data android:scheme="childguard"/></intent-filter></activity></application>')
p.write_text(s)
p=dst/'frontend/android/app/build.gradle.kts';p.write_text(p.read_text().replace('minSdk = flutter.minSdkVersion','minSdk = 24'))
