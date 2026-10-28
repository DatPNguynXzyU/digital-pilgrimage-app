import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/nfc_admin_service.dart';

class NfcStatisticsPage extends StatefulWidget {
  const NfcStatisticsPage({super.key});
  @override
  State<NfcStatisticsPage> createState() => _NfcStatisticsPageState();
}

class _NfcStatisticsPageState extends State<NfcStatisticsPage> {
  final _service = NfcAdminService();
  late DateTimeRange _range;
  String? _temple;
  List<dynamic> _temples = [];
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  int _request = 0;
  static String date(DateTime value) =>
      value.toIso8601String().substring(0, 10);
  static String eventTime(dynamic value) =>
      DateTime.parse(value as String)
          .toUtc()
          .add(const Duration(hours: 7))
          .toIso8601String()
          .substring(0, 16)
          .replaceFirst('T', ' ');
  @override
  void initState() {
    super.initState();
    final vn = DateTime.now().toUtc().add(const Duration(hours: 7));
    final today = DateTime(vn.year, vn.month, vn.day);
    _range = DateTimeRange(
      start: today.subtract(const Duration(days: 29)),
      end: today,
    );
    _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
      _data = null;
    });
    try {
      final query = Uri(
        queryParameters: {
          'from': date(_range.start),
          'to': date(_range.end),
          'templeId': ?_temple,
        },
      ).query;
      final results = await Future.wait([
        _service.request('statistics?$query'),
        _service.request('temples'),
      ]);
      if (!mounted || request != _request) return;
      setState(() {
        _data = Map<String, dynamic>.from(results[0] as Map);
        _temples = results[1] as List;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _range,
    );
    if (picked == null || !mounted) return;
    if (picked.duration.inDays >= 366) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Chọn tối đa 366 ngày.')));
      return;
    }
    setState(() => _range = picked);
    await _load();
  }

  Future<void> _createEvent() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _EventForm(temples: _temples)),
    );
    if (saved == true && mounted) await _load();
  }

  Widget _chart(
    String title,
    List<dynamic> rows,
    String Function(dynamic) label,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const Text('Chưa có dữ liệu trong khoảng ngày đã chọn.'),
          // Bounded viewport keeps daily reports usable even for a full year.
          if (rows.isNotEmpty)
            SizedBox(
              height: (rows.length * 90.0).clamp(90, 360),
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  final maximum = rows.fold<int>(
                    1,
                    (m, r) => (r['scans'] as int) > m ? r['scans'] as int : m,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(label(row)),
                        const SizedBox(height: 4),
                        Semantics(
                          label:
                              '${row['scans']} lượt check-in, ${row['participants']} người',
                          child: LinearProgressIndicator(
                            value: (row['scans'] as int) / maximum,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(6),
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          '${row['scans']} lượt · ${row['participants']} người',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê NFC'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            tooltip: 'Tải lại',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'QUẢN TRỊ',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text('Check-in thành công · Ngày theo giờ Việt Nam (UTC+7)'),
          OutlinedButton.icon(
            onPressed: _loading ? null : _pickRange,
            icon: const Icon(Icons.date_range),
            label: Text('${date(_range.start)} → ${date(_range.end)}'),
          ),
          DropdownButton<String>(
            isExpanded: true,
            value: _temple,
            hint: const Text('Tất cả chùa'),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Tất cả chùa'),
              ),
              ..._temples.map(
                (t) => DropdownMenuItem<String>(
                  value: t['_id'] as String,
                  child: Text(
                    t['name'] as String,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: _loading
                ? null
                : (value) {
                    setState(() => _temple = value);
                    _load();
                  },
          ),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: _load, child: const Text('Thử lại')),
          ],
          if (data != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _metric('Lượt check-in', data['total']['scans']),
                    _metric('Người duy nhất', data['total']['participants']),
                    _metric('Chùa có lượt', data['activeTemples']),
                  ],
                ),
              ),
            ),
            _chart(
              'Theo ngày',
              data['days'] as List,
              (r) => r['_id'] as String,
            ),
            _chart(
              'Theo chùa',
              data['temples'] as List,
              (r) => r['name'] as String,
            ),
            _chart(
              'Theo sự kiện',
              data['events'] as List,
              (r) =>
                  '${r['title']} · ${r['templeName']}\n'
                  '${eventTime(r['startAt'])} → ${eventTime(r['endAt'])}',
            ),
            if (data['eventsTruncated'] == true)
              const Text(
                'Đang hiển thị 100 sự kiện gần nhất. Hãy thu hẹp khoảng ngày.',
              ),
            OutlinedButton.icon(
              onPressed: _createEvent,
              icon: const Icon(Icons.add),
              label: const Text('Thêm sự kiện thống kê'),
            ),
            const Text(
              'Cách đọc\n'
              '• Mỗi check-in được lưu thành công là 1 lượt; không tính quét lỗi.\n'
              '• Một tài khoản quét nhiều lần vẫn là 1 người trong từng nhóm.\n'
              '• Tổng số người là số tài khoản duy nhất trong toàn bộ bộ lọc, không cộng các cột.\n'
              '• Sự kiện đếm check-in tại đúng chùa và trong giờ tổ chức, giao với khoảng ngày đang chọn. '
              'Sự kiện trùng giờ có thể đếm cùng một lượt; không cộng các sự kiện thành tổng.\n'
              '• Chỉ phản ánh người có check-in, không phải toàn bộ khách tham dự.\n'
              '• Chiều dài thanh biểu diễn lượt check-in, dùng chung thang đo trong mỗi biểu đồ.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String title, dynamic value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$value',
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      Text(title),
    ],
  );
}

