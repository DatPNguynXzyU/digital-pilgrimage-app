import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../services/auth_service.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key});
  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  String? _url;
  int _request = 0;
  @override
  void initState() {
    super.initState();
    AuthService.sessionChanges.addListener(_reload);
    AuthService.profileChanges.addListener(_reload);
    _reload();
  }

  Future<void> _reload() async {
    final request = ++_request;
    if (mounted) setState(() => _url = null);
    try {
      final auth = AuthService();
      if (await auth.getToken() == null) return;
      final data = await auth.getMe();
      final user = data['user'] as Map<String, dynamic>;
      final avatar = user['avatar']?.toString().trim() ?? '';
      if (!mounted || request != _request || avatar.isEmpty) return;
      final uri = Uri.parse(ApiConfig.baseUrl).resolve(
        avatar.startsWith('http') || avatar.startsWith('/')
            ? avatar
            : '/$avatar',
      );
      setState(
        () => _url = uri
            .replace(
              queryParameters: {
                ...uri.queryParameters,
                if (user['updatedAt'] != null)
                  'v': user['updatedAt'].toString(),
              },
            )
            .toString(),
      );
    } catch (_) {
      // Keep the placeholder when the profile or image is unavailable.
    }
  }

  @override
  void dispose() {
    _request++;
    AuthService.sessionChanges.removeListener(_reload);
    AuthService.profileChanges.removeListener(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(
      Icons.person_outline_rounded,
      color: AppTheme.primary,
    );
    return ClipOval(
      child: _url == null
          ? fallback
          : Image.network(
              _url!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stack) => fallback,
            ),
    );
  }
}
