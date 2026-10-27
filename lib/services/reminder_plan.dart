import '../models/calendar_event.dart';
import 'calendar_festival_service.dart';

class PlannedReminder {
  final String title;
  final String body;
  final DateTime at;
  const PlannedReminder(this.title, this.body, this.at);
}

/// A rolling queue replenished whenever the app opens or calendars change.
/// Limited to 60 pending entries to stay below iOS's 64-notification limit.
List<PlannedReminder> buildReminderPlan({
  required DateTime now,
  required bool festivals,
  required bool personal,
  required int leadMinutes,
  required List<CalendarEvent> events,
}) {
  final result = <PlannedReminder>[];
  if (festivals) {
    for (final item in CalendarFestivalService().upcoming(
      now: now,
      limit: 70,
    )) {
      final date = item.solarDate;
      final at = DateTime(
        date.year,
        date.month,
        date.day,
        8,
      ).subtract(Duration(minutes: leadMinutes));
      if (at.isAfter(now)) {
        result.add(
          PlannedReminder(
            item.festival.name,
            '${item.lunarDay}/${item.lunarMonth} âm lịch · ${date.day}/${date.month}/${date.year}',
            at,
          ),
        );
      }
    }
  }
  if (personal) {
    for (final stored in events) {
      // API timestamps may be UTC; recurrence days must use device-local dates.
      final event = CalendarEvent(
        id: stored.id,
        title: stored.title,
        startAt: stored.startAt.toLocal(),
        endAt: stored.endAt.toLocal(),
        usesLunarDate: stored.usesLunarDate,
        reminderMinutes: stored.reminderMinutes,
        repeat: stored.repeat,
      );
      // A null reminder explicitly means this event has no reminder.
      final lead = event.reminderMinutes;
      if (lead == null) continue;
      if (event.repeat == CalendarRepeat.none) {
        final at = event.startAt.toLocal().subtract(Duration(minutes: lead));
        if (at.isAfter(now)) {
          result.add(PlannedReminder(event.title, 'Lịch cá nhân của bạn', at));
        }
        continue;
      }
      for (var offset = 0; offset <= 366; offset++) {
        final day = DateTime(now.year, now.month, now.day + offset);
        if (!event.occursOn(day)) continue;
        final start = event.startAt.toLocal();
        final at = DateTime(
          day.year,
          day.month,
          day.day,
          start.hour,
          start.minute,
        ).subtract(Duration(minutes: lead));
        if (at.isAfter(now)) {
          result.add(PlannedReminder(event.title, 'Lịch cá nhân của bạn', at));
        }
      }
    }
  }
  result.sort((a, b) => a.at.compareTo(b.at));
  return result.take(60).toList();
}
