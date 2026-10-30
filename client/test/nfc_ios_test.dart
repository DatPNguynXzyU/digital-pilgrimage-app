import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// Pigeon fixtures exercise the installed plugin's iOS message codec.
// ignore: implementation_imports
import 'package:nfc_manager/src/nfc_manager_ios/pigeon.g.dart' as native;
import 'package:hanh_trinh_an_nhien/services/nfc_platform_support.dart';
import 'package:hanh_trinh_an_nhien/services/nfc_tag_writer.dart';

void main() {
  final messenger =
      TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger;
  const codec = native.HostApiPigeon.pigeonChannelCodec;
  late native.NdefMessagePigeon stored;
  int writes = 0, stops = 0;
  bool denied = false;
  const prefix = 'dev.flutter.pigeon.nfc_manager.HostApiPigeon.';
  void handler(String name, Future<Object?> Function(Object?) callback) =>
      messenger.setMockDecodedMessageHandler<Object?>(
        BasicMessageChannel<Object?>(prefix + name, codec),
        callback,
      );
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    NfcPlatformSupport.iosSessionActive = false;
    writes = 0;
    stops = 0;
    denied = false;
    stored = native.NdefMessagePigeon(records: []);
    handler('tagSessionReadingAvailable', (_) async => [true]);
    handler('tagSessionInvalidate', (_) async {
      stops++;
      return [null];
    });
    handler('ndefReadNdef', (_) async => [stored]);
    handler('ndefWriteNdef', (args) async {
      stored = (args as List)[1] as native.NdefMessagePigeon;
      writes++;
      return [null];
    });
    handler('tagSessionBegin', (args) async {
      if (denied) return ['security', 'Missing required entitlement', null];
      expect(
        (args as List)[2],
        false,
      ); // Retain session through write + readback.
      scheduleMicrotask(() async {
        final tag = native.TagPigeon(
          handle: 'ios-test',
          miFare: native.MiFarePigeon(
            mifareFamily: native.MiFareFamilyPigeon.ultralight,
            identifier: Uint8List.fromList([4, 17, 34, 51, 68, 85, 102]),
          ),
          ndef: native.NdefPigeon(
            status: native.NdefStatusPigeon.readWrite,
            capacity: 496,
          ),
        );
        await messenger.handlePlatformMessage(
          'dev.flutter.pigeon.nfc_manager.FlutterApiPigeon.tagSessionDidDetect',
          codec.encodeMessage([tag]),
          (_) {},
        );
      });
      return [null];
    });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    NfcPlatformSupport.iosSessionActive = false;
  });
  test('iOS reads physical MiFare UID and verifies a write using Core NFC channels', () async {
    expect(NfcPlatformSupport.iosEnabled, isTrue);
    final reader = MobileNfcTagReader();
    final read = await reader.read();
    expect(read.uid, '04112233445566');
    expect(read.capacity, 496);
    final message = templeTagMessage('chua-giac-lam');
    final written = await reader.write(read.uid, message);
    expect(sameNdef(written.message, message), isTrue);
    expect(writes, 1);
    expect(stops, 2);
    expect(NfcPlatformSupport.hasIosSheet, isFalse);
  });
  test(
    'iOS missing signing entitlement stops the session without writing',
    () async {
      denied = true;
      await expectLater(
        MobileNfcTagReader().read(),
        throwsA(isA<PlatformException>()),
      );
      expect(writes, 0);
      expect(stops, 1);
      expect(NfcPlatformSupport.hasIosSheet, isFalse);
    },
  );
}
