import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {
  static const Color primaryBrown =
      Color(0xFFA56A12);

  final AuthService _authService =
      AuthService();

  final TextEditingController
      _emailController =
      TextEditingController();

  final TextEditingController
      _passwordController =
      TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    if (email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập email và mật khẩu.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Đăng nhập thành công.',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
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

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFFFBF7),

      appBar: AppBar(
        title: const Text(
          'Đăng nhập',
        ),
        backgroundColor:
            const Color(0xFFFFFBF7),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),

            const CircleAvatar(
              radius: 50,
              backgroundColor:
                  Color(0xFFF3E1C5),

              child: Icon(
                Icons
                    .temple_buddhist,
                size: 55,
                color:
                    primaryBrown,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            const Text(
              'Hành Hương Số',
              style: TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Đăng nhập để lưu hành trình viếng chùa',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            TextField(
              controller:
                  _emailController,

              keyboardType:
                  TextInputType
                      .emailAddress,

              decoration:
                  InputDecoration(
                labelText: 'Email',

                prefixIcon:
                    const Icon(
                  Icons
                      .email_outlined,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  _passwordController,

              obscureText:
                  _hidePassword,

              onSubmitted: (_) =>
                  _login(),

              decoration:
                  InputDecoration(
                labelText:
                    'Mật khẩu',

                prefixIcon:
                    const Icon(
                  Icons.lock_outline,
                ),

                suffixIcon:
                    IconButton(
                  onPressed: () {
                    setState(() {
                      _hidePassword =
                          !_hidePassword;
                    });
                  },

                  icon: Icon(
                    _hidePassword
                        ? Icons
                            .visibility_outlined
                        : Icons
                            .visibility_off_outlined,
                  ),
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 52,

              child:
                  ElevatedButton(
                onPressed:
                    _loading
                        ? null
                        : _login,

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      primaryBrown,

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                ),

                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,

                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Text(
                        'Đăng nhập',
                        style:
                            TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .bold,
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