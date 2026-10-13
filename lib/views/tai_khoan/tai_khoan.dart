import 'package:flutter/material.dart';
import '../../config/api_config.dart';
import '../nfc/nfc_scan_page.dart';
import '../../services/auth_service.dart';
import 'change_password_page.dart';
import 'login_page.dart';
import 'pilgrimage_page.dart';
import 'edit_profile_page.dart';

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

      final data = result['data'];

      final rawUser = result['user'] ??
          (data is Map
              ? (data['user'] ?? data)
              : null);

      final Map<String, dynamic>? user =
          rawUser is Map
              ? Map<String, dynamic>.from(rawUser)
              : null;

      if (!mounted) return;

      setState(() {
        _token = token;

        _user = user;

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
  Future<void> _openEditProfile() async {
  final updated = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => const EditProfilePage(),
    ),
  );

  if (!mounted) return;

  if (updated == true) {
    await _loadAccount();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cập nhật hồ sơ thành công.',
        ),
      ),
    );
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

  String? _getAvatarUrl() {
    final avatar = _user?['avatar']
            ?.toString()
            .trim() ??
        '';

    if (avatar.isEmpty) {
      return null;
    }

    if (avatar.startsWith('http://') ||
        avatar.startsWith('https://')) {
      return avatar;
    }

    final serverUrl =
        ApiConfig.baseUrl.replaceFirst(
      RegExp(r'/api/?$'),
      '',
    );

    final path = avatar.startsWith('/')
        ? avatar
        : '/$avatar';

    return '$serverUrl$path';
  }

  // ===================================
  // HIỂN THỊ ẢNH ĐẠI DIỆN
  // ===================================
  Widget _buildAvatar() {
    final avatarUrl = _getAvatarUrl();

    Widget fallbackAvatar() {
      return Container(
        color: const Color(0xFFF3E1C5),
        alignment: Alignment.center,
        child: const Icon(
          Icons.person,
          size: 54,
          color: primaryBrown,
        ),
      );
    }

    return Center(
      child: ClipOval(
        child: SizedBox(
          width: 96,
          height: 96,
          child: avatarUrl == null
              ? fallbackAvatar()
              : Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return fallbackAvatar();
                  },
                ),
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
                  _buildAvatar(),

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
                    // ===================================
// CHỈNH SỬA HỒ SƠ
// ===================================
Card(
  elevation: 0,
  color: Colors.white,

  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),

  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 8,
    ),

    leading: const CircleAvatar(
      backgroundColor: Color(0xFFF3E1C5),

      child: Icon(
        Icons.manage_accounts_outlined,
        color: primaryBrown,
      ),
    ),

    title: const Text(
      'Chỉnh sửa hồ sơ',
      style: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),

    subtitle: const Text(
      'Thay đổi họ tên và ảnh đại diện',
    ),

    trailing: const Icon(
      Icons.chevron_right,
    ),

    onTap: _openEditProfile,
  ),
),

const SizedBox(height: 12),
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
