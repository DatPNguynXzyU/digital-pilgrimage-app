import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _customBaseUrl = String.fromEnvironment('API_BASE_URL');

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
