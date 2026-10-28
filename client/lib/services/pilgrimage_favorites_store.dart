import 'package:shared_preferences/shared_preferences.dart';

class PilgrimageFavoritesStore {
  static const String _storageKey = 'pilgrimage_favorite_temple_ids_v1';

  Future<Set<String>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_storageKey) ?? []).toSet();
  }

  Future<bool> toggle(String templeId) async {
    if (templeId.isEmpty) {
      throw ArgumentError.value(templeId, 'templeId', 'Must not be empty.');
    }

    final preferences = await SharedPreferences.getInstance();
    final favorites = (preferences.getStringList(_storageKey) ?? []).toSet();
    final isFavorite = favorites.add(templeId);
    if (!isFavorite) favorites.remove(templeId);

    final saved = await preferences.setStringList(
      _storageKey,
      favorites.toList(),
    );
    if (!saved) {
      throw StateError('Không thể lưu danh sách chùa yêu thích.');
    }
    return isFavorite;
  }
}
