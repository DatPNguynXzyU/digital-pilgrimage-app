import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../temples/temple_list_page.dart';
import 'change_password_page.dart';
import 'login_page.dart';
import 'pilgrimage_page.dart';
import 'pilgrimage_history_page.dart';
import 'edit_profile_page.dart';
import 'stamp_book_page.dart';

class TaiKhoanPage extends StatefulWidget {
  const TaiKhoanPage({super.key});

  @override
  State<TaiKhoanPage> createState() => _TaiKhoanPageState();
}

class _TaiKhoanPageState extends State<TaiKhoanPage> {
  static const Color primaryBrown = AppTheme.primary;

  final AuthService _authService = AuthService();

  bool _loading = true;

  String? _token;

  Map<String, dynamic>? _user;

  String? _accountError;

  @override
  void initState() {
    super.initState();

    _loadAccount();
    AuthService.sessionChanges.addListener(_loadAccount);
  }

  @override
  void dispose() {
    AuthService.sessionChanges.removeListener(_loadAccount);
    super.dispose();
  }

  int _accountRequest = 0;
  Future<void> _loadAccount() async {
    final requestId = ++_accountRequest;
    var token = '';
    setState(() {
      _loading = true;
      _accountError = null;
    });

    try {
      token = await _authService.getToken() ?? '';

      if (token.isEmpty) {
        if (!mounted || requestId != _accountRequest) return;

        setState(() {
          _token = null;
          _user = null;
          _loading = false;
          _accountError = null;
        });

        return;
      }

      final result = await _authService.getMe();

      final data = result['data'];

      final rawUser =
          result['user'] ?? (data is Map ? (data['user'] ?? data) : null);

      final Map<String, dynamic>? user = rawUser is Map
          ? Map<String, dynamic>.from(rawUser)
          : null;

      if (!mounted || requestId != _accountRequest) return;

      setState(() {
        _token = token;

        _user = user;

        _loading = false;
        _accountError = null;
      });
    } catch (_) {
      if (!mounted || requestId != _accountRequest) return;

      setState(() {
        _token = token.isEmpty ? _token : token;
        _user = null;
        _loading = false;
        _accountError =
            'Không thể tải thông tin tài khoản. Kiểm tra kết nối và thử lại.';
      });
    }
  }

