import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class BackendReadiness {
  static bool get enabled =>
      const bool.fromEnvironment('BACKEND_WARMUP') ||
      Uri.parse(ApiConfig.baseUrl).host.endsWith('.onrender.com');

  static Future<void> waitUntilReady() async {
    final deadline = DateTime.now().add(const Duration(seconds: 90));
    while (DateTime.now().isBefore(deadline)) {
      try {
        final response = await http
            .get(Uri.parse('${ApiConfig.baseUrl}/health'))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) return;
      } catch (_) {
        // Retry only this read-only readiness request, never a user mutation.
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    throw Exception(
      'Máy chủ chưa sẵn sàng. Vui lòng kiểm tra mạng và thử lại.',
    );
  }
}