class _EventForm extends StatefulWidget {
  final List<dynamic> temples;
  const _EventForm({required this.temples});
  @override
  State<_EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<_EventForm> {
  final _title = TextEditingController();
  String? _temple;
  DateTime? _start, _end;
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pick(bool start) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: (start ? _start : _end) ?? DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (time == null || !mounted) return;
    // Entered wall time is always Vietnam time, independent of phone timezone.
    final value = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (start) {
        _start = value;
      } else {
        _end = value;
      }
    });
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty ||
        _temple == null ||
        _start == null ||
        _end == null ||
        !_end!.isAfter(_start!)) {
      setState(
        () => _error = 'Điền tên, chùa và giờ kết thúc sau giờ bắt đầu.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await NfcAdminService().request(
        'events',
        body: {
          'title': _title.text.trim(),
          'templeId': _temple,
          'startAt': _start!
              .subtract(const Duration(hours: 7))
              .toIso8601String(),
          'endAt': _end!.subtract(const Duration(hours: 7)).toIso8601String(),
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _saving = false;
        });
      }
    }
  }

  String _label(DateTime? value) => value == null
      ? 'Chọn giờ'
      : value.toIso8601String().substring(0, 16).replaceFirst('T', ' ');
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sự kiện thống kê')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Nhập giờ Việt Nam (UTC+7). Dùng để thống kê check-in tại chùa; không tạo lịch cá nhân hay gửi thông báo.',
        ),
        TextField(
          controller: _title,
          maxLength: 200,
          decoration: const InputDecoration(labelText: 'Tên sự kiện'),
        ),
        DropdownButton<String>(
          isExpanded: true,
          value: _temple,
          hint: const Text('Chọn chùa'),
          items: widget.temples
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
          onChanged: _saving
              ? null
              : (value) => setState(() => _temple = value),
        ),
        TextButton(
          onPressed: _saving ? null : () => _pick(true),
          child: Text('Bắt đầu: ${_label(_start)}'),
        ),
        TextButton(
          onPressed: _saving ? null : () => _pick(false),
          child: Text('Kết thúc: ${_label(_end)}'),
        ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Đang lưu…' : 'Lưu sự kiện'),
        ),
      ],
    ),
  );
}
