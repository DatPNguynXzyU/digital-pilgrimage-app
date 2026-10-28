import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/services/pilgrimage_favorites_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('toggles and persists favorite temple IDs locally', () async {
    SharedPreferences.setMockInitialValues({});
    final store = PilgrimageFavoritesStore();

    expect(await store.toggle('temple-1'), isTrue);
    expect(await store.load(), {'temple-1'});

    expect(await store.toggle('temple-1'), isFalse);
    expect(await store.load(), isEmpty);
  });

  test('rejects an empty temple ID', () async {
    SharedPreferences.setMockInitialValues({});
    final store = PilgrimageFavoritesStore();

    await expectLater(store.toggle(''), throwsArgumentError);
  });
}
