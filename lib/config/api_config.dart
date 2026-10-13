import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _customBaseUrl =
      String.fromEnvironment(
    'API_BASE_URL',
  );

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    return 'http://10.0.2.2:3000/api';
  }
}