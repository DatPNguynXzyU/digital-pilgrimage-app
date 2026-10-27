import 'package:flutter/material.dart';

import '../../utils/lunar_calendar.dart';

class FolkHomeHero extends StatelessWidget {
  const FolkHomeHero({super.key, this.onOpenCalendar, this.date});

  final VoidCallback? onOpenCalendar;
  final DateTime? date;

  static const _weekdays = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ nhật',
  ];
  static const _can = [
    'Canh',
    'Tân',
    'Nhâm',
    'Quý',
    'Giáp',
    'Ất',
    'Bính',
    'Đinh',
    'Mậu',
    'Kỷ',
  ];
  static const _chi = [
    'Tý',
    'Sửu',
    'Dần',
    'Mão',
    'Thìn',
    'Tỵ',
    'Ngọ',
    'Mùi',
    'Thân',
    'Dậu',
    'Tuất',
    'Hợi',
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context)
        .scale(1)
        .clamp(1.0, 2.0)
        .toDouble();
    final now = date ?? DateTime.now();
    final lunar = LunarCalendar.fromSolar(now);
    final lunarYearName =
        '${_can[lunar.year % 10]} ${_chi[(lunar.year + 8) % 12]}';
    final dateLabel =
        '${_weekdays[now.weekday - 1]} · '
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
    final card = AspectRatio(
      key: const ValueKey('hero-date-card'),
      aspectRatio: (width < 380 ? 1.42 : 1.52) - (textScale - 1) * .36,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'images/buddha-meditation.png',
              fit: BoxFit.cover,
              semanticLabel: 'Đức Phật ngồi thiền giữa rừng cây thanh tịnh',
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x080D1B12),
                    Color(0x18131B14),
                    Color(0xD90E1711),
                  ],
                  stops: [0, .43, 1],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 18,
              bottom: 17,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      color: Color(0xFFF6F0E5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.nightlight_round,
                        color: Color(0xFFFFD43B),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Âm lịch',
                        style: TextStyle(
                          color: Color(0xFFFFD43B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${lunar.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width < 380 ? 52 : 60,
                      height: 1.16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1.2,
                      shadows: const [
                        Shadow(color: Colors.black38, blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Tháng ${lunar.month.toString().padLeft(2, '0')}'
                    '${lunar.isLeapMonth ? ' nhuận' : ''}',
                    style: const TextStyle(
                      color: Color(0xFFF6F0E5),
                      fontSize: 18,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Năm $lunarYearName',
                    style: const TextStyle(
                      color: Color(0xFFE6D7B9),
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      button: onOpenCalendar != null,
      label:
          'Lịch âm dương hôm nay. $dateLabel. '
          'Ngày âm ${lunar.day}, tháng ${lunar.month}, năm $lunarYearName.',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onOpenCalendar,
          borderRadius: BorderRadius.circular(25),
          child: card,
        ),
      ),
    );
  }
}
