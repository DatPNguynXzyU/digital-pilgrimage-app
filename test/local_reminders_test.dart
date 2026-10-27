import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanh_trinh_an_nhien/services/local_reminders.dart';
import 'package:hanh_trinh_an_nhien/services/calendar_reminder_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  setUp(() {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'initialize' ||
              call.method == 'requestNotificationsPermission') {
            return true;
          }
          return null;
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test('opt-in schedules native reminders; disabling cancels all without asking for permission at startup', () async {
    final service = LocalReminders();
    await service.sync();
    expect(calls.where((c) => c.method == 'zonedSchedule'), isEmpty);
    expect(
      calls.where((c) => c.method == 'requestNotificationsPermission'),
      isEmpty,
    );
    await CalendarReminderPreferences().save(
      festivalsEnabled: true,
      personalEnabled: false,
      leadMinutes: 60,
    );
    calls.clear();
    await service.sync();
    expect(calls.first.method, 'cancelAll');
    final scheduled = calls.where((c) => c.method == 'zonedSchedule').toList();
    expect(scheduled, isNotEmpty);
    expect(scheduled.length, lessThanOrEqualTo(60));
    expect(
      scheduled.map((c) => (c.arguments as Map)['id']).toSet().length,
      scheduled.length,
    );
    await CalendarReminderPreferences().save(
      festivalsEnabled: false,
      personalEnabled: false,
      leadMinutes: 60,
    );
    calls.clear();
    await service.sync();
    expect(calls.map((c) => c.method), ['cancelAll']);
  });
  test(
    'test notification explicitly requests permission and invokes native show',
    () async {
      await LocalReminders().sendTest();
      expect(
        calls.map((c) => c.method),
        containsAllInOrder([
          'initialize',
          'requestNotificationsPermission',
          'show',
        ]),
      );
    },
  );
  test('denied permission does not display a test notification', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return call.method == 'initialize';
        });
    await expectLater(LocalReminders().sendTest(), throwsStateError);
    expect(calls.where((c) => c.method == 'show'), isEmpty);
  });
}
