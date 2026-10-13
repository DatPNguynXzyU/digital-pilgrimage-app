import 'dart:convert';

import 'package:apptungkinh/models/visited_temple.dart';
import 'package:http/http.dart'
    as http;

import '../config/api_config.dart';
import '../models/pilgrimage_stats.dart';
import '../models/visited_temple.dart';

class PilgrimageService {
  Map<String, String> _headers(
    String token,
  ) {
    return {
      'Content-Type':
          'application/json',

      'Authorization':
          'Bearer $token',
    };
  }

  // =====================================
  // THỐNG KÊ
  // =====================================
  Future<PilgrimageStats> getStats(
    String token,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/pilgrimage/stats',
    );

    final response = await http.get(
      uri,
      headers: _headers(token),
    );

    final body =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ??
            'Không thể tải thống kê.',
      );
    }

    return PilgrimageStats.fromJson(
      body['data']
          as Map<String, dynamic>,
    );
  }

  // =====================================
  // CHÙA ĐÃ ĐI
  // =====================================
  Future<List<VisitedTemple>>
      getVisitedTemples(
    String token, {
    String sort = 'most_visited',
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}'
      '/pilgrimage/temples',
    ).replace(
      queryParameters: {
        'sort': sort,
      },
    );

    final response = await http.get(
      uri,
      headers: _headers(token),
    );

    final body =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ??
            'Không thể tải danh sách chùa.',
      );
    }

    final List<dynamic> data =
        body['data'] ?? [];

    return data
        .map(
          (item) =>
              VisitedTemple.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}