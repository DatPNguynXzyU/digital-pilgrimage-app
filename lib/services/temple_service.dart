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
    final query = <String, String>{
      'sort': sort,
    };

    if (search != null &&
        search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/temples',
    ).replace(
      queryParameters: query,
    );

    final response = await http.get(uri);

    final body = jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ??
            'Không thể tải danh sách chùa.',
      );
    }

    final data =
        body['data'] as List? ?? [];

    return data
        .map(
          (item) => Temple.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // ==========================================
  // LẤY CHI TIẾT CHÙA THEO SLUG
  // ==========================================
  Future<Temple> getTempleBySlug(
    String slug,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/temples/$slug',
    );

    final response = await http.get(uri);

    final body = jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ??
            'Không tìm thấy chùa.',
      );
    }

    return Temple.fromJson(
      body['data']
          as Map<String, dynamic>,
    );
  }
}