import '../models/buddhist_festival.dart';
import '../utils/lunar_calendar.dart';

class CalendarFestivalService {
  final Map<int, List<FestivalOccurrence>> _yearCache = {};

  static const List<BuddhistFestival> referenceFestivals = [
    BuddhistFestival(
      id: 'lunar-new-year-monthly',
      name: 'Mùng Một âm lịch',
      lunarMonth: 1,
      lunarDay: 1,
      everyLunarMonth: true,
      description: 'Ngày đầu tháng âm lịch; ngày thực hành tùy theo mỗi người.',
      kind: FestivalKind.monthly,
    ),
    BuddhistFestival(
      id: 'full-moon-monthly',
      name: 'Ngày Rằm',
      lunarMonth: 1,
      lunarDay: 15,
      everyLunarMonth: true,
      description: 'Ngày 15 âm lịch hằng tháng.',
      kind: FestivalKind.monthly,
    ),
    BuddhistFestival(
      id: 'tet-nguyen-tieu',
      name: 'Rằm tháng Giêng',
      lunarMonth: 1,
      lunarDay: 15,
      description: 'Ngày Rằm đầu năm âm lịch, được nhiều cộng đồng Phật giáo và địa phương ghi nhận.',
      kind: FestivalKind.major,
      traditionNote:
          'Ý nghĩa và nghi lễ có thể khác nhau theo truyền thống, địa phương.',
    ),
    BuddhistFestival(
      id: 'buddha-renunciation',
      name: 'Ngày Đức Phật xuất gia',
      lunarMonth: 2,
      lunarDay: 8,
      description: 'Ngày kỷ niệm theo một số lịch lễ Phật giáo Đông Á.',
      traditionNote: 'Ngày kỷ niệm có thể khác nhau theo truyền thống.',
    ),
    BuddhistFestival(
      id: 'buddha-parinirvana',
      name: 'Ngày Đức Phật nhập Niết-bàn',
      lunarMonth: 2,
      lunarDay: 15,
      description: 'Ngày tưởng niệm theo truyền thống Phật giáo Bắc truyền.',
      traditionNote:
          'Các truyền thống Phật giáo có thể tưởng niệm vào ngày khác.',
    ),
    BuddhistFestival(
      id: 'avalokitesvara-2',
      name: 'Vía Quán Thế Âm Bồ Tát',
      lunarMonth: 2,
      lunarDay: 19,
      description: 'Ngày vía được ghi nhận trong lịch Phật giáo Bắc truyền.',
    ),
    BuddhistFestival(
      id: 'vesak',
      name: 'Đại lễ Phật Đản',
      lunarMonth: 4,
      lunarDay: 15,
      description: 'Đại lễ kỷ niệm ngày Đức Phật đản sinh; ngày tổ chức theo lịch truyền thống được chọn.',
      kind: FestivalKind.major,
      traditionNote: 'Ngày 15 tháng 4 âm lịch là quy ước tham khảo; ngày đại lễ có thể khác theo quốc gia và truyền thống.',
    ),
    BuddhistFestival(
      id: 'avalokitesvara-6',
      name: 'Vía Quán Thế Âm Bồ Tát',
      lunarMonth: 6,
      lunarDay: 19,
      description: 'Ngày vía được ghi nhận trong lịch Phật giáo Bắc truyền.',
    ),
    BuddhistFestival(
      id: 'vu-lan',
      name: 'Vu Lan Báo Hiếu',
      lunarMonth: 7,
      lunarDay: 15,
      description: 'Lễ Vu Lan gắn với thực hành tri ân, báo ân trong văn hóa Phật giáo Việt Nam.',
      kind: FestivalKind.major,
      traditionNote:
          'Các nghi lễ và hoạt động cụ thể tùy từng tự viện và địa phương.',
    ),
    BuddhistFestival(
      id: 'ksitigarbha',
      name: 'Vía Địa Tạng Bồ Tát',
      lunarMonth: 7,
      lunarDay: 30,
      description: 'Ngày vía theo lịch Phật giáo Bắc truyền.',
      traditionNote:
          'Nếu tháng 7 chỉ có 29 ngày, lịch tham khảo chuyển về ngày 29.',
    ),
    BuddhistFestival(
      id: 'avalokitesvara-9',
      name: 'Vía Quán Thế Âm Bồ Tát',
      lunarMonth: 9,
      lunarDay: 19,
      description: 'Ngày vía được ghi nhận trong lịch Phật giáo Bắc truyền.',
    ),
    BuddhistFestival(
      id: 'amitabha',
      name: 'Vía Phật A Di Đà',
      lunarMonth: 11,
      lunarDay: 17,
      description: 'Ngày vía được ghi nhận trong lịch Phật giáo Bắc truyền.',
    ),
    BuddhistFestival(
      id: 'buddha-enlightenment',
      name: 'Ngày Đức Phật Thành đạo',
      lunarMonth: 12,
      lunarDay: 8,
      description: 'Ngày kỷ niệm theo lịch Phật giáo Bắc truyền.',
    ),
  ];

