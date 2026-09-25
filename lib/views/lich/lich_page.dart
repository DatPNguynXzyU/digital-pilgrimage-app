import 'package:flutter/material.dart';

class LichPage extends StatefulWidget {
  const LichPage({super.key});

  @override
  State<LichPage> createState() => _LichPageState();
}

class _LichPageState extends State<LichPage> {
  static const Color primaryBrown = Color(0xFFA56A12);
  static const Color darkBrown = Color(0xFF6B4310);
  static const Color lightBrown = Color(0xFFFFE9C5);
  static const Color backgroundColor = Color(0xFFFFFCF8);

  DateTime _focusedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  DateTime _selectedDate = DateTime.now();

  final Map<String, List<CalendarEvent>> _events = {
    '2026-09-25': [
      CalendarEvent(
        title: 'Tụng Kinh Phổ Môn',
        time: '19:00',
        location: 'Tại nhà',
        icon: Icons.menu_book_rounded,
      ),
      CalendarEvent(
        title: 'Thiền 15 phút',
        time: '21:00',
        location: 'Cá nhân',
        icon: Icons.self_improvement_rounded,
      ),
    ],
    '2026-09-27': [
      CalendarEvent(
        title: 'Viếng chùa',
        time: '08:00',
        location: 'Chùa đã lưu',
        icon: Icons.temple_buddhist_rounded,
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

  bool _isToday(DateTime date) {
    return _isSameDay(date, DateTime.now());
  }

  List<CalendarEvent> get _selectedEvents {
    return _events[_dateKey(_selectedDate)] ?? [];
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

    // Chuyển để tuần bắt đầu từ Thứ 2.
    return weekday - 1;
  }

  String _monthTitle(DateTime date) {
    return 'Tháng ${date.month}, ${date.year}';
  }

  String _selectedDateTitle(DateTime date) {
    final weekdayNames = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];

    return '${weekdayNames[date.weekday - 1]}, '
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            SliverToBoxAdapter(
              child: _buildCalendarCard(),
            ),
            SliverToBoxAdapter(
              child: _buildSelectedDateHeader(),
            ),
            SliverToBoxAdapter(
              child: _buildEventSection(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 110),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Thêm lịch',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: lightBrown,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: primaryBrown,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lịch',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF332516),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Theo dõi lịch tu tập và hành hương',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A7764),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthNavigation(),
          const SizedBox(height: 18),
          _buildWeekDays(),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      children: [
        _monthButton(
          icon: Icons.chevron_left_rounded,
          onPressed: _previousMonth,
        ),
        Expanded(
          child: Text(
            _monthTitle(_focusedMonth),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),
        ),
        _monthButton(
          icon: Icons.chevron_right_rounded,
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _monthButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0xFFFFF5E7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: primaryBrown,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDays() {
    const days = [
      'T2',
      'T3',
      'T4',
      'T5',
      'T6',
      'T7',
      'CN',
    ];

    return Row(
      children: days.map((day) {
        final isSunday = day == 'CN';

        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSunday
                    ? const Color(0xFFC14F3B)
                    : const Color(0xFF8A7764),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _daysInMonth(_focusedMonth);
    final leadingDays = _firstWeekdayOfMonth(_focusedMonth);

    final totalCells = leadingDays + daysInMonth;

    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Row(
          children: List.generate(7, (columnIndex) {
            final cellIndex = rowIndex * 7 + columnIndex;
            final dayNumber = cellIndex - leadingDays + 1;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const Expanded(
                child: SizedBox(height: 54),
              );
            }

            final date = DateTime(
              _focusedMonth.year,
              _focusedMonth.month,
              dayNumber,
            );

            return Expanded(
              child: _buildDayCell(date),
            );
          }),
        );
      }),
    );
  }

  Widget _buildDayCell(DateTime date) {
    final selected = _isSameDay(date, _selectedDate);
    final today = _isToday(date);
    final hasEvents = (_events[_dateKey(date)] ?? []).isNotEmpty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: SizedBox(
        height: 54,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? primaryBrown
                      : today
                          ? lightBrown
                          : Colors.transparent,
                  shape: BoxShape.circle,
                  border: today && !selected
                      ? Border.all(
                          color: primaryBrown,
                          width: 1.2,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected || today
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF443729),
                  ),
                ),
              ),
              if (hasEvents)
                Positioned(
                  bottom: 3,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : primaryBrown,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDateHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hoạt động trong ngày',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF332516),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedDateTitle(_selectedDate),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A7764),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedEvents.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: lightBrown,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedEvents.length} lịch',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: darkBrown,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventSection() {
    if (_selectedEvents.isEmpty) {
      return _buildEmptyEvents();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _selectedEvents
            .map(
              (event) => _buildEventCard(event),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyEvents() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF1E5D6),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 44,
            color: Color(0xFFD3B486),
          ),
          SizedBox(height: 12),
          Text(
            'Chưa có hoạt động',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF443729),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Bạn chưa có lịch tu tập hoặc hành hương trong ngày này.',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.4,
              fontSize: 13,
              color: Color(0xFF9A8977),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: lightBrown,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              event.icon,
              color: primaryBrown,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A2D20),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Color(0xFF9B846D),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      event.time,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7B6855),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF9B846D),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        event.location,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7B6855),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF9B846D),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteEvent(event);
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 8),
                      Text('Xóa'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0D7CE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Thêm lịch mới',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF332516),
                        ),
                      ),
                    ),
                    Text(
                      '${_selectedDate.day}/'
                      '${_selectedDate.month}/'
                      '${_selectedDate.year}',
                      style: const TextStyle(
                        color: primaryBrown,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: _inputDecoration(
                    label: 'Tên hoạt động',
                    icon: Icons.edit_calendar_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: timeController,
                  decoration: _inputDecoration(
                    label: 'Thời gian',
                    icon: Icons.schedule_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: locationController,
                  decoration: _inputDecoration(
                    label: 'Địa điểm',
                    icon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        return;
                      }

                      final event = CalendarEvent(
                        title: titleController.text.trim(),
                        time: timeController.text.trim().isEmpty
                            ? 'Chưa đặt giờ'
                            : timeController.text.trim(),
                        location:
                            locationController.text.trim().isEmpty
                                ? 'Chưa có địa điểm'
                                : locationController.text.trim(),
                        icon: Icons.event_rounded,
                      );

                      setState(() {
                        _events.putIfAbsent(
                          _dateKey(_selectedDate),
                          () => [],
                        );

                        _events[_dateKey(_selectedDate)]!.add(event);
                      });

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBrown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Thêm vào lịch',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: primaryBrown,
      ),
      filled: true,
      fillColor: const Color(0xFFFFFAF3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFF0E1CE),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: primaryBrown,
          width: 1.5,
        ),
      ),
    );
  }

  void _deleteEvent(CalendarEvent event) {
    setState(() {
      _events[_dateKey(_selectedDate)]?.remove(event);

      if (_events[_dateKey(_selectedDate)]?.isEmpty ?? false) {
        _events.remove(_dateKey(_selectedDate));
      }
    });
  }
}

class CalendarEvent {
  final String title;
  final String time;
  final String location;
  final IconData icon;

  CalendarEvent({
    required this.title,
    required this.time,
    required this.location,
    required this.icon,
  });
}