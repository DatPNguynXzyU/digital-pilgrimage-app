import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/services/calendar_festival_service.dart';
import 'package:hanh_trinh_an_nhien/utils/lunar_calendar.dart';

void main() {
  const expected = <String, (int, int)>{
    'observance-01-01': (1, 1),
    'buddha-renunciation': (8, 2),
    'buddha-parinirvana': (15, 2),
    'avalokitesvara-2': (19, 2),
    'observance-02-21': (21, 2),
    'observance-03-06': (6, 3),
    'observance-03-16': (16, 3),
    'observance-04-04': (4, 4),
    'buddha-birth': (8, 4),
    'vesak': (15, 4),
    'observance-04-20': (20, 4),
    'observance-04-23': (23, 4),
    'observance-04-28': (28, 4),
    'observance-05-13': (13, 5),
    'observance-06-03': (3, 6),
    'observance-06-15': (15, 6),
    'avalokitesvara-6': (19, 6),
    'observance-07-13': (13, 7),
    'vu-lan': (15, 7),
    'ksitigarbha': (30, 7),
    'observance-08-01': (1, 8),
    'observance-08-03': (3, 8),
    'observance-08-08': (8, 8),
    'observance-08-22': (22, 8),
    'observance-09-15': (15, 9),
    'avalokitesvara-9': (19, 9),
    'observance-09-30': (30, 9),
    'observance-10-05': (5, 10),
    'observance-11-11': (11, 11),
    'amitabha': (17, 11),
    'buddha-enlightenment': (8, 12),
    'observance-10-23': (23, 10),
  };
  test('Only document events occur on their exact lunar dates', () {
    final service = CalendarFestivalService();
    final catalog = CalendarFestivalService.referenceFestivals;
    expect(catalog.map((f) => f.id).toSet(), expected.keys.toSet());
    expect(catalog.every((f) => !f.everyLunarMonth), isTrue);
    for (final year in [2023, 2024, 2026, 2027]) {
      final occurrences = service.occurrencesForYear(year);
      for (final entry in expected.entries) {
        final matches = occurrences
            .where((o) => o.festival.id == entry.key)
            .toList();
        final (expectedDay, expectedMonth) = entry.value;
        final exact = service.dateForLunarDate(
          year: year,
          month: expectedMonth,
          day: expectedDay,
          clampDay30: false,
        );
        if (exact == null) {
          expect(matches, isEmpty, reason: '${entry.key} in $year');
          continue;
        }
        expect(matches, hasLength(1), reason: '${entry.key} in $year');
        final lunar = LunarCalendar.fromSolar(matches.single.solarDate);
        final (day, month) = entry.value;
        expect(lunar.year, year);
        expect(lunar.month, month);
        expect(lunar.isLeapMonth, false);
        expect(lunar.day, day);
      }
    }
  });
  test('Buddha birthday and Vesak are separate; local ceremony is labeled', () {
    final events = CalendarFestivalService().occurrencesForYear(2026);
    final birth = events.singleWhere((o) => o.festival.id == 'buddha-birth');
    final vesak = events.singleWhere((o) => o.festival.id == 'vesak');
    expect(vesak.solarDate.difference(birth.solarDate).inDays, 7);
    final local = events.singleWhere(
      (o) => o.festival.id == 'observance-10-23',
    );
    expect(local.festival.name, contains('chùa Ba Vàng'));
    expect(local.festival.description, contains('3 ngày 3 đêm'));
  });
}
