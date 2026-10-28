import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_tag_writer.dart';

class MemoryNdef implements Ndef {
  @override
  bool isWritable = true;
  @override
  int maxSize = 496;
  int writes = 0;
  bool corrupt = false;
  NdefMessage? stored;
  @override
  Map<String, dynamic> get additionalData => {};
  @override
  NdefMessage? get cachedMessage => stored;
  @override
  Future<NdefMessage?> read() async => corrupt ? null : stored;
  @override
  Future<void> write({required NdefMessage message}) async {
    writes++;
    stored = message;
  }

  @override
  Future<void> writeLock() async => throw StateError('Must not lock a tag');
}

void main() {
  final message = templeTagMessage('chua-giac-lam');
  test('temple NDEF fits NTAG215 and carries app opening records', () {
    expect(message.byteLength, lessThan(496));
    expect(jsonDecode(utf8.decode(message.records.first.payload)), {
      'type': 'temple',
      'slug': 'chua-giac-lam',
    });
    expect(
      utf8.decode(message.records.last.payload),
      'com.example.apptungkinh',
    );
    expect(sameNdef(NdefMessage.decode(message.encode()), message), isTrue);
  });
  test('wrong UID, locked card, insufficient capacity and cancellation never write', () async {
    for (var scenario = 0; scenario < 4; scenario++) {
      final ndef = MemoryNdef();
      if (scenario == 1) ndef.isWritable = false;
      if (scenario == 2) ndef.maxSize = 10;
      await expectLater(
        writeVerifiedNdef(
          ndef: ndef,
          uid: '04AB0102',
          expectedUid: scenario == 0 ? '04AB0103' : '04AB0102',
          message: message,
          cancelled: () => scenario == 3,
        ),
        throwsException,
      );
      expect(ndef.writes, 0);
    }
  });
  test('readback required after write and corrupt readback fails', () async {
    final ndef = MemoryNdef();
    expect(
      sameNdef(
        await writeVerifiedNdef(
          ndef: ndef,
          uid: '04AB0102',
          expectedUid: '04AB0102',
          message: message,
        ),
        message,
      ),
      isTrue,
    );
    ndef.corrupt = true;
    await expectLater(
      writeVerifiedNdef(
        ndef: ndef,
        uid: '04AB0102',
        expectedUid: '04AB0102',
        message: message,
      ),
      throwsException,
    );
  });
}
