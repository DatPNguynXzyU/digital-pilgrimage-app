import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/models/temple.dart';

void main() {
  test('parses coordinates from the backend location object', () {
    final temple = Temple.fromJson({
      'name': 'Chùa kiểm thử',
      'location': {'latitude': 10.75, 'longitude': 106.66},
    });

    expect(temple.latitude, 10.75);
    expect(temple.longitude, 106.66);
  });

  test('keeps address navigation available when coordinates are absent', () {
    final temple = Temple.fromJson({
      'name': 'Chùa kiểm thử',
      'address': {
        'street': 'Đường kiểm thử',
        'ward': 'Phường 1',
        'city': 'TP. Hồ Chí Minh',
        'country': 'Việt Nam',
      },
    });

    expect(temple.latitude, isNull);
    expect(temple.longitude, isNull);
    expect(
      temple.fullAddress,
      'Đường kiểm thử, Phường 1, TP. Hồ Chí Minh, Việt Nam',
    );
  });
}
