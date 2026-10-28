import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String resolveImageUrl(Object? value) {
    final path = value?.toString().trim() ?? '';
    if (path.isEmpty) return '';
    final uri = Uri.tryParse(path);
    if (uri == null) return '';
    if (uri.hasScheme) return path;
    return Uri.parse(baseUrl).resolve(path.startsWith('/') ? path : '/$path').toString();
  }

  static String get baseUrl {
    final customBaseUrl = _customBaseUrl.trim();
    final configuredUrl = customBaseUrl.isNotEmpty
        ? customBaseUrl
        : kIsWeb
        ? 'http://localhost:3000/api'
        : 'http://10.0.2.2:3000/api';
    return configuredUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
