import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

import '../../config/app_theme.dart';
import '../../models/temple.dart';
import '../temples/chi_tiet_chua.dart';
import '../../services/auth_service.dart';
import '../../services/nfc_service.dart';
import '../tai_khoan/login_page.dart';
import '../tai_khoan/pilgrimage_history_page.dart';
import '../tai_khoan/stamp_book_page.dart';

class NfcScanPage extends StatefulWidget {
  const NfcScanPage({super.key});

  @override
  State<NfcScanPage> createState() => _NfcScanPageState();
}

class _NfcScanPageState extends State<NfcScanPage> {
  static const Color primaryBrown = AppTheme.primary;

  final NfcService _nfcService = NfcService();
  final AuthService _authService = AuthService();

  bool _starting = false;
  bool _scanning = false;
  bool _processing = false;
  bool _isLoggedIn = false;
  bool _checkingAuth = true;

  String _status = 'Nhấn nút bên dưới và chạm thẻ NFC vào mặt lưng điện thoại.';

  Temple? _temple;
  int? _visitCount;
  bool _newStamp = false;

  @override
  void initState() {
    super.initState();
    _initAuthAndScan();
  }

  Future<void> _initAuthAndScan() async {
    final token = await _authService.getToken();
    final loggedIn = token != null && token.isNotEmpty;

    if (!mounted) return;
    setState(() {
      _isLoggedIn = loggedIn;
      _checkingAuth = false;
    });

    if (loggedIn &&
        !kIsWeb &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform)) {
      _startScan();
    }
  }

  // ==========================================
  // TRÍCH XUẤT UID VẬT LÝ CỦA THẺ NFC
  // ==========================================
  String? _extractUid(NfcTag tag) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final bytes =
          MiFareIos.from(tag)?.identifier ??
          Iso15693Ios.from(tag)?.identifier ??
          Iso7816Ios.from(tag)?.identifier;
      if (bytes == null || bytes.isEmpty) return null;
      return bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join()
          .toUpperCase();
    }
    try {
      final androidTag = NfcTagAndroid.from(tag);
      if (androidTag != null && androidTag.id.isNotEmpty) {
        return androidTag.id
            .map((b) => b.toRadixString(16).padLeft(2, '0'))
            .join()
            .toUpperCase();
      }
    } catch (_) {}

    // ignore: invalid_use_of_protected_member
    return _findUidInMap(tag.data);
  }

  String? _findUidInMap(dynamic value) {
    if (value is Map) {
      for (final entry in value.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key == 'identifier' || key == 'id') {
          final bytes = entry.value;
          if (bytes is List) {
            final numbers = bytes.whereType<num>().toList();
            if (numbers.isNotEmpty) {
              return numbers
                  .map((b) => b.toInt().toRadixString(16).padLeft(2, '0'))
                  .join()
                  .toUpperCase();
            }
          }
        }
        final result = _findUidInMap(entry.value);
        if (result != null) return result;
      }
    } else if (value is List) {
      for (final item in value) {
        final result = _findUidInMap(item);
        if (result != null) return result;
      }
    }
    return null;
  }

  // ==========================================
  // ĐỌC DỮ LIỆU CHÙA TỪ NDEF CỦA THẺ NFC
  //
  // Cấu trúc chuẩn:
  // {
  //   "type": "temple",
  //   "slug": "chua-giac-lam",
  //   "name": "Chùa Giác Lâm"
  // }
  // ==========================================
  Map<String, dynamic>? _readTempleData(NfcTag tag) {
    try {
      final ndef = Ndef.from(tag);
      if (ndef == null) return null;
      final message = ndef.cachedMessage;
      if (message == null || message.records.isEmpty) return null;

      for (final record in message.records) {
        final payload = record.payload;
        if (payload.isEmpty) continue;

        final langLen = payload[0] & 0x3F;
        final textStart = 1 + langLen;
        String text;
        if (textStart < payload.length) {
          text = utf8.decode(payload.sublist(textStart), allowMalformed: true);
        } else {
          text = utf8.decode(payload, allowMalformed: true);
        }

        text = text.trim();
        if (text.isEmpty) continue;

        try {
          final decoded = jsonDecode(text);
          if (decoded is Map<String, dynamic>) {
            final type = decoded['type']?.toString().trim();
            final slug = decoded['slug']?.toString().trim();
            final name = decoded['name']?.toString().trim();

            if (type == 'temple' && slug != null && slug.isNotEmpty) {
              return {'type': type, 'slug': slug, 'name': name ?? slug};
            }
          }
        } catch (_) {}

        if (text.toUpperCase().startsWith('TEMPLE:')) {
          final slug = text.substring(7).trim().toLowerCase();
          return {'type': 'temple', 'slug': slug, 'name': slug};
        }
      }
    } catch (_) {}
    return null;
  }

  // ==========================================
  // BẮT ĐẦU QUÉT NFC (BẮT BUỘC ĐÃ ĐĂNG NHẬP)
  // ==========================================
  @override
  void dispose() {
    if (_scanning) {
      NfcManager.instance.stopSession().catchError((Object _) {});
    }
    super.dispose();
  }

  Future<void> _openResult(bool stamps) async {
    final token = await AuthService().getToken();
    if (!mounted || token == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => stamps
            ? StampBookPage(token: token)
            : PilgrimageHistoryPage(token: token),
      ),
    );
  }

  Future<void> _startScan() async {
    if (_starting || _processing || _scanning) return;
    setState(() => _starting = true);
    try {
      var token = await AuthService().getToken();
      if (!mounted) return;
      if (token == null || token.isEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        token = await AuthService().getToken();
        if (!mounted || token == null || token.isEmpty) return;
      }
      setState(() => _isLoggedIn = true);
      await _scan();
    } catch (_) {
      if (mounted) _showMessage('Không thể khởi động NFC. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _scan() async {
    if (kIsWeb ||
        ![
          TargetPlatform.android,
          TargetPlatform.iOS,
        ].contains(defaultTargetPlatform)) {
      _showMessage(
        'Vui lòng sử dụng điện thoại Android hoặc iPhone có hỗ trợ NFC.',
      );
      return;
    }

    final availability = await NfcManager.instance.checkAvailability();

    if (!mounted) return;
    if (availability != NfcAvailability.enabled) {
      _showMessage('NFC chưa được bật hoặc thiết bị không hỗ trợ NFC.');
      return;
    }

    setState(() {
      _scanning = true;
      _processing = false;
      _status = 'Đang chờ thẻ NFC...\nHãy chạm thẻ vào mặt lưng điện thoại.';
      _temple = null;
      _visitCount = null;
      _newStamp = false;
    });

    try {
      await NfcManager.instance.startSession(
        alertMessageIos: 'Đưa phần trên iPhone lại gần thẻ NFC của chùa.',
        invalidateAfterFirstReadIos: false,
        onSessionErrorIos: (_) {
          if (!mounted || _processing) return;
          setState(() {
            _scanning = false;
            _status = 'Phiên quét đã kết thúc. Nhấn quét để thử lại.';
          });
        },
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          if (!mounted || !_scanning || _processing) {
            return;
          }

          setState(() => _processing = true);

          try {
            HapticFeedback.mediumImpact();
          } catch (_) {}

          try {
            final uid = _extractUid(tag);

            try {
              await NfcManager.instance.stopSession();
            } catch (_) {}

            if (uid == null || uid.isEmpty) {
              throw Exception('Không đọc được ID (UID) của thẻ NFC.');
            }

            final templeData = _readTempleData(tag);

            if (templeData == null) {
              // Thử kiểm tra thẻ qua backend theo UID
              try {
                final response = await _nfcService.getTempleByUid(uid);
                final data = response['data'] as Map<String, dynamic>? ?? {};
                final tJson = data['temple'] as Map<String, dynamic>? ?? {};
                final slug = tJson['slug']?.toString();

                if (slug != null && slug.isNotEmpty) {
                  await _checkInTemple(uid: uid, slug: slug);
                  return;
                }
              } catch (_) {}

              throw Exception(
                'Thẻ NFC chưa chứa thông tin chùa hợp lệ.\n'
                'Thẻ cần có định dạng:\n'
                '{"type": "temple", "slug": "...", "name": "..."}',
              );
            }

            final slug = templeData['slug'] as String;
            final name = templeData['name'] as String;

            if (!mounted) return;
            setState(() {
              _scanning = false;
              _status = 'Đã nhận diện: $name\nĐang ghi nhận check-in...';
            });

            await _checkInTemple(uid: uid, slug: slug);
          } catch (error) {
            try {
              await NfcManager.instance.stopSession();
            } catch (_) {}

            if (!mounted) return;
            setState(() {
              _scanning = false;
              _status = error.toString().replaceFirst('Exception: ', '');
            });
          } finally {
            if (mounted) setState(() => _processing = false);
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _status = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // ==========================================
  // CHECK-IN BACKEND
  // ==========================================
  Future<void> _checkInTemple({
    required String uid,
    required String slug,
  }) async {
    try {
      final response = await _nfcService.checkIn(uid: uid, slug: slug);
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final templeJson = data['temple'] as Map<String, dynamic>? ?? {};
      final visitJson = data['visit'] as Map<String, dynamic>? ?? {};
      final stampJson = data['stamp'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        _scanning = false;
        _temple = Temple.fromJson(templeJson);
        _visitCount = visitJson['visitCount'] as int?;
        _newStamp = stampJson['isNew'] == true;
        _status = response['message']?.toString() ?? 'Check-in thành công!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _status = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _stopScan() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _scanning = false;
      _processing = false;
      _status = 'Đã dừng quét NFC.';
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        title: const Text('Check-in NFC'),
        backgroundColor: const Color(0xFFFFFBF7),
      ),
      body: SafeArea(
        child: _checkingAuth
            ? const Center(child: CircularProgressIndicator())
            : !_isLoggedIn
            ? SingleChildScrollView(child: _buildLoginRequiredView())
            : _buildScanView(),
      ),
    );
  }

  // ==========================================
  // GIAO DIỆN BẮT BUỘC ĐĂNG NHẬP
  // ==========================================
  Widget _buildLoginRequiredView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: Color(0xFFF3E1C5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                size: 56,
                color: primaryBrown,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Yêu cầu đăng nhập',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bạn cần đăng nhập tài khoản để có thể quét thẻ NFC tại chùa và nhận tem hành hương.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                  );
                  await _initAuthAndScan();
                },
                icon: const Icon(Icons.login_rounded),
                label: const Text(
                  'Đăng nhập ngay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: primaryBrown,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // GIAO DIỆN QUÉT NFC KHI ĐÃ ĐĂNG NHẬP
  // ==========================================
  Widget _buildScanView() {
    final hasTemple = _temple != null;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),

                  // ICON TRẠNG THÁI
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: hasTemple
                            ? const Color(0xFFE8F5E9)
                            : _scanning
                            ? const Color(0xFFFBE9E7)
                            : const Color(0xFFF3E1C5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasTemple
                            ? Icons.check_circle_rounded
                            : _scanning
                            ? Icons.nfc_rounded
                            : Icons.nfc,
                        size: 64,
                        color: hasTemple
                            ? Colors.green.shade700
                            : _scanning
                            ? Colors.deepOrange
                            : primaryBrown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasTemple
                          ? Colors.green.shade800
                          : AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CARD THÔNG TIN NGÔI CHÙA VỪA QUÉT ĐƯỢC
                  if (hasTemple) ...[
                    _buildTempleSuccessCard(_temple!),
                    const SizedBox(height: 12),
                  ],

                  if (hasTemple) ...[
                    TextButton(
                      onPressed: () => _openResult(true),
                      child: const Text('Xem sổ tem'),
                    ),
                    TextButton(
                      onPressed: () => _openResult(false),
                      child: const Text('Xem lịch sử viếng chùa'),
                    ),
                  ],
                  const Spacer(),

                  // NÚT ĐIỀU KHIỂN QUÉT
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _processing || _starting
                          ? null
                          : (_scanning ? _stopScan : _startScan),
                      icon: Icon(_scanning ? Icons.close : Icons.nfc),
                      label: Text(
                        _scanning
                            ? 'Dừng quét'
                            : hasTemple
                            ? 'Quét lại'
                            : 'Bắt đầu quét NFC',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _scanning
                            ? Colors.red.shade700
                            : primaryBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CARD THÔNG TIN CHÙA (ĐÃ XÓA CÁC CHIP DEBUG THEO YÊU CẦU)
  // ==========================================
  Widget _buildTempleSuccessCard(Temple temple) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (temple.thumbnail.isNotEmpty)
            Image.network(
              temple.thumbnail,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder(),
            )
          else
            _placeholder(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temple.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
                if (temple.fullAddress.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          temple.fullAddress,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (_visitCount != null)
                      Chip(
                        avatar: const Icon(Icons.check_rounded, size: 16),
                        label: Text('Đã viếng: $_visitCount lần'),
                        backgroundColor: const Color(0xFFE8F5E9),
                        labelStyle: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_newStamp)
                      const Chip(
                        avatar: Icon(Icons.workspace_premium, size: 16),
                        label: Text('Tem mới!'),
                        backgroundColor: Color(0xFFFFF3E0),
                        labelStyle: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChiTietChuaPage(temple: temple),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Xem chi tiết chùa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryBrown,
                      side: const BorderSide(color: primaryBrown),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 120,
      color: AppTheme.surface,
      alignment: Alignment.center,
      child: const Icon(
        Icons.temple_buddhist_rounded,
        size: 54,
        color: AppTheme.secondary,
      ),
    );
  }
}
