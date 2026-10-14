import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

String solarDateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

String lunarDateLabel(int day, int month, {bool leap = false}) =>
    '$day/${month.toString().padLeft(2, '0')}${leap ? ' nhuận' : ''} âm lịch';

String weekdayLabel(DateTime date) {
  const weekdays = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ nhật',
  ];
  return weekdays[date.weekday - 1];
}

class CalendarSectionLabel extends StatelessWidget {
  final String title;
  final String? trailing;

  const CalendarSectionLabel(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: AppTheme.text,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      if (trailing != null)
        Text(
          trailing!,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
    ],
  );
}

class CalendarPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const CalendarPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}
