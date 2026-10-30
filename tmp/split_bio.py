from pathlib import Path
p=Path('D:/PhamNguyenTuanDat_2380614580/frontend')
(p/'lib/fingerprint.dart').write_text('''import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

enum LoginBiometric { face, fingerprint }
extension LoginBiometricInfo on LoginBiometric {
 String get label => this == LoginBiometric.face ? 'khuôn mặt' : 'vân tay';
 String get storageKey => this == LoginBiometric.face ? 'face_token' : 'fingerprint_token';
 IconData get icon => this == LoginBiometric.face ? Icons.face_retouching_natural : Icons.fingerprint;
}
class FingerprintAuth {
 final LocalAuthentication _auth = LocalAuthentication();
 static bool supportsOnly(List<BiometricType> types, LoginBiometric method) {
  final wanted=method==LoginBiometric.face?BiometricType.face:BiometricType.fingerprint;
  final other=method==LoginBiometric.face?BiometricType.fingerprint:BiometricType.face;
  // The plugin cannot restrict the system prompt to one modality. Fail closed.
  return types.contains(wanted) && !types.contains(other) && !types.contains(BiometricType.iris)
    && !types.contains(BiometricType.strong) && !types.contains(BiometricType.weak);
 }
 Future<bool> available(LoginBiometric method) async => supportsOnly(await _auth.getAvailableBiometrics(),method);
 Future<bool> authenticate(BuildContext context, LoginBiometric method) async {
  if(!await available(method))throw Exception('Android không cho xác thực riêng bằng ${method.label} trên cấu hình thiết bị này. Hãy dùng OTP.');
  return _auth.authenticate(localizedReason:'Dùng ${method.label} để mở ChildGuard',options:const AuthenticationOptions(biometricOnly:true,stickyAuth:true));
 }
}
''',encoding='utf8')
f=p/'lib/main.dart';s=f.read_text(encoding='utf8').replace('Future<void> biometric()', 'Future<void> biometric(LoginBiometric method)').replace('Future<void> enableFinger()', 'Future<void> enableFinger(LoginBiometric method)')
s=s.replace('auth.available()', 'auth.available(method)').replace('auth.authenticate(context)', 'auth.authenticate(context, method)').replace("key: 'biometric_token'",'key: method.storageKey')
s=s.replace("'Thiết bị cần sinh trắc học đã đăng ký và được Android hỗ trợ.'","'Không xác nhận được riêng ${method.label}. Android có thể chỉ cung cấp sinh trắc học chung; hãy dùng OTP.'")
s=s.replace("'Hãy đăng ký khuôn mặt hoặc vân tay trong cài đặt Android.'","'Không xác nhận được riêng ${method.label} trên thiết bị này. Hãy dùng OTP.'")
s=s.replace("'Hãy đăng nhập bằng OTP và bật sinh trắc học trong tài khoản trước.'","'Hãy đăng nhập và bật mở bằng ${method.label} trong Tài khoản trước.'")
s=s.replace("'Đã bật vân tay. Phiên hết hạn sau 12 giờ; sau đó cần OTP.'","'Đã bật ${method.label}. Phiên hết hạn sau 12 giờ; sau đó cần đăng nhập lại.'")
a=s.index('                  TextButton.icon(',s.index("label: const Text('Tiếp tục với Google')"));b=s.index('\n                ],',a)
s=s[:a]+'''                  for (final method in LoginBiometric.values)
                    TextButton.icon(
                      onPressed: busy ? null : () => biometric(method),
                      icon: Icon(method.icon),
                      label: Text('Mở bằng ${method.label}'),
                    ),'''+s[b:]
a=s.index('              Card(',s.index("subtitle: Text(widget.user['email'])") if "subtitle: Text(widget.user['email'])" in s else s.index("title: const Text('Bật khuôn mặt / vân tay')")-150)
# Locate the card that directly contains the combined biometric setting.
title=s.index("title: const Text('Bật khuôn mặt / vân tay')")
a=s.rfind('              Card(',0,title);b=s.index('              const SizedBox(height: 16),',title)
s=s[:a]+'''              for (final method in LoginBiometric.values)
                Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(children: [
                  ListTile(leading: Icon(method.icon), title: Text('Đăng nhập bằng ${method.label}'),
                    subtitle: const Text('Cài đặt riêng. Chỉ hoạt động khi hệ điều hành xác định đúng phương thức; nếu không, dùng OTP.')),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: () async {
                      await Api.storage.delete(key: method.storageKey);
                      if (context.mounted) notify(context, 'Đã tắt ${method.label}');
                    }, child: const Text('Tắt')),
                    FilledButton.icon(onPressed: () => enableFinger(method), icon: Icon(method.icon), label: const Text('Bật')),
                    const SizedBox(width: 12),
                  ]),
                ]))),
'''+s[b:];f.write_text(s,encoding='utf8')
(p/'test/biometric_test.dart').write_text('''import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:phamnguyentuandat_2380614580/fingerprint.dart';
void main(){
 test('Separate keys and no cross-modality authentication',(){
  expect(LoginBiometric.face.storageKey,isNot(LoginBiometric.fingerprint.storageKey));
  expect(FingerprintAuth.supportsOnly([BiometricType.face],LoginBiometric.face),isTrue);
  expect(FingerprintAuth.supportsOnly([BiometricType.face],LoginBiometric.fingerprint),isFalse);
  expect(FingerprintAuth.supportsOnly([BiometricType.fingerprint],LoginBiometric.fingerprint),isTrue);
  for(final method in LoginBiometric.values){
   expect(FingerprintAuth.supportsOnly([BiometricType.face,BiometricType.fingerprint],method),isFalse);
   expect(FingerprintAuth.supportsOnly([BiometricType.strong,BiometricType.weak],method),isFalse);
   expect(FingerprintAuth.supportsOnly([],method),isFalse);
  }
 });
}
''',encoding='utf8')
f=p/'test/widget_test.dart';s=f.read_text().replace("expect(find.text('Tiếp tục với Google'), findsOneWidget);","expect(find.text('Tiếp tục với Google'), findsOneWidget);\n      expect(find.text('Mở bằng khuôn mặt'), findsOneWidget);\n      expect(find.text('Mở bằng vân tay'), findsOneWidget);");f.write_text(s)
