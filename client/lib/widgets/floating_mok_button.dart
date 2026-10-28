import 'dart:async';

import 'package:flutter/material.dart';

import '../services/mok_audio_service.dart';

/// Matching floating wooden-fish and bell controls for scripture readers.
class FloatingMokButton extends StatefulWidget {
  const FloatingMokButton({super.key}) : isBell = false;

  const FloatingMokButton.bell({super.key}) : isBell = true;

  final bool isBell;

  @override
  State<FloatingMokButton> createState() => _FloatingMokButtonState();
}

class _FloatingMokButtonState extends State<FloatingMokButton> {
  bool _busy = false;

  MokAudioService get _audio =>
      widget.isBell ? MokAudioService.bell : MokAudioService.instance;

  String get _soundName => widget.isBell ? 'chuông' : 'mõ';

  @override
  void initState() {
    super.initState();
    // Load into the low-latency pool without starting playback.
    unawaited(_audio.prepare());
  }

  Future<void> _play() async {
    if (_busy) return;
    setState(() => _busy = true);
    final succeeded = await _audio.playOnce();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!succeeded) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Không phát được tiếng $_soundName. Hãy thử lại.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _busy ? 'Đang phát tiếng $_soundName' : 'Phát tiếng $_soundName',
      child: Tooltip(
        message: _busy
            ? 'Đang phát tiếng $_soundName'
            : 'Phát tiếng $_soundName',
        child: Material(
          color: const Color(0xFF754000),
          shape: const CircleBorder(),
          elevation: 5,
          shadowColor: Colors.black26,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _busy ? null : _play,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Center(
                child: AnimatedScale(
                  scale: _busy ? 1.12 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: widget.isBell
                      ? const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 34,
                        )
                      : const CustomPaint(
                          size: Size(34, 34),
                          painter: _MokGlyphPainter(),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact white line drawing of a wooden fish and its striker.
class _MokGlyphPainter extends CustomPainter {
  const _MokGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final body = Path()
      ..moveTo(size.width * .12, size.height * .56)
      ..quadraticBezierTo(
        size.width * .23,
        size.height * .18,
        size.width * .58,
        size.height * .2,
      )
      ..quadraticBezierTo(
        size.width * .91,
        size.height * .22,
        size.width * .88,
        size.height * .57,
      )
      ..quadraticBezierTo(
        size.width * .86,
        size.height * .82,
        size.width * .58,
        size.height * .82,
      )
      ..lineTo(size.width * .36, size.height * .82)
      ..quadraticBezierTo(
        size.width * .16,
        size.height * .81,
        size.width * .12,
        size.height * .56,
      );
    canvas.drawPath(body, white);

    // Sound slit and its short opening at the top.
    canvas.drawLine(
      Offset(size.width * .36, size.height * .55),
      Offset(size.width * .66, size.height * .55),
      white,
    );
    canvas.drawLine(
      Offset(size.width * .52, size.height * .55),
      Offset(size.width * .52, size.height * .68),
      white,
    );
    // The beater rests beside the body, suggesting the striking action.
    canvas.drawLine(
      Offset(size.width * .73, size.height * .08),
      Offset(size.width * .63, size.height * .32),
      white,
    );
    canvas.drawCircle(
      Offset(size.width * .75, size.height * .11),
      2.4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _MokGlyphPainter oldDelegate) => false;
}
