import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/buddhist_festival.dart';
import '../../services/calendar_festival_service.dart';
import '../../services/saved_items_store.dart';
import '../../utils/lunar_calendar.dart';
import 'calendar_event_form_page.dart';
import 'calendar_presentation.dart';
import 'calendar_reminder_settings_page.dart';
import '../../widgets/saved_item_buttons.dart';

enum FestivalFilter { all, upcoming, vesak, vuLan }

class BuddhistFestivalListPage extends StatefulWidget {
  final VoidCallback? onFindTemples;

  const BuddhistFestivalListPage({super.key, this.onFindTemples});

  @override
  State<BuddhistFestivalListPage> createState() =>
      _BuddhistFestivalListPageState();
}

class _BuddhistFestivalListPageState extends State<BuddhistFestivalListPage> {
  final _service = CalendarFestivalService();
  FestivalFilter _filter = FestivalFilter.all;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final year = LunarCalendar.fromSolar(today).year;
    final occurrences =
        [
            ..._service.occurrencesForYear(year),
            ..._service.occurrencesForYear(year + 1),
          ].where((item) => !item.solarDate.isBefore(today)).toList()
          ..sort((a, b) => a.solarDate.compareTo(b.solarDate));
    final filtered = occurrences.where(_matchesFilter).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Ngày lễ Phật giáo'),
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
        children: [
          _buildIntro(),
          const SizedBox(height: 16),
          _buildFilters(),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            _buildEmpty()
          else
            ...filtered.map(
              (occurrence) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FestivalCard(
                  occurrence: occurrence,
                  onTap: () => _openFestival(occurrence),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Lịch này là dữ liệu tham khảo theo âm lịch Việt Nam, múi giờ UTC+7. '
            'Ngày kỷ niệm và nghi lễ có thể khác giữa truyền thống, tự viện và địa phương.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  bool _matchesFilter(FestivalOccurrence occurrence) {
    switch (_filter) {
      case FestivalFilter.all:
        return true;
      case FestivalFilter.upcoming:
        return occurrence.solarDate.isBefore(
          DateTime.now().add(const Duration(days: 60)),
        );
      case FestivalFilter.vesak:
        return occurrence.festival.id == 'vesak' ||
            occurrence.festival.id == 'buddha-birth';
      case FestivalFilter.vuLan:
        return occurrence.festival.id == 'vu-lan';
    }
  }

  Widget _buildIntro() => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        Icon(Icons.spa_rounded, color: AppTheme.secondary, size: 28),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Các ngày lễ được quy đổi theo âm lịch Việt Nam. Chương trình tại từng chùa chưa được xác minh.',
            style: TextStyle(color: Colors.white, height: 1.4, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  Widget _buildFilters() {
    const filters = [
      (FestivalFilter.all, 'Tất cả'),
      (FestivalFilter.upcoming, 'Sắp diễn ra'),
      (FestivalFilter.vesak, 'Phật Đản / Vesak'),
      (FestivalFilter.vuLan, 'Vu Lan'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CalendarPill(
                  label: filter.$2,
                  selected: _filter == filter.$1,
                  onTap: () => setState(() => _filter = filter.$1),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmpty() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.border),
    ),
    child: const Text(
      'Không có ngày lễ phù hợp trong khoảng thời gian sắp tới.',
      style: TextStyle(color: AppTheme.textSecondary),
    ),
  );

  void _openFestival(FestivalOccurrence occurrence) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => BuddhistFestivalDetailPage(occurrence: occurrence),
      ),
    ).then((findTemples) {
      if (findTemples == true && mounted) {
        Navigator.pop(context);
        widget.onFindTemples?.call();
      }
    });
  }
}

class BuddhistFestivalDetailPage extends StatelessWidget {
  final FestivalOccurrence occurrence;

  const BuddhistFestivalDetailPage({super.key, required this.occurrence});

  @override
  Widget build(BuildContext context) {
    final festival = occurrence.festival;
    final isVesak = festival.id == 'vesak';
    final isVuLan = festival.id == 'vu-lan';
    final lunarText = '${occurrence.lunarDay}/${occurrence.lunarMonth} âm lịch';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Ngày lễ'),
        actions: [
          SaveItemButton(
            id: SavedItemsStore.festivalId(festival.id, occurrence.solarDate),
            temple: false,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
        children: [
          _FestivalHero(
            title: festival.name,
            icon: isVesak ? Icons.local_florist_rounded : Icons.spa_rounded,
            color: isVesak ? const Color(0xFF76513C) : AppTheme.primary,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ngày lễ',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  '$lunarText · ${solarDateLabel(occurrence.solarDate)}',
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _InfoCard(
            title: isVesak
                ? 'Đại lễ Tam hợp (Vesak)'
                : isVuLan
                ? 'Ý nghĩa Vu Lan'
                : 'Thông tin ngày lễ',
            body: festival.description,
            icon: Icons.auto_awesome_outlined,
          ),
          if (festival.traditionNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoCard(
              title: 'Lưu ý về truyền thống',
              body: festival.traditionNote,
              icon: Icons.info_outline_rounded,
            ),
          ],
          const SizedBox(height: 10),
          const _InfoCard(
            title: 'Hoạt động tại các chùa',
            body: 'Chưa có lịch chương trình đã xác minh cho ngày này. Vui lòng kiểm tra thông báo trực tiếp từ tự viện.',
            icon: Icons.temple_buddhist_outlined,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _addToPersonalCalendar(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm vào lịch của tôi'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _openReminderSettings(context),
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(isVesak ? 'Nhắc tôi trước ngày lễ' : 'Đặt lời nhắc'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          if (isVesak) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.search_rounded),
              label: const Text('Tìm chùa'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addToPersonalCalendar(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CalendarEventFormPage(
          initialDate: occurrence.solarDate,
          initialTitle: occurrence.festival.name,
        ),
      ),
    );
  }

  void _openReminderSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const CalendarReminderSettingsPage(),
      ),
    );
  }
}

class _FestivalCard extends StatelessWidget {
  final FestivalOccurrence occurrence;
  final VoidCallback onTap;

  const _FestivalCard({required this.occurrence, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final festival = occurrence.festival;
    final color = festival.kind == FestivalKind.major
        ? AppTheme.accent
        : AppTheme.warmBrown;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.spa_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      festival.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${occurrence.lunarDay}/${occurrence.lunarMonth} âm · '
                      '${solarDateLabel(occurrence.solarDate)}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      festival.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        height: 1.3,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FestivalHero extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _FestivalHero({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 190,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color, AppTheme.primary],
      ),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -20,
          top: -40,
          child: Icon(
            Icons.circle_outlined,
            size: 190,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        Positioned(
          right: 17,
          bottom: 14,
          child: Icon(
            Icons.temple_buddhist_rounded,
            size: 110,
            color: AppTheme.secondary.withValues(alpha: 0.55),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(icon, color: AppTheme.secondary, size: 30),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lịch tham khảo · âm lịch Việt Nam',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.secondary, size: 21),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                body,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
