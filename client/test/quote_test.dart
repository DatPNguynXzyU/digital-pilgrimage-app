import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hanh_trinh_an_nhien/models/quote.dart';
import 'package:hanh_trinh_an_nhien/services/quote_service.dart';
import 'package:hanh_trinh_an_nhien/views/trang_chu/home_dhammapada_card.dart';

void main() {
  test('restores original verse lines without replacing edited content', () {
    const verse = Quote(
      code: 'quote-342',
      content: 'Người bị ái buộc ràng, Vùng vẫy và hoảng sợ, Như thỏ bị sa lưới. Họ sanh ái trói buộc, Chịu khổ đau dài dài.',
      source: 'Kinh Pháp Cú',
    );
    expect(verse.displayContent.split('\n'), [
      'Người bị ái buộc ràng,',
      'Vùng vẫy và hoảng sợ,',
      'Như thỏ bị sa lưới.',
      'Họ sanh ái trói buộc,',
      'Chịu khổ đau dài dài.',
    ]);
    const edited = Quote(code: 'quote-342', content: 'Nội dung mới', source: 'Kinh Pháp Cú');
    expect(edited.displayContent, edited.content);
    const multiline = Quote(code: 'quote-342', content: 'Dòng một\nDòng hai');
    expect(multiline.displayContent, multiline.content);
  });
  test('quote service sends exclusion and decodes source', () async {
    final client = MockClient((request) async {
      expect(request.url.path, endsWith('/quotes/random'));
      expect(request.url.queryParameters['exclude'], 'previous');
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {'code': 'next', 'content': 'Nội dung', 'source': 'Kệ 1'},
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final result = await QuoteService(client: client)
        .random(exclude: 'previous');
    expect(result!.source, 'Kệ 1');
    expect(result.content, 'Nội dung');
    client.close();
  });
  test(
    'quote service rejects server errors and accepts empty collection',
    () async {
      final failed = MockClient((_) async => http.Response('unavailable', 503));
      await expectLater(QuoteService(client: failed).random(), throwsException);
      failed.close();
      final empty = MockClient(
        (_) async => http.Response('{"success":true,"data":null}', 200),
      );
      expect(await QuoteService(client: empty).random(), isNull);
      empty.close();
    },
  );
  testWidgets(
    'quote card displays source and excludes current quote on refresh',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeDhammapadaCard(
              loadQuote: (exclude) async {
                expect(exclude, calls == 0 ? null : 'one');
                calls++;
                return Quote(
                  code: calls == 1 ? 'one' : 'two',
                  content: 'Câu $calls',
                  source: 'Kinh Pháp Cú — kệ $calls',
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kinh Pháp Cú — kệ 1'), findsOneWidget);
      await tester.tap(find.text('Câu khác'));
      await tester.pumpAndSettle();
      expect(find.text('Câu 2'), findsOneWidget);
      expect(find.text('Câu 1'), findsNothing);
    },
  );
}