  Future<void> _openLogin() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );

    if (result == true) {
      await _loadAccount();
    }
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );

    if (!mounted) return;

    if (updated == true) {
      await _loadAccount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công.')),
      );
    }
  }

  void _openExplore() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const TempleListPage()),
    );
  }

  void _openPilgrimage() {
    if (_token == null) {
      _openLogin();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PilgrimagePage(token: _token!)),
    );
  }

  void _openStampBook() {
    if (_token == null) {
      _openLogin();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => StampBookPage(token: _token!)),
    );
  }

  void _openPilgrimageHistory() {
    if (_token == null) {
      _openLogin();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => PilgrimageHistoryPage(token: _token!),
      ),
    );
  }

  Future<void> _openChangePassword() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
    );
    if (mounted && changed == true) await _loadAccount();
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    setState(() {
      _token = null;
      _user = null;
      _accountError = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã đăng xuất.')));
  }

  String? _getAvatarUrl() {
    final avatar = _user?['avatar']?.toString().trim() ?? '';

    if (avatar.isEmpty) {
      return null;
    }

    if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
      return avatar;
    }

    final serverUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

    final path = avatar.startsWith('/') ? avatar : '/$avatar';

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
        child: const Icon(Icons.person, size: 54, color: primaryBrown),
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
                  errorBuilder: (context, error, stackTrace) {
                    return fallbackAvatar();
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildProfileHero() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          SizedBox(width: 72, height: 72, child: _buildAvatar()),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _token == null
                      ? 'Chào bạn'
                      : (_user?['fullName']?.toString() ?? 'Tài khoản'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _token == null
                      ? 'Đăng nhập để lưu hành trình'
                      : (_user?['email']?.toString() ?? 'Thành viên ĐI CHÙA'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (_token != null)
            IconButton(
              tooltip: 'Chỉnh sửa hồ sơ',
              onPressed: _openEditProfile,
              icon: const Icon(Icons.edit_outlined, color: AppTheme.surface),
            ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 9),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.warmBrown,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text(
          'Cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator(color: primaryBrown))
          : RefreshIndicator(
              onRefresh: _loadAccount,

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.all(16),

                children: [
                  const SizedBox(height: 15),

                  if (_accountError != null) ...[
                    Card(
                      color: AppTheme.surface,
                      child: ListTile(
                        leading: const Icon(
                          Icons.cloud_off_outlined,
                          color: AppTheme.accent,
                        ),
                        title: const Text(
                          'Chưa tải được hồ sơ',
                          style: TextStyle(
                            color: AppTheme.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(_accountError!),
                        trailing: IconButton(
                          tooltip: 'Thử lại',
                          onPressed: _loadAccount,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // =========================
                  // AVATAR
                  // =========================
                  _buildProfileHero(),
                  const SizedBox(height: 24),

                  // =========================
                  // CHƯA ĐĂNG NHẬP
                  // =========================
                  if (_token == null)
                    SizedBox(
                      height: 50,

                      child: ElevatedButton(
                        onPressed: _openLogin,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBrown,

                          foregroundColor: Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),

                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // =========================
                  // ĐÃ ĐĂNG NHẬP
                  // =========================
                  if (_token != null) ...[
                    _sectionLabel('Tài khoản'),
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
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: const Text('Thay đổi họ tên và ảnh đại diện'),

                        trailing: const Icon(Icons.chevron_right),

                        onTap: _openEditProfile,
                      ),
                    ),

                    const SizedBox(height: 12),
                    _sectionLabel('Hành trình của tôi'),
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
                            Icons.temple_buddhist_outlined,
                            color: primaryBrown,
                          ),
                        ),

                        title: const Text(
                          'Thống kê hành hương',

                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),

                        subtitle: const Text(
                          'Số chùa, lượt viếng và chùa đi nhiều lần',
                        ),

                        trailing: const Icon(Icons.chevron_right),

                        onTap: _openPilgrimage,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Card(
                      elevation: 0,
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.surface,
                          child: Icon(
                            Icons.local_activity_outlined,
                            color: AppTheme.primary,
                          ),
                        ),
                        title: const Text(
                          'Sổ tem hành hương',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Các dấu ấn được máy chủ xác nhận',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _openStampBook,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Card(
                      elevation: 0,
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.surface,
                          child: Icon(
                            Icons.history_rounded,
                            color: AppTheme.primary,
                          ),
                        ),
                        title: const Text(
                          'Nhật ký hành hương',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text(
                          'Lịch sử các lần viếng đã xác nhận',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _openPilgrimageHistory,
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 22),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'Khám phá & kết nối',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.surface,
                        child: Icon(
                          Icons.explore_outlined,
                          color: AppTheme.primary,
                        ),
                      ),
                      title: const Text(
                        'Khám phá',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Tra cứu chùa và tìm hiểu địa điểm hành hương',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _openExplore,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      enabled: false,
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.surface,
                        child: Icon(
                          Icons.groups_outlined,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      title: const Text(
                        'Cộng đồng',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Chưa có API và hệ thống kiểm duyệt',
                      ),
                      trailing: const Icon(Icons.lock_outline),
                    ),
                  ),
                  if (_token != null) ...[
                    const SizedBox(height: 22),
                    _sectionLabel('Bảo mật'),
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
                          child: Icon(Icons.lock_outline, color: primaryBrown),
                        ),
                        title: const Text(
                          'Đổi mật khẩu',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Thay đổi mật khẩu đăng nhập'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _openChangePassword,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          backgroundColor: Color(0xFFFFE7E7),
                          child: Icon(Icons.logout, color: Colors.red),
                        ),
                        title: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text('Thoát khỏi tài khoản hiện tại'),
                        onTap: _logout,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
