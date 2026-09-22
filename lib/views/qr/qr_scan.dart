import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/temple.dart';
import '../chua/chi_tiet_chua.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  static const Color primaryBrown = Color(0xFFA56A12);

  final MobileScannerController controller =
      MobileScannerController(
    formats: [
      BarcodeFormat.qrCode,
    ],
  );

  bool _isProcessing = false;

  Future<void> _handleQrCode(
    BarcodeCapture capture,
  ) async {
    if (_isProcessing) return;

    if (capture.barcodes.isEmpty) return;

    final String? rawValue =
        capture.barcodes.first.rawValue;

    if (rawValue == null || rawValue.isEmpty) {
      return;
    }

    _isProcessing = true;

    await controller.stop();

    // QR hợp lệ:
    // TEMPLE:chua-giac-lam

    if (!rawValue.startsWith('TEMPLE:')) {
      if (!mounted) return;

      await _showInvalidQr();

      _isProcessing = false;

      await controller.start();

      return;
    }

    final templeId = rawValue
        .replaceFirst('TEMPLE:', '')
        .trim();

    final temple = findTempleById(templeId);

    if (temple == null) {
      if (!mounted) return;

      await _showTempleNotFound();

      _isProcessing = false;

      await controller.start();

      return;
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChiTietChuaPage(
          temple: temple,
        ),
      ),
    );

    _isProcessing = false;

    await controller.start();
  }

  Future<void> _showInvalidQr() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.qr_code_2,
            size: 45,
            color: primaryBrown,
          ),

          title: const Text(
            'Mã QR không hợp lệ',
          ),

          content: const Text(
            'Đây không phải mã QR của chùa '
            'trong hệ thống Hành Hương Số.',
            textAlign: TextAlign.center,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Quét lại'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTempleNotFound() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(
            Icons.search_off,
            size: 45,
            color: primaryBrown,
          ),

          title: const Text(
            'Không tìm thấy chùa',
          ),

          content: const Text(
            'Mã chùa chưa có trong cơ sở dữ liệu.',
            textAlign: TextAlign.center,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Quét lại'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        fit: StackFit.expand,
        children: [
          // CAMERA
          MobileScanner(
            controller: controller,
            onDetect: _handleQrCode,
          ),

          // DARK OVERLAY + KHUNG QR
          CustomPaint(
            painter: QrScannerOverlayPainter(),
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      _circleButton(
                        icon: Icons.close,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),

                      const Text(
                        'Quét mã QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      ValueListenableBuilder(
                        valueListenable: controller,
                        builder: (
                          context,
                          state,
                          child,
                        ) {
                          return _circleButton(
                            icon: state.torchState ==
                                    TorchState.on
                                ? Icons.flash_on
                                : Icons.flash_off,
                            onPressed: () {
                              controller.toggleTorch();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                  ),
                  child: Text(
                    'Đưa mã QR của chùa vào trong khung',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Hệ thống sẽ tự động nhận diện mã QR',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.75,
                    ),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 55),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ======================================================
// OVERLAY QUÉT QR
// ======================================================

class QrScannerOverlayPainter extends CustomPainter {
  static const Color primaryBrown = Color(0xFFA56A12);

  @override
  void paint(Canvas canvas, Size size) {
    final double scanSize =
        size.width * 0.72;

    final Rect scanRect = Rect.fromCenter(
      center: Offset(
        size.width / 2,
        size.height / 2 - 30,
      ),
      width: scanSize,
      height: scanSize,
    );

    // Tạo overlay tối nhưng chừa giữa trong suốt
    final Path backgroundPath = Path()
      ..addRect(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    final Path scanPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          scanRect,
          const Radius.circular(24),
        ),
      );

    final Path overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      scanPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()
        ..color =
            Colors.black.withValues(alpha: 0.55),
    );

    // Khung QR
    final paint = Paint()
      ..color = primaryBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 45;

    // Góc trên trái
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top + cornerLength),
      Offset(scanRect.left, scanRect.top),
      paint,
    );

    canvas.drawLine(
      Offset(scanRect.left, scanRect.top),
      Offset(scanRect.left + cornerLength, scanRect.top),
      paint,
    );

    // Góc trên phải
    canvas.drawLine(
      Offset(scanRect.right - cornerLength, scanRect.top),
      Offset(scanRect.right, scanRect.top),
      paint,
    );

    canvas.drawLine(
      Offset(scanRect.right, scanRect.top),
      Offset(scanRect.right, scanRect.top + cornerLength),
      paint,
    );

    // Góc dưới trái
    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom - cornerLength),
      Offset(scanRect.left, scanRect.bottom),
      paint,
    );

    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom),
      Offset(scanRect.left + cornerLength, scanRect.bottom),
      paint,
    );

    // Góc dưới phải
    canvas.drawLine(
      Offset(scanRect.right - cornerLength, scanRect.bottom),
      Offset(scanRect.right, scanRect.bottom),
      paint,
    );

    canvas.drawLine(
      Offset(scanRect.right, scanRect.bottom),
      Offset(scanRect.right, scanRect.bottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}