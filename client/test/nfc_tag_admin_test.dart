import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_tag_writer.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_admin_service.dart';
import 'package:hanh_trinh_an_nhien/views/admin/nfc_tag_admin_page.dart';

class Reader extends Fake implements NfcTagReader {
  int reads = 0, writes = 0;
  NdefMessage? stored;
  @override
  Future<NfcTagSnapshot> read() async {
    reads++;
    return snapshot();
  }

  NfcTagSnapshot snapshot() => NfcTagSnapshot(
    uid: '04112233445566',
    ndefSupported: true,
    writable: true,
    capacity: 496,
    message: stored,
  );
  @override
  Future<NfcTagSnapshot> write(String expectedUid, NdefMessage message) async {
    expect(expectedUid, '04112233445566');
    writes++;
    stored = message;
    return snapshot();
  }

  @override
  Future<void> cancel() async {}
}

class Api extends NfcAdminService {
  bool deny = false, conflict = false, failLink = false, registered = false;
  int links = 0;
  @override
  Future<dynamic> request(String path, {Map<String, dynamic>? body}) async {
    if (deny) throw Exception('Chỉ quản trị viên được quản lý NFC.');
    if (path == 'temples') {
      return [
        {
          '_id': 'temple1',
          'name': 'Chùa thử',
          'slug': 'chua-thu',
          'status': 'active',
        },
      ];
    }
    if (path == 'tags') {
      links++;
      if (failLink) throw Exception('Mất mạng');
      registered = true;
      return {};
    }
    return {
      'tag': conflict || registered
          ? {
              'templeId': {
                '_id': conflict ? 'other' : 'temple1',
                'name': 'Chùa thử',
              },
              'status': 'active',
            }
          : null,
    };
  }
}

Future<void> prepare(WidgetTester tester, Reader reader, Api api) async {
  await tester.pumpWidget(
    MaterialApp(
      home: NfcTagAdminPage(reader: reader, service: api),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Đọc thẻ'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.byType(DropdownButton<String>),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.byType(DropdownButton<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Chùa thử').last);
  await tester.pumpAndSettle();
}

Future<void> write(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Ghi và liên kết thẻ'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text('Ghi và liên kết thẻ'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Xác nhận'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('denied role never starts NFC', (tester) async {
    final reader = Reader(), api = Api()..deny = true;
    await tester.pumpWidget(
      MaterialApp(
        home: NfcTagAdminPage(reader: reader, service: api),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Đọc thẻ'), findsNothing);
    expect(reader.reads, 0);
    expect(reader.writes, 0);
  });
  testWidgets('conflicting temple prevents physical write', (tester) async {
    final reader = Reader(), api = Api()..conflict = true;
    await prepare(tester, reader, api);
    await write(tester);
    expect(reader.writes, 0);
    expect(api.links, 0);
  });
  testWidgets(
    'verified write links UID; network failure retries with readback only',
    (tester) async {
      final reader = Reader(), api = Api()..failLink = true;
      await prepare(tester, reader, api);
      await write(tester);
      expect(reader.writes, 1);
      expect(api.links, 1);
      api.failLink = false;
      await tester.scrollUntilVisible(
        find.text('Thử liên kết lại (chạm thẻ)'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(
        find.ancestor(
          of: find.text('Thử liên kết lại (chạm thẻ)'),
          matching: find.byType(OutlinedButton),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thử liên kết lại (chạm thẻ)'));
      await tester.pumpAndSettle();
      expect(reader.reads, 2);
      expect(reader.writes, 1);
      expect(api.links, 2);
      expect(api.registered, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
