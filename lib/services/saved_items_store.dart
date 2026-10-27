import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedItemsStore {
  static const _templesKey = 'saved_temple_ids_v1';
  static const _eventsKey = 'saved_event_ids_v1';
  static final changes = ValueNotifier<int>(0);

  static String personalEventId(String id) => 'personal:$id';

  static String festivalId(String id, DateTime date) =>
      'festival:$id:${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<Set<String>> loadTemples() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_templesKey) ?? const <String>[]).toSet();
  }

  Future<Set<String>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_eventsKey) ?? const <String>[]).toSet();
  }

  Future<bool> toggleTemple(String id) => _toggle(_templesKey, id);
  Future<bool> toggleEvent(String id) => _toggle(_eventsKey, id);

  Future<bool> _toggle(String key, String id) async {
    final value = id.trim();
    if (value.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final saved = (prefs.getStringList(key) ?? const <String>[]).toSet();
    final added = saved.add(value);
    if (!added) saved.remove(value);
    await prefs.setStringList(key, saved.toList()..sort());
    changes.value++;
    return added;
  }
}
