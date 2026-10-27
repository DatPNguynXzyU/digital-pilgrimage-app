import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/calendar_event.dart';
import 'calendar_event_store.dart';
import 'calendar_reminder_preferences.dart';
import 'reminder_plan.dart';

class LocalReminders {
  static final instance = LocalReminders();
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _initializing;
  Future<void> _queue = Future.value();
  int _revision = 0;
  bool get supported =>
      !kIsWeb &&
      [
        TargetPlatform.android,
        TargetPlatform.iOS,
      ].contains(defaultTargetPlatform);

  static const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'calendar_reminders',
      'Nhắc lịch',
      channelDescription: 'Ngày lễ và lịch cá nhân',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      visibility: NotificationVisibility.private,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> initialize() => _initializing ??= _initialize();
  Future<void> _initialize() async {
    if (!supported) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  Future<bool> requestPermission() async {
    if (!supported) return false;
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: false, sound: true) ??
        false;
  }

  Future<void> sendTest() async {
    if (!await requestPermission()) {
      throw StateError('Hãy cấp quyền thông báo trong Cài đặt điện thoại.');
    }
    await _plugin.show(
      id: 99999,
      title: 'Hành trình an nhiên',
      body: 'Thông báo nhắc lịch đã sẵn sàng.',
      notificationDetails: details,
    );
  }

  Future<void> sync({bool sessionChanged = false}) {
    final revision = ++_revision;
    final next = _queue.catchError((Object _) {}).then((_) async {
      if (!supported) return;
      await initialize();
      // Clear previous account notifications even if loading the new account fails.
      if (sessionChanged) await _plugin.cancelAll();
      if (revision != _revision) return;
      final prefs = CalendarReminderPreferences();
      final festivals = await prefs.festivalsEnabled();
      final personal = await prefs.personalEnabled();
      final lead = await prefs.leadMinutes();
      final events = personal
          ? await CalendarEventStore().load()
          : <CalendarEvent>[];
      if (revision != _revision) return;
      final plan = buildReminderPlan(
        now: DateTime.now(),
        festivals: festivals,
        personal: personal,
        leadMinutes: lead,
        events: events,
      );
      await _plugin.cancelAll();
      for (var i = 0; i < plan.length; i++) {
        if (revision != _revision) return;
        final item = plan[i];
        await _plugin.zonedSchedule(
          id: i + 1,
          title: item.title,
          body: item.body,
          scheduledDate: tz.TZDateTime.from(item.at, tz.UTC),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    });
    _queue = next;
    return next;
  }
}
