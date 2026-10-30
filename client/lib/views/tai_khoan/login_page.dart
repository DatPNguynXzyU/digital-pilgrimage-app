import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_identity.dart';
import '../../widgets/app_header.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color primaryBrown = AppTheme.primary;

  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;
  bool _remembered = false;

  @override
  void initState() {
    super.initState();
    _refreshRemembered();
  }

  Future<void> _refreshRemembered() async {
    final value = await _authService.hasRememberedAccount();
    if (mounted) setState(() => _remembered = value);
  }

  Future<void> _biometricLogin() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _authService.loginWithBiometrics();
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
      }
      await _refreshRemembered();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forget() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _authService.logout();
      await _refreshRemembered();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await _authService.loginWithGoogle();
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_loading) return;
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showMessage(
        'Hãy nhập email và mật khẩu đã đăng ký để gửi lại xác nhận.',
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _authService.resendVerification(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        _showMessage('Đã gửi email xác nhận. Hãy kiểm tra cả thư rác.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================
  // HIỂN THỊ THÔNG BÁO
  // ============================================
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================
  // ĐĂNG NHẬP
  // ============================================
  Future<void> _login() async {
    if (_loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Vui lòng nhập email và mật khẩu.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // Gọi API backend và lưu JWT qua AuthService
      await _authService.login(email: email, password: password);

      if (!mounted) return;

      _showMessage('Đăng nhập thành công.');

      // Trả kết quả về trang Cá nhân
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

  // ============================================
  // MỞ TRANG ĐĂNG KÝ
  // ============================================
  Future<void> _openRegister() async {
    if (_loading) return;

    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );

    if (!mounted) return;

    if (registered == true) {
      final loggedIn = await _authService.isLoggedIn();
      if (!mounted) return;
      if (loggedIn) {
        Navigator.pop(context, true);
      } else {
        _showMessage(
          FirebaseIdentity.configured
              ? 'Đã gửi email xác nhận. Hãy mở liên kết trong email rồi đăng nhập.'
              : 'Đăng ký thành công! Hãy đăng nhập bằng tài khoản mới.',
        );
      }
    }
  }

  // ============================================
  // GIAO DIỆN ĐĂNG NHẬP
  // ============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppHeader(
        title: const Text(
          'Đăng nhập',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.background,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              if (_remembered) ...[
                OutlinedButton.icon(
                  onPressed: _loading ? null : _biometricLogin,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Đăng nhập bằng sinh trắc học'),
                ),
                TextButton(
                  onPressed: _loading ? null : _forget,
                  child: const Text('Quên tài khoản trên thiết bị này'),
                ),
              ],
              const SizedBox(height: 30),

              // ===================================
              // LOGO
              // ===================================
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.surface,

                child: Icon(
                  Icons.temple_buddhist,
                  size: 55,
                  color: primaryBrown,
                ),
              ),

              const SizedBox(height: 24),

              // ===================================
              // TÊN ỨNG DỤNG
              // ===================================
              const Text(
                'Hành Hương Số',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Đăng nhập để lưu hành trình viếng chùa',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // ===================================
              // NHẬP EMAIL
              // ===================================
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,

                decoration: InputDecoration(
                  labelText: 'Email',

                  prefixIcon: const Icon(Icons.email_outlined),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ===================================
              // NHẬP MẬT KHẨU
              // ===================================
              TextField(
                controller: _passwordController,
                obscureText: _hidePassword,

                onSubmitted: (_) {
                  if (!_loading) {
                    _login();
                  }
                },

                decoration: InputDecoration(
                  labelText: 'Mật khẩu',

                  prefixIcon: const Icon(Icons.lock_outline),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _hidePassword = !_hidePassword;
                      });
                    },

                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ForgotPasswordPage(
                              initialEmail: _emailController.text,
                            ),
                          ),
                        ),
                  child: const Text('Quên mật khẩu?'),
                ),
              ),
              const SizedBox(height: 12),

              // ===================================
              // NÚT ĐĂNG NHẬP
              // ===================================
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: _loading ? null : _login,

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
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _loading ? null : _google,
                icon: const Icon(Icons.account_circle_outlined),
                label: const Text('Tiếp tục với Google'),
              ),
              if (FirebaseIdentity.configured)
                TextButton(
                  onPressed: _loading ? null : _resend,
                  child: const Text('Gửi lại email xác nhận'),
                ),

              // ===================================
              // NÚT ĐĂNG KÝ - MỚI THÊM
              // ===================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    'Chưa có tài khoản?',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),

                  TextButton(
                    onPressed: _loading ? null : _openRegister,

                    child: const Text(
                      'Đăng ký',
                      style: TextStyle(
                        color: primaryBrown,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
