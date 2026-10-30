import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

import 'nfc_platform_support.dart';

class NfcTagSnapshot {
  final String uid;
  final List<String> technologies;
  final bool ndefSupported, writable;
  final int capacity;
  final NdefMessage? message;
  const NfcTagSnapshot({
    required this.uid,
    this.technologies = const [],
    required this.ndefSupported,
    required this.writable,
    required this.capacity,
    this.message,
  });
  String get contents {
    if (!ndefSupported) return 'Thẻ chưa hỗ trợ hoặc chưa được định dạng NDEF.';
    if (message == null || message!.records.isEmpty) {
      return 'Thẻ chưa có nội dung NDEF.';
    }
    return message!.records
        .map((r) {
          final type = utf8.decode(r.type, allowMalformed: true);
          var payload = r.payload;
          if (r.typeNameFormat == TypeNameFormat.wellKnown &&
              type == 'T' &&
              payload.isNotEmpty) {
            final offset = 1 + (payload.first & 0x3f);
            if (offset <= payload.length && (payload.first & 0x80) == 0) {
              payload = payload.sublist(offset);
            }
          }
          return '$type\n${utf8.decode(payload, allowMalformed: true)}';
        })
        .join('\n\n');
  }
}

abstract interface class NfcTagReader {
  Future<NfcTagSnapshot> read();
  Future<NfcTagSnapshot> write(String expectedUid, NdefMessage message);
  Future<void> cancel();
}

NdefMessage templeTagMessage(String slug) {
  if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug)) {
    throw Exception('Slug chùa không hợp lệ.');
  }
  Uint8List bytes(String value) => Uint8List.fromList(utf8.encode(value));
  return NdefMessage(
    records: [
      NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: bytes('U'),
        identifier: Uint8List(0),
        payload: Uint8List.fromList([
          4,
          ...bytes(
            'hanh-trinh-an-nhien-app.starryflute8194.chatgpt.site/nfc/?temple=$slug',
          ),
        ]),
      ),
      NdefRecord(
        typeNameFormat: TypeNameFormat.media,
        type: bytes('application/vnd.hanhtrinhannhien.temple'),
        identifier: Uint8List(0),
        payload: bytes(jsonEncode({'type': 'temple', 'slug': slug})),
      ),
    ],
  );
}

bool sameNdef(NdefMessage? a, NdefMessage b) =>
    a != null && listEquals(a.encode(), b.encode());

Future<NdefMessage> writeVerifiedNdef({
  required Ndef? ndef,
  required String uid,
  required String expectedUid,
  required NdefMessage message,
  bool Function()? cancelled,
}) async {
  if (uid != expectedUid) {
    throw Exception('Bạn chạm nhầm thẻ. UID khác thẻ đã đọc; chưa ghi.');
  }
  if (ndef == null) {
    throw Exception(
      'Thẻ chưa hỗ trợ/định dạng NDEF. Hãy dùng thẻ NTAG215 đã định dạng NDEF.',
    );
  }
  if (!ndef.isWritable) throw Exception('Thẻ bị khóa hoặc không cho phép ghi.');
  if (message.byteLength > ndef.maxSize) {
    throw Exception(
      'Nội dung ${message.byteLength} byte vượt dung lượng ${ndef.maxSize} byte của thẻ.',
    );
  }
  if (cancelled?.call() == true) throw Exception('Đã hủy trước khi ghi.');
  await ndef.write(message: message);
  final current = await ndef.read();
  if (!sameNdef(current, message)) {
    throw Exception(
      'Đã thử ghi nhưng đọc lại không khớp. Chưa liên kết máy chủ; hãy đọc thẻ và thử lại.',
    );
  }
  return current!;
}

