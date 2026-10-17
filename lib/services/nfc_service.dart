import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class NfcService {
  final AuthService _authService = AuthService();

  // ==========================================
  // CHUẨN HÓA UID
  // ==========================================
  String normalizeUid(String uid) {
    return uid.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toUpperCase();
  }

  // ==========================================
  // TRA CỨU CHÙA TỪ UID THẺ NFC (KHÔNG CẦN ĐĂNG NHẬP)
  // ==========================================
  Future<Map<String, dynamic>> getTempleByUid(String uid) async {
    final normalizedUid = normalizeUid(uid);

    if (normalizedUid.isEmpty) {
      throw Exception('UID NFC không hợp lệ.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/nfc/temple/$normalizedUid');

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    late final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Backend trả về dữ liệu không hợp lệ.');
    }

    if (response.statusCode != 200 || body['success'] != true) {
      final msg = body['message']?.toString() ??
          'Thẻ NFC chưa được liên kết với chùa nào.';
      throw Exception(msg);
    }

    return body;
  }

  // ==========================================
  // CHECK-IN THẺ NFC (YÊU CẦU ĐĂNG NHẬP)
  // Slug và templeId là tùy chọn. Nếu chỉ có UID,
  // backend sẽ tự tìm chùa đã liên kết với UID này.
  // ==========================================
  Future<Map<String, dynamic>> checkIn({
    required String uid,
    String? slug,
    String? templeId,
  }) async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Bạn cần đăng nhập trước khi check-in.');
    }

    final normalizedUid = normalizeUid(uid);
    final normalizedSlug = slug?.trim().toLowerCase();

    if (normalizedUid.isEmpty) {
      throw Exception('UID NFC không hợp lệ.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/nfc/scan');

    final requestBody = <String, dynamic>{
      'uid': normalizedUid,
    };

    if (normalizedSlug != null && normalizedSlug.isNotEmpty) {
      requestBody['slug'] = normalizedSlug;
    }

    if (templeId != null && templeId.trim().isNotEmpty) {
      requestBody['templeId'] = templeId.trim();
    }

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    late final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Backend trả về dữ liệu không hợp lệ.');
    }

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(
        body['message']?.toString() ?? 'Check-in NFC thất bại.',
      );
    }

    return body;
  }

  // ==========================================
  // LIÊN KẾT THẺ NFC VỚI CHÙA (YÊU CẦU ĐĂNG NHẬP)
  // ==========================================
  Future<Map<String, dynamic>> bindTag({
    required String uid,
    required String templeId,
    String? label,
  }) async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Bạn cần đăng nhập để liên kết thẻ NFC.');
    }

    final normalizedUid = normalizeUid(uid);

    if (normalizedUid.isEmpty) {
      throw Exception('UID NFC không hợp lệ.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/nfc/bind');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'uid': normalizedUid,
        'templeId': templeId.trim(),
        if (label != null && label.trim().isNotEmpty) 'label': label.trim(),
      }),
    );

    late final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Backend trả về dữ liệu không hợp lệ.');
    }

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(
        body['message']?.toString() ?? 'Không thể liên kết thẻ NFC.',
      );
    }

    return body;
  }
}