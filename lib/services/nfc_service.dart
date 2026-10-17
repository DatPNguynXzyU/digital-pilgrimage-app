import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class NfcService {
  static final checkIns = ValueNotifier<int>(0);
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> checkIn({
    required String uid,
    required String slug,
  }) async {
    final token = await _authService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Bạn cần đăng nhập trước khi check-in.');
    }

    final normalizedUid = uid
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '')
        .toUpperCase();

    final normalizedSlug = slug.trim().toLowerCase();

    if (normalizedUid.isEmpty) {
      throw Exception('UID NFC không hợp lệ.');
    }

    if (normalizedSlug.isEmpty) {
      throw Exception('Thẻ NFC không chứa thông tin chùa.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/nfc/scan');

    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'uid': normalizedUid, 'slug': normalizedSlug}),
        )
        .timeout(const Duration(seconds: 15));

    Map<String, dynamic> body;

    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Backend trả về dữ liệu không hợp lệ.');
    }

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Check-in NFC thất bại.');
    }

    checkIns.value++;
    return body;
  }
}
