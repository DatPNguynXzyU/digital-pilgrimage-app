import 'package:flutter/material.dart';
import '../nfc/nfc_scan_page.dart';
import '../../services/auth_service.dart';
import 'change_password_page.dart';
import 'login_page.dart';
import 'pilgrimage_page.dart';

class TaiKhoanPage extends StatefulWidget {
  const TaiKhoanPage({
    super.key,
  });

  @override
  State<TaiKhoanPage> createState() =>
      _TaiKhoanPageState();
}

class _TaiKhoanPageState

    extends State<TaiKhoanPage> {
      void _openNfcScan() {
  if (_token == null) {
    _openLogin();
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const NfcScanPage(),
    ),
  );
}
  static const Color primaryBrown =
      Color(0xFFA56A12);

  final AuthService _authService =
      AuthService();

  bool _loading = true;

  String? _token;

  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();

    _loadAccount();
  }

  Future<void> _loadAccount() async {
    setState(() {
      _loading = true;
    });

    try {
      final token =
          await _authService.getToken();

      if (token == null ||
          token.isEmpty) {
        if (!mounted) return;

        setState(() {
          _token = null;
          _user = null;
          _loading = false;
        });

        return;
      }

      final result =
          await _authService.getMe();

      final user =
          result['user'] ??
          result['data'];

      if (!mounted) return;

      setState(() {
        _token = token;

        if (user
            is Map<String, dynamic>) {
          _user = user;
        } else {
          _user = null;
        }

        _loading = false;
      });
    } catch (_) {
      await _authService.logout();

      if (!mounted) return;

      setState(() {
        _token = null;
        _user = null;
        _loading = false;
      });
    }
  }

  Future<void> _openLogin() async {
    final result =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginPage(),
      ),
    );

    if (result == true) {
      await _loadAccount();
    }
  }

  void _openPilgrimage() {
    if (_token == null) {
      _openLogin();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PilgrimagePage(
          token: _token!,
        ),
      ),
    );
  }

  void _openChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ChangePasswordPage(),
      ),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    setState(() {
      _token = null;
      _user = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Đã đăng xuất.',
        ),
      ),
    );
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
          'Cá nhân',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading:
            false,
        backgroundColor:
            const Color(0xFFFFFBF7),
        elevation: 0,
      ),

      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: primaryBrown,
              ),
            )
          : RefreshIndicator(
              onRefresh:
                  _loadAccount,

              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(
                  16,
                ),

                children: [
                  const SizedBox(
                    height: 15,
                  ),

                  // =========================
                  // AVATAR
                  // =========================
                  const Center(
                    child: CircleAvatar(
                      radius: 48,

                      backgroundColor:
                          Color(
                        0xFFF3E1C5,
                      ),

                      child: Icon(
                        Icons.person,
                        size: 54,
                        color:
                            primaryBrown,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // =========================
                  // TÊN USER
                  // =========================
                  Center(
                    child: Text(
                      _token == null
                          ? 'Chưa đăng nhập'
                          : (_user?[
                                      'fullName']
                                  ?.toString() ??
                              'Tài khoản'),

                      textAlign:
                          TextAlign.center,

                      style:
                          const TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  // =========================
                  // EMAIL
                  // =========================
                  if (_user?['email'] !=
                      null)
                    Center(
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          top: 6,
                        ),

                        child: Text(
                          _user!['email']
                              .toString(),

                          style:
                              const TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(
                    height: 30,
                  ),

                  // =========================
                  // CHƯA ĐĂNG NHẬP
                  // =========================
                  if (_token == null)
                    SizedBox(
                      height: 50,

                      child:
                          ElevatedButton(
                        onPressed:
                            _openLogin,

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

                        child:
                            const Text(
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

                  // =========================
                  // ĐÃ ĐĂNG NHẬP
                  // =========================
                  if (_token != null) ...[
                    // =======================
                    // HÀNH TRÌNH
                    // =======================
                    Card(
                      elevation: 0,
                      color: Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                      ),

                      child: ListTile(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),

                        leading:
                            const CircleAvatar(
                          backgroundColor:
                              Color(
                            0xFFF3E1C5,
                          ),

                          child: Icon(
                            Icons
                                .temple_buddhist_outlined,
                            color:
                                primaryBrown,
                          ),
                        ),

                        title:
                            const Text(
                          'Hành trình của tôi',

                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        subtitle:
                            const Text(
                          'Chùa đã viếng, số lần đi và tem đã nhận',
                        ),

                        trailing:
                            const Icon(
                          Icons
                              .chevron_right,
                        ),

                        onTap:
                            _openPilgrimage,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =======================
                    // ĐỔI MẬT KHẨU
                    // =======================
                    Card(
                      elevation: 0,
                      color: Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                      ),

                      child: ListTile(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),

                        leading:
                            const CircleAvatar(
                          backgroundColor:
                              Color(
                            0xFFF3E1C5,
                          ),

                          child: Icon(
                            Icons
                                .lock_outline,
                            color:
                                primaryBrown,
                          ),
                        ),

                        title:
                            const Text(
                          'Đổi mật khẩu',

                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        subtitle:
                            const Text(
                          'Thay đổi mật khẩu đăng nhập',
                        ),

                        trailing:
                            const Icon(
                          Icons
                              .chevron_right,
                        ),

                        onTap:
                            _openChangePassword,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =======================
                    // ĐĂNG XUẤT
                    // =======================
                    Card(
                      elevation: 0,
                      color: Colors.white,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                      ),

                      child: ListTile(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),

                        leading:
                            const CircleAvatar(
                          backgroundColor:
                              Color(
                            0xFFFFE7E7,
                          ),

                          child: Icon(
                            Icons.logout,
                            color:
                                Colors.red,
                          ),
                        ),

                        title:
                            const Text(
                          'Đăng xuất',

                          style:
                              TextStyle(
                            color:
                                Colors.red,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        subtitle:
                            const Text(
                          'Thoát khỏi tài khoản hiện tại',
                        ),

                        onTap:
                            _logout,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}