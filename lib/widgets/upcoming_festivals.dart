import 'dart:async';

import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../services/calendar_festival_service.dart';
import '../views/lich/buddhist_festival_pages.dart';
import '../views/lich/calendar_reminder_settings_page.dart';

class UpcomingFestivals extends StatefulWidget {
  const UpcomingFestivals({super.key, this.limit = 3});
  final int limit;
  @override
  State<UpcomingFestivals> createState() => _UpcomingFestivalsState();
}

class _UpcomingFestivalsState extends State<UpcomingFestivals>
    with WidgetsBindingObserver {
  Timer? _timer;
  final _service = CalendarFestivalService();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final events = _service.upcoming(now: now, limit: widget.limit);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sắp diễn ra',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Nhắc ngày lễ',
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const CalendarReminderSettingsPage(),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const BuddhistFestivalListPage(),
                    ),
                  ),
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            if (events.isEmpty) const Text('Chưa có ngày lễ sắp tới.'),
            for (final event in events)
              Builder(
                builder: (context) {
                  final days =
                      DateTime.utc(
                            event.solarDate.year,
                            event.solarDate.month,
                            event.solarDate.day,
                          )
                          .difference(
                            DateTime.utc(now.year, now.month, now.day),
                          )
                          .inDays;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.spa_outlined,
                      color: AppTheme.warmBrown,
                    ),
                    title: Text(event.festival.name),
                    subtitle: Text(
                      '${event.solarDate.day}/${event.solarDate.month}/${event.solarDate.year}'
                      ' · ${event.lunarDay}/${event.lunarMonth} âm lịch\n${days == 0 ? 'Hôm nay' : 'Còn $days ngày'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            BuddhistFestivalDetailPage(occurrence: event),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
