import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../models/calendar_event.dart';
import '../../services/calendar_event_store.dart';
import '../../widgets/app_header.dart';
import '../../services/calendar_festival_service.dart';
import '../../utils/lunar_calendar.dart';
import 'calendar_presentation.dart';

class CalendarEventFormPage extends StatefulWidget {
  final DateTime initialDate;
  final CalendarEvent? event;
  final String? initialTitle;

  const CalendarEventFormPage({
    super.key,
    required this.initialDate,
    this.event,
    this.initialTitle,
  });

  @override
  State<CalendarEventFormPage> createState() => _CalendarEventFormPageState();
}

class _CalendarEventFormPageState extends State<CalendarEventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _store = CalendarEventStore();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _usesLunarDate;
  int? _reminderMinutes;
  CalendarRepeat _repeat = CalendarRepeat.none;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController.text = event?.title ?? widget.initialTitle ?? '';
    _locationController.text = event?.location ?? '';
    _descriptionController.text = event?.description ?? '';
    _startDate = event?.startAt ?? _dateOnly(widget.initialDate);
    _endDate = event?.endAt ?? _dateOnly(widget.initialDate);
    _startTime = event == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay.fromDateTime(event.startAt);
    _endTime = event == null
        ? const TimeOfDay(hour: 10, minute: 0)
        : TimeOfDay.fromDateTime(event.endAt);
    _usesLunarDate = event?.usesLunarDate ?? false;
    _reminderMinutes = event?.reminderMinutes;
    _repeat = event?.repeat ?? CalendarRepeat.none;
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  Future<void> _selectSolarDate({required bool start}) async {
    final current = start ? _startDate : _endDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      helpText: start ? 'Chọn ngày bắt đầu' : 'Chọn ngày kết thúc',
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (start) {
        _startDate = selected;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _selectLunarDate({required bool start}) async {
    final solarDate = start ? _startDate : _endDate;
    final initialLunar = LunarCalendar.fromSolar(solarDate);
    var day = initialLunar.day;
    var month = initialLunar.month;
    var year = initialLunar.year;
    var leapMonth = initialLunar.isLeapMonth;
    final firstYear = year < DateTime.now().year - 10
        ? year
        : DateTime.now().year - 10;
    final lastYear = year > DateTime.now().year + 10
        ? year
        : DateTime.now().year + 10;
    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                start ? 'Chọn ngày âm bắt đầu' : 'Chọn ngày âm kết thúc',
                style: const TextStyle(
                  color: AppTheme.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: day,
                      decoration: const InputDecoration(labelText: 'Ngày âm'),
                      items: List.generate(
                        30,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) setSheetState(() => day = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: month,
                      decoration: const InputDecoration(labelText: 'Tháng âm'),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('Tháng ${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) setSheetState(() => month = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: year,
                decoration: const InputDecoration(labelText: 'Năm âm lịch'),
                items: List.generate(
                  lastYear - firstYear + 1,
                  (index) => DropdownMenuItem(
                    value: firstYear + index,
                    child: Text('${firstYear + index}'),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) setSheetState(() => year = value);
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tháng nhuận'),
                value: leapMonth,
                onChanged: (value) => setSheetState(() => leapMonth = value),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final date = CalendarFestivalService().dateForLunarDate(
                      year: year,
                      month: month,
                      day: day,
                      leapMonth: leapMonth,
                    );
                    if (date == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không tìm thấy ngày âm đã chọn.'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, date);
                  },
                  child: const Text('Xác nhận ngày âm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (start) {
        _startDate = selected;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _selectTime({required bool start}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (time == null || !mounted) return;
    setState(() {
      if (start) {
        _startTime = time;
      } else {
        _endTime = time;
      }
    });
  }

  Future<void> _selectCustomReminder() async {
    final controller = TextEditingController(
      text:
          _reminderMinutes != null && ![15, 60, 1440].contains(_reminderMinutes)
          ? '$_reminderMinutes'
          : '30',
    );
    String? errorText;
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thời gian nhắc tùy chỉnh'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            onChanged: (_) => setDialogState(() => errorText = null),
            decoration: InputDecoration(
              labelText: 'Số phút trước sự kiện',
              suffixText: 'phút',
              errorText: errorText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                if (value == null || value <= 0) {
                  setDialogState(() => errorText = 'Nhập số phút lớn hơn 0.');
                  return;
                }
                Navigator.pop(context, value);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (minutes != null && mounted) {
      setState(() => _reminderMinutes = minutes);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final startAt = _combine(_startDate, _startTime);
    final endAt = _combine(_endDate, _endTime);
    if (!endAt.isAfter(startAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giờ kết thúc phải sau giờ bắt đầu.')),
      );
      return;
    }
    setState(() => _saving = true);
    final event = CalendarEvent(
      id: widget.event?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      startAt: startAt,
      endAt: endAt,
      usesLunarDate: _usesLunarDate,
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      reminderMinutes: _reminderMinutes,
      repeat: _repeat,
    );

    try {
      await _store.upsert(event);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã lưu lịch.')));
      Navigator.pop(context, event);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Không thể lưu lịch: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final startLunar = LunarCalendar.fromSolar(_startDate);
    final endLunar = LunarCalendar.fromSolar(_endDate);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppHeader(
        title: Text(widget.event == null ? 'Thêm lịch mới' : 'Chỉnh sửa lịch'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _fieldLabel('Tiêu đề sự kiện *'),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Lễ Phật, thời khóa tụng kinh',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Vui lòng nhập tiêu đề.'
                  : null,
            ),
            const SizedBox(height: 20),
            _fieldLabel('Loại lịch'),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Dương lịch')),
                ButtonSegment(value: true, label: Text('Âm lịch')),
              ],
              selected: {_usesLunarDate},
              onSelectionChanged: (value) =>
                  setState(() => _usesLunarDate = value.first),
            ),
            const SizedBox(height: 18),
            _dateTimeRow(
              title: 'Bắt đầu',
              date: _usesLunarDate
                  ? '${lunarDateLabel(startLunar.day, startLunar.month, leap: startLunar.isLeapMonth)} · ${startLunar.year}'
                  : solarDateLabel(_startDate),
              time: _startTime,
              onDateTap: () => _usesLunarDate
                  ? _selectLunarDate(start: true)
                  : _selectSolarDate(start: true),
              onTimeTap: () => _selectTime(start: true),
            ),
            const SizedBox(height: 10),
            _dateTimeRow(
              title: 'Kết thúc',
              date: _usesLunarDate
                  ? '${lunarDateLabel(endLunar.day, endLunar.month, leap: endLunar.isLeapMonth)} · ${endLunar.year}'
                  : solarDateLabel(_endDate),
              time: _endTime,
              onDateTap: () => _usesLunarDate
                  ? _selectLunarDate(start: false)
                  : _selectSolarDate(start: false),
              onTimeTap: () => _selectTime(start: false),
            ),
            const SizedBox(height: 20),
            _fieldLabel('Lặp lại'),
            DropdownButtonFormField<CalendarRepeat>(
              initialValue: _repeat,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.repeat_rounded),
              ),
              items: const [
                DropdownMenuItem(
                  value: CalendarRepeat.none,
                  child: Text('Không lặp'),
                ),
                DropdownMenuItem(
                  value: CalendarRepeat.daily,
                  child: Text('Hằng ngày'),
                ),
                DropdownMenuItem(
                  value: CalendarRepeat.weekly,
                  child: Text('Hằng tuần'),
                ),
                DropdownMenuItem(
                  value: CalendarRepeat.monthly,
                  child: Text('Hằng tháng'),
                ),
                DropdownMenuItem(
                  value: CalendarRepeat.yearly,
                  child: Text('Hằng năm'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _repeat = value);
              },
            ),
            const SizedBox(height: 20),
            _fieldLabel('Nhắc trước'),
            DropdownButtonFormField<int?>(
              initialValue:
                  _reminderMinutes != null &&
                      ![15, 60, 1440].contains(_reminderMinutes)
                  ? -1
                  : _reminderMinutes,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.notifications_none_rounded),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text('Không nhắc')),
                DropdownMenuItem(value: 15, child: Text('15 phút')),
                DropdownMenuItem(value: 60, child: Text('1 giờ')),
                DropdownMenuItem(value: 1440, child: Text('1 ngày')),
                DropdownMenuItem(
                  value: -1,
                  child: Text(
                    _reminderMinutes != null &&
                            ![15, 60, 1440].contains(_reminderMinutes)
                        ? 'Tùy chỉnh · $_reminderMinutes phút'
                        : 'Tùy chỉnh…',
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == -1) {
                  _selectCustomReminder();
                } else {
                  setState(() => _reminderMinutes = value);
                }
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Chọn thời gian nhắc cho lịch này, rồi bật Lịch cá nhân trong Cài đặt nhắc lịch và cấp quyền thông báo trên điện thoại.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            _fieldLabel('Địa điểm hoặc tên chùa'),
            TextFormField(
              controller: _locationController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Thêm địa điểm (không bắt buộc)',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 20),
            _fieldLabel('Mô tả và ghi chú'),
            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ghi chú cho lịch cá nhân',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(widget.event == null ? 'Lưu lịch' : 'Lưu thay đổi'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        color: AppTheme.text,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _dateTimeRow({
    required String title,
    required String date,
    required TimeOfDay time,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
  }) => Row(
    children: [
      Expanded(
        flex: 3,
        child: _PickerTile(
          title: title,
          value: date,
          icon: Icons.calendar_today_outlined,
          onTap: onDateTap,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: _PickerTile(
          title: 'Giờ',
          value: time.format(context),
          icon: Icons.schedule_rounded,
          onTap: onTimeTap,
        ),
      ),
    ],
  );
}

class _PickerTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.warmBrown),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
