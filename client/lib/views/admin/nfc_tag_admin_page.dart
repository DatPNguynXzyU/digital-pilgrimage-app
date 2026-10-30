import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nfc_manager/ndef_record.dart';

import '../../services/nfc_admin_service.dart';
import '../../services/nfc_tag_writer.dart';
import '../../services/nfc_launch_service.dart';
import '../../services/nfc_platform_support.dart';

class NfcTagAdminPage extends StatefulWidget {
  const NfcTagAdminPage({super.key, this.reader, this.service});
  final NfcTagReader? reader;
  final NfcAdminService? service;
  @override
  State<NfcTagAdminPage> createState() => _NfcTagAdminPageState();
}

class _NfcTagAdminPageState extends State<NfcTagAdminPage>
    with WidgetsBindingObserver {
  late final NfcTagReader _reader = widget.reader ?? MobileNfcTagReader();
  late final NfcAdminService _api = widget.service ?? NfcAdminService();
  List<dynamic> _temples = [];
  String? _temple;
  NfcTagSnapshot? _tag;
  Map<String, dynamic>? _registration;
  String _status = 'Đang kiểm tra quyền quản trị…';
  bool _allowed = false, _busy = true, _waiting = false;
  String? _verifiedTemple;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NfcLaunchService.managementActive = true;
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached ||
        (state == AppLifecycleState.inactive &&
            !NfcPlatformSupport.hasIosSheet)) {
      unawaited(_reader.cancel());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_reader.cancel());
    // Drop management taps so they cannot become check-ins on leaving this page.
    unawaited(NfcLaunchService().takePendingTag());
    NfcLaunchService.managementActive = false;
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _allowed = false;
    });
    try {
      final values = await _api.request('temples') as List;
      if (!mounted) return;
      setState(() {
        _temples = values.where((t) => t['status'] == 'active').toList();
        _allowed = true;
        _status = 'Chọn Đọc thẻ và đưa thẻ sát mặt lưng điện thoại.';
      });
    } catch (error) {
      if (mounted) setState(() => _status = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _message(Object error) => NfcPlatformSupport.explain(error);
  void _ensureForeground() {
    if (!mounted ||
        (WidgetsBinding.instance.lifecycleState != null &&
            WidgetsBinding.instance.lifecycleState !=
                AppLifecycleState.resumed)) {
      throw Exception('Hãy mở lại màn hình quản lý để thao tác NFC.');
    }
  }

  Future<Map<String, dynamic>?> _inspect(String uid) async {
    final data = await _api.request('tags/$uid') as Map;
    return data['tag'] == null
        ? null
        : Map<String, dynamic>.from(data['tag'] as Map);
  }

  Future<void> _read() async {
    setState(() {
      _busy = true;
      _tag = null;
      _registration = null;
      _verifiedTemple = null;
      _status = 'Đang chờ thẻ… Giữ thẻ sát điện thoại.';
    });
    try {
      await _api.request(
        'temples',
      ); // Check server-side role again before starting NFC.
      if (!mounted) return;
      _ensureForeground();
      setState(() => _waiting = true);
      final tag = await _reader.read();
      if (!mounted) return;
      setState(() {
        _waiting = false;
        _tag = tag;
        _status = 'Đã đọc thẻ. Đang kiểm tra liên kết…';
      });
      final registration = await _inspect(tag.uid);
      if (!mounted) return;
      setState(() {
        _registration = registration;
        _status = 'Đã đọc thẻ và kiểm tra máy chủ.';
      });
    } catch (error) {
      if (mounted) setState(() => _status = _message(error));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _waiting = false;
        });
      }
    }
  }

  String? _boundTemple(Map<String, dynamic>? registration) {
    final temple = registration?['templeId'];
    return temple is Map ? temple['_id']?.toString() : temple?.toString();
  }

  Future<void> _checkBinding(String uid, String temple) async {
    final registration = await _inspect(uid);
    if (registration != null && _boundTemple(registration) != temple) {
      throw Exception('Thẻ đã thuộc chùa khác. Không ghi đè hoặc chuyển chùa.');
    }
    if (registration != null && registration['status'] != 'active') {
      throw Exception('Thẻ đang vô hiệu hóa. Hãy bật lại trước khi ghi.');
    }
  }

  Future<bool> _confirm(String title, String content) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ) ??
      false;
  Future<void> _write({bool retryLink = false}) async {
    final tag = _tag;
    final templeId = retryLink ? _verifiedTemple : _temple;
    if (tag == null || templeId == null) return;
    final temple = _temples.firstWhere((t) => t['_id'] == templeId);
    late NdefMessage message;
    try {
      message = templeTagMessage(temple['slug'] as String? ?? '');
    } catch (_) {
      setState(
        () => _status = 'Máy chủ chưa cung cấp slug chùa hợp lệ. Cần cập nhật backend trước khi ghi.',
      );
      return;
    }
    if (!retryLink &&
        !await _confirm(
          'Ghi thẻ NFC?',
          'Thay toàn bộ nội dung NDEF của thẻ ${tag.uid} bằng thông tin ${temple['name']}? '
              'Thao tác này không đổi UID. Sau đó hãy chạm lại đúng thẻ và giữ yên.',
        )) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _busy = true;
      _status = 'Đang kiểm tra quyền và liên kết thẻ…';
    });
    var verified = false;
    try {
      await _checkBinding(tag.uid, templeId);
      if (!mounted) return;
      _ensureForeground();
      setState(() {
        _waiting = true;
        _status = retryLink
            ? 'Chạm lại thẻ để xác nhận nội dung trước khi liên kết.'
            : 'Chạm lại đúng thẻ để ghi và đọc kiểm tra. Giữ thẻ yên.';
      });
      final current = retryLink
          ? await _reader.read()
          : await _reader.write(tag.uid, message);
      if (current.uid != tag.uid || !sameNdef(current.message, message)) {
        throw Exception(
          'UID hoặc nội dung đọc lại không khớp. Chưa liên kết với máy chủ.',
        );
      }
      verified = true;
      if (!mounted) return;
      setState(() {
        _waiting = false;
        _tag = current;
        _verifiedTemple = templeId;
        _status = 'Nội dung đã xác nhận. Đang liên kết máy chủ…';
      });
      await _api.request('tags', body: {'uid': tag.uid, 'templeId': templeId});
      if (!mounted) return;
      final registration = await _inspect(tag.uid);
      if (!mounted) return;
      setState(() {
        _registration = registration;
        _verifiedTemple = null;
        _status =
            'Thành công: đã ghi, đọc xác nhận và liên kết thẻ với ${temple['name']}.';
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _status =
              '${verified ? 'Thẻ đã xác nhận nội dung nhưng chưa xác nhận liên kết máy chủ. Có thể thử liên kết lại.\n' : ''}${_message(error)}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _waiting = false;
        });
      }
    }
  }

  Future<void> _toggle() async {
    final tag = _tag;
    if (tag == null || _registration == null) return;
    final active = _registration!['status'] != 'active';
    if (!await _confirm(
      active ? 'Bật lại thẻ?' : 'Vô hiệu hóa thẻ?',
      active
          ? 'Cho phép UID ${tag.uid} check-in trở lại?'
          : 'Ngừng check-in bằng UID ${tag.uid}? Lịch sử và tem đã nhận vẫn được giữ.',
    )) {
      return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      await _api.request(
        'tags/${tag.uid}/status',
        body: {'status': active ? 'active' : 'inactive'},
      );
      final registration = await _inspect(tag.uid);
      if (mounted) {
        setState(() {
          _registration = registration;
          _status = active
              ? 'Đã bật lại thẻ.'
              : 'Đã vô hiệu hóa thẻ trên máy chủ.';
        });
      }
    } catch (error) {
      if (mounted) setState(() => _status = _message(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tag = _tag;
    final bound = _registration?['templeId'];
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý thẻ NFC')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'QUẢN TRỊ · NFC',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Đọc thẻ NTAG215/NDEF, chọn chùa, ghi rồi chạm lại để kiểm tra. Không rời màn hình trong lúc ghi.',
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_status),
            ),
          ),
          if (_busy) const Center(child: CircularProgressIndicator()),
          if (_waiting)
            TextButton(
              onPressed: _reader.cancel,
              child: const Text('Hủy quét'),
            ),
          if (!_allowed && !_busy)
            TextButton(
              onPressed: _load,
              child: const Text('Kiểm tra quyền lại'),
            ),
          if (_allowed) ...[
            FilledButton.icon(
              onPressed: _busy ? null : _read,
              icon: const Icon(Icons.nfc),
              label: const Text('Đọc thẻ'),
            ),
            if (tag != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText('UID: ${tag.uid}'),
                      Text('Công nghệ: ${tag.technologies.join(', ')}'),
                      Text(
                        'NDEF: ${tag.ndefSupported ? 'Có' : 'Không'} · ${tag.writable ? 'Cho phép ghi' : 'Không ghi được'}',
                      ),
                      Text('Dung lượng NDEF: ${tag.capacity} byte'),
                      Text(
                        'Liên kết: ${bound is Map ? bound['name'] : 'Chưa đăng ký hoặc chưa kiểm tra được'}',
                      ),
                      if (_registration != null)
                        Text(
                          'Trạng thái: ${_registration!['status'] == 'active' ? 'Đang hoạt động' : 'Vô hiệu hóa'}',
                        ),
                      const Divider(),
                      const Text('Nội dung đang có:'),
                      SelectableText(tag.contents),
                    ],
                  ),
                ),
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: _temple,
                hint: const Text('Chọn chùa để ghi'),
                items: _temples
                    .map(
                      (t) => DropdownMenuItem<String>(
                        value: t['_id'] as String,
                        child: Text(
                          t['name'] as String,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _temple = value),
              ),
              FilledButton.icon(
                onPressed:
                    _busy ||
                        _temple == null ||
                        !tag.writable ||
                        !tag.ndefSupported
                    ? null
                    : () => _write(),
                icon: const Icon(Icons.edit_note),
                label: const Text('Ghi và liên kết thẻ'),
              ),
              if (_verifiedTemple != null)
                OutlinedButton(
                  onPressed: _busy ? null : () => _write(retryLink: true),
                  child: const Text('Thử liên kết lại (chạm thẻ)'),
                ),
              if (_registration != null)
                OutlinedButton(
                  onPressed: _busy ? null : _toggle,
                  child: Text(
                    _registration!['status'] == 'active'
                        ? 'Vô hiệu hóa thẻ'
                        : 'Bật lại thẻ',
                  ),
                ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Ghi sẽ thay toàn bộ nội dung NDEF. Không khóa thẻ vĩnh viễn, không thay UID. '
              'Thẻ chưa định dạng NDEF cần được chuẩn bị bằng công cụ NFC trước. '
              'Quyền admin bảo vệ chức năng trong app; thẻ chưa bảo vệ ghi vẫn có thể bị ứng dụng khác ghi đè.',
            ),
          ],
        ],
      ),
    );
  }
}
