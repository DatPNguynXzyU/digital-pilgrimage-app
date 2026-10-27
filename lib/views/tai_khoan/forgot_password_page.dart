import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/firebase_identity.dart';
import '../../widgets/app_header.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail = '', this.sendReset});

  final String initialEmail;
  final Future<void> Function(String email)? sendReset;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _email;
  Timer? _timer;
  bool _sending = false;
  bool _sent = false;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_sending || _seconds > 0 || !_form.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await (widget.sendReset ?? FirebaseIdentity.sendPasswordReset)(
        _email.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _sent = true;
        _seconds = 60;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return timer.cancel();
        setState(() => _seconds--);
        if (_seconds == 0) timer.cancel();
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(FirebaseIdentity.message(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppHeader(title: const Text('Quên mật khẩu')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_reset, size: 64, color: AppTheme.primary),
                const SizedBox(height: 24),
                const Text(
                  'Nhập email đã đăng ký để nhận liên kết đặt lại mật khẩu.',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _email,
                  enabled: !_sending,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch(value?.trim() ?? '')
                      ? null
                      : 'Vui lòng nhập email hợp lệ.',
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sending || _seconds > 0 ? null : _submit,
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _seconds > 0
                              ? 'Gửi lại sau $_seconds giây'
                              : 'Gửi liên kết đặt lại',
                        ),
                ),
                if (_sent) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Nếu email có tài khoản hỗ trợ đặt lại mật khẩu, bạn sẽ nhận được liên kết. Hãy kiểm tra hộp thư và thư rác, mở liên kết rồi quay lại đăng nhập bằng mật khẩu mới.',
                  ),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Nếu đăng nhập bằng Google, bạn có thể tiếp tục dùng nút Google. Mật khẩu tài khoản Google được quản lý tại Google.',
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Quay lại đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
