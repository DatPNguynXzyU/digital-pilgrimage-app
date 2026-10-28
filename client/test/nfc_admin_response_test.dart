import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_admin_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({'auth_token': 'test'}));
  test('missing deployment and HTML errors produce actionable messages', () async {
    for (final status in [404, 502]) {
      await http.runWithClient(() async {
        await expectLater(NfcAdminService().request('statistics'), throwsA(
          predicate((error) => error.toString().contains(
            status == 404 ? 'triển khai backend mới' : 'HTTP 502')),
        ));
      }, () => MockClient((_) async => http.Response('<!DOCTYPE html>', status)));
    }
  });
}
