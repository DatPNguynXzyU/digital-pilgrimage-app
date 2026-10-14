import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/calendar_event.dart';

class CalendarEventStore {
  static const String _storageKey = 'personal_calendar_events_v1';

  Future<List<CalendarEvent>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded == null || encoded.isEmpty) return [];

    final decoded = jsonDecode(encoded);
    if (decoded is! List) {
      throw const FormatException('Dữ liệu lịch cá nhân không hợp lệ.');
    }
    return decoded
        .map((item) => CalendarEvent.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<CalendarEvent> events) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(events.map((event) => event.toJson()).toList());
    final saved = await preferences.setString(_storageKey, encoded);
    if (!saved) {
      throw StateError('Không thể lưu lịch cá nhân trên thiết bị.');
    }
  }

  Future<void> upsert(CalendarEvent event) async {
    final events = await load();
    final index = events.indexWhere((item) => item.id == event.id);
    if (index == -1) {
      events.add(event);
    } else {
      events[index] = event;
    }
    await save(events);
  }

  Future<void> delete(String id) async {
    final events = await load();
    events.removeWhere((event) => event.id == id);
    await save(events);
  }
}
