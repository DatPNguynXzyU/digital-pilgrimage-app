import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_platform_support.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_tag_writer.dart';

void main() {
  test(
    'NFC-disabled sideload build fails clearly before opening native reader',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        if (NfcPlatformSupport.iosEnabled) {
          return; // Also runs in the standard full suite.
        }
        expect(NfcPlatformSupport.disabledIosBuild, isTrue);
        await expectLater(
          MobileNfcTagReader().read(),
          throwsA(
            predicate(
              (error) => error.toString().contains('IOS_NFC_ENABLED=true'),
            ),
          ),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );
}
