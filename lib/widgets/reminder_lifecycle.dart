import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/calendar_event_store.dart';
import '../services/local_reminders.dart';

class ReminderLifecycle extends StatefulWidget {
  final Widget child;
  const ReminderLifecycle({super.key, required this.child});
  @override
  State<ReminderLifecycle> createState() => _ReminderLifecycleState();
}

class _ReminderLifecycleState extends State<ReminderLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthService.sessionChanges.addListener(_session);
    CalendarEventStore.changes.addListener(_session);
    _sync();
  }

  void _sync() => unawaited(
    LocalReminders.instance.sync().catchError((Object error) {
      debugPrint('Không thể cập nhật nhắc lịch: ${error.runtimeType}');
    }),
  );
  void _session() => unawaited(
    LocalReminders.instance.sync(sessionChanged: true).catchError((
      Object error,
    ) {
      debugPrint(
        'Không thể cập nhật nhắc lịch theo tài khoản: ${error.runtimeType}',
      );
    }),
  );
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AuthService.sessionChanges.removeListener(_session);
    CalendarEventStore.changes.removeListener(_session);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
