import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../config/api_config.dart';
import '../models/buddhist_figure.dart';

class BuddhistFigureService {
  Future<List<BuddhistFigure>>
      getFigures({
    String? search,
    String? category,
    String sort = 'name_asc',
  }) async {
    final queryParameters =
        <String, String>{
      'sort': sort,
    };

    if (search != null &&
        search.trim().isNotEmpty) {
      queryParameters['search'] =
          search.trim();
    }

    if (category != null &&
        category.trim().isNotEmpty &&
        category != 'all') {
      queryParameters['category'] =
          category.trim();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/buddhist-figures',
    ).replace(
      queryParameters:
          queryParameters,
    );

    final response =
        await http.get(uri);

    final Map<String, dynamic> body =
        jsonDecode(response.body);

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ??
            'Không thể tải dữ liệu.',
      );
    }

    final List<dynamic> data =
        body['data'] ?? [];

    return data
        .map(
          (item) =>
              BuddhistFigure.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<BuddhistFigure>
      getFigureBySlug(
    String slug,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}'
      '/buddhist-figures/$slug',
    );

    final response =
        await http.get(uri);

    final Map<String, dynamic> body =
        jsonDecode(response.body);

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ??
            'Không tìm thấy dữ liệu.',
      );
    }

    return BuddhistFigure.fromJson(
      body['data']
          as Map<String, dynamic>,
    );
  }
}