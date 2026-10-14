import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/temple.dart';

class TempleService {
  // ==========================================
  // LẤY DANH SÁCH CHÙA
  // ==========================================
  Future<List<Temple>> getTemples({
    String sort = 'name_asc',
    String? search,
  }) async {
    final query = <String, String>{'sort': sort};

    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/temples')
        .replace(queryParameters: query);

    final response = await _get(uri);

    late final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw Exception(
        response.statusCode == 200
            ? 'Backend trả về dữ liệu chùa không hợp lệ.'
            : 'Không thể tải danh sách chùa '
                  '(mã HTTP ${response.statusCode}).',
      );
    }

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Không thể tải danh sách chùa.');
    }

    final data = body['data'] as List? ?? [];

    return data
        .map((item) => Temple.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      return await http.get(uri).timeout(const Duration(seconds: 15));
    } on http.ClientException {
      throw Exception(
        'Không kết nối được máy chủ tại ${ApiConfig.baseUrl}. '
        'Hãy kiểm tra backend đang chạy và địa chỉ API phù hợp với thiết bị.',
      );
    } on TimeoutException {
      throw Exception(
        'Máy chủ tại ${ApiConfig.baseUrl} không phản hồi sau 15 giây. '
        'Hãy kiểm tra backend và kết nối mạng.',
      );
    }
  }

  // ==========================================
  // LẤY CHI TIẾT CHÙA THEO SLUG
  // ==========================================
  Future<Temple> getTempleBySlug(String slug) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/temples/$slug');

    final response = await _get(uri);

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Không tìm thấy chùa.');
    }

    return Temple.fromJson(body['data'] as Map<String, dynamic>);
  }
}
