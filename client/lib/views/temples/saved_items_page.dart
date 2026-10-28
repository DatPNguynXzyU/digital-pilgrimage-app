import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/buddhist_festival.dart';
import '../../models/calendar_event.dart';
import '../../models/temple.dart';
import '../../services/calendar_event_store.dart';
import '../../services/calendar_festival_service.dart';
import '../../services/saved_items_store.dart';
import '../../widgets/app_header.dart';
import '../../services/temple_service.dart';
import '../../utils/lunar_calendar.dart';
import '../../widgets/saved_item_buttons.dart';
import '../lich/buddhist_festival_pages.dart';
import '../lich/calendar_event_detail_page.dart';
import 'chi_tiet_chua.dart';

enum _SavedFilter { all, temples, events }

class SavedItemsPage extends StatefulWidget {
  const SavedItemsPage({super.key});

  @override
  State<SavedItemsPage> createState() => _SavedItemsPageState();
}

class _SavedItemsPageState extends State<SavedItemsPage> {
  final _saved = SavedItemsStore();
  final _temples = TempleService();
  final _events = CalendarEventStore();
  final _festivalService = CalendarFestivalService();
  late Future<_SavedData> _data;
  _SavedFilter _filter = _SavedFilter.all;

  @override
  void initState() {
    super.initState();
    _data = _load();
    SavedItemsStore.changes.addListener(_reload);
    CalendarEventStore.changes.addListener(_reload);
  }

  void _reload() {
    if (mounted) setState(() => _data = _load());
  }

  Future<_SavedData> _load() async {
    final ids = await _saved.loadTemples();
    final eventIds = await _saved.loadEvents();
    final templeData = ids.isEmpty ? <Temple>[] : await _temples.getTemples();
    final templeEntries = templeData
        .where((item) => ids.contains(item.id))
        .toList();
    final personal = await _events.load();
    final personalSaved = personal
        .where(
          (item) => eventIds.contains(SavedItemsStore.personalEventId(item.id)),
        )
        .toList();
    final now = DateTime.now();
    final year = LunarCalendar.fromSolar(now).year;
    final festivalYears = <int>{year, year + 1};
    for (final eventId in eventIds) {
      final match = RegExp(r':(\d{4})-').firstMatch(eventId);
      final solarYear = int.tryParse(match?.group(1) ?? '');
      if (solarYear != null) {
        festivalYears
          ..add(solarYear - 1)
          ..add(solarYear)
          ..add(solarYear + 1);
      }
    }
    final occurrences = festivalYears
        .expand(_festivalService.occurrencesForYear)
        .toSet()
        .toList();
    final festivals = occurrences
        .where((item) => eventIds.contains(_festivalKey(item)))
        .toList();
    return _SavedData(templeEntries, personalSaved, festivals);
  }

  String _festivalKey(FestivalOccurrence item) =>
      SavedItemsStore.festivalId(item.festival.id, item.solarDate);

  @override
  void dispose() {
    SavedItemsStore.changes.removeListener(_reload);
    CalendarEventStore.changes.removeListener(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppHeader(title: const Text('Đã lưu')),
    body: FutureBuilder<_SavedData>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _EmptySaved(
            message: 'Chưa tải được mục đã lưu. Kiểm tra kết nối và thử lại.',
          );
        }
        final data = snapshot.data!;
        final count =
            data.temples.length + data.events.length + data.festivals.length;
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                children: [
                  _filterChip('Tất cả', _SavedFilter.all),
                  _filterChip('Chùa', _SavedFilter.temples),
                  _filterChip('Sự kiện', _SavedFilter.events),
                ],
              ),
            ),
            Expanded(
              child: count == 0
                  ? const _EmptySaved(
                      message: 'Những ngôi chùa và ngày lễ bạn lưu sẽ xuất hiện ở đây.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        if (_filter != _SavedFilter.events) ...[
                          _section('Chùa yêu thích'),
                          if (data.temples.isEmpty)
                            const _SectionEmpty(
                              text: 'Chưa lưu ngôi chùa nào.',
                            ),
                          ...data.temples.map(_templeTile),
                        ],
                        if (_filter != _SavedFilter.temples) ...[
                          _section('Sự kiện và ngày lễ'),
                          if (data.events.isEmpty && data.festivals.isEmpty)
                            const _SectionEmpty(
                              text: 'Chưa lưu sự kiện hoặc ngày lễ nào.',
                            ),
                          ...data.events.map(_eventTile),
                          ...data.festivals.map(_festivalTile),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    ),
  );

  Widget _filterChip(String label, _SavedFilter filter) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _filter == filter,
      onSelected: (_) => setState(() => _filter = filter),
    ),
  );

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.text,
      ),
    ),
  );

  Widget _templeTile(Temple item) => Card(
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppTheme.surface,
        child: Icon(Icons.temple_buddhist_outlined),
      ),
      title: Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        item.fullAddress.isEmpty ? 'Địa chỉ chưa cập nhật' : item.fullAddress,
        maxLines: 2,
      ),
      trailing: SaveItemButton(id: item.id, temple: true),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => ChiTietChuaPage(temple: item)),
      ),
    ),
  );

  Widget _eventTile(CalendarEvent item) => Card(
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppTheme.surface,
        child: Icon(Icons.event_outlined),
      ),
      title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${item.startAt.day}/${item.startAt.month}/${item.startAt.year} · Lịch cá nhân',
      ),
      trailing: SaveItemButton(
        id: SavedItemsStore.personalEventId(item.id),
        temple: false,
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CalendarEventDetailPage(event: item),
        ),
      ),
    ),
  );

  Widget _festivalTile(FestivalOccurrence item) => Card(
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: AppTheme.surface,
        child: Icon(Icons.spa_outlined),
      ),
      title: Text(
        item.festival.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${item.lunarDay}/${item.lunarMonth} âm · ${item.solarDate.day}/${item.solarDate.month}/${item.solarDate.year}',
      ),
      trailing: SaveItemButton(id: _festivalKey(item), temple: false),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BuddhistFestivalDetailPage(occurrence: item),
        ),
      ),
    ),
  );
}

class _SavedData {
  final List<Temple> temples;
  final List<CalendarEvent> events;
  final List<FestivalOccurrence> festivals;
  const _SavedData(this.temples, this.events, this.festivals);
}

class _EmptySaved extends StatelessWidget {
  final String message;
  const _EmptySaved({required this.message});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bookmark_border_rounded,
            size: 48,
            color: AppTheme.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    ),
  );
}

class _SectionEmpty extends StatelessWidget {
  final String text;
  const _SectionEmpty({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: const TextStyle(color: AppTheme.textSecondary)),
  );
}
