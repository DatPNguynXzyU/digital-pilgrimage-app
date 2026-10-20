import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanh_trinh_an_nhien/services/auth_service.dart';
import 'package:hanh_trinh_an_nhien/services/biometric_lock.dart';
import 'package:hanh_trinh_an_nhien/widgets/biometric_gate.dart';

void main() {
  Widget app() => const MaterialApp(
    home: BiometricGate(child: Scaffold(body: Text('Private content'))),
  );

  testWidgets('saved opt-in hides content; failed biometric stays locked', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'session',
      BiometricLock.preferenceKey: true,
    });
    await tester.pumpWidget(
      MaterialApp(
        home: BiometricGate(
          authenticate: () async => false,
          child: const Scaffold(body: Text('Private content')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Private content'), findsNothing);
    await tester.tap(find.text('Xác thực vân tay'));
    await tester.pumpAndSettle();
    // A cancelled or unsuccessful native challenge must fail closed.
    expect(find.text('Private content'), findsNothing);
    expect(find.textContaining('Chưa xác thực'), findsOneWidget);
    await tester.tap(find.text('Đăng xuất để dùng mật khẩu'));
    await tester.pumpAndSettle();
    expect(await AuthService().getToken(), isNull);
    expect(await BiometricLock.enabled(), isFalse);
    expect(find.text('Private content'), findsOneWidget);
  });

  testWidgets('without opt-in app opens normally', (tester) async {
    SharedPreferences.setMockInitialValues({'auth_token': 'session'});
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Private content'), findsOneWidget);
  });

  testWidgets('success unlocks and leaving app locks again', (tester) async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'session',
      BiometricLock.preferenceKey: true,
    });
    await tester.pumpWidget(
      MaterialApp(
        home: BiometricGate(
          authenticate: () async => true,
          child: const Scaffold(body: Text('Private content')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác thực vân tay'));
    await tester.pumpAndSettle();
    expect(find.text('Private content'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(find.text('Private content'), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Private content'), findsNothing);
  });

  test(
    'stale unauthorized response does not disable another session lock',
    () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'new-session',
        BiometricLock.preferenceKey: true,
      });
      await AuthService().invalidateSession('old-session');
      expect(await BiometricLock.enabled(), isTrue);
      await AuthService().invalidateSession('new-session');
      expect(await BiometricLock.enabled(), isFalse);
      expect(await AuthService().getToken(), isNull);
    },
  );
}
