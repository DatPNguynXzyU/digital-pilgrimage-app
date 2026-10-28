import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hanh_trinh_an_nhien/services/backend_readiness.dart';

void main() {
  test(
    'readiness retries an unavailable server using GET health only',
    () async {
      var calls = 0;
      await http.runWithClient(
        BackendReadiness.waitUntilReady,
        () => MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/health');
          calls++;
          return http.Response('{}', calls == 1 ? 503 : 200);
        }),
      );
      expect(calls, 2);
    },
  );
}
