import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/buddhist_festival.dart';
import '../../models/calendar_event.dart';
import '../../services/calendar_event_store.dart';
import '../../services/calendar_festival_service.dart';
import '../../services/saved_items_store.dart';
import '../../utils/lunar_calendar.dart';
import '../../widgets/saved_item_buttons.dart';
import 'buddhist_festival_pages.dart';
import 'calendar_event_detail_page.dart';

enum _EventFilter { all, festivals, personal }

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final _store = CalendarEventStore();
  final _festivals = CalendarFestivalService();
  late Future<List<_EventEntry>> _entries;
  _EventFilter _filter = _EventFilter.all;

  @override
  void initState() {
    super.initState();
    _entries = _load();
    CalendarEventStore.changes.addListener(_reload);
  }

  void _reload() {
    if (mounted) setState(() => _entries = _load());
  }

  Future<List<_EventEntry>> _load() async {
    final personal = await _store.load();
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final lunarYear = LunarCalendar.fromSolar(start).year;
    final celebrations = [
      ..._festivals.occurrencesForYear(lunarYear),
      ..._festivals.occurrencesForYear(lunarYear + 1),
    ].where((event) => !event.solarDate.isBefore(start));
    final entries = <_EventEntry>[
      ...personal
          .where(
            (event) =>
                event.endAt.isAfter(start) ||
                event.repeat != CalendarRepeat.none,
          )
          .map(_EventEntry.personal),
      ...celebrations.map(_EventEntry.festival),
    ]..sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  @override
  void dispose() {
    CalendarEventStore.changes.removeListener(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sự kiện và ngày lễ')),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 8, 18, 8),
          child: Text(
            'Lịch lễ theo âm lịch Việt Nam và các lịch cá nhân của bạn. Lịch chương trình tại từng chùa chưa có nguồn xác thực.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 12),
          child: Row(
            children: [
              _chip('Tất cả', _EventFilter.all),
              _chip('Ngày lễ', _EventFilter.festivals),
              _chip('Lịch của tôi', _EventFilter.personal),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<_EventEntry>>(
            future: _entries,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _EventMessage(
                  text: 'Chưa tải được lịch. Kiểm tra kết nối rồi thử lại.',
                  onRetry: _reload,
                );
              }
              final entries = (snapshot.data ?? const <_EventEntry>[])
                  .where(
                    (entry) => switch (_filter) {
                      _EventFilter.all => true,
                      _EventFilter.festivals => entry.festival != null,
                      _EventFilter.personal => entry.personal != null,
                    },
                  )
                  .toList();
              if (entries.isEmpty) {
                return const _EventMessage(
                  text:
                      'Chưa có sự kiện phù hợp trong khoảng thời gian sắp tới.',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (context, index) => _tile(entries[index]),
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _chip(String label, _EventFilter filter) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _filter == filter,
      onSelected: (_) => setState(() => _filter = filter),
    ),
  );

  Widget _tile(_EventEntry entry) {
    final festival = entry.festival;
    final personal = entry.personal;
    final date = entry.date;
    final title = festival?.festival.name ?? personal!.title;
    final dateLabel = '${date.day}/${date.month}/${date.year}';
    final subtitle = festival != null
        ? '${festival.lunarDay}/${festival.lunarMonth} âm lịch · $dateLabel · Lịch tham khảo'
        : '$dateLabel · Lịch cá nhân';
    final favoriteId = festival != null
        ? SavedItemsStore.festivalId(festival.festival.id, festival.solarDate)
        : SavedItemsStore.personalEventId(personal!.id);
    return Card(
      child: ListTile(
        minVerticalPadding: 10,
        leading: const CircleAvatar(
          backgroundColor: AppTheme.surface,
          child: Icon(Icons.event_note_outlined, color: AppTheme.primary),
        ),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
        trailing: SaveItemButton(id: favoriteId, temple: false),
        onTap: () => Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => festival != null
                ? BuddhistFestivalDetailPage(occurrence: festival)
                : CalendarEventDetailPage(event: personal!),
          ),
        ),
      ),
    );
  }
}

class _EventEntry {
  final FestivalOccurrence? festival;
  final CalendarEvent? personal;
  final DateTime date;

  const _EventEntry._({this.festival, this.personal, required this.date});

  factory _EventEntry.festival(FestivalOccurrence event) =>
      _EventEntry._(festival: event, date: event.solarDate);

  factory _EventEntry.personal(CalendarEvent event) =>
      _EventEntry._(personal: event, date: event.startAt);
}

class _EventMessage extends StatelessWidget {
  final String text;
  final VoidCallback? onRetry;
  const _EventMessage({required this.text, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_busy_outlined,
            size: 42,
            color: AppTheme.secondary,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ],
      ),
    ),
  );
}
