import 'package:shared_preferences/shared_preferences.dart';

class CalendarReminderPreferences {
  static const _festivalEnabledKey = 'calendar_reminders_festivals';
  static const _personalEnabledKey = 'calendar_reminders_personal';
  static const _leadMinutesKey = 'calendar_reminder_lead_minutes';

  Future<bool> festivalsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_festivalEnabledKey) ?? false;
  }

  Future<bool> personalEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_personalEnabledKey) ?? false;
  }

  Future<int> leadMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_leadMinutesKey) ?? 60;
  }

  Future<void> save({
    required bool festivalsEnabled,
    required bool personalEnabled,
    required int leadMinutes,
  }) async {
    if (leadMinutes <= 0) {
      throw ArgumentError.value(
        leadMinutes,
        'leadMinutes',
        'Must be positive.',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_festivalEnabledKey, festivalsEnabled);
    await prefs.setBool(_personalEnabledKey, personalEnabled);
    await prefs.setInt(_leadMinutesKey, leadMinutes);
  }
}
