import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NfcLaunchTag {
  const NfcLaunchTag({this.uid, this.slug, required this.eventId});
  final String? uid;
  final String? slug;
  final String eventId;

  static NfcLaunchTag? fromNative(Object? value) {
    if (value is! Map) return null;
    final uid = value['uid'];
    final eventId = value['eventId'];
    final slug = value['slug'];
    if (slug is String &&
        slug.length <= 150 &&
        RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug) &&
        eventId is String &&
        eventId.isNotEmpty) {
      return NfcLaunchTag(slug: slug, eventId: eventId);
    }
    if (uid is! String ||
        !RegExp(r'^(?:[0-9A-Fa-f]{2}){4,16}$').hasMatch(uid) ||
        eventId is! String ||
        eventId.isEmpty) {
      return null;
    }
    return NfcLaunchTag(uid: uid.toUpperCase(), eventId: eventId);
  }
}

/// Receives Android NFC intents, including taps that cold-started the app.
class NfcLaunchService extends ChangeNotifier {
  static bool managementActive = false;
  static int scanPages = 0;
  static const channel = MethodChannel('hanh_trinh_an_nhien/nfc_launch');
  bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void initialize() {
    if (!supported) return;
    channel.setMethodCallHandler((call) async {
      if (call.method == 'tagAvailable') notifyListeners();
    });
  }

  Future<NfcLaunchTag?> takePendingTag() async {
    if (!supported) return null;
    try {
      return NfcLaunchTag.fromNative(
        await channel.invokeMethod('takePendingTag'),
      );
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  void dispose() {
    if (supported) channel.setMethodCallHandler(null);
    super.dispose();
  }
}
