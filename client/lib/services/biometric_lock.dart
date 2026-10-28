import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An optional local app lock. Server authentication still uses the existing
/// session, including its expiry and revocation rules.
class BiometricLock {
  static const preferenceKey = 'biometric_lock_enabled';
  static final changes = ValueNotifier<int>(0);
  static final _auth = LocalAuthentication();
  static bool authenticating = false;

  static Future<bool> enabled() async =>
      (await SharedPreferences.getInstance()).getBool(preferenceKey) ?? false;

  static Future<bool> authenticate() async {
    if (authenticating || kIsWeb) return false;
    authenticating = true;
    try {
      if ((await _auth.getAvailableBiometrics()).isEmpty) return false;
      return await _auth.authenticate(
        localizedReason: 'Xác thực để mở Hành trình an nhiên',
        biometricOnly: true,
      );
    } finally {
      authenticating = false;
    }
  }

  static Future<void> setEnabled(bool value) async {
    await (await SharedPreferences.getInstance()).setBool(preferenceKey, value);
    changes.value++;
  }
}
