import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/models/scripture.dart';
import 'package:hanh_trinh_an_nhien/views/kinh_sach/chi_tiet_kinh_sach.dart';

void main() {
  Future<ScrollController> open(WidgetTester tester) async {
    final scripture = Scripture(
      id: '1',
      title: 'Bài đọc',
      slug: 'bai-doc',
      type: 'Kinh',
      description: '',
      content: List.filled(100, 'Một dòng kinh để đọc.').join('\n'),
      source: '',
      imageUrl: '',
      order: 0,
      featured: false,
    );
    await tester.pumpWidget(
      MaterialApp(home: ChiTietKinhSachPage(scripture: scripture)),
    );
    return tester
        .widget<ListView>(find.byKey(const ValueKey('scripture-reader')))
        .controller!;
  }

  testWidgets('Auto scroll moves, changes speed and pauses', (tester) async {
    final scroll = await open(tester);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    final slow = scroll.offset;
    expect(slow, greaterThan(0));
    tester.widget<Slider>(find.byType(Slider)).onChanged!(64);
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(scroll.offset - slow, greaterThan(slow));
    await tester.tap(find.text('Tạm dừng'));
    await tester.pump();
    final paused = scroll.offset;
    await tester.pump(const Duration(seconds: 1));
    expect(scroll.offset, paused);
  });

  testWidgets('Stops at end, on background and manual drag', (tester) async {
    final scroll = await open(tester);
    scroll.jumpTo(scroll.position.maxScrollExtent - 1);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    scroll.jumpTo(scroll.position.maxScrollExtent - 0.5);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Bắt đầu'), findsOneWidget);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.text('Bắt đầu'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    await tester.drag(
      find.byKey(const ValueKey('scripture-reader')),
      const Offset(0, -100),
    );
    await tester.pump();
    expect(find.text('Bắt đầu'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
