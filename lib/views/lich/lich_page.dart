import 'package:flutter/material.dart';
import '../../utils/lunar_calendar.dart';

class LichPage extends StatefulWidget {
  const LichPage({super.key});

  @override
  State<LichPage> createState() => _LichPageState();
}

class _LichPageState extends State<LichPage> {
  static const Color primaryBrown = Color(0xFFA56A12);
  static const Color darkText = Color(0xFF2B2B2B);
  static const Color softBackground = Color(0xFFF7F4EF);
  static const Color headerBackground = Color(0xFFF3EEE7);
  static const Color sundayRed = Color(0xFFD4574B);
  static const Color lunarGray = Color(0xFF9C9C9C);
  static const Color greenDot = Color(0xFF20B36A);
  static const Color yellowDot = Color(0xFFF2A51A);

  DateTime _focusedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  DateTime _selectedDate = DateTime.now();

  final Map<String, List<CalendarEvent>> _events = {
    '2026-09-01': [
      CalendarEvent(
        title: 'Lễ đầu tháng',
        time: '08:00',
        location: 'Chùa gần bạn',
        type: 'green',
      ),
    ],
    '2026-09-03': [
      CalendarEvent(
        title: 'Tụng kinh tối',
        time: '19:00',
        location: 'Tại nhà',
        type: 'yellow',
      ),
    ],
    '2026-09-06': [
      CalendarEvent(
        title: 'Viếng chùa',
        time: '09:00',
        location: 'Chùa X',
        type: 'green',
      ),
    ],
    '2026-09-11': [
      CalendarEvent(
        title: 'Thiền',
        time: '20:00',
        location: 'Tại nhà',
        type: 'yellow',
      ),
    ],
    '2026-09-13': [
      CalendarEvent(
        title: 'Đọc kinh',
        time: '19:30',
        location: 'Tại nhà',
        type: 'green',
      ),
    ],
    '2026-09-14': [
      CalendarEvent(
        title: 'Thắp hương',
        time: '06:00',
        location: 'Tại nhà',
        type: 'green',
      ),
    ],
    '2026-09-18': [
      CalendarEvent(
        title: 'Lễ chùa',
        time: '07:30',
        location: 'Chùa Y',
        type: 'yellow',
      ),
      CalendarEvent(
        title: 'Nghe pháp',
        time: '18:30',
        location: 'Chùa Y',
        type: 'green',
      ),
    ],
    '2026-09-20': [
      CalendarEvent(
        title: 'Tụng kinh',
        time: '19:00',
        location: 'Tại nhà',
        type: 'green',
      ),
    ],
    '2026-09-25': [
      CalendarEvent(
        title: 'Đọc kinh Phổ Môn',
        time: '20:00',
        location: 'Tại nhà',
        type: 'yellow',
      ),
      CalendarEvent(
        title: 'Thiền',
        time: '21:00',
        location: 'Tại nhà',
        type: 'green',
      ),
    ],
    '2026-09-26': [
      CalendarEvent(
        title: 'Lễ cuối tuần',
        time: '08:00',
        location: 'Chùa A',
        type: 'green',
      ),
    ],
    '2026-09-30': [
      CalendarEvent(
        title: 'Sự kiện cuối tháng',
        time: '17:00',
        location: 'Tại nhà',
        type: 'green',
      ),
    ],
  };

