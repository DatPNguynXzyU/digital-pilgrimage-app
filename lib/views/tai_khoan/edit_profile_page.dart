import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const Color primaryBrown = AppTheme.primary;

  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  String _originalName = '';
  String _avatarUrl = '';

  Uint8List? _newAvatar;
  String? _avatarFilename;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // =====================================
  // CHUYỂN ĐƯỜNG DẪN ẢNH THÀNH URL
  // =====================================
  String _resolveAvatarUrl(String value) {
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final server = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

    if (value.startsWith('/')) {
      return '$server$value';
    }

    return '$server/$value';
  }

  // =====================================
  // LẤY THÔNG TIN NGƯỜI DÙNG
  // =====================================
  Future<void> _loadProfile() async {
    try {
      final result = await _authService.getMe();

      final data = result['data'];

      final rawUser =
          result['user'] ?? (data is Map ? (data['user'] ?? data) : null);

      if (rawUser is! Map) {
        throw Exception('Không đọc được thông tin tài khoản.');
      }

      final name = rawUser['fullName']?.toString() ?? '';

      final avatar = rawUser['avatar']?.toString() ?? '';

      if (!mounted) return;

      setState(() {
        _originalName = name;
        _nameController.text = name;
        _avatarUrl = _resolveAvatarUrl(avatar);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  // =====================================
  // CHỌN ẢNH
  // =====================================
  Future<void> _pickAvatar() async {
    if (_saving) return;

    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (bytes.length > 2 * 1024 * 1024) {
        _showMessage('Ảnh không được vượt quá 2MB.');
        return;
      }

      if (!mounted) return;

      setState(() {
        _newAvatar = bytes;
        _avatarFilename = image.name;
      });
    } catch (error) {
      if (!mounted) return;

      _showMessage('Không thể chọn ảnh: $error');
    }
  }

  // =====================================
  // LƯU THÔNG TIN
  // =====================================
  Future<void> _saveProfile() async {
    if (_saving) return;

    final fullName = _nameController.text.trim();

    if (fullName.length < 2 || fullName.length > 100) {
      _showMessage('Họ tên phải có từ 2 đến 100 ký tự.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      // Cập nhật tên khi có thay đổi
      if (fullName != _originalName) {
        await _authService.updateProfile(fullName: fullName);

        _originalName = fullName;
      }

      // Upload ảnh khi user chọn ảnh mới
      if (_newAvatar != null && _avatarFilename != null) {
        await _authService.uploadAvatar(
          bytes: _newAvatar!,
          filename: _avatarFilename!,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;

    if (_newAvatar != null) {
      avatarImage = MemoryImage(_newAvatar!);
    } else if (_avatarUrl.isNotEmpty) {
      avatarImage = NetworkImage(_avatarUrl);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,

      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.background,
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  const SizedBox(height: 20),

                  // ẢNH ĐẠI DIỆN
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,

                      children: [
                        CircleAvatar(
                          radius: 58,
                          backgroundColor: AppTheme.surface,

                          backgroundImage: avatarImage,

                          child: avatarImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 65,
                                  color: primaryBrown,
                                )
                              : null,
                        ),

                        CircleAvatar(
                          radius: 20,
                          backgroundColor: primaryBrown,

                          child: IconButton(
                            onPressed: _pickAvatar,
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 19,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Center(
                    child: Text(
                      'Chạm biểu tượng máy ảnh để đổi ảnh',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // HỌ VÀ TÊN
                  TextField(
                    controller: _nameController,

                    decoration: InputDecoration(
                      labelText: 'Họ và tên',

                      prefixIcon: const Icon(Icons.person_outline),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // NÚT LƯU
                  SizedBox(
                    height: 52,

                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _saveProfile,

                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),

                      label: Text(_saving ? 'Đang lưu...' : 'Lưu thay đổi'),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        foregroundColor: Colors.white,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
