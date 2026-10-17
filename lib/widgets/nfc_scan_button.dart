import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../views/nfc/nfc_scan_page.dart';

class NfcScanButton extends StatelessWidget {
  const NfcScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const NfcScanPage(),
              ),
            );
          },
          icon: const Icon(
            Icons.nfc_rounded,
            size: 24,
          ),
          label: const Text(
            'Quét thẻ NFC tại chùa',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: const Color(0xFFFFF8EF),
            textStyle: const TextStyle(
              fontSize: 16,
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
