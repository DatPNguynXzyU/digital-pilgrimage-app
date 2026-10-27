import '../models/buddhist_festival.dart';
import '../utils/lunar_calendar.dart';

class CalendarFestivalService {
  final Map<int, List<FestivalOccurrence>> _yearCache = {};

  List<FestivalOccurrence> upcoming({required DateTime now, int limit = 3}) {
    final today = DateTime(now.year, now.month, now.day);
    final year = LunarCalendar.fromSolar(today).year;
    final events =
        [
            ...occurrencesForYear(year),
            ...occurrencesForYear(year + 1),
          ].where((event) => !event.solarDate.isBefore(today)).toList()
          ..sort((a, b) => a.solarDate.compareTo(b.solarDate));
    return events.take(limit).toList();
  }

  static const List<BuddhistFestival> referenceFestivals = [
    BuddhistFestival(
      id: "observance-01-01",
      name: "Ngày vía Đức Phật Di Lặc",
      lunarMonth: 1,
      lunarDay: 1,
      description: "Ngày vía Đức Phật Di Lặc, ngày 01/01 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "buddha-renunciation",
      name: "Ngày Thái tử Tất Đạt Đa xuất gia",
      lunarMonth: 2,
      lunarDay: 8,
      description: "Kỷ niệm Thái tử Tất Đạt Đa xuất gia cầu đạo, tìm con đường giải thoát. Tài liệu đề cập các hoạt động tụng kinh, nghe pháp, thiền quán và văn nghệ tưởng niệm tại chùa Ba Vàng.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "buddha-parinirvana",
      name: "Ngày Đức Phật Thích Ca nhập Niết Bàn",
      lunarMonth: 2,
      lunarDay: 15,
      description: "Ngày tưởng niệm Đức Phật Thích Ca nhập Niết-bàn, hướng về lời dạy và lòng từ bi của Ngài.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "avalokitesvara-2",
      name: "Ngày vía Quan Thế Âm Bồ Tát đản sinh",
      lunarMonth: 2,
      lunarDay: 19,
      description: "Kỷ niệm ngày Quán Thế Âm Bồ Tát đản sinh. Tài liệu đề cập Lễ Ngũ Bách Danh và hoạt động sám hối tại chùa Ba Vàng.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-02-21",
      name: "Ngày vía Phổ Hiền Bồ tát đản sinh",
      lunarMonth: 2,
      lunarDay: 21,
      description: "Ngày vía Phổ Hiền Bồ tát đản sinh, ngày 21/02 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-03-06",
      name: "Ngày vía tôn giả Ca Diếp",
      lunarMonth: 3,
      lunarDay: 6,
      description: "Tưởng niệm Tôn giả Ma Ha Ca Diếp, vị đại đệ tử nổi tiếng về hạnh đầu đà. Tài liệu nhắc đến vai trò của Ngài trong việc kết tập kinh điển sau khi Đức Phật nhập diệt.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-03-16",
      name: "Ngày vía Phật Mẫu chuẩn đề",
      lunarMonth: 3,
      lunarDay: 16,
      description: "Ngày vía Phật Mẫu chuẩn đề, ngày 16/03 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-04-04",
      name: "Ngày vía Văn Thù Bồ tát đản sinh",
      lunarMonth: 4,
      lunarDay: 4,
      description: "Ngày vía Văn Thù Bồ tát đản sinh, ngày 04/04 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "buddha-birth",
      name: "Ngày Đức Phật Thích Ca đản sinh",
      lunarMonth: 4,
      lunarDay: 8,
      description: "Kỷ niệm ngày Đức Phật Thích Ca đản sinh theo mốc 08/4 âm lịch trong tài liệu. Các hoạt động được nhắc đến tại chùa Ba Vàng gồm lễ tắm Phật, rước đăng, cúng dường và tu tập.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
      kind: FestivalKind.major,
    ),
    BuddhistFestival(
      id: "vesak",
      name: "Đại lễ Tam hợp (Vesak)",
      lunarMonth: 4,
      lunarDay: 15,
      description: "Đại lễ Tam hợp (Vesak), được tài liệu ghi riêng vào ngày 15/4 âm lịch.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
      kind: FestivalKind.major,
    ),
    BuddhistFestival(
      id: "observance-04-20",
      name: "Ngày vía Bồ tát Quảng Đức vị pháp thiêu thân",
      lunarMonth: 4,
      lunarDay: 20,
      description: "Tưởng niệm Hòa thượng Thích Quảng Đức vị pháp thiêu thân. Tài liệu đề cập hoạt động giảng pháp và tưởng niệm công đức của Ngài tại chùa Ba Vàng.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-04-23",
      name: "Ngày vía Phổ Hiền thành đạo",
      lunarMonth: 4,
      lunarDay: 23,
      description: "Ngày vía Phổ Hiền thành đạo, ngày 23/04 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-04-28",
      name: "Ngày vía Đức Phật Dược Sư đản sinh",
      lunarMonth: 4,
      lunarDay: 28,
      description: "Ngày vía Đức Phật Dược Sư đản sinh, ngày 28/04 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-05-13",
      name: "Ngày vía Già Lam Thánh Chúng",
      lunarMonth: 5,
      lunarDay: 13,
      description: "Ngày vía Già Lam Thánh Chúng, ngày 13/05 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-06-03",
      name: "Ngày vía Đức Hộ Pháp",
      lunarMonth: 6,
      lunarDay: 3,
      description:
          "Ngày vía Đức Hộ Pháp, ngày 03/06 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-06-15",
      name: "Ngày Đức Phật chuyển pháp luân tại vườn Lộc Uyển",
      lunarMonth: 6,
      lunarDay: 15,
      description: "Kỷ niệm Đức Phật chuyển pháp luân tại vườn Lộc Uyển, truyền dạy con đường thực hành hướng đến chấm dứt khổ đau.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "avalokitesvara-6",
      name: "Ngày vía Quan Thế Âm Bồ tát thành đạo",
      lunarMonth: 6,
      lunarDay: 19,
      description: "Ngày vía Quan Thế Âm Bồ tát thành đạo, ngày 19/06 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-07-13",
      name: "Ngày vía Đức Đại Thế Chí Bồ tát đản sinh",
      lunarMonth: 7,
      lunarDay: 13,
      description: "Ngày vía Đức Đại Thế Chí Bồ tát đản sinh, ngày 13/07 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "vu-lan",
      name: "Ngày Vu Lan báo hiếu - ngày chư Tăng tự tứ",
      lunarMonth: 7,
      lunarDay: 15,
      description: "Ngày Vu Lan báo hiếu, đồng thời là ngày chư Tăng tự tứ theo nội dung tài liệu.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
      kind: FestivalKind.major,
    ),
    BuddhistFestival(
      id: "ksitigarbha",
      name: "Ngày vía Đức Địa Tạng Vương Bồ tát thành đạo",
      lunarMonth: 7,
      lunarDay: 30,
      description: "Ngày vía Đức Địa Tạng Vương Bồ tát thành đạo, ngày 30/07 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện. Tháng âm lịch không có ngày 30 sẽ không hiển thị sự kiện này; không tự đổi sang ngày 29.",
    ),
    BuddhistFestival(
      id: "observance-08-01",
      name: "Ngày Huệ Viễn Tuệ Sư Sơ Tổ Tịnh Độ Tông",
      lunarMonth: 8,
      lunarDay: 1,
      description: "Ngày Huệ Viễn Tuệ Sư Sơ Tổ Tịnh Độ Tông, ngày 01/08 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-08-03",
      name: "Ngày vía Đức Lục Tổ Huệ Năng",
      lunarMonth: 8,
      lunarDay: 3,
      description: "Ngày vía Đức Lục Tổ Huệ Năng, ngày 03/08 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-08-08",
      name: "Ngày vía Tôn giả A Nan Đà",
      lunarMonth: 8,
      lunarDay: 8,
      description: "Ngày vía Tôn giả A Nan Đà, ngày 08/08 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-08-22",
      name: "Ngày vía Đức Phật Nhiên Đăng đản sinh",
      lunarMonth: 8,
      lunarDay: 22,
      description: "Ngày vía Đức Phật Nhiên Đăng đản sinh, ngày 22/08 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-09-15",
      name: "Ngày Tăng Bảo",
      lunarMonth: 9,
      lunarDay: 15,
      description: "Ngày Tăng Bảo, ngày 15/09 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "avalokitesvara-9",
      name: "Ngày vía Quan Âm Bồ Tát xuất gia",
      lunarMonth: 9,
      lunarDay: 19,
      description: "Ngày vía Quan Âm Bồ Tát xuất gia, ngày 19/09 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-09-30",
      name: "Ngày vía Đức Phật Dược Sư Lưu Ly thành đạo",
      lunarMonth: 9,
      lunarDay: 30,
      description: "Ngày vía Đức Phật Dược Sư Lưu Ly thành đạo, ngày 30/09 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện. Tháng âm lịch không có ngày 30 sẽ không hiển thị sự kiện này; không tự đổi sang ngày 29.",
    ),
    BuddhistFestival(
      id: "observance-10-05",
      name: "Ngày vía Đức Bồ Đề Đạt Ma (Sư tổ thiền tông)",
      lunarMonth: 10,
      lunarDay: 5,
      description: "Ngày vía Đức Bồ Đề Đạt Ma (Sư tổ thiền tông), ngày 05/10 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-11-11",
      name: "Ngày sinh Phật Hoàng Trần Nhân Tông",
      lunarMonth: 11,
      lunarDay: 11,
      description: "Ngày sinh Phật Hoàng Trần Nhân Tông, ngày 11/11 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "amitabha",
      name: "Ngày vía Đức Phật A Di Đà đản sinh",
      lunarMonth: 11,
      lunarDay: 17,
      description: "Ngày vía Đức Phật A Di Đà đản sinh, ngày 17/11 âm lịch theo tài liệu cung cấp.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "buddha-enlightenment",
      name: "Ngày vía Đức Phật Thích Ca Thành Đạo",
      lunarMonth: 12,
      lunarDay: 8,
      description: "Kỷ niệm Đức Phật Thích Ca thành đạo; dịp tưởng nhớ ân đức, thực hành tu tập và nuôi dưỡng tâm tri ân Tam Bảo.",
      traditionNote: "Nguồn: nội dung Lịch.docx do người dùng cung cấp. Ngày lễ và nghi thức có thể khác theo truyền thống, tự viện.",
    ),
    BuddhistFestival(
      id: "observance-10-23",
      name: "Pháp đàn Lương Hoàng Bảo Sám tại chùa Ba Vàng",
      lunarMonth: 10,
      lunarDay: 23,
      description: "Tài liệu đề cập Pháp đàn Lương Hoàng Bảo Sám tại chùa Ba Vàng, bắt đầu ngày 23/10 âm lịch và diễn ra trong 3 ngày 3 đêm.",
      traditionNote: "Đây là hoạt động riêng tại chùa Ba Vàng được nêu trong tài liệu, không phải ngày lễ chung. Mốc trên là ngày bắt đầu tham khảo; cần xem thông báo của chùa để xác nhận lịch tổ chức từng năm.",
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
        final date = datesByLunarDate[exactKey];
        final actualDay = festival.lunarDay;
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