  String _dateKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  List<CalendarEvent> _getEvents(DateTime date) {
    return _events[_dateKey(date)] ?? [];
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + 1,
      );
    });
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstWeekdayOfMonth(DateTime date) {
    final weekday = DateTime(date.year, date.month, 1).weekday;
    return weekday - 1; // tuần bắt đầu từ thứ 2
  }

  String _monthLabel(DateTime date) {
    return 'Tháng ${date.month.toString().padLeft(2, '0')} - ${date.year}';
  }

  Color _weekdayColor(int index) {
    if (index == 6) return sundayRed;
    return const Color(0xFF7A7A7A);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    _buildMonthBar(),
                    const SizedBox(height: 14),
                    _buildWeekDays(),
                    const SizedBox(height: 10),
                    _buildCalendarGrid(),
                    const SizedBox(height: 28),
                    _buildYearButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 18),
      decoration: const BoxDecoration(
        color: headerBackground,
      ),
      child: Stack(
        children: [
          Positioned(
            left: -8,
            top: -10,
            child: Icon(
              Icons.local_florist_rounded,
              size: 60,
              color: Colors.brown.withOpacity(0.08),
            ),
          ),
          Positioned(
            right: -8,
            top: -10,
            child: Icon(
              Icons.local_florist_rounded,
              size: 60,
              color: Colors.brown.withOpacity(0.08),
            ),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lịch và Sự kiện',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xem lịch / sự kiện'),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: darkText,
                  size: 28,
                ),
              ),
              IconButton(
                onPressed: _showAddEventDialog,
                icon: const Icon(
                  Icons.add,
                  color: darkText,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(
              Icons.chevron_left,
              size: 30,
              color: darkText,
            ),
          ),
          Expanded(
            child: Text(
              _monthLabel(_focusedMonth),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(
              Icons.chevron_right,
              size: 30,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays() {
    const days = ['Hai', 'Ba', 'Tư', 'Năm', 'Sáu', 'Bảy', 'CN'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: List.generate(days.length, (index) {
          return Expanded(
            child: Center(
              child: Text(
                days[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _weekdayColor(index),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _daysInMonth(_focusedMonth);
    final leadingDays = _firstWeekdayOfMonth(_focusedMonth);

    final previousMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 0);
    final daysInPreviousMonth = previousMonth.day;

    final totalCells = 42; // 6 hàng x 7 cột

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: List.generate(6, (rowIndex) {
          return Row(
            children: List.generate(7, (columnIndex) {
              final cellIndex = rowIndex * 7 + columnIndex;
              late DateTime cellDate;
              bool isCurrentMonth = true;

              if (cellIndex < leadingDays) {
                final day = daysInPreviousMonth - leadingDays + cellIndex + 1;
                cellDate = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                  day,
                );
                isCurrentMonth = false;
              } else if (cellIndex >= leadingDays + daysInMonth) {
                final day = cellIndex - (leadingDays + daysInMonth) + 1;
                cellDate = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                  day,
                );
                isCurrentMonth = false;
              } else {
                final day = cellIndex - leadingDays + 1;
                cellDate = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month,
                  day,
                );
              }

              return Expanded(
                child: _buildDayCell(
                  date: cellDate,
                  isCurrentMonth: isCurrentMonth,
                  isSunday: columnIndex == 6,
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildDayCell({
  required DateTime date,
  required bool isCurrentMonth,
  required bool isSunday,
}) {
  final isSelected = _isSameDay(date, _selectedDate);
  final lunar = LunarCalendar.fromSolar(date);
  final events = _getEvents(date);

  String lunarText;

  if (lunar.day == 1) {
    lunarText =
        '1/${lunar.month}${lunar.isLeapMonth ? "N" : ""}';
  } else {
    lunarText = '${lunar.day}';
  }

  final dayTextColor = !isCurrentMonth
      ? Colors.grey.shade400
      : isSelected
          ? Colors.white
          : isSunday
              ? sundayRed
              : darkText;

  final lunarTextColor = !isCurrentMonth
      ? Colors.grey.shade300
      : isSelected
          ? Colors.white70
          : lunarGray;

  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedDate = date;

        if (!isCurrentMonth) {
          _focusedMonth = DateTime(
            date.year,
            date.month,
          );
        }
      });
    },
    child: SizedBox(
      height: 74,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 58,
          decoration: BoxDecoration(
            color: isSelected
                ? primaryBrown
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  children: [
                    Text(
                      date.day
                          .toString()
                          .padLeft(2, '0'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: dayTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lunarText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1,
                        fontWeight: FontWeight.w400,
                        color: lunarTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (events.isNotEmpty)
                Positioned(
                  top: 5,
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: events
                        .take(2)
                        .map(
                          (event) => Container(
                            width: 7,
                            height: 7,
                            margin:
                                const EdgeInsets.only(
                              left: 2,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  event.type ==
                                          'yellow'
                                      ? yellowDot
                                      : greenDot,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildYearButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chức năng xem toàn bộ sự kiện trong năm'),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF7F7F7),
            foregroundColor: darkText,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Toàn bộ sự kiện trong năm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();
    String selectedType = 'green';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Thêm sự kiện',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tên sự kiện',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: 'Giờ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Địa điểm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(
                        value: 'green',
                        child: Text('Chấm xanh'),
                      ),
                      DropdownMenuItem(
                        value: 'yellow',
                        child: Text('Chấm vàng'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedType = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Loại dấu chấm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;

                        final key = _dateKey(_selectedDate);

                        setState(() {
                          _events.putIfAbsent(key, () => []);
                          _events[key]!.add(
                            CalendarEvent(
                              title: titleController.text.trim(),
                              time: timeController.text.trim(),
                              location: locationController.text.trim(),
                              type: selectedType,
                            ),
                          );
                        });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Lưu sự kiện'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class CalendarEvent {
  final String title;
  final String time;
  final String location;
  final String type;

  CalendarEvent({
    required this.title,
    required this.time,
    required this.location,
    required this.type,
  });
}