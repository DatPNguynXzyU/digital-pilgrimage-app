import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/quote.dart';

class QuoteService {
  final http.Client? client;
  QuoteService({this.client});

  Future<Quote?> random({String? exclude}) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/quotes/random',
    ).replace(queryParameters: exclude == null ? null : {'exclude': exclude});
    final transport = client ?? http.Client();
    try {
      final response = await transport
          .get(uri)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw Exception('Không thể tải câu Phật ngôn.');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception('Không thể tải câu Phật ngôn.');
      }
      return body['data'] == null
          ? null
          : Quote.fromJson(body['data'] as Map<String, dynamic>);
    } finally {
      if (client == null) transport.close();
    }
  }
}
