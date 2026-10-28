import 'package:flutter/material.dart';

import '../services/biometric_lock.dart';

class BiometricSettingsTile extends StatefulWidget {
  const BiometricSettingsTile({super.key});

  @override
  State<BiometricSettingsTile> createState() => _BiometricSettingsTileState();
}

class _BiometricSettingsTileState extends State<BiometricSettingsTile> {
  bool _enabled = false;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    BiometricLock.enabled().then((value) {
      if (mounted) {
        setState(() {
          _enabled = value;
          _busy = false;
        });
      }
    });
  }

  Future<void> _change(bool value) async {
    setState(() => _busy = true);
    try {
      if (!await BiometricLock.authenticate()) {
        throw Exception(
          'Chưa xác thực được. Hãy kiểm tra vân tay hoặc khuôn mặt đã đăng ký trong cài đặt điện thoại.',
        );
      }
      await BiometricLock.setEnabled(value);
      if (mounted) setState(() => _enabled = value);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không thể xác thực. Hãy đăng ký vân tay trong cài đặt điện thoại hoặc thử lại sau.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: const Icon(Icons.fingerprint),
    title: const Text('Khóa bằng vân tay / sinh trắc học'),
    subtitle: const Text(
      'Xác thực khi mở lại ứng dụng. Dùng sinh trắc học đã đăng ký trên điện thoại.',
    ),
    value: _enabled,
    onChanged: _busy ? null : _change,
  );
}