  List<FestivalOccurrence> occurrencesForYear(int year) {
    final cached = _yearCache[year];
    if (cached != null) return cached;
    final datesByLunarDate = <(int, int, bool, int), DateTime>{};
    for (
      var date = DateTime(year, 1, 1);
      date.isBefore(DateTime(year + 2, 1, 1));
      date = date.add(const Duration(days: 1))
    ) {
      final lunar = LunarCalendar.fromSolar(date);
      datesByLunarDate.putIfAbsent((
        lunar.month,
        lunar.day,
        lunar.isLeapMonth,
        lunar.year,
      ), () => date);
    }

    final results = <FestivalOccurrence>[];
    for (final festival in referenceFestivals) {
      final months = festival.everyLunarMonth
          ? List<int>.generate(12, (index) => index + 1)
          : [festival.lunarMonth];
      for (final month in months) {
        if (festival.everyLunarMonth) {
          for (final entry in datesByLunarDate.entries) {
            final (entryMonth, entryDay, _, entryYear) = entry.key;
            if (entryMonth == month &&
                entryDay == festival.lunarDay &&
                entryYear == year) {
              results.add(
                FestivalOccurrence(
                  festival: festival,
                  solarDate: entry.value,
                  lunarDay: entryDay,
                  lunarMonth: entryMonth,
                ),
              );
            }
          }
          continue;
        }

        final exactKey = (month, festival.lunarDay, false, year);
        var date = datesByLunarDate[exactKey];
        var actualDay = festival.lunarDay;
        if (date == null && festival.lunarDay == 30) {
          date = datesByLunarDate[(month, 29, false, year)];
          actualDay = 29;
        }
        if (date == null) continue;
        results.add(
          FestivalOccurrence(
            festival: festival,
            solarDate: date,
            lunarDay: actualDay,
            lunarMonth: month,
          ),
        );
      }
    }
    results.sort((a, b) => a.solarDate.compareTo(b.solarDate));
    _yearCache[year] = results;
    return results;
  }

  List<FestivalOccurrence> occurrencesForDate(DateTime date) {
    final lunar = LunarCalendar.fromSolar(date);
    return occurrencesForYear(lunar.year)
        .where(
          (event) =>
              event.solarDate.year == date.year &&
              event.solarDate.month == date.month &&
              event.solarDate.day == date.day,
        )
        .toList();
  }

  DateTime? dateForLunarDate({
    required int year,
    required int month,
    required int day,
    bool leapMonth = false,
    bool clampDay30 = true,
  }) {
    for (
      var date = DateTime(year, 1, 1);
      date.isBefore(DateTime(year + 2, 1, 1));
      date = date.add(const Duration(days: 1))
    ) {
      final lunar = LunarCalendar.fromSolar(date);
      if (lunar.year == year &&
          lunar.month == month &&
          lunar.day == day &&
          lunar.isLeapMonth == leapMonth) {
        return date;
      }
    }
    if (clampDay30 && day == 30) {
      for (
        var date = DateTime(year, 1, 1);
        date.isBefore(DateTime(year + 2, 1, 1));
        date = date.add(const Duration(days: 1))
      ) {
        final lunar = LunarCalendar.fromSolar(date);
        if (lunar.year == year &&
            lunar.month == month &&
            lunar.day == 29 &&
            lunar.isLeapMonth == leapMonth) {
          final next = date.add(const Duration(days: 1));
          final nextLunar = LunarCalendar.fromSolar(next);
          if (nextLunar.month != month || nextLunar.isLeapMonth != leapMonth) {
            return date;
          }
        }
      }
    }
    return null;
  }
}
