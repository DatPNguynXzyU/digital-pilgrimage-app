
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcScanButton extends StatefulWidget {
  const NfcScanButton({super.key});

  @override
  State<NfcScanButton> createState() => _NfcScanButtonState();
}

class _NfcScanButtonState extends State<NfcScanButton> {
  bool _isScanning = false;

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _scanNfc() async {
    // NFC vật lý không hoạt động trong Flutter Web.
    if (kIsWeb) {
      _showMessage(
        'Hãy mở ứng dụng trên điện thoại Android có hỗ trợ NFC để quét thẻ.',
      );
      return;
    }

    // Nhấn lần nữa để dừng phiên quét.
    if (_isScanning) {
      try {
        await NfcManager.instance.stopSession();
      } catch (_) {}

      if (mounted) {
        setState(() => _isScanning = false);
      }
      return;
    }

    setState(() => _isScanning = true);

    try {
      final availability =
          await NfcManager.instance.checkAvailability();

      if (availability != NfcAvailability.enabled) {
        if (mounted) {
          setState(() => _isScanning = false);
        }

        _showMessage(
          'NFC chưa bật hoặc thiết bị không hỗ trợ NFC.',
        );
        return;
      }

      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        onDiscovered: (NfcTag tag) async {
          final tagData = tag.data;
          final uid = _findUid(tagData);

          try {
            await NfcManager.instance.stopSession();
          } catch (_) {}

          if (!mounted) return;

          setState(() => _isScanning = false);

          await showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Đã phát hiện thẻ NFC'),
                content: SingleChildScrollView(
                  child: SelectableText(
                    'UID: ${uid ?? 'Chưa xác định được UID'}'
                    '\n\nDữ liệu thẻ:\n$tagData',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('Đóng'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
      }

      _showMessage('Không thể quét NFC: $e');
    }
  }

  String? _findUid(dynamic value) {
    if (value is Map) {
      for (final entry in value.entries) {
        if (entry.key.toString().toLowerCase() == 'identifier') {
          final bytes = entry.value;

          if (bytes is List) {
            final numbers = bytes.whereType<num>().toList();

            if (numbers.isNotEmpty) {
              return numbers
                  .map(
                    (byte) => byte
                        .toInt()
                        .toRadixString(16)
                        .padLeft(2, '0'),
                  )
                  .join(':')
                  .toUpperCase();
            }
          }
        }

        final result = _findUid(entry.value);
        if (result != null) return result;
      }
    } else if (value is List) {
      for (final item in value) {
        final result = _findUid(item);
        if (result != null) return result;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton.icon(
          onPressed: _scanNfc,
          icon: Icon(
            _isScanning ? Icons.hourglass_top_rounded : Icons.nfc,
            size: 24,
          ),
          label: Text(
            _isScanning
                ? 'Đang chờ thẻ NFC... (nhấn để dừng)'
                : 'Quét NFC tại chùa',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF684735),
            foregroundColor: const Color(0xFFFFF8EF),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
