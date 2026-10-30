import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseIdentity {
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
  static bool get _isIos =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static const senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const googleClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
  static bool get configured =>
      projectId.isNotEmpty &&
      apiKey.isNotEmpty &&
      (_isIos ? iosAppId : appId).isNotEmpty &&
      senderId.isNotEmpty;
  static Future<FirebaseAuth>? _initialization;
  static Future<void>? _googleInitialization;

  static Future<FirebaseAuth> auth() {
    if (!configured) {
      throw Exception(
        'Chưa cấu hình Firebase. Hãy dùng bản cập nhật đã cấu hình đăng nhập Google.',
      );
    }
    return _initialization ??= _initialize().catchError((Object error) {
      _initialization = null;
      throw error;
    });
  }

  static Future<FirebaseAuth> _initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: apiKey,
          appId: _isIos ? iosAppId : appId,
          iosClientId: _isIos ? iosClientId : null,
          messagingSenderId: senderId,
          projectId: projectId,
        ),
      );
    }
    final instance = FirebaseAuth.instance;
    await instance.setLanguageCode('vi');
    // Wait for native persistence restoration before inspecting currentUser.
    await instance.authStateChanges().first;
    return instance;
  }

  static Future<User> password(String email, String password) async {
    final result = await (await auth()).signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return result.user!;
  }

  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    final instance = await auth();
    final result = await instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await result.user!.updateDisplayName(name.trim());
    try {
      await result.user!.sendEmailVerification();
    } catch (_) {
      throw Exception(
        'Tài khoản đã tạo nhưng chưa gửi được email. Hãy dùng nút Gửi lại email xác nhận trên trang đăng nhập.',
      );
    } finally {
      await instance.signOut();
    }
  }

  static Future<User> google() async {
    final instance = await auth();
    if (kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform)) {
      throw Exception('Đăng nhập Google hỗ trợ Android và iOS.');
    }
    if (_isIos && iosClientId.isEmpty) {
      throw Exception('Chưa cấu hình Google iOS Client ID.');
    }
    if (googleClientId.isEmpty) {
      throw Exception('Chưa cấu hình Google Web Client ID.');
    }
    await (_googleInitialization ??= GoogleSignIn.instance
        .initialize(
          clientId: _isIos ? iosClientId : null,
          serverClientId: googleClientId,
        )
        .catchError((Object error) {
          _googleInitialization = null;
          throw error;
        }));
    final account = await GoogleSignIn.instance.authenticate();
    final token = account.authentication.idToken;
    if (token == null) throw Exception('Google chưa trả về token xác thực.');
    final result = await instance.signInWithCredential(
      GoogleAuthProvider.credential(idToken: token),
    );
    return result.user!;
  }

  static Future<void> signOut() async {
    if (_initialization == null) return;
    await (await auth()).signOut();
    if (_googleInitialization != null) await GoogleSignIn.instance.signOut();
  }

  static Future<void> sendPasswordReset(String email) async {
    try {
      await (await auth()).sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      // Give the same result for unknown addresses to avoid account enumeration.
      if (error.code != 'user-not-found') rethrow;
    }
  }

  static String message(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'email-already-in-use' =>
          'Email đã được đăng ký. Hãy đăng nhập hoặc gửi lại email xác nhận.',
        'invalid-email' => 'Email không hợp lệ.',
        'weak-password' => 'Mật khẩu chưa đủ mạnh.',
        'too-many-requests' =>
          'Bạn đã thử quá nhiều lần. Vui lòng đợi rồi thử lại.',
        'network-request-failed' =>
          'Không kết nối được Google. Hãy kiểm tra mạng.',
        'operation-not-allowed' =>
          'Phương thức đăng nhập chưa được bật trong Firebase.',
        'requires-recent-login' => 'Hãy đăng nhập lại trước khi đổi mật khẩu.',
        'user-disabled' => 'Tài khoản đã bị khóa.',
        _ => 'Không thể xác thực. Hãy kiểm tra email, mật khẩu và thử lại.',
      };
    }
    if (error is GoogleSignInException) {
      return 'Đăng nhập Google chưa hoàn tất. Bạn có thể thử lại.';
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
