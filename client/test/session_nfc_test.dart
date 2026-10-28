import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanh_trinh_an_nhien/services/auth_service.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({'auth_token': 'old'}));

  test('expired account session is cleared and notifies screens', () async {
    final revision = AuthService.sessionChanges.value;
    await http.runWithClient(() async {
      await expectLater(AuthService().getMe(), throwsException);
    }, () => MockClient((_) async => http.Response('{}', 401)));
    expect(await AuthService().getToken(), isNull);
    expect(AuthService.sessionChanges.value, revision + 1);
  });

  test('late unauthorized response cannot clear a newer login', () async {
    await http.runWithClient(
      () async {
        await expectLater(AuthService().getMe(), throwsException);
      },
      () => MockClient((_) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', 'new');
        return http.Response('{}', 401);
      }),
    );
    expect(await AuthService().getToken(), 'new');
  });

  test('NFC sends authenticated normalized data and refreshes stats only on success', () async {
    final revision = NfcService.checkIns.value;
    await http.runWithClient(
      () async {
        await NfcService().checkIn(uid: '04:ab:01', slug: ' Test-Temple ');
      },
      () => MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer old');
        expect(jsonDecode(request.body), {
          'uid': '04AB01',
          'slug': 'test-temple',
        });
        return http.Response('{"success":true,"data":{}}', 200);
      }),
    );
    expect(NfcService.checkIns.value, revision + 1);
    await http.runWithClient(() async {
      await expectLater(
        NfcService().checkIn(uid: '04AB01', slug: 'test'),
        throwsException,
      );
    }, () => MockClient((_) async => http.Response('{"success":false}', 400)));
    expect(NfcService.checkIns.value, revision + 1);
  });

  test(
    'NFC supports UID-only check-in without a nullable slug crash',
    () async {
      await http.runWithClient(
        () => NfcService().checkIn(uid: '04:ab:01'),
        () => MockClient((request) async {
          expect(jsonDecode(request.body), {'uid': '04AB01'});
          return http.Response('{"success":true,"data":{}}', 200);
        }),
      );
    },
  );
}
