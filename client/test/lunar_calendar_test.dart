import 'package:flutter_test/flutter_test.dart';

import 'package:hanh_trinh_an_nhien/utils/lunar_calendar.dart';

void main() {
  test('converts Vietnamese lunar new year dates', () {
    final lunarNewYear = LunarCalendar.fromSolar(DateTime(2024, 2, 10));

    expect(lunarNewYear.day, 1);
    expect(lunarNewYear.month, 1);
    expect(lunarNewYear.year, 2024);
    expect(lunarNewYear.isLeapMonth, isFalse);
  });

  test('converts the 2024 Mid-Autumn Festival date', () {
    final midAutumn = LunarCalendar.fromSolar(DateTime(2024, 9, 17));

    expect(midAutumn.day, 15);
    expect(midAutumn.month, 8);
    expect(midAutumn.year, 2024);
    expect(midAutumn.isLeapMonth, isFalse);
  });

  test('identifies a leap month', () {
    final leapMonthStart = LunarCalendar.fromSolar(DateTime(2023, 3, 22));

    expect(leapMonthStart.day, 1);
    expect(leapMonthStart.month, 2);
    expect(leapMonthStart.year, 2023);
    expect(leapMonthStart.isLeapMonth, isTrue);
  });
}
