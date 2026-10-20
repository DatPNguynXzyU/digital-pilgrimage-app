import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/models/calendar_event.dart';
import 'package:hanh_trinh_an_nhien/services/calendar_event_store.dart';
import 'package:hanh_trinh_an_nhien/services/calendar_festival_service.dart';
import 'package:hanh_trinh_an_nhien/utils/lunar_calendar.dart';
import 'package:hanh_trinh_an_nhien/views/lich/calendar_event_detail_page.dart';
import 'package:hanh_trinh_an_nhien/views/lich/calendar_event_form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CalendarFestivalService', () {
    final service = CalendarFestivalService();

    test('converts the 2024 Vesak and Vu Lan reference dates', () {
      final occurrences = service.occurrencesForYear(2024);
      final vesak = occurrences.singleWhere(
        (item) => item.festival.id == 'vesak',
      );
      final vuLan = occurrences.singleWhere(
        (item) => item.festival.id == 'vu-lan',
      );

      expect(vesak.solarDate, DateTime(2024, 5, 22));
      expect(vuLan.solarDate, DateTime(2024, 8, 18));
    });

    test('includes full moons in leap lunar months', () {
      final fullMoons = service
          .occurrencesForYear(2023)
          .where((item) => item.festival.id == 'full-moon-monthly')
          .toList();

      expect(fullMoons, hasLength(13));
      expect(
        fullMoons.where((item) {
          return LunarCalendar.fromSolar(item.solarDate).isLeapMonth;
        }),
        hasLength(1),
      );
    });

    test('falls the 30th-day observance back to day 29 in a short month', () {
      DateTime? fallback;
      for (var year = 2000; year < 2050 && fallback == null; year++) {
        final exact = service.dateForLunarDate(
          year: year,
          month: 7,
          day: 30,
          clampDay30: false,
        );
        if (exact == null) {
          fallback = service.dateForLunarDate(year: year, month: 7, day: 30);
        }
      }

      expect(fallback, isNotNull);
      final lunar = LunarCalendar.fromSolar(fallback!);
      expect(lunar.day, 29);
      expect(lunar.month, 7);
    });
  });

  group('CalendarEvent', () {
    test('covers every day of a multi-day personal event', () {
      final event = CalendarEvent(
        id: 'retreat',
        title: 'Khóa tu',
        startAt: DateTime(2024, 2, 10, 9),
        endAt: DateTime(2024, 2, 12, 15),
      );

      expect(event.occursOn(DateTime(2024, 2, 10)), isTrue);
      expect(event.occursOn(DateTime(2024, 2, 11)), isTrue);
      expect(event.occursOn(DateTime(2024, 2, 12)), isTrue);
      expect(event.occursOn(DateTime(2024, 2, 13)), isFalse);
    });

    test('repeats a lunar yearly event using the Vietnamese lunar date', () {
      final service = CalendarFestivalService();
      final nextLunarNewYear = service.dateForLunarDate(
        year: 2025,
        month: 1,
        day: 1,
      )!;
      final event = CalendarEvent(
        id: 'lunar-yearly',
        title: 'Lịch âm',
        startAt: DateTime(2024, 2, 10, 9),
        endAt: DateTime(2024, 2, 10, 10),
        usesLunarDate: true,
        repeat: CalendarRepeat.yearly,
      );

      expect(event.occursOn(nextLunarNewYear), isTrue);
    });

    test('round-trips personal event fields through JSON', () {
      final event = CalendarEvent(
        id: 'event-1',
        title: 'Thời khóa',
        startAt: DateTime(2024, 2, 10, 9),
        endAt: DateTime(2024, 2, 10, 10),
        usesLunarDate: true,
        location: 'Chùa',
        description: 'Ghi chú',
        reminderMinutes: 30,
        repeat: CalendarRepeat.monthly,
      );

      expect(CalendarEvent.fromJson(event.toJson()).toJson(), event.toJson());
    });
  });

  test('stores, updates, and deletes personal events locally', () async {
    SharedPreferences.setMockInitialValues({});
    final store = CalendarEventStore();
    final event = CalendarEvent(
      id: 'local-1',
      title: 'Lễ Phật',
      startAt: DateTime(2024, 2, 10, 9),
      endAt: DateTime(2024, 2, 10, 10),
    );

    await store.upsert(event);
    expect((await store.load()).single.title, 'Lễ Phật');

    final updated = CalendarEvent(
      id: event.id,
      title: 'Lễ Phật buổi sáng',
      startAt: event.startAt,
      endAt: event.endAt,
    );
    await store.upsert(updated);
    expect((await store.load()).single.title, 'Lễ Phật buổi sáng');

    await store.delete(event.id);
    expect(await store.load(), isEmpty);
  });

  testWidgets('creates a personal event from the form and stores it locally', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => CalendarEventFormPage(
                      initialDate: DateTime(2024, 2, 10),
                    ),
                  ),
                ),
                child: const Text('Open add form'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open add form'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Thời khóa');
    final saveButton = find.text('Lưu lịch');
    await tester.scrollUntilVisible(
      saveButton,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final events = await CalendarEventStore().load();
    expect(events, hasLength(1));
    expect(events.single.title, 'Thời khóa');
  });

  testWidgets('deletes a personal event only after confirmation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final event = CalendarEvent(
      id: 'delete-me',
      title: 'Lịch cần xóa',
      startAt: DateTime(2024, 2, 10, 9),
      endAt: DateTime(2024, 2, 10, 10),
    );
    await CalendarEventStore().upsert(event);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => CalendarEventDetailPage(event: event),
                  ),
                ),
                child: const Text('Open detail'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open detail'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Xóa lịch'));
    await tester.pumpAndSettle();
    expect(find.text('Xóa lịch này?'), findsOneWidget);
    await tester.tap(find.text('Xóa lịch'));
    await tester.pumpAndSettle();

    expect(await CalendarEventStore().load(), isEmpty);
  });
}
