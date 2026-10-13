import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/scripture.dart';

class ScriptureService {
  Future<List<Scripture>> getScriptures() async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/scriptures',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Không thể tải kinh sách',
      );
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body);

    if (json['success'] != true) {
      throw Exception(
        json['message'] ??
            'Không thể tải kinh sách',
      );
    }

    final List<dynamic> data =
        json['data'] ?? [];

    return data
        .map(
          (item) => Scripture.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}