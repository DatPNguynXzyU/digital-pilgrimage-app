import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';

class AuthService {
  static final sessionChanges = ValueNotifier<int>(0);
  static const String _tokenKey = 'auth_token';

  // ==============================
  // ĐĂNG NHẬP
  // ==============================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Đăng nhập thất bại.');
    }

    final token = body['token']?.toString();

    if (token == null || token.isEmpty) {
      throw Exception('Backend không trả về JWT token.');
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);

    sessionChanges.value++;
    return body;
  }

  // ==============================
  // LẤY USER HIỆN TẠI
  // ==============================
  Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/me');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 401) {
      await invalidateSession(token);
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }
    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Không thể lấy thông tin tài khoản.');
    }

    return body;
  }

  // Only invalidate the session that produced the unauthorized response.
  Future<void> invalidateSession(String rejectedToken) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_tokenKey) != rejectedToken) return;
    await prefs.remove(_tokenKey);
    sessionChanges.value++;
  }

  // ==============================
  // LẤY TOKEN
  // ==============================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey);
  }

  // ==============================
  // KIỂM TRA ĐĂNG NHẬP
  // ==============================
  Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/register');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if ((response.statusCode != 200 && response.statusCode != 201) ||
        body['success'] != true) {
      throw Exception(
        body['message']?.toString() ?? 'Đăng ký tài khoản thất bại.',
      );
    }
  }

  // =====================================
  // CẬP NHẬT HỌ TÊN
  // =====================================
  Future<void> updateProfile({required String fullName}) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/profile');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'fullName': fullName.trim()}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Không thể cập nhật hồ sơ.');
    }
  }

  // =====================================
  // UPLOAD ẢNH ĐẠI DIỆN
  // =====================================
  Future<void> uploadAvatar({
    required Uint8List bytes,
    required String filename,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    final lowerName = filename.toLowerCase();

    String subtype;

    if (lowerName.endsWith('.png')) {
      subtype = 'png';
    } else if (lowerName.endsWith('.webp')) {
      subtype = 'webp';
    } else if (lowerName.endsWith('.jpg') || lowerName.endsWith('.jpeg')) {
      subtype = 'jpeg';
    } else {
      throw Exception('Chỉ hỗ trợ ảnh JPG, PNG hoặc WEBP.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/avatar');

    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes(
        'avatar',
        bytes,
        filename: filename,
        contentType: MediaType('image', subtype),
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Không thể cập nhật ảnh đại diện.');
    }
  }

  // ==============================
  // ĐĂNG XUẤT
  // ==============================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    sessionChanges.value++;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/change-password');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode != 200 || body['success'] != true) {
      throw Exception(body['message'] ?? 'Không thể đổi mật khẩu.');
    }
    await logout();
  }
}
