import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/models/temple.dart';
import 'package:hanh_trinh_an_nhien/models/calendar_event.dart';
import 'package:hanh_trinh_an_nhien/services/nearby_temples.dart';
import 'package:hanh_trinh_an_nhien/services/calendar_festival_service.dart';
import 'package:hanh_trinh_an_nhien/services/reminder_plan.dart';

void main() {
  Temple temple(String id, double? lat, double? lon) => Temple.fromJson({
    'id': id,
    'name': id,
    'location': {'latitude': lat, 'longitude': lon},
  });
  test('nearest ordering handles missing and invalid coordinates without mutating input', () {
    final source = [
      temple('unknown', null, null),
      temple('far', 0, 1),
      temple('near', 0, 0.001),
      temple('invalid', 91, 0),
    ];
    final result = NearbyTemples.sorted(source, 0, 0);
    expect(result.map((e) => e.id), ['near', 'far', 'invalid', 'unknown']);
    expect(source.first.id, 'unknown');
    expect(NearbyTemples.distance(source[2], 0, 0), closeTo(111, 2));
    expect(NearbyTemples.distance(source[3], 0, 0), isNull);
    expect(NearbyTemples.distance(temple('nan', double.nan, 1), 0, 0), isNull);
  });
  test('upcoming includes today at night and crosses lunar year boundary', () {
    final service = CalendarFestivalService();
    final festival = service.occurrencesForYear(2026).first;
    final today = festival.solarDate.add(const Duration(hours: 23));
    expect(
      service.upcoming(now: today).first.festival.id,
      festival.festival.id,
    );
    final next = service.upcoming(now: DateTime(2026, 12, 31, 23), limit: 6);
    expect(next, hasLength(6));
    expect(
      next.every((e) => !e.solarDate.isBefore(DateTime(2026, 12, 31))),
      isTrue,
    );
    expect(
      next.map((e) => '${e.festival.id}:${e.solarDate}').toSet(),
      hasLength(6),
    );
  });
  CalendarEvent event(
    String id, {
    int? lead = 15,
    CalendarRepeat repeat = CalendarRepeat.none,
  }) => CalendarEvent(
    id: id,
    title: id,
    startAt: DateTime(2026, 10, 24, 9),
    endAt: DateTime(2026, 10, 26, 10),
    reminderMinutes: lead,
    repeat: repeat,
  );
  test('personal reminders respect opt out, offsets, past times and multi-day start', () {
    final events = [event('yes'), event('no', lead: null)];
    final plan = buildReminderPlan(
      now: DateTime(2026, 10, 24, 8),
      festivals: false,
      personal: true,
      leadMinutes: 60,
      events: events,
    );
    expect(plan, hasLength(1));
    expect(plan.single.title, 'yes');
    expect(plan.single.at, DateTime(2026, 10, 24, 8, 45));
    expect(
      buildReminderPlan(
        now: DateTime(2026, 10, 24, 10),
        festivals: false,
        personal: true,
        leadMinutes: 60,
        events: events,
      ),
      isEmpty,
    );
    expect(
      buildReminderPlan(
        now: DateTime(2026, 10, 24, 8),
        festivals: false,
        personal: false,
        leadMinutes: 60,
        events: events,
      ),
      isEmpty,
    );
  });
  test('recurring queue is sorted and bounded to 60, deletion rebuild removes old entries', () {
    final plan = buildReminderPlan(
      now: DateTime(2026, 10, 24, 8),
      festivals: true,
      personal: true,
      leadMinutes: 60,
      events: [event('daily', repeat: CalendarRepeat.daily)],
    );
    expect(plan, hasLength(60));
    for (var i = 1; i < plan.length; i++) {
      expect(plan[i].at.isBefore(plan[i - 1].at), isFalse);
    }
    expect(
      buildReminderPlan(
        now: DateTime(2026, 10, 24, 8),
        festivals: false,
        personal: true,
        leadMinutes: 60,
        events: [],
      ),
      isEmpty,
    );
  });
  test('festival default reminder is before 08:00, using document dates', () {
    final occurrence = CalendarFestivalService().occurrencesForYear(2026).first;
    final date = occurrence.solarDate;
    final plan = buildReminderPlan(
      now: date,
      festivals: true,
      personal: false,
      leadMinutes: 60,
      events: [],
    );
    expect(plan.first.title, occurrence.festival.name);
    expect(plan.first.at, DateTime(date.year, date.month, date.day, 7));
  });
}
