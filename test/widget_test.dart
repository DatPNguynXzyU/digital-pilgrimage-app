import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hanh_trinh_an_nhien/utils/lunar_calendar.dart';
import 'package:hanh_trinh_an_nhien/views/buddhist_figures/buddhist_figure_list_page.dart';
import 'package:hanh_trinh_an_nhien/views/kinh_sach/kinh_sach.dart';
import 'package:hanh_trinh_an_nhien/views/lich/lich_page.dart';
import 'package:hanh_trinh_an_nhien/views/main_nav.dart';
import 'package:hanh_trinh_an_nhien/views/temples/temple_list_page.dart';
import 'package:hanh_trinh_an_nhien/views/trang_chu/home_dhammapada_card.dart';
import 'package:hanh_trinh_an_nhien/views/trang_chu/home_hero.dart';
import 'package:hanh_trinh_an_nhien/views/trang_chu/folk_home_hero.dart';
import 'package:hanh_trinh_an_nhien/services/saved_items_store.dart';
import 'package:hanh_trinh_an_nhien/widgets/saved_item_buttons.dart';
import 'package:hanh_trinh_an_nhien/views/temples/saved_items_page.dart';

void main() {
  testWidgets('scripture tab opens the Buddhist figure lookup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: KinhSachPage()));

    expect(find.text('Tra cứu chư vị'), findsOneWidget);
    final headingRect = tester.getRect(
      find.byKey(const ValueKey('scripture-page-heading')),
    );
    final lookupRect = tester.getRect(
      find.byKey(const ValueKey('buddhist-figure-lookup')),
    );
    expect(lookupRect.left, greaterThan(headingRect.right));
    expect(lookupRect.center.dy, closeTo(headingRect.center.dy, 8));

    await tester.tap(find.text('Tra cứu chư vị'));
    await tester.pumpAndSettle();

    expect(find.byType(BuddhistFigureListPage), findsOneWidget);
    expect(find.byType(KinhSachPage, skipOffstage: false), findsOneWidget);
  });

  testWidgets('temple tab no longer shows the Buddhist figure lookup', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: TempleListPage()));

    expect(find.text('Tra cứu chư vị'), findsNothing);
    expect(find.text('Check-In'), findsOneWidget);

    await tester.tap(find.text('Check-In'));
    await tester.pumpAndSettle();

    expect(find.text('Check-in NFC'), findsOneWidget);
    expect(find.text('Yêu cầu đăng nhập'), findsOneWidget);
  });

  testWidgets('main navigation has the five required tabs', (
    WidgetTester tester,
  ) async {
    var selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() => selectedIndex = index);
              },
            ),
          ),
        ),
      ),
    );

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.destinations, hasLength(5));
    expect(
      tester
          .widgetList<NavigationDestination>(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.byType(NavigationDestination),
            ),
          )
          .map((destination) => destination.label),
      ['Trang chủ', 'Lịch', 'Kinh sách', 'Chùa', 'Cá nhân'],
    );
    expect(navigationBar.selectedIndex, 0);

    await tester.tap(find.text('Chùa'));
    await tester.pump();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
  });

  testWidgets('calendar displays and navigates full months', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(home: LichPage(initialDate: DateTime(2026, 10, 14))),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tháng 10 năm 2026'), findsOneWidget);
    expect(find.text('T2'), findsOneWidget);
    expect(find.text('CN'), findsOneWidget);
    expect(find.byKey(const ValueKey('selected-lunar-date')), findsOneWidget);
    expect(find.text('Ngày'), findsOneWidget);
    expect(find.text('Tuần'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('next-month')));
    await tester.pumpAndSettle();

    expect(find.text('Tháng 11 năm 2026'), findsOneWidget);
    expect(find.text('Thứ Bảy, 14/11/2026'), findsOneWidget);

    final lastDay = find.byKey(const ValueKey('calendar-day-2026-11-30'));
    await tester.tap(lastDay);
    await tester.pumpAndSettle();

    expect(find.text('Thứ Hai, 30/11/2026'), findsOneWidget);
  });

  testWidgets('calendar shows lunar dates for each solar day', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(home: LichPage(initialDate: DateTime(2024, 2, 10))),
    );
    await tester.pumpAndSettle();

    final lunarNewYearCell = find.byKey(
      const ValueKey('calendar-day-2024-2-10'),
    );
    expect(
      tester
          .widgetList<Text>(
            find.descendant(of: lunarNewYearCell, matching: find.byType(Text)),
          )
          .map((text) => text.data),
      ['10', '1'],
    );
    expect(find.text('Âm lịch: ngày 1, tháng 1 năm 2024'), findsOneWidget);
  });

  testWidgets('calendar switches between day, week, and month views', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(home: LichPage(initialDate: DateTime(2024, 2, 10))),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tuần'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('week-calendar')), findsOneWidget);

    await tester.tap(find.text('Ngày'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('day-agenda')), findsOneWidget);

    await tester.tap(find.text('Tháng'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('month-calendar')), findsOneWidget);
  });

  testWidgets('home hero shows solar and lunar dates without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(348, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final today = DateTime(2026, 10, 14);
    final lunarDate = LunarCalendar.fromSolar(today);
    final solarLabel =
        '${today.day.toString().padLeft(2, '0')}/'
        '${today.month.toString().padLeft(2, '0')}/${today.year}';
    final lunarLabel =
        '${lunarDate.day.toString().padLeft(2, '0')}/'
        '${lunarDate.month.toString().padLeft(2, '0')}'
        '${lunarDate.isLeapMonth ? ' nhuận' : ''}/${lunarDate.year}';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 308, child: HomeHero(date: today)),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(solarLabel), findsOneWidget);
    expect(find.text(lunarLabel), findsOneWidget);
    expect(find.text('DƯƠNG'), findsOneWidget);
    expect(find.text('ÂM'), findsOneWidget);

    final brandRect = tester.getRect(find.byKey(const ValueKey('hero-brand')));
    final titleRect = tester.getRect(find.text('Một ngày\nan nhiên'));
    final descriptionRect = tester.getRect(
      find.text('Chậm lại một nhịp, lắng nghe lòng mình.'),
    );
    final dateCardRect = tester.getRect(
      find.byKey(const ValueKey('hero-date-card')),
    );

    expect(brandRect.top, lessThan(titleRect.top));
    expect(titleRect.left, closeTo(descriptionRect.left, 0.1));
    expect(titleRect.left, closeTo(dateCardRect.left, 0.1));
    final gaps = [
      titleRect.top - brandRect.bottom,
      descriptionRect.top - titleRect.bottom,
      dateCardRect.top - descriptionRect.bottom,
    ];
    expect(gaps[0], closeTo(gaps[1], 1));
    expect(gaps[1], closeTo(gaps[2], 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('editorial calendar hero fits small and large layouts', (
    WidgetTester tester,
  ) async {
    for (final size in [const Size(320, 700), const Size(460, 900)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(size.width < 400 ? 1.5 : 1),
            ),
            child: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: size.width - 32,
                  child: FolkHomeHero(
                    date: DateTime(2026, 10, 27),
                    onOpenCalendar: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const ValueKey('hero-date-card')), findsOneWidget);
      expect(find.textContaining('Thứ Ba'), findsOneWidget);
      expect(find.textContaining('Năm Bính Ngọ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Dhammapada handles empty data and retry', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeDhammapadaCard(
            loadQuote: (_) async {
              attempts++;
              if (attempts == 1) throw Exception('offline');
              return null;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Không thể tải câu Phật ngôn. Vui lòng thử lại.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có câu Phật ngôn.'), findsOneWidget);
  });

  testWidgets('saved temple button persists and toggles favorite state', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SaveItemButton(id: 'temple-1', temple: true)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_border_rounded));
    await tester.pumpAndSettle();
    expect(await SavedItemsStore().loadTemples(), contains('temple-1'));
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_rounded));
    await tester.pumpAndSettle();
    expect(await SavedItemsStore().loadTemples(), isEmpty);
  });

  testWidgets('saved page shows a useful empty state', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: SavedItemsPage()));
    await tester.pumpAndSettle();
    expect(
      find.text('Những ngôi chùa và ngày lễ bạn lưu sẽ xuất hiện ở đây.'),
      findsOneWidget,
    );
  });
}
