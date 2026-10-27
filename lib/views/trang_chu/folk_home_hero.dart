import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/daily_buddha_image_service.dart';
import '../../utils/lunar_calendar.dart';

class FolkHomeHero extends StatefulWidget {
  const FolkHomeHero({
    super.key,
    this.onOpenCalendar,
    this.date,
    this.clock = DateTime.now,
  });

  final VoidCallback? onOpenCalendar;

  /// Optional fixed date for previews/tests. Production follows Vietnam time.
  final DateTime? date;
  final DateTime Function() clock;

  @override
  State<FolkHomeHero> createState() => _FolkHomeHeroState();
}

class _FolkHomeHeroState extends State<FolkHomeHero>
    with WidgetsBindingObserver {
  late DateTime _displayDate;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _displayDate = widget.date ?? _currentVietnamDate();
    _scheduleMidnightCheck();
  }

  @override
  void didUpdateWidget(covariant FolkHomeHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date || oldWidget.clock != widget.clock) {
      _displayDate = widget.date ?? _currentVietnamDate();
      _scheduleMidnightCheck();
    }
  }

  DateTime _currentVietnamDate() =>
      DailyBuddhaImageService.vietnamDateTime(widget.clock());

  void _scheduleMidnightCheck() {
    _midnightTimer?.cancel();
    if (widget.date != null) return;
    final now = _currentVietnamDate();
    final delay = DailyBuddhaImageService.nextVietnamMidnight(now).difference(
      now,
    );
    _midnightTimer = Timer(delay + const Duration(milliseconds: 50), () {
      _refreshForCurrentDay();
    });
  }

  void _refreshForCurrentDay() {
    if (!mounted || widget.date != null) return;
    final current = _currentVietnamDate();
    if (DailyBuddhaImageService.dayKey(current) !=
        DailyBuddhaImageService.dayKey(_displayDate)) {
      setState(() => _displayDate = current);
    }
    _scheduleMidnightCheck();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshForCurrentDay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    super.dispose();
  }

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
    final now = _displayDate;
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
              DailyBuddhaImageService.imageForDate(now),
              fit: BoxFit.cover,
              semanticLabel: 'Đức Phật ngồi thiền giữa rừng cây thanh tịnh',
              errorBuilder: (context, error, stackTrace) => Image.asset(
                DailyBuddhaImageService.fallbackAsset,
                fit: BoxFit.cover,
                semanticLabel: 'Đức Phật ngồi thiền giữa rừng cây thanh tịnh',
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: Color(0xFF42574A),
                  child: Center(
                    child: Icon(
                      Icons.self_improvement_rounded,
                      color: Color(0xFFEDE3D0),
                      size: 56,
                    ),
                  ),
                ),
              ),
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
              bottom: 25,
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
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 3),
                  Text(
                    '${lunar.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width < 380 ? 52 : 60,
                      height: 1.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1.2,
                      shadows: const [
                        Shadow(color: Colors.black38, blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
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
                  const SizedBox(height: 6),
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
      button: widget.onOpenCalendar != null,
      label:
          'Lịch âm dương hôm nay. $dateLabel. '
          'Ngày âm ${lunar.day}, tháng ${lunar.month}, năm $lunarYearName.',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: widget.onOpenCalendar,
          borderRadius: BorderRadius.circular(25),
          child: card,
        ),
      ),
    );
  }
}
