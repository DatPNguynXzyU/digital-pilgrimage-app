import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import 'biometric_lock.dart';
import 'firebase_identity.dart';

import 'package:firebase_auth/firebase_auth.dart' as firebase;

class AuthService {
  AuthService({this.authenticate = BiometricLock.authenticate});
  final Future<bool> Function() authenticate;
  static final profileChanges = ValueNotifier<int>(0);
  static final sessionChanges = ValueNotifier<int>(0);
  static const String _tokenKey = 'auth_token';
  static const rememberedUidKey = 'remembered_firebase_uid';
  static int _sessionEpoch = 0;

  Future<bool> hasRememberedAccount() async =>
      (await SharedPreferences.getInstance()).containsKey(rememberedUidKey);

  /// Opt-in suspension: Firebase SDK retains its own session, while the app
  /// removes its active bearer. Never store a password or copy a refresh token.
  Future<void> rememberAndLogout() async {
    if (kIsWeb || !FirebaseIdentity.configured) {
      throw Exception(
        'Ghi nhớ sinh trắc học cần tài khoản Firebase trên điện thoại.',
      );
    }
    final epoch = _sessionEpoch;
    final token = await getToken();
    final user = (await FirebaseIdentity.auth()).currentUser;
    if (token?.startsWith('firebase:') != true || user == null) {
      throw Exception(
        'Hãy đăng nhập bằng Google hoặc tài khoản Firebase trước.',
      );
    }
    if (!await authenticate()) {
      throw Exception('Chưa xác thực sinh trắc học; chưa đăng xuất.');
    }
    if (_sessionEpoch != epoch) {
      throw Exception('Phiên đã thay đổi. Hãy thử lại.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(rememberedUidKey, user.uid);
    await prefs.remove(_tokenKey);
    _sessionEpoch++;
    await BiometricLock.setEnabled(false);
    sessionChanges.value++;
  }

  Future<void> loginWithBiometrics() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(rememberedUidKey);
    final epoch = _sessionEpoch;
    if (uid == null || kIsWeb) throw Exception('Chưa có tài khoản ghi nhớ.');
    if (!await authenticate()) {
      throw Exception('Chưa xác thực sinh trắc học.');
    }
    if (epoch != _sessionEpoch || prefs.getString(rememberedUidKey) != uid) {
      throw Exception('Tài khoản ghi nhớ đã thay đổi.');
    }
    try {
      final user = (await FirebaseIdentity.auth()).currentUser;
      if (user == null || user.uid != uid) {
        await logout();
        throw Exception(
          'Phiên đã hết hạn. Hãy đăng nhập lại bằng Google hoặc mật khẩu.',
        );
      }
      // _acceptFirebase reloads the user, forces token refresh and asks backend
      // to validate email, revocation and account status before restoring access.
      await _acceptFirebase(user, expectedEpoch: epoch);
    } on firebase.FirebaseAuthException catch (error) {
      if ([
        'user-disabled',
        'user-token-expired',
        'invalid-user-token',
        'user-not-found',
      ].contains(error.code)) {
        await logout();
      }
      throw Exception(FirebaseIdentity.message(error));
    }
  }

  // ==============================
  // ĐĂNG NHẬP
  // ==============================
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await logout();
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 401 && FirebaseIdentity.configured) {
      try {
        return await _acceptFirebase(
          await FirebaseIdentity.password(email, password),
        );
      } catch (error) {
        await FirebaseIdentity.signOut();
        throw Exception(FirebaseIdentity.message(error));
      }
    }
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
    await prefs.remove(rememberedUidKey);
    _sessionEpoch++;
    await BiometricLock.setEnabled(false);
    sessionChanges.value++;
  }

  // ==============================
  // LẤY TOKEN
  // ==============================
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey);
    if (saved?.startsWith('firebase:') == true) {
      final user = (await FirebaseIdentity.auth()).currentUser;
      if (user == null) {
        await invalidateSession(saved!);
        return null;
      }
      try {
        final idToken = await user.getIdToken();
        if (idToken == null) {
          await invalidateSession(saved!);
          return null;
        }
        final token = 'firebase:$idToken';
        // Do not resurrect a session if logout happened while refreshing.
        if (prefs.getString(_tokenKey) != saved) return null;
        await prefs.setString(_tokenKey, token);
        return token;
      } on firebase.FirebaseAuthException catch (error) {
        if ([
          'user-disabled',
          'user-token-expired',
          'invalid-user-token',
        ].contains(error.code)) {
          await invalidateSession(saved!);
        }
        rethrow;
      }
    }
    return saved;
  }

  // ==============================
  // KIỂM TRA ĐĂNG NHẬP
  // ==============================
  Future<bool> isLoggedIn() async {
    // A UI hint only; API access always refreshes and validates the token.
    // Avoid a network request while initializing the biometric lock.
    final token = (await SharedPreferences.getInstance()).getString(_tokenKey);

    return token != null && token.isNotEmpty;
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (FirebaseIdentity.configured) {
      try {
        await FirebaseIdentity.register(fullName, email, password);
        return;
      } catch (error) {
        throw Exception(FirebaseIdentity.message(error));
      }
    }
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
    profileChanges.value++;
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
    profileChanges.value++;
  }

  // ==============================
  // ĐĂNG XUẤT
  // ==============================
  Future<void> logout() async {
    _sessionEpoch++;
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(rememberedUidKey);
    await BiometricLock.setEnabled(false);
    sessionChanges.value++;
    // Clear the app session even if the identity provider is unavailable.
    try {
      await FirebaseIdentity.signOut();
    } catch (_) {}
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    await logout();
    try {
      return await _acceptFirebase(await FirebaseIdentity.google());
    } catch (error) {
      try {
        await FirebaseIdentity.signOut();
      } catch (_) {}
      throw Exception(FirebaseIdentity.message(error));
    }
  }

  Future<Map<String, dynamic>> _acceptFirebase(
    firebase.User user, {
    int? expectedEpoch,
  }) async {
    await user.reload();
    final current = (await FirebaseIdentity.auth()).currentUser!;
    if (!current.emailVerified) {
      throw Exception(
        'Hãy mở email xác nhận (kiểm tra cả thư rác) rồi đăng nhập lại.',
      );
    }
    final idToken = await current.getIdToken(true);
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/firebase'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 ||
        body['success'] != true ||
        body['token'] is! String) {
      throw Exception(body['message'] ?? 'Không thể đăng nhập.');
    }
    if (expectedEpoch != null && expectedEpoch != _sessionEpoch) {
      throw Exception('Phiên đã thay đổi. Hãy đăng nhập lại.');
    }
    await (await SharedPreferences.getInstance()).setString(
      _tokenKey,
      body['token'],
    );
    sessionChanges.value++;
    return body;
  }

  Future<void> resendVerification(String email, String password) async {
    try {
      final user = await FirebaseIdentity.password(email, password);
      if (user.emailVerified) {
        throw Exception('Email đã xác nhận. Bạn có thể đăng nhập.');
      }
      await user.sendEmailVerification();
    } catch (error) {
      throw Exception(FirebaseIdentity.message(error));
    } finally {
      try {
        await FirebaseIdentity.signOut();
      } catch (_) {}
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final stored = (await SharedPreferences.getInstance()).getString(_tokenKey);
    if (stored?.startsWith('firebase:') == true) {
      try {
        final instance = await FirebaseIdentity.auth();
        final user = instance.currentUser;
        if (user == null ||
            !user.providerData.any((p) => p.providerId == 'password')) {
          throw Exception(
            'Tài khoản Google: hãy quản lý mật khẩu trong tài khoản Google.',
          );
        }
        await user.reauthenticateWithCredential(
          firebase.EmailAuthProvider.credential(
            email: user.email!,
            password: currentPassword,
          ),
        );
        final freshToken = await user.getIdToken(true);
        final response = await http.put(
          Uri.parse('${ApiConfig.baseUrl}/auth/firebase/change-password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer firebase:$freshToken',
          },
          body: jsonEncode({'newPassword': newPassword}),
        );
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (response.statusCode != 200) {
          throw Exception(body['message'] ?? 'Không thể đổi mật khẩu.');
        }
        await logout();
        return;
      } catch (error) {
        throw Exception(FirebaseIdentity.message(error));
      }
    }
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
