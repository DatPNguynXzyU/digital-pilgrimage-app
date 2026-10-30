import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanh_trinh_an_nhien/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => SharedPreferences.setMockInitialValues({
      AuthService.rememberedUidKey: 'remembered-user',
    }),
  );
  test('remembered account is not an active app session', () async {
    final auth = AuthService();
    expect(await auth.hasRememberedAccount(), isTrue);
    expect(await auth.isLoggedIn(), isFalse);
    expect(await auth.getToken(), isNull);
  });
  test('cancelled biometrics cannot restore a session', () async {
    final auth = AuthService(authenticate: () async => false);
    await expectLater(auth.loginWithBiometrics(), throwsException);
    expect(await auth.isLoggedIn(), isFalse);
    expect(await auth.hasRememberedAccount(), isTrue);
  });
  test('forget during biometric prompt prevents restoration', () async {
    final auth = AuthService(
      authenticate: () async {
        await AuthService().logout();
        return true;
      },
    );
    await expectLater(auth.loginWithBiometrics(), throwsException);
    expect(await auth.isLoggedIn(), isFalse);
    expect(await auth.hasRememberedAccount(), isFalse);
  });
  test('full logout deletes remembered account and active bearer', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'legacy-token');
    await AuthService().logout();
    expect(prefs.getString('auth_token'), isNull);
    expect(await AuthService().hasRememberedAccount(), isFalse);
  });
}
