import 'package:flutter/foundation.dart';

/// Enables the code path; Apple still enforces the signed NFC entitlement.
class NfcPlatformSupport {
  static bool iosSessionActive = false;
  static bool get hasIosSheet =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.iOS &&
      iosSessionActive;
  static const iosEnabled = bool.fromEnvironment(
    'IOS_NFC_ENABLED',
    defaultValue: !bool.fromEnvironment('IOS_SIDELOAD_BUILD'),
  );
  static bool get disabledIosBuild =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS && !iosEnabled;
  static const disabledMessage =
      'Bản iPhone này chưa bật NFC. Hãy build với '
      'IOS_NFC_ENABLED=true và ký bằng profile có quyền NFC Tag Reading.';
  static String explain(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '');
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return '$text\nNếu iOS báo thiếu quyền hoặc Security Violation, cần ký lại IPA '
          'bằng profile có NFC Tag Reading. Chỉ bật trong app không cấp được quyền NFC.';
    }
    return text;
  }
}