class MobileNfcTagReader implements NfcTagReader {
  Completer<NfcTagSnapshot>? _pending;
  bool _handling = false;
  Timer? _timer;
  bool _sessionOpen = false;
  Future<NfcTagSnapshot> _scan({
    String? expectedUid,
    NdefMessage? message,
  }) async {
    if (kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform)) {
      throw Exception('Đọc/ghi thẻ cần điện thoại Android hoặc iPhone có NFC.');
    }
    if (NfcPlatformSupport.disabledIosBuild) {
      throw Exception(NfcPlatformSupport.disabledMessage);
    }
    if (_pending != null) throw Exception('Đang có phiên NFC khác.');
    final result = Completer<NfcTagSnapshot>();
    // Cancellation can happen while availability/startSession is still awaited.
    unawaited(
      result.future.then<void>((_) {}, onError: (Object _, StackTrace _) {}),
    );
    _pending = result;
    try {
      if (await NfcManager.instance.checkAvailability() !=
          NfcAvailability.enabled) {
        throw Exception(
          defaultTargetPlatform == TargetPlatform.iOS
              ? 'iPhone chưa cung cấp NFC cho bản cài này. Hãy kiểm tra thiết bị và profile NFC Tag Reading.'
              : 'Hãy bật NFC trên điện thoại.',
        );
      }
      if (_pending != result || result.isCompleted) {
        throw Exception('Đã hủy phiên NFC.');
      }
      _timer = Timer(const Duration(seconds: 45), () {
        cancel();
      });
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        NfcPlatformSupport.iosSessionActive = true;
      }
      _sessionOpen = true;
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443},
        alertMessageIos: message == null
            ? 'Đưa thẻ NFC sát phần trên của iPhone để đọc.'
            : 'Giữ đúng thẻ sát phần trên của iPhone để ghi và kiểm tra.',
        invalidateAfterFirstReadIos: false,
        onSessionErrorIos: (error) {
          if (!result.isCompleted) {
            result.completeError(
              Exception('iOS đã kết thúc phiên NFC (${error.code.name}).'),
            );
          }
        },
        onDiscovered: (tag) async {
          if (_handling || _pending != result || result.isCompleted) return;
          _handling = true;
          try {
            final ios = defaultTargetPlatform == TargetPlatform.iOS;
            final native = ios ? null : NfcTagAndroid.from(tag);
            final miFare = ios ? MiFareIos.from(tag) : null;
            final iso7816 = ios ? Iso7816Ios.from(tag) : null;
            final identifier = ios
                ? miFare?.identifier ?? iso7816?.identifier
                : native?.id;
            if (identifier == null || identifier.isEmpty) {
              throw Exception('Không đọc được UID vật lý.');
            }
            final uid = identifier
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join()
                .toUpperCase();
            final ndef = Ndef.from(tag);
            final current = message == null
                ? await ndef?.read()
                : await writeVerifiedNdef(
                    ndef: ndef,
                    uid: uid,
                    expectedUid: expectedUid!,
                    message: message,
                    cancelled: () => _pending != result || result.isCompleted,
                  );
            if (!result.isCompleted) {
              result.complete(
                NfcTagSnapshot(
                  uid: uid,
                  technologies:
                      native?.techList ??
                      [
                        if (miFare != null)
                          'MiFare ${miFare.mifareFamily.name}',
                        if (iso7816 != null) 'ISO 7816',
                      ],
                  ndefSupported: ndef != null,
                  writable: ndef?.isWritable ?? false,
                  capacity: ndef?.maxSize ?? 0,
                  message: current,
                ),
              );
            }
          } catch (error, stack) {
            if (!result.isCompleted) result.completeError(error, stack);
          } finally {
            _handling = false;
          }
        },
      );
      return await result.future;
    } finally {
      NfcPlatformSupport.iosSessionActive = false;
      _timer?.cancel();
      // Keep Android reader mode while the admin edits the form. Releasing it
      // immediately redispatches the URL on a card still held against the phone.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          await NfcManager.instance.stopSession();
        } catch (_) {}
        _sessionOpen = false;
      }
      if (_pending == result) _pending = null;
    }
  }

  @override
  Future<NfcTagSnapshot> read() => _scan();
  @override
  Future<NfcTagSnapshot> write(String expectedUid, NdefMessage message) =>
      _scan(expectedUid: expectedUid, message: message);
  @override
  Future<void> cancel() async {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(Exception('Phiên NFC đã hủy hoặc hết thời gian.'));
    }
    if (_sessionOpen) {
      _sessionOpen = false;
      try {
        await NfcManager.instance.stopSession();
      } catch (_) {}
    }
  }
}
