import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

import '../../services/nfc_service.dart';

class NfcScanPage extends StatefulWidget {
  const NfcScanPage({
    super.key,
  });

  @override
  State<NfcScanPage> createState() =>
      _NfcScanPageState();
}

class _NfcScanPageState
    extends State<NfcScanPage> {
  static const Color primaryBrown =
      Color(0xFFA56A12);

  final NfcService _nfcService =
      NfcService();

  bool _scanning = false;
  bool _processing = false;

  String _status =
      'Nhấn nút bên dưới để bắt đầu quét NFC.';

  String? _uid;
  String? _ndefName;
  String? _ndefSlug;

  String? _templeName;

  int? _visitCount;

  bool _newStamp = false;

  // ==========================================
  // CHUYỂN UID BYTE -> HEX
  // ==========================================
  String _bytesToHex(
    Uint8List bytes,
  ) {
    return bytes
        .map(
          (byte) => byte
              .toRadixString(16)
              .padLeft(2, '0'),
        )
        .join()
        .toUpperCase();
  }

  // ==========================================
  // ĐỌC TEXT RECORD CỦA NDEF
  // ==========================================
  String? _decodeTextRecord(
    Uint8List payload,
  ) {
    if (payload.isEmpty) {
      return null;
    }

    try {
      // Byte đầu tiên:
      // chứa độ dài language code.
      final languageLength =
          payload[0] & 0x3F;

      final textStart =
          1 + languageLength;

      if (textStart >=
          payload.length) {
        return null;
      }

      return utf8.decode(
        payload.sublist(
          textStart,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // ĐỌC JSON TỪ NDEF
  // ==========================================
  Map<String, dynamic>?
      _readTempleData(
    NfcTag tag,
  ) {
    final ndef =
        Ndef.from(tag);

    if (ndef == null) {
      return null;
    }

    // cachedMessage được đọc khi tag
    // vừa được phát hiện.
    final message =
        ndef.cachedMessage;

    if (message == null ||
        message.records.isEmpty) {
      return null;
    }

    for (final record
        in message.records) {
      final text =
          _decodeTextRecord(
        record.payload,
      );

      if (text == null ||
          text.isEmpty) {
        continue;
      }

      try {
        final decoded =
            jsonDecode(text);

        if (decoded
            is! Map<String, dynamic>) {
          continue;
        }

        if (decoded['type'] !=
            'temple') {
          continue;
        }

        final slug =
            decoded['slug']
                ?.toString()
                .trim();

        if (slug == null ||
            slug.isEmpty) {
          continue;
        }

        return decoded;
      } catch (_) {
        // Record này không phải
        // JSON của ứng dụng.
      }
    }

    return null;
  }

  // ==========================================
  // START NFC
  // ==========================================
  Future<void> _startScan()
      async {
    if (kIsWeb ||
        defaultTargetPlatform !=
            TargetPlatform.android) {
      _showMessage(
        'Hãy chạy chức năng NFC trên điện thoại Android.',
      );

      return;
    }

    final availability =
        await NfcManager.instance
            .checkAvailability();

    if (availability !=
        NfcAvailability.enabled) {
      _showMessage(
        'NFC chưa được bật hoặc thiết bị không hỗ trợ NFC.',
      );

      return;
    }

    setState(() {
      _scanning = true;
      _processing = false;

      _status =
          'Đang chờ thẻ NFC...\n'
          'Đưa thẻ lại gần mặt lưng điện thoại.';

      _uid = null;

      _ndefName = null;
      _ndefSlug = null;

      _templeName = null;

      _visitCount = null;

      _newStamp = false;
    });

    try {
      await NfcManager.instance
          .startSession(
        pollingOptions: {
          NfcPollingOption
              .iso14443,
        },

        onDiscovered:
            (NfcTag tag) async {
          if (_processing) {
            return;
          }

          _processing = true;

          try {
            // ==========================
            // 1. UID VẬT LÝ
            // ==========================
            final androidTag =
                NfcTagAndroid.from(
              tag,
            );

            if (androidTag ==
                null) {
              throw Exception(
                'Không đọc được UID của thẻ.',
              );
            }

            final uid =
                _bytesToHex(
              androidTag.id,
            );

            // ==========================
            // 2. NDEF
            // ==========================
            final templeData =
                _readTempleData(
              tag,
            );

            if (templeData ==
                null) {
              throw Exception(
                'Thẻ NFC chưa chứa thông tin chùa.',
              );
            }

            final type =
                templeData['type']
                    ?.toString();

            final slug =
                templeData['slug']
                    ?.toString()
                    .trim();

            final name =
                templeData['name']
                    ?.toString()
                    .trim();

            if (type !=
                'temple') {
              throw Exception(
                'Đây không phải thẻ NFC của chùa.',
              );
            }

            if (slug == null ||
                slug.isEmpty) {
              throw Exception(
                'Thẻ NFC thiếu slug của chùa.',
              );
            }

            await NfcManager.instance
                .stopSession();

            if (!mounted) return;

            setState(() {
              _scanning = false;

              _uid = uid;

              _ndefSlug = slug;

              _ndefName =
                  name;

              _status =
                  'Đã nhận diện thẻ.\n'
                  'Đang thực hiện check-in...';
            });

            debugPrint(
              'NFC UID: $uid',
            );

            debugPrint(
              'Temple slug: $slug',
            );

            // ==========================
            // 3. CHECK-IN BACKEND
            // ==========================
            final response =
                await _nfcService
                    .checkIn(
              uid: uid,
              slug: slug,
            );

            final data =
                response['data']
                    as Map<String,
                        dynamic>? ??
                {};

            final temple =
                data['temple']
                    as Map<String,
                        dynamic>? ??
                {};

            final visit =
                data['visit']
                    as Map<String,
                        dynamic>? ??
                {};

            final stamp =
                data['stamp']
                    as Map<String,
                        dynamic>? ??
                {};

            if (!mounted) return;

            setState(() {
              _templeName =
                  temple['name']
                      ?.toString();

              _visitCount =
                  visit['visitCount']
                      as int?;

              _newStamp =
                  stamp['isNew'] ==
                      true;

              _status =
                  response['message']
                          ?.toString() ??
                      'Check-in thành công.';
            });
          } catch (error) {
            try {
              await NfcManager
                  .instance
                  .stopSession();
            } catch (_) {}

            if (!mounted) return;

            setState(() {
              _scanning =
                  false;

              _status = error
                  .toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  );
            });
          } finally {
            _processing =
                false;
          }
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _scanning = false;

        _status = error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  Future<void> _stopScan()
      async {
    try {
      await NfcManager.instance
          .stopSession();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _scanning = false;

      _processing = false;

      _status =
          'Đã dừng quét NFC.';
    });
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }

  // ==========================================
  // UI
  // ==========================================
  @override
  Widget build(
    BuildContext context,
  ) {
    final successful =
        _templeName != null;

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFFFFBF7,
      ),

      appBar: AppBar(
        title: const Text(
          'Check-in NFC',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        backgroundColor:
            const Color(
          0xFFFFFBF7,
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(
            20,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,

            children: [
              const SizedBox(
                height: 15,
              ),

              // NFC ICON
              Center(
                child: Container(
                  width: 140,
                  height: 140,

                  decoration:
                      const BoxDecoration(
                    color: Color(
                      0xFFF3E1C5,
                    ),

                    shape:
                        BoxShape.circle,
                  ),

                  child: Icon(
                    successful
                        ? Icons
                            .check_circle
                        : Icons.nfc,

                    size: 75,

                    color:
                        successful
                            ? Colors
                                .green
                            : primaryBrown,
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              Text(
                successful
                    ? 'Check-in thành công'
                    : _scanning
                        ? 'Đang quét NFC'
                        : 'Check-in tại chùa',

                textAlign:
                    TextAlign.center,

                style:
                    const TextStyle(
                  fontSize: 24,

                  fontWeight:
                      FontWeight
                          .bold,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Text(
                _status,

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(
                  fontSize: 15,

                  color:
                      successful
                          ? Colors.green
                          : Colors
                              .grey[700],
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              if (_templeName !=
                  null)
                _infoCard(
                  icon: Icons
                      .temple_buddhist,

                  title: 'Chùa',

                  value:
                      _templeName!,
                ),

              if (_visitCount !=
                  null)
                _infoCard(
                  icon: Icons
                      .directions_walk,

                  title:
                      'Số lần đã viếng',

                  value:
                      '$_visitCount lần',
                ),

              if (_newStamp)
                Card(
                  child: ListTile(
                    leading:
                        const CircleAvatar(
                      backgroundColor:
                          Color(
                        0xFFF3E1C5,
                      ),

                      child: Icon(
                        Icons
                            .workspace_premium,
                        color:
                            primaryBrown,
                      ),
                    ),

                    title:
                        const Text(
                      'Bạn nhận được tem mới!',
                    ),

                    subtitle:
                        Text(
                      _templeName ??
                          '',
                    ),
                  ),
                ),

              if (_ndefName !=
                  null)
                _infoCard(
                  icon: Icons
                      .info_outline,

                  title:
                      'Thông tin trên thẻ',

                  value:
                      _ndefName!,
                ),

              if (_ndefSlug !=
                  null)
                _infoCard(
                  icon:
                      Icons.link,

                  title: 'Slug',

                  value:
                      _ndefSlug!,
                ),

              if (_uid != null)
                _infoCard(
                  icon: Icons.nfc,

                  title:
                      'UID NFC',

                  value: _uid!,
                ),

              const Spacer(),

              SizedBox(
                height: 54,

                child:
                    ElevatedButton.icon(
                  onPressed:
                      _scanning
                          ? _stopScan
                          : _startScan,

                  icon: Icon(
                    _scanning
                        ? Icons.close
                        : Icons.nfc,
                  ),

                  label: Text(
                    _scanning
                        ? 'Dừng quét'
                        : successful
                            ? 'Quét lại'
                            : 'Bắt đầu quét NFC',
                  ),

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        _scanning
                            ? Colors.red
                            : primaryBrown,

                    foregroundColor:
                        Colors.white,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 8,
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: primaryBrown,
        ),

        title:
            Text(title),

        subtitle: Text(
          value,

          style:
              const TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }
}