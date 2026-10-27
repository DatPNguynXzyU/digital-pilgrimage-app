import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_header.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const Color primaryBrown = AppTheme.primary;

  final AuthService _authService = AuthService();

  final TextEditingController _currentPasswordController =
      TextEditingController();

  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _loading = false;

  bool _hideCurrentPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();

    _newPasswordController.dispose();

    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text;

    final newPassword = _newPasswordController.text;

    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ thông tin.');

      return;
    }

    if (newPassword.length < 6) {
      _showMessage('Mật khẩu mới phải có ít nhất 6 ký tự.');

      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Xác nhận mật khẩu mới không khớp.');

      return;
    }

    if (currentPassword == newPassword) {
      _showMessage('Mật khẩu mới phải khác mật khẩu hiện tại.');

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,

        newPassword: newPassword,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công. Vui lòng đăng nhập lại.'),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool hidden,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon),

      suffixIcon: IconButton(
        onPressed: onToggle,

        icon: Icon(
          hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppHeader(
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        backgroundColor: AppTheme.background,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const SizedBox(height: 20),

            const Center(
              child: CircleAvatar(
                radius: 45,

                backgroundColor: Color(0xFFF3E1C5),

                child: Icon(Icons.lock_outline, size: 45, color: primaryBrown),
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _currentPasswordController,

              obscureText: _hideCurrentPassword,

              decoration: _inputDecoration(
                label: 'Mật khẩu hiện tại',

                icon: Icons.lock_outline,

                hidden: _hideCurrentPassword,

                onToggle: () {
                  setState(() {
                    _hideCurrentPassword = !_hideCurrentPassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _newPasswordController,

              obscureText: _hideNewPassword,

              decoration: _inputDecoration(
                label: 'Mật khẩu mới',

                icon: Icons.password_outlined,

                hidden: _hideNewPassword,

                onToggle: () {
                  setState(() {
                    _hideNewPassword = !_hideNewPassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _confirmPasswordController,

              obscureText: _hideConfirmPassword,

              onSubmitted: (_) => _changePassword(),

              decoration: _inputDecoration(
                label: 'Xác nhận mật khẩu mới',

                icon: Icons.check_circle_outline,

                hidden: _hideConfirmPassword,

                onToggle: () {
                  setState(() {
                    _hideConfirmPassword = !_hideConfirmPassword;
                  });
                },
              ),
            ),

            const SizedBox(height: 26),

            SizedBox(
              height: 52,

              child: ElevatedButton(
                onPressed: _loading ? null : _changePassword,

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBrown,

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Đổi mật khẩu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
