import 'package:flutter_test/flutter_test.dart';
import 'package:hanh_trinh_an_nhien/config/api_config.dart';

void main() {
  test('Seed image paths resolve against server origin, not /api', () {
    final origin = Uri.parse(ApiConfig.baseUrl).origin;
    expect(ApiConfig.resolveImageUrl('/img/chua/a.png'), '$origin/img/chua/a.png');
    expect(ApiConfig.resolveImageUrl('img/chua/a.png'), '$origin/img/chua/a.png');
    expect(ApiConfig.resolveImageUrl('https://example.com/a.png'), 'https://example.com/a.png');
    expect(ApiConfig.resolveImageUrl(null), '');
    expect(ApiConfig.resolveImageUrl('  '), '');
  });
}
