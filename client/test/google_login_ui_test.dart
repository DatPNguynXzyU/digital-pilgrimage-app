import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanh_trinh_an_nhien/views/tai_khoan/login_page.dart';
import 'package:hanh_trinh_an_nhien/services/auth_service.dart';

void main() {
  testWidgets('Google unavailable does not create a session or close login', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.ensureVisible(find.text('Tiếp tục với Google'));
    await tester.tap(find.text('Tiếp tục với Google'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(await AuthService().getToken(), isNull);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
