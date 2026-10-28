import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/calendar_event.dart';
import '../../services/calendar_event_store.dart';
import '../../widgets/app_header.dart';
import '../../services/saved_items_store.dart';
import '../../widgets/saved_item_buttons.dart';
import '../../utils/lunar_calendar.dart';
import 'calendar_event_form_page.dart';
import 'calendar_presentation.dart';

class CalendarEventDetailPage extends StatefulWidget {
  final CalendarEvent event;

  const CalendarEventDetailPage({super.key, required this.event});

  @override
  State<CalendarEventDetailPage> createState() =>
      _CalendarEventDetailPageState();
}

class _CalendarEventDetailPageState extends State<CalendarEventDetailPage> {
  final _store = CalendarEventStore();
  late CalendarEvent _event = widget.event;

  Future<void> _edit() async {
    final updated = await Navigator.push<CalendarEvent>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CalendarEventFormPage(initialDate: _event.startAt, event: _event),
      ),
    );
    if (updated != null && mounted) setState(() => _event = updated);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch này?'),
        content: const Text('Bạn có chắc muốn xóa lịch cá nhân này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Giữ lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa lịch'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _store.delete(_event.id);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không thể xóa lịch: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lunar = LunarCalendar.fromSolar(_event.startAt);
    final endLunar = LunarCalendar.fromSolar(_event.endAt);
    final repeatLabel = switch (_event.repeat) {
      CalendarRepeat.none => 'Không lặp',
      CalendarRepeat.daily => 'Lặp hằng ngày',
      CalendarRepeat.weekly => 'Lặp hằng tuần',
      CalendarRepeat.monthly => 'Lặp hằng tháng',
      CalendarRepeat.yearly => 'Lặp hằng năm',
    };

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppHeader(
        title: const Text('Chi tiết lịch'),
        actions: [
          SaveItemButton(
            id: SavedItemsStore.personalEventId(_event.id),
            temple: false,
          ),
          IconButton(
            tooltip: 'Chỉnh sửa lịch',
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Xóa lịch',
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      color: AppTheme.secondary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'LỊCH CÁ NHÂN · TRÊN THIẾT BỊ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${solarDateLabel(_event.startAt)}'
                  '${_event.usesLunarDate ? ' · ${lunarDateLabel(lunar.day, lunar.month, leap: lunar.isLeapMonth)}' : ''}',
                  style: const TextStyle(
                    color: Color(0xFFE7DCCD),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _InfoTile(
            icon: Icons.schedule_rounded,
            title: 'Thời gian',
            value:
                '${TimeOfDay.fromDateTime(_event.startAt).format(context)} – '
                '${TimeOfDay.fromDateTime(_event.endAt).format(context)}',
            subtitle:
                _event.startAt.day == _event.endAt.day &&
                    _event.startAt.month == _event.endAt.month &&
                    _event.startAt.year == _event.endAt.year
                ? solarDateLabel(_event.startAt)
                : '${solarDateLabel(_event.startAt)} – ${solarDateLabel(_event.endAt)}'
                      '${_event.usesLunarDate ? '\nÂm lịch: ${lunarDateLabel(lunar.day, lunar.month)} – ${lunarDateLabel(endLunar.day, endLunar.month)}' : ''}',
          ),
          _InfoTile(
            icon: Icons.repeat_rounded,
            title: 'Lặp lại',
            value: _event.usesLunarDate
                ? '$repeatLabel · âm lịch'
                : repeatLabel,
          ),
          if (_event.location.isNotEmpty)
            _InfoTile(
              icon: Icons.place_outlined,
              title: 'Địa điểm',
              value: _event.location,
            ),
          if (_event.reminderMinutes != null)
            _InfoTile(
              icon: Icons.notifications_none_rounded,
              title: 'Nhắc trước',
              value: _reminderLabel(_event.reminderMinutes!),
              subtitle: 'Bật Lịch cá nhân trong Cài đặt nhắc lịch để nhận thông báo trên điện thoại.',
            ),
          if (_event.description.isNotEmpty)
            _InfoTile(
              icon: Icons.notes_rounded,
              title: 'Ghi chú',
              value: _event.description,
            ),
          const SizedBox(height: 12),
          const Text(
            'Khi đăng nhập, lịch được lưu theo tài khoản trên máy chủ. Lịch khách được lưu riêng trên thiết bị.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _reminderLabel(int minutes) => switch (minutes) {
    15 => '15 phút trước',
    60 => '1 giờ trước',
    1440 => '1 ngày trước',
    _ => '$minutes phút trước',
  };
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.warmBrown, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
