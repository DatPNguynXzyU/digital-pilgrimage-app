import 'package:flutter/material.dart';

import '../../models/quote.dart';
import '../../services/quote_service.dart';

class HomeDhammapadaCard extends StatefulWidget {
  const HomeDhammapadaCard({super.key, this.loadQuote});
  final Future<Quote?> Function(String? exclude)? loadQuote;

  @override
  State<HomeDhammapadaCard> createState() => _HomeDhammapadaCardState();
}

class _HomeDhammapadaCardState extends State<HomeDhammapadaCard> {
  Quote? _quote;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final quote =
          await (widget.loadQuote?.call(_quote?.code) ??
              QuoteService().random(exclude: _quote?.code));
      if (mounted) setState(() => _quote = quote);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final quoteSize = width < 340
          ? 16.0
          : width < 430
          ? 18.0
          : 20.0;
      return Container(
        key: const ValueKey('dhammapada-card'),
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRect(
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _LotusDecorationPainter()),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  width < 360 ? 20 : 28,
                  25,
                  width < 360 ? 20 : 28,
                  18,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'KINH PHÁP CÚ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF806D4D),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 17),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF806D4D),
                          ),
                        ),
                      )
                    else if (_failed)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Không thể tải câu Phật ngôn. Vui lòng thử lại.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF68645C)),
                        ),
                      )
                    else if (_quote == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Chưa có câu Phật ngôn.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF68645C)),
                        ),
                      )
                    else ...[
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          _quote!.content,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: quoteSize,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            height: 1.52,
                            color: const Color(0xFF171717),
                          ),
                        ),
                      ),
                      if (_quote!.source.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _quote!.source,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF68645C),
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    Tooltip(
                      message: 'Tải câu Phật ngôn khác từ nguồn',
                      child: TextButton.icon(
                        onPressed: _loading ? null : _load,
                        icon: _loading
                            ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 17),
                        label: Text(_failed ? 'Thử lại' : 'Câu khác'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF526A58),
                          textStyle: const TextStyle(fontSize: 13),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _LotusDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final watermarkPaint = Paint()
      ..color = const Color(0x24E5D4B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _drawLotus(
      canvas,
      Offset(size.width / 2, size.height * .51),
      Size(size.width * .48, size.width * .35),
      watermarkPaint,
    );

    final cornerPaint = Paint()
      ..color = const Color(0x66DCC18D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cornerSize = Size(size.width * .28, size.width * .2);
    _drawLotus(canvas, Offset(0, size.height + 5), cornerSize, cornerPaint);
    canvas.save();
    canvas.translate(size.width, 0);
    canvas.scale(-1, 1);
    _drawLotus(canvas, Offset(0, size.height + 5), cornerSize, cornerPaint);
    canvas.restore();
  }

  void _drawLotus(Canvas canvas, Offset center, Size size, Paint paint) {
    final halfWidth = size.width / 2;
    final height = size.height;
    final baseY = center.dy + height * .28;
    final path = Path()
      ..moveTo(center.dx, baseY)
      ..cubicTo(
        center.dx - halfWidth * .14,
        center.dy + height * .04,
        center.dx - halfWidth * .13,
        center.dy - height * .34,
        center.dx,
        center.dy - height * .5,
      )
      ..cubicTo(
        center.dx + halfWidth * .13,
        center.dy - height * .34,
        center.dx + halfWidth * .14,
        center.dy + height * .04,
        center.dx,
        baseY,
      )
      ..moveTo(center.dx, baseY)
      ..cubicTo(
        center.dx - halfWidth * .38,
        center.dy + height * .13,
        center.dx - halfWidth * .76,
        center.dy - height * .18,
        center.dx - halfWidth,
        center.dy - height * .02,
      )
      ..cubicTo(
        center.dx - halfWidth * .78,
        center.dy + height * .23,
        center.dx - halfWidth * .36,
        center.dy + height * .34,
        center.dx,
        baseY,
      )
      ..moveTo(center.dx, baseY)
      ..cubicTo(
        center.dx + halfWidth * .38,
        center.dy + height * .13,
        center.dx + halfWidth * .76,
        center.dy - height * .18,
        center.dx + halfWidth,
        center.dy - height * .02,
      )
      ..cubicTo(
        center.dx + halfWidth * .78,
        center.dy + height * .23,
        center.dx + halfWidth * .36,
        center.dy + height * .34,
        center.dx,
        baseY,
      )
      ..moveTo(center.dx - halfWidth * .74, baseY + height * .09)
      ..quadraticBezierTo(
        center.dx,
        baseY + height * .3,
        center.dx + halfWidth * .74,
        baseY + height * .09,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
