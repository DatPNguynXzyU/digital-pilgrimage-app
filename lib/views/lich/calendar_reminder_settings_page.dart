import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../services/calendar_reminder_preferences.dart';

class CalendarReminderSettingsPage extends StatefulWidget {
  const CalendarReminderSettingsPage({super.key});

  @override
  State<CalendarReminderSettingsPage> createState() =>
      _CalendarReminderSettingsPageState();
}

class _CalendarReminderSettingsPageState
    extends State<CalendarReminderSettingsPage> {
  final _preferences = CalendarReminderPreferences();
  late Future<void> _load;
  bool _festivalEnabled = false;
  bool _personalEnabled = false;
  int _leadMinutes = 60;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load = _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _festivalEnabled = await _preferences.festivalsEnabled();
    _personalEnabled = await _preferences.personalEnabled();
    _leadMinutes = await _preferences.leadMinutes();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _preferences.save(
        festivalsEnabled: _festivalEnabled,
        personalEnabled: _personalEnabled,
        leadMinutes: _leadMinutes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tùy chọn đã lưu trên thiết bị.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể lưu tùy chọn: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _selectCustomLeadTime() async {
    final controller = TextEditingController(
      text: _leadMinutes != 15 && _leadMinutes != 60 && _leadMinutes != 1440
          ? '$_leadMinutes'
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
      setState(() => _leadMinutes = minutes);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(title: const Text('Cài đặt nhắc lịch')),
    body: FutureBuilder<void>(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Không thể tải tùy chọn: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    color: AppTheme.secondary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bạn có thể chọn loại lịch và thời điểm nhắc. Ứng dụng hiện lưu tùy chọn trên thiết bị; chưa gửi thông báo hệ thống.',
                      style: TextStyle(
                        color: Colors.white,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Nhắc cho',
              style: TextStyle(
                color: AppTheme.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _ReminderSwitchTile(
              icon: Icons.spa_outlined,
              title: 'Ngày lễ Phật giáo',
              subtitle: 'Rằm, mùng Một và các ngày lễ tham khảo',
              value: _festivalEnabled,
              onChanged: (value) => setState(() => _festivalEnabled = value),
            ),
            const SizedBox(height: 9),
            _ReminderSwitchTile(
              icon: Icons.event_note_outlined,
              title: 'Lịch cá nhân',
              subtitle: 'Các lịch cá nhân của bạn',
              value: _personalEnabled,
              onChanged: (value) => setState(() => _personalEnabled = value),
            ),
            const SizedBox(height: 20),
            const Text(
              'Thời gian nhắc trước',
              style: TextStyle(
                color: AppTheme.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: [15, 60, 1440].contains(_leadMinutes)
                      ? _leadMinutes
                      : -1,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 15, child: Text('15 phút trước')),
                    DropdownMenuItem(value: 60, child: Text('1 giờ trước')),
                    DropdownMenuItem(value: 1440, child: Text('1 ngày trước')),
                    DropdownMenuItem(
                      value: -1,
                      child: Text(
                        [15, 60, 1440].contains(_leadMinutes)
                            ? 'Tùy chỉnh…'
                            : 'Tùy chỉnh · $_leadMinutes phút',
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == -1) {
                      _selectCustomLeadTime();
                    } else if (value != null) {
                      setState(() => _leadMinutes = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lịch được đồng bộ theo tài khoản khi đăng nhập. Tùy chọn nhắc vẫn lưu trên thiết bị; ứng dụng chưa gửi thông báo hệ thống.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu tùy chọn trên thiết bị'),
            ),
          ],
        );
      },
    ),
  );
}

class _ReminderSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReminderSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppTheme.border),
    ),
    child: SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppTheme.warmBrown),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.text,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
    ),
  );
}
