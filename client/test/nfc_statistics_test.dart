import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanh_trinh_an_nhien/views/admin/nfc_statistics_page.dart';

void main() {
  setUp(
    () =>
        SharedPreferences.setMockInitialValues({'auth_token': 'test-session'}),
  );
  testWidgets(
    'statistics display server totals and handle forbidden without data',
    (tester) async {
      var denied = false;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(const MaterialApp(home: NfcStatisticsPage()));
          await tester.pumpAndSettle();
          expect(find.text('Lượt check-in'), findsOneWidget);
          expect(find.text('7'), findsOneWidget);
          expect(find.text('Người duy nhất'), findsOneWidget);
          expect(find.text('2'), findsOneWidget);
          expect(tester.takeException(), isNull);
          denied = true;
          await tester.tap(find.byTooltip('Tải lại'));
          await tester.pumpAndSettle();
          expect(find.text('Chỉ quản trị viên'), findsOneWidget);
          expect(find.text('Lượt check-in'), findsNothing);
        },
        () => MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer test-session');
          if (denied) {
            return http.Response(
              jsonEncode({'success': false, 'message': 'Chỉ quản trị viên'}),
              403,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          final data = request.url.path.endsWith('/temples')
              ? []
              : {
                  'total': {'scans': 7, 'participants': 2},
                  'activeTemples': 1,
                  'days': [
                    {'_id': '2026-10-28', 'scans': 7, 'participants': 2},
                  ],
                  'temples': [
                    {'name': 'Chùa thử nghiệm', 'scans': 7, 'participants': 2},
                  ],
                  'events': [],
                  'eventsTruncated': false,
                };
          return http.Response(
            jsonEncode({'success': true, 'data': data}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
    },
  );
}
