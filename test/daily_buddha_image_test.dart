import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/services/daily_buddha_image_service.dart';
import 'package:hanh_trinh_an_nhien/views/trang_chu/folk_home_hero.dart';

AssetImage heroAsset(WidgetTester tester) => tester
    .widget<Image>(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage,
      ),
    )
    .image as AssetImage;

void main() {
  group('DailyBuddhaImageService', () {
    test('selects a stable image and rotates without adjacent repeats', () {
      final firstDay = DateTime(2026, 10, 27);
      final first = DailyBuddhaImageService.imageForDate(firstDay);
      expect(DailyBuddhaImageService.imageForDate(firstDay), first);
      expect(
        DailyBuddhaImageService.imageForDate(DateTime(2026, 10, 28)),
        isNot(first),
      );

      final selections = List.generate(
        DailyBuddhaImageService.imageAssets.length * 2,
        (offset) => DailyBuddhaImageService.imageForDate(
          firstDay.add(Duration(days: offset)),
        ),
      );
      expect(selections.toSet(), hasLength(DailyBuddhaImageService.imageAssets.length));
      for (var i = 1; i < selections.length; i++) {
        expect(selections[i], isNot(selections[i - 1]));
      }
    });

    test('uses fallback for empty lists and supports a single asset', () {
      expect(
        DailyBuddhaImageService.imageForDate(
          DateTime(2026, 10, 27),
          assets: const [],
        ),
        DailyBuddhaImageService.fallbackAsset,
      );
      expect(
        DailyBuddhaImageService.imageForDate(
          DateTime(2026, 10, 27),
          assets: const ['only.jpg'],
        ),
        'only.jpg',
      );
    });

    test('formats the Vietnam day key', () {
      expect(
        DailyBuddhaImageService.dayKey(DateTime(2026, 10, 7)),
        '2026-10-07',
      );
    });
  });

  testWidgets('refreshes on Vietnam midnight and when the app resumes', (
    tester,
  ) async {
    var instant = DateTime.utc(2026, 10, 27, 16, 59); // 23:59 in Vietnam.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FolkHomeHero(clock: () => instant),
        ),
      ),
    );

    final beforeMidnight = heroAsset(tester).assetName;
    instant = DateTime.utc(2026, 10, 27, 17, 1); // 00:01 the next day.
    await tester.pump(const Duration(minutes: 1, seconds: 1));
    final afterMidnight = heroAsset(tester).assetName;
    expect(afterMidnight, isNot(beforeMidnight));
    expect(find.textContaining('28/10/2026'), findsOneWidget);

    instant = DateTime.utc(2026, 10, 28, 17, 1); // 00:01 on the 29th.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(heroAsset(tester).assetName, isNot(afterMidnight));
    expect(find.textContaining('29/10/2026'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
