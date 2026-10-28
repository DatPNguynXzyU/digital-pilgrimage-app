import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../utils/lunar_calendar.dart';

class HomeHero extends StatelessWidget {
  final DateTime? date;

  const HomeHero({super.key, this.date});

  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final today = date ?? DateTime.now();
    final lunarDate = LunarCalendar.fromSolar(today);
    final leapMonth = lunarDate.isLeapMonth ? ' nhuận' : '';
    final solarLabel = _dateLabel(today);
    final lunarLabel =
        '${lunarDate.day.toString().padLeft(2, '0')}/'
        '${lunarDate.month.toString().padLeft(2, '0')}$leapMonth/'
        '${lunarDate.year}';

    return AspectRatio(
      aspectRatio: 1.62,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF76513C),
                    Color(0xFF422C22),
                    Color(0xFF33271F),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -35,
              top: -45,
              child: Icon(
                Icons.circle_outlined,
                size: 200,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Positioned(
              right: 7,
              bottom: 1,
              child: Icon(
                Icons.temple_buddhist_rounded,
                size: 126,
                color: AppTheme.secondary.withValues(alpha: 0.6),
              ),
            ),
            Positioned(
              right: 34,
              bottom: 36,
              child: Icon(
                Icons.local_florist_outlined,
                size: 36,
                color: AppTheme.surface.withValues(alpha: 0.78),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(17, 10, 91, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      key: const ValueKey('hero-brand'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const Text(
                        'ĐI CHÙA  ·  VĂN HÓA VIỆT',
                        style: TextStyle(
                          color: Color(0xFFF4E8D4),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                    const Text(
                      'Một ngày\nan nhiên',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.02,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const Text(
                      'Chậm lại một nhịp, lắng nghe lòng mình.',
                      maxLines: 2,
                      style: TextStyle(
                        color: Color(0xFFD8C9BA),
                        fontSize: 11,
                        height: 1.18,
                      ),
                    ),
                    Container(
                      key: const ValueKey('hero-date-card'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 19,
                            color: AppTheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DateLine(label: 'DƯƠNG', date: solarLabel),
                              const SizedBox(height: 3),
                              _DateLine(label: 'ÂM', date: lunarLabel),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateLine extends StatelessWidget {
  final String label;
  final String date;

  const _DateLine({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Text(
          date,
          style: const TextStyle(
            color: Color(0xFFF9F3E9),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
