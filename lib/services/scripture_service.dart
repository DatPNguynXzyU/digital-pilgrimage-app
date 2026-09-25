import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart'
    as http;

import '../models/scripture.dart';

class ScriptureService {
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    return 'http://10.0.2.2:3000/api';
  }

  Future<List<Scripture>>
      getScriptures() async {
    final response =
        await http.get(
      Uri.parse(
        '$baseUrl/scriptures',
      ),
    );

    if (response.statusCode !=
        200) {
      throw Exception(
        'Không thể tải kinh sách',
      );
    }

    final Map<String, dynamic>
        json =
        jsonDecode(
      response.body,
    );

    final List<dynamic> data =
        json['data'] ?? [];

    return data
        .map(
          (item) =>
              Scripture.fromJson(
            item,
          ),
        )
        .toList();
  }
}