import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/views/tai_khoan/forgot_password_page.dart';

void main() {
  testWidgets(
    'invalid email does not send; valid email blocks duplicate sends and permits resend after cooldown',
    (tester) async {
      final pending = Completer<void>();
      final emails = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: ForgotPasswordPage(
            sendReset: (email) {
              emails.add(email);
              return pending.future;
            },
          ),
        ),
      );
      await tester.tap(find.text('Gửi liên kết đặt lại'));
      await tester.pump();
      expect(find.text('Vui lòng nhập email hợp lệ.'), findsOneWidget);
      expect(emails, isEmpty);
      await tester.enterText(
        find.byType(TextFormField),
        '  pilgrim@example.com  ',
      );
      await tester.tap(find.text('Gửi liên kết đặt lại'));
      await tester.pump();
      expect(emails, ['pilgrim@example.com']);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      pending.complete();
      await tester.pump();
      expect(find.textContaining('Nếu email có tài khoản'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      await tester.pump(const Duration(seconds: 60));
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'failed send leaves email and permits retry without claiming success',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ForgotPasswordPage(
            initialEmail: 'pilgrim@example.com',
            sendReset: (_) async => throw Exception('Không có mạng'),
          ),
        ),
      );
      await tester.tap(find.text('Gửi liên kết đặt lại'));
      await tester.pumpAndSettle();
      expect(find.text('Không có mạng'), findsOneWidget);
      expect(find.textContaining('Nếu email có tài khoản'), findsNothing);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
      expect(find.text('pilgrim@example.com'), findsOneWidget);
    },
  );
}
