import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color primaryBrown = Color(0xFFA56A12);

  final AuthService _authService = AuthService();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================
  // ĐĂNG NHẬP
  // ============================================
  Future<void> _login() async {
    if (_loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Vui lòng nhập email và mật khẩu.',
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // Gọi API backend và lưu JWT qua AuthService
      await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showMessage('Đăng nhập thành công.');

      // Trả kết quả về trang Cá nhân
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
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
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );

    if (!mounted) return;

    if (registered == true) {
      _showMessage(
        'Đăng ký thành công! Hãy đăng nhập bằng tài khoản mới.',
      );
    }
  }

  // ============================================
  // GIAO DIỆN ĐĂNG NHẬP
  // ============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),

      appBar: AppBar(
        title: const Text(
          'Đăng nhập',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFFBF7),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              const SizedBox(height: 30),

              // ===================================
              // LOGO
              // ===================================
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFF3E1C5),

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
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Đăng nhập để lưu hành trình viếng chùa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
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

                  prefixIcon: const Icon(
                    Icons.email_outlined,
                  ),

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

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),

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

              const SizedBox(height: 24),

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

              // ===================================
              // NÚT ĐĂNG KÝ - MỚI THÊM
              // ===================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    'Chưa có tài khoản?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
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