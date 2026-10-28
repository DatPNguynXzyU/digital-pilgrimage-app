import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanh_trinh_an_nhien/models/calendar_event.dart';
import 'package:hanh_trinh_an_nhien/services/calendar_event_store.dart';

void main() {
  final event = CalendarEvent(
    id: 'cloud-1',
    title: 'Lịch tài khoản',
    startAt: DateTime(2026, 10, 16, 9),
    endAt: DateTime(2026, 10, 16, 10),
  );
  test(
    'authenticated calendar uses token and does not merge guest events',
    () async {
      SharedPreferences.setMockInitialValues({
        'auth_token': 'alice-token',
        'personal_calendar_events_v1': jsonEncode([event.toJson()]),
      });
      final requests = <http.Request>[];
      final store = CalendarEventStore(
        client: MockClient((request) async {
          requests.add(request);
          expect(request.headers['Authorization'], 'Bearer alice-token');
          if (request.method == 'GET' &&
              request.url.path.endsWith('/cloud-1')) {
            return http.Response('{"success":false}', 404);
          }
          return http.Response(
            jsonEncode({
              'success': true,
              'data': request.method == 'GET' ? [] : event.toJson(),
            }),
            request.method == 'POST' ? 201 : 200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      expect(await store.load(), isEmpty);
      await store.upsert(event);
      await store.delete(event.id);
      expect(requests.map((r) => r.method).toList(), [
        'GET',
        'GET',
        'POST',
        'DELETE',
      ]);
      final prefs = await SharedPreferences.getInstance();
      expect(
        jsonDecode(prefs.getString('personal_calendar_events_v1')!),
        hasLength(1),
      );
    },
  );
  test(
    'expired token and server errors never fall back to guest storage',
    () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'expired'});
      final store = CalendarEventStore(
        client: MockClient(
          (_) async => http.Response('{"success":false}', 401),
        ),
      );
      await expectLater(store.load(), throwsException);
      await expectLater(store.upsert(event), throwsException);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('personal_calendar_events_v1'), isNull);
    },
  );
  test(
    'existing cloud event is updated and backend fields round-trip',
    () async {
      SharedPreferences.setMockInitialValues({'auth_token': 'token'});
      final methods = <String>[];
      final store = CalendarEventStore(
        client: MockClient((request) async {
          methods.add(request.method);
          if (request.method == 'PUT') {
            expect(jsonDecode(request.body), event.toJson());
          }
          return http.Response(
            jsonEncode({
              'success': true,
              'data': request.url.path.endsWith('/cloud-1')
                  ? event.toJson()
                  : [event.toJson()],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      expect((await store.load()).single.toJson(), event.toJson());
      await store.upsert(event);
      expect(methods, ['GET', 'GET', 'PUT']);
    },
  );
}
