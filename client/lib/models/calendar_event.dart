import '../utils/lunar_calendar.dart';

enum CalendarRepeat { none, daily, weekly, monthly, yearly }

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final bool usesLunarDate;
  final String location;
  final String description;
  final int? reminderMinutes;
  final CalendarRepeat repeat;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.usesLunarDate = false,
    this.location = '',
    this.description = '',
    this.reminderMinutes,
    this.repeat = CalendarRepeat.none,
  });

  bool occursOn(DateTime date) {
    final selected = DateTime(date.year, date.month, date.day);
    final start = DateTime(startAt.year, startAt.month, startAt.day);

    if (selected.isBefore(start)) return false;

    if (repeat == CalendarRepeat.none) {
      final end = DateTime(endAt.year, endAt.month, endAt.day);
      return !selected.isBefore(start) && !selected.isAfter(end);
    }

    if (usesLunarDate) {
      final startLunar = LunarCalendar.fromSolar(startAt);
      final selectedLunar = LunarCalendar.fromSolar(selected);

      return switch (repeat) {
        CalendarRepeat.daily => true,
        CalendarRepeat.weekly => selected.weekday == start.weekday,
        CalendarRepeat.monthly => _matchesLunarDay(
          startLunar.day,
          selected,
          selectedLunar,
        ),
        CalendarRepeat.yearly =>
          selectedLunar.month == startLunar.month &&
              _matchesLunarDay(startLunar.day, selected, selectedLunar) &&
              !selectedLunar.isLeapMonth,
        CalendarRepeat.none => selected == start,
      };
    }

    return switch (repeat) {
      CalendarRepeat.daily => true,
      CalendarRepeat.weekly => selected.weekday == start.weekday,
      CalendarRepeat.monthly =>
        selected.day == _dayForMonth(start.day, selected.year, selected.month),
      CalendarRepeat.yearly =>
        selected.month == start.month &&
            selected.day == _dayForMonth(start.day, selected.year, start.month),
      CalendarRepeat.none => selected == start,
    };
  }

  static int _dayForMonth(int day, int year, int month) =>
      day.clamp(1, DateTime(year, month + 1, 0).day);

  static bool _matchesLunarDay(
    int targetDay,
    DateTime selected,
    LunarDate selectedLunar,
  ) {
    if (selectedLunar.day == targetDay) return true;
    if (targetDay != 30 || selectedLunar.day != 29) return false;
    final nextLunar = LunarCalendar.fromSolar(
      selected.add(const Duration(days: 1)),
    );
    return nextLunar.month != selectedLunar.month ||
        nextLunar.isLeapMonth != selectedLunar.isLeapMonth;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startAt': startAt.toIso8601String(),
    'endAt': endAt.toIso8601String(),
    'usesLunarDate': usesLunarDate,
    'location': location,
    'description': description,
    'reminderMinutes': reminderMinutes,
    'repeat': repeat.name,
  };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
    id: json['id'] as String,
    title: json['title'] as String,
    startAt: DateTime.parse(json['startAt'] as String),
    endAt: DateTime.parse(json['endAt'] as String),
    usesLunarDate: json['usesLunarDate'] as bool? ?? false,
    location: json['location'] as String? ?? '',
    description: json['description'] as String? ?? '',
    reminderMinutes: json['reminderMinutes'] as int?,
    repeat: CalendarRepeat.values.firstWhere(
      (value) => value.name == json['repeat'],
      orElse: () => CalendarRepeat.none,
    ),
  );
}
