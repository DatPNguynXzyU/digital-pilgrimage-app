import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  // ==============================
  // ĐĂNG NHẬP
  // ==============================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/auth/login',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final Map<String, dynamic> body =
        jsonDecode(response.body);

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Đăng nhập thất bại.',
      );
    }

    final token = body['token']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Backend không trả về JWT token.',
      );
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );

    return body;
  }

  // ==============================
  // LẤY USER HIỆN TẠI
  // ==============================
  Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Bạn chưa đăng nhập.',
      );
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/auth/me',
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final Map<String, dynamic> body =
        jsonDecode(response.body);

    if (response.statusCode != 200 ||
        body['success'] != true) {
      throw Exception(
        body['message'] ??
            'Không thể lấy thông tin tài khoản.',
      );
    }

    return body;
  }

  // ==============================
  // LẤY TOKEN
  // ==============================
  Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey);
  }

  // ==============================
  // KIỂM TRA ĐĂNG NHẬP
  // ==============================
  Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null &&
        token.isNotEmpty;
  }

  // ==============================
  // ĐĂNG XUẤT
  // ==============================
  Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
  }
  Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  final token = await getToken();

  if (token == null || token.isEmpty) {
    throw Exception(
      'Bạn chưa đăng nhập.',
    );
  }

  final uri = Uri.parse(
    '${ApiConfig.baseUrl}/auth/change-password',
  );

  final response = await http.put(
    uri,
    headers: {
      'Content-Type':
          'application/json',
      'Authorization':
          'Bearer $token',
    },
    body: jsonEncode({
      'currentPassword':
          currentPassword,
      'newPassword':
          newPassword,
    }),
  );

  final Map<String, dynamic> body =
      jsonDecode(response.body);

  if (response.statusCode != 200 ||
      body['success'] != true) {
    throw Exception(
      body['message'] ??
          'Không thể đổi mật khẩu.',
    );
  }
}
}