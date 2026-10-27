import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/buddhist_festival.dart';
import '../../models/calendar_event.dart';
import '../../services/calendar_event_store.dart';
import '../../services/auth_service.dart';
import '../../services/calendar_festival_service.dart';
import '../../utils/lunar_calendar.dart';
import 'buddhist_festival_pages.dart';
import 'calendar_event_detail_page.dart';
import 'calendar_event_form_page.dart';
import 'calendar_presentation.dart';
import 'calendar_reminder_settings_page.dart';
import 'event_list_page.dart';

enum CalendarViewMode { month, week, day }

class LichPage extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<int>? onNavigate;

  const LichPage({super.key, this.initialDate, this.onNavigate});

  @override
  State<LichPage> createState() => _LichPageState();
}

class _LichPageState extends State<LichPage> {
  static const List<String> _weekdays = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  final _eventStore = CalendarEventStore();
  final _festivalService = CalendarFestivalService();
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  late Future<List<CalendarEvent>> _eventsFuture;
  CalendarViewMode _viewMode = CalendarViewMode.month;
  bool _showPersonalEvents = true;
  bool _showFestivals = true;

  DateTime get _today => _dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    final initialDate = widget.initialDate ?? DateTime.now();
    _selectedDate = _dateOnly(initialDate);
    _focusedMonth = DateTime(initialDate.year, initialDate.month);
    _eventsFuture = _eventStore.load();
    AuthService.sessionChanges.addListener(_sessionChanged);
  }

  void _sessionChanged() {
    if (mounted) setState(() => _eventsFuture = _eventStore.load());
  }

  @override
  void dispose() {
    AuthService.sessionChanges.removeListener(_sessionChanged);
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int _daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;

  DateTime _startOfWeek(DateTime date) =>
      _dateOnly(date).subtract(Duration(days: date.weekday - DateTime.monday));

  void _movePeriod(int offset) {
    setState(() {
      switch (_viewMode) {
        case CalendarViewMode.month:
          final target = DateTime(
            _focusedMonth.year,
            _focusedMonth.month + offset,
          );
          final day = _selectedDate.day.clamp(1, _daysInMonth(target));
          _focusedMonth = target;
          _selectedDate = DateTime(target.year, target.month, day);
        case CalendarViewMode.week:
          _selectedDate = _selectedDate.add(Duration(days: offset * 7));
          _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
        case CalendarViewMode.day:
          _selectedDate = _selectedDate.add(Duration(days: offset));
          _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month);
      }
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = _dateOnly(date);
      _focusedMonth = DateTime(date.year, date.month);
    });
  }

  Future<void> _reloadEvents() async {
    setState(() => _eventsFuture = _eventStore.load());
    await _eventsFuture;
  }

  Future<void> _addEvent() async {
    final event = await Navigator.push<CalendarEvent>(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarEventFormPage(initialDate: _selectedDate),
      ),
    );
    if (event == null || !mounted) return;
    _selectDate(event.startAt);
    await _reloadEvents();
  }

  Future<void> _openFestivalList() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BuddhistFestivalListPage(
          onFindTemples: () => widget.onNavigate?.call(3),
        ),
      ),
    );
  }

  Future<void> _openEvent(CalendarEvent event) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _PersonalEventBottomSheet(
        event: event,
        onDetails: () {
          Navigator.pop(context);
          _pushEventDetail(event);
        },
      ),
    );
  }

  Future<void> _pushEventDetail(CalendarEvent event) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CalendarEventDetailPage(event: event)),
    );
    if (mounted) await _reloadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final lunar = LunarCalendar.fromSolar(_selectedDate);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lịch Phật giáo'),
        actions: [
          IconButton(
            tooltip: 'Ngày lễ Phật giáo',
            onPressed: _openFestivalList,
            icon: const Icon(Icons.spa_outlined),
          ),
          IconButton(
            tooltip: 'Cài đặt nhắc lịch',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const CalendarReminderSettingsPage(),
              ),
            ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('add-calendar-event'),
        tooltip: 'Thêm lịch mới',
        onPressed: _addEvent,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<CalendarEvent>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildError(snapshot.error);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }
            final personalEvents = snapshot.data ?? const <CalendarEvent>[];
            return ListView(
              key: const ValueKey('calendar-content'),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
              children: [
                _buildMonthNavigator(),
                const SizedBox(height: 12),
                _buildSelectedDateCard(lunar),
                const SizedBox(height: 16),
                _buildViewSelector(),
                const SizedBox(height: 14),
                _buildFilterRow(),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: switch (_viewMode) {
                    CalendarViewMode.month => _buildMonthCalendar(
                      key: const ValueKey('month-calendar'),
                      personalEvents: personalEvents,
                    ),
                    CalendarViewMode.week => _buildWeekCalendar(
                      key: const ValueKey('week-calendar'),
                      personalEvents: personalEvents,
                    ),
                    CalendarViewMode.day => _buildDayAgenda(
                      key: const ValueKey('day-agenda'),
                      personalEvents: personalEvents,
                    ),
                  },
                ),
                if (_viewMode != CalendarViewMode.day) ...[
                  const SizedBox(height: 20),
                  _buildEventSection(personalEvents),
                ],
                const SizedBox(height: 20),
                _buildUpcomingSection(personalEvents),
                if (_viewMode != CalendarViewMode.day) ...[
                  const SizedBox(height: 14),
                  _buildFestivalDisclaimer(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthNavigator() {
    final label = switch (_viewMode) {
      CalendarViewMode.month =>
        'Tháng ${_focusedMonth.month} năm ${_focusedMonth.year}',
      CalendarViewMode.week =>
        '${solarDateLabel(_startOfWeek(_selectedDate))} – '
            '${solarDateLabel(_startOfWeek(_selectedDate).add(const Duration(days: 6)))}',
      CalendarViewMode.day => solarDateLabel(_selectedDate),
    };
    return Row(
      children: [
        IconButton(
          key: const ValueKey('previous-month'),
          tooltip: 'Kỳ trước',
          onPressed: () => _movePeriod(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            label,
            key: const ValueKey('calendar-month-title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          key: const ValueKey('next-month'),
          tooltip: 'Kỳ sau',
          onPressed: () => _movePeriod(1),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
        TextButton(
          onPressed: () => _selectDate(_today),
          child: const Text('Hôm nay'),
        ),
      ],
    );
  }

  Widget _buildSelectedDateCard(LunarDate lunar) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    decoration: BoxDecoration(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        colors: [AppTheme.warmBrown, AppTheme.primary],
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: AppTheme.secondary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weekdayLabel(_selectedDate)}, ${solarDateLabel(_selectedDate)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Âm lịch: ngày ${lunar.day}, tháng ${lunar.month}'
                '${lunar.isLeapMonth ? ' nhuận' : ''} năm ${lunar.year}',
                key: const ValueKey('selected-lunar-date'),
                style: const TextStyle(color: Color(0xFFE9DCCB), fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Danh sách ngày lễ',
          onPressed: _openFestivalList,
          color: AppTheme.secondary,
          icon: const Icon(Icons.spa_outlined),
        ),
      ],
    ),
  );

  Widget _buildViewSelector() => SegmentedButton<CalendarViewMode>(
    key: const ValueKey('calendar-view-selector'),
    showSelectedIcon: false,
    segments: const [
      ButtonSegment(
        value: CalendarViewMode.day,
        label: Text('Ngày'),
        icon: Icon(Icons.view_day_outlined),
      ),
      ButtonSegment(
        value: CalendarViewMode.week,
        label: Text('Tuần'),
        icon: Icon(Icons.view_week_outlined),
      ),
      ButtonSegment(
        value: CalendarViewMode.month,
        label: Text('Tháng'),
        icon: Icon(Icons.calendar_view_month_outlined),
      ),
    ],
    selected: {_viewMode},
    onSelectionChanged: (selection) =>
        setState(() => _viewMode = selection.first),
  );

  Widget _buildFilterRow() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      FilterChip(
        label: const Text('Lịch cá nhân'),
        selected: _showPersonalEvents,
        onSelected: (value) => setState(() => _showPersonalEvents = value),
        avatar: const Icon(Icons.event_note_rounded, size: 17),
        selectedColor: const Color(0xFFE8DED0),
      ),
      FilterChip(
        label: const Text('Ngày lễ Phật giáo'),
        selected: _showFestivals,
        onSelected: (value) => setState(() => _showFestivals = value),
        avatar: const Icon(Icons.spa_outlined, size: 17),
        selectedColor: const Color(0xFFF3E3DF),
      ),
    ],
  );

  Widget _buildMonthCalendar({
    required Key key,
    required List<CalendarEvent> personalEvents,
  }) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month);
    final leadingDays = firstDay.weekday - DateTime.monday;
    final dayCount = _daysInMonth(_focusedMonth);
    final cellCount = ((leadingDays + dayCount + 6) ~/ 7) * 7;
    final firstVisibleDate = firstDay.subtract(Duration(days: leadingDays));
    final rowCount = cellCount ~/ 7;
    return Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(
              _weekdays.length,
              (index) => Expanded(
                child: Center(
                  child: Text(
                    _weekdays[index],
                    style: TextStyle(
                      color: index == 6
                          ? AppTheme.accent
                          : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          ...List.generate(rowCount, (rowIndex) {
            return Row(
              children: List.generate(7, (columnIndex) {
                final cellIndex = rowIndex * 7 + columnIndex;
                final date = firstVisibleDate.add(Duration(days: cellIndex));
                return Expanded(
                  child: _buildDayCell(
                    date: date,
                    isCurrentMonth: date.month == _focusedMonth.month,
                    personalEvents: personalEvents,
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 8),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildDayCell({
    required DateTime date,
    required bool isCurrentMonth,
    required List<CalendarEvent> personalEvents,
  }) {
    final lunar = LunarCalendar.fromSolar(date);
    final selected = _dateOnly(date) == _selectedDate;
    final today = _dateOnly(date) == _today;
    final hasPersonal =
        _showPersonalEvents &&
        personalEvents.any((event) => event.occursOn(date));
    final hasFestival =
        _showFestivals && _festivalService.occurrencesForDate(date).isNotEmpty;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 150);
    return Semantics(
      button: true,
      selected: selected,
      label: '${date.day}/${date.month}/${date.year}, ngày âm ${lunar.day}',
      child: InkWell(
        key: ValueKey('calendar-day-${date.year}-${date.month}-${date.day}'),
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectDate(date),
        child: AnimatedContainer(
          duration: duration,
          height: 55,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: today && !selected
                ? Border.all(color: AppTheme.secondary, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : !isCurrentMonth
                      ? AppTheme.border
                      : date.weekday == DateTime.sunday
                      ? AppTheme.accent
                      : AppTheme.text,
                  fontSize: 14,
                  fontWeight: selected || today
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '${lunar.day}',
                style: TextStyle(
                  color: selected
                      ? Colors.white70
                      : isCurrentMonth
                      ? AppTheme.textSecondary
                      : AppTheme.border,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasFestival)
                    _marker(selected ? AppTheme.secondary : AppTheme.accent),
                  if (hasFestival && hasPersonal) const SizedBox(width: 3),
                  if (hasPersonal)
                    _marker(selected ? Colors.white : AppTheme.warmBrown),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _marker(Color color) => Container(
    width: 4,
    height: 4,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _buildLegend() => Wrap(
    alignment: WrapAlignment.center,
    spacing: 16,
    children: [
      _legendItem(AppTheme.accent, 'Ngày lễ'),
      _legendItem(AppTheme.warmBrown, 'Lịch cá nhân'),
      _legendItem(AppTheme.secondary, 'Hôm nay'),
    ],
  );

  Widget _legendItem(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
      ),
    ],
  );

  Widget _buildWeekCalendar({
    required Key key,
    required List<CalendarEvent> personalEvents,
  }) {
    final weekStart = _startOfWeek(_selectedDate);
    return Container(
      key: key,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final festivals = _showFestivals
              ? _festivalService.occurrencesForDate(date)
              : const <FestivalOccurrence>[];
          final events = _showPersonalEvents
              ? personalEvents.where((event) => event.occursOn(date)).toList()
              : const <CalendarEvent>[];
          return InkWell(
            key: ValueKey('week-day-${date.year}-${date.month}-${date.day}'),
            borderRadius: BorderRadius.circular(13),
            onTap: () => _selectDate(date),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: _dateOnly(date) == _selectedDate
                    ? AppTheme.surface.withValues(alpha: 0.55)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 74,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekdayLabel(date).replaceAll('Thứ ', 'T'),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          '${date.day} · ${LunarCalendar.fromSolar(date).day}',
                          style: const TextStyle(
                            color: AppTheme.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: events.isEmpty && festivals.isEmpty
                        ? const Text(
                            'Không có sự kiện',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...festivals.map(
                                (event) => _CompactEventLine(
                                  label: event.festival.name,
                                  color: AppTheme.accent,
                                  icon: Icons.spa_outlined,
                                ),
                              ),
                              ...events.map(
                                (event) => _CompactEventLine(
                                  label: event.title,
                                  color: AppTheme.warmBrown,
                                  icon: Icons.event_note_outlined,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayAgenda({
    required Key key,
    required List<CalendarEvent> personalEvents,
  }) => Container(
    key: key,
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          weekdayLabel(_selectedDate),
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          solarDateLabel(_selectedDate),
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ..._eventEntriesForDate(personalEvents).map(_buildEventTile),
        if (_eventEntriesForDate(personalEvents).isEmpty)
          const Text(
            'Chưa có lịch trong ngày này. Nhấn + để thêm lịch cá nhân.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
      ],
    ),
  );

  Widget _buildEventSection(List<CalendarEvent> personalEvents) {
    final entries = _eventEntriesForDate(personalEvents);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalendarSectionLabel(
          'Sự kiện trong ngày',
          trailing: '${entries.length} mục',
        ),
        const SizedBox(height: 10),
        if (entries.isEmpty)
          _buildEmptyEvents()
        else
          ...entries.map(_buildEventTile),
      ],
    );
  }

  Widget _buildUpcomingSection(List<CalendarEvent> personalEvents) {
    final entries = _upcomingEntries(personalEvents);
    final visibleEntries = entries.take(3).toList();
    return Column(
      key: const ValueKey('upcoming-calendar-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Lịch sắp diễn ra',
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (entries.length > visibleEntries.length)
              TextButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const EventListPage(),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Xem tất cả'),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (visibleEntries.isEmpty)
          _buildUpcomingEmptyState()
        else
          ...visibleEntries.map(_buildUpcomingTile),
      ],
    );
  }

  List<_CalendarEntry> _upcomingEntries(List<CalendarEvent> personalEvents) {
    final today = _today;
    final entries = <_CalendarEntry>[];
    if (_showFestivals) {
      final lunarYear = LunarCalendar.fromSolar(today).year;
      entries.addAll(
        [
              ..._festivalService.occurrencesForYear(lunarYear),
              ..._festivalService.occurrencesForYear(lunarYear + 1),
            ]
            .where((festival) => !festival.solarDate.isBefore(today))
            .map(_CalendarEntry.upcomingFestival),
      );
    }
    if (_showPersonalEvents) {
      for (final event in personalEvents) {
        DateTime? occurrence;
        for (var offset = 0; offset <= 366; offset++) {
          final date = today.add(Duration(days: offset));
          if (event.occursOn(date)) {
            occurrence = date;
            break;
          }
        }
        if (occurrence == null) continue;
        if (occurrence == today &&
            event.repeat == CalendarRepeat.none &&
            event.endAt.isBefore(DateTime.now())) {
          continue;
        }
        entries.add(_CalendarEntry.upcomingPersonal(event, occurrence));
      }
    }
    entries.sort((a, b) => a.date!.compareTo(b.date!));
    return entries;
  }

  Widget _buildUpcomingTile(_CalendarEntry entry) {
    final date = entry.date!;
    final lunar = LunarCalendar.fromSolar(date);
    final days = date.difference(_today).inDays;
    final when = days == 0 ? 'Hôm nay' : 'Còn $days ngày';
    final event = entry.event;
    if (event != null) {
      return _EventCard(
        key: ValueKey(
          'upcoming-personal-${event.id}-${date.toIso8601String()}',
        ),
        title: event.title,
        subtitle:
            '${solarDateLabel(date)} · ${lunar.day}/${lunar.month} âm lịch · '
            '${TimeOfDay.fromDateTime(event.startAt).format(context)} · $when',
        color: AppTheme.warmBrown,
        icon: Icons.event_note_rounded,
        badge: 'CÁ NHÂN',
        onTap: () => _openEvent(event),
      );
    }
    final festival = entry.festival!;
    return _EventCard(
      key: ValueKey(
        'upcoming-festival-${festival.festival.id}-${festival.solarDate.year}',
      ),
      title: festival.festival.name,
      subtitle:
          '${solarDateLabel(date)} · ${festival.lunarDay}/${festival.lunarMonth} âm lịch · $when',
      color: AppTheme.accent,
      icon: Icons.spa_rounded,
      badge: 'NGÀY LỄ',
      onTap: () => _openFestival(festival),
    );
  }

  Widget _buildUpcomingEmptyState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.event_note_outlined, color: AppTheme.secondary),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chưa có sự kiện sắp diễn ra',
                    style: TextStyle(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Thêm lịch cá nhân để ghi nhớ những ngày quan trọng.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _addEvent,
            child: const Text('+ Thêm lịch'),
          ),
        ),
      ],
    ),
  );

  List<_CalendarEntry> _eventEntriesForDate(
    List<CalendarEvent> personalEvents,
  ) {
    final entries = <_CalendarEntry>[];
    if (_showFestivals) {
      entries.addAll(
        _festivalService
            .occurrencesForDate(_selectedDate)
            .map(_CalendarEntry.festival),
      );
    }
    if (_showPersonalEvents) {
      entries.addAll(
        personalEvents
            .where((event) => event.occursOn(_selectedDate))
            .map(_CalendarEntry.personal),
      );
    }
    entries.sort((a, b) {
      final aTime = a.event?.startAt ?? DateTime(0);
      final bTime = b.event?.startAt ?? DateTime(0);
      return aTime.compareTo(bTime);
    });
    return entries;
  }

  Widget _buildEventTile(_CalendarEntry entry) {
    if (entry.event != null) {
      final event = entry.event!;
      return _EventCard(
        key: ValueKey('personal-event-${event.id}'),
        title: event.title,
        subtitle:
            '${TimeOfDay.fromDateTime(event.startAt).format(context)}'
            ' – ${TimeOfDay.fromDateTime(event.endAt).format(context)}'
            '${event.location.isNotEmpty ? ' · ${event.location}' : ''}',
        color: AppTheme.warmBrown,
        icon: Icons.event_note_rounded,
        badge: 'CÁ NHÂN',
        onTap: () => _openEvent(event),
      );
    }
    final festival = entry.festival!;
    return _EventCard(
      key: ValueKey(
        'festival-${festival.festival.id}-${festival.solarDate.year}',
      ),
      title: festival.festival.name,
      subtitle:
          '${festival.lunarDay}/${festival.lunarMonth} âm lịch · '
          '${solarDateLabel(festival.solarDate)}',
      color: AppTheme.accent,
      icon: Icons.spa_rounded,
      badge: 'NGÀY LỄ',
      onTap: () => _openFestival(festival),
    );
  }

  Future<void> _openFestival(FestivalOccurrence festival) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _FestivalBottomSheet(
        occurrence: festival,
        onDetails: () {
          Navigator.pop(context);
          Navigator.push<void>(
            this.context,
            MaterialPageRoute<void>(
              builder: (_) => BuddhistFestivalDetailPage(occurrence: festival),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyEvents() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(
      children: [
        const Icon(Icons.event_note_outlined, color: AppTheme.secondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _showPersonalEvents || _showFestivals
                ? 'Chưa có sự kiện ngày này. Nhấn + để thêm lịch cá nhân.'
                : 'Bật bộ lọc để xem lịch cá nhân hoặc ngày lễ.',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildFestivalDisclaimer() => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppTheme.surface.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline_rounded,
          color: AppTheme.warmBrown,
          size: 17,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Ngày lễ là lịch tham khảo theo âm lịch Việt Nam (UTC+7); ngày kỷ niệm có thể khác giữa các truyền thống và địa phương.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
        TextButton(onPressed: _openFestivalList, child: const Text('Ngày lễ')),
      ],
    ),
  );

  Widget _buildLoading() => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      const SizedBox(height: 14),
      Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      const SizedBox(height: 14),
      Container(
        height: 350,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ],
  );

  Widget _buildError(Object? error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: AppTheme.accent,
          ),
          const SizedBox(height: 12),
          const Text(
            'Không thể tải lịch cá nhân',
            style: TextStyle(color: AppTheme.text, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => setState(() => _eventsFuture = _eventStore.load()),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}

class _CalendarEntry {
  final CalendarEvent? event;
  final FestivalOccurrence? festival;
  final DateTime? date;

  const _CalendarEntry._({this.event, this.festival, this.date});

  factory _CalendarEntry.personal(CalendarEvent event) =>
      _CalendarEntry._(event: event);

  factory _CalendarEntry.festival(FestivalOccurrence festival) =>
      _CalendarEntry._(festival: festival);

  factory _CalendarEntry.upcomingPersonal(CalendarEvent event, DateTime date) =>
      _CalendarEntry._(event: event, date: date);

  factory _CalendarEntry.upcomingFestival(FestivalOccurrence festival) =>
      _CalendarEntry._(festival: festival, date: festival.solarDate);
}

class _EventCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String badge;
  final VoidCallback onTap;

  const _EventCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppTheme.border),
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(17),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color, size: 21),
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ),
        trailing: Text(
          badge,
          style: TextStyle(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),
  );
}

class _CompactEventLine extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _CompactEventLine({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PersonalEventBottomSheet extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onDetails;

  const _PersonalEventBottomSheet({
    required this.event,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.event_note_rounded,
            color: AppTheme.warmBrown,
            size: 27,
          ),
          const SizedBox(height: 10),
          Text(
            event.title,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${solarDateLabel(event.startAt)} · '
            '${TimeOfDay.fromDateTime(event.startAt).format(context)} – '
            '${TimeOfDay.fromDateTime(event.endAt).format(context)}',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          if (event.location.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              event.location,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              event.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.text, height: 1.4),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDetails,
              child: const Text('Xem và chỉnh sửa lịch'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _FestivalBottomSheet extends StatelessWidget {
  final FestivalOccurrence occurrence;
  final VoidCallback onDetails;

  const _FestivalBottomSheet({
    required this.occurrence,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.spa_rounded, color: AppTheme.accent, size: 27),
          const SizedBox(height: 10),
          Text(
            occurrence.festival.name,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${occurrence.lunarDay}/${occurrence.lunarMonth} âm lịch · '
            '${solarDateLabel(occurrence.solarDate)}',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            occurrence.festival.description,
            style: const TextStyle(color: AppTheme.text, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onDetails,
              child: const Text('Xem thông tin ngày lễ'),
            ),
          ),
        ],
      ),
    ),
  );
}
