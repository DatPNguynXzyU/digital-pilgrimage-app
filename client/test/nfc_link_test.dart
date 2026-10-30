import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_launch_service.dart';

void main() {
  test('URL navigation never accepts a UID supplied alongside a slug', () {
    final link = NfcLaunchTag.fromNative({'slug': 'chua-giac-lam', 'uid': '04112233', 'eventId': 'tap'});
    expect(link?.slug, 'chua-giac-lam');
    expect(link?.uid, isNull);
  });
  test('malformed link slugs cannot navigate', () {
    for (final slug in ['../auth', '', 'https://example.com', 'chua?a=b']) {
      expect(NfcLaunchTag.fromNative({'slug': slug, 'eventId': 'tap'}), isNull);
    }
  });
}
