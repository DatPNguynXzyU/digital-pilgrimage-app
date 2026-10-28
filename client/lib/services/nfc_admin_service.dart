import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class NfcAdminService {
  Future<dynamic> request(String path, {Map<String, dynamic>? body}) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('Vui lòng đăng nhập lại.');
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/nfc/$path');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final response =
        await (body == null
                ? http.get(uri, headers: headers)
                : http.post(uri, headers: headers, body: jsonEncode(body)))
            .timeout(const Duration(seconds: 25));
    if (response.statusCode == 401) {
      await AuthService().invalidateSession(token);
    }
    if (response.statusCode == 404) {
      throw Exception(
        'Máy chủ chưa có API quản trị NFC này. Cần triển khai backend mới lên Render.',
      );
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception(
        'Máy chủ trả về phản hồi không hợp lệ (HTTP ${response.statusCode}). Vui lòng kiểm tra triển khai backend và thử lại.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Dữ liệu thống kê từ máy chủ không hợp lệ.');
    }
    if (response.statusCode >= 400 || decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Không thể tải dữ liệu quản trị.');
    }
    return decoded['data'];
  }
}
