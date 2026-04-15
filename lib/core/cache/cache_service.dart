import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String _boxName = 'opus_cache';

  Box<Map> get _box => Hive.box<Map>(_boxName);

  Future<void> put<T>(
    String key,
    T value, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    final expiresAt = DateTime.now().add(ttl).toIso8601String();
    await _box.put(key, {
      'data': value,
      'expiresAt': expiresAt,
    });
  }

  Future<T?> get<T>(String key) async {
    final entry = _box.get(key);
    if (entry == null) return null;

    final expiresAtStr = entry['expiresAt'] as String?;
    if (expiresAtStr == null) return null;

    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
      await delete(key);
      return null;
    }

    final data = entry['data'];
    if (data is T) return data;
    return null;
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }

  Future<bool> isExpired(String key) async {
    final entry = _box.get(key);
    if (entry == null) return true;

    final expiresAtStr = entry['expiresAt'] as String?;
    if (expiresAtStr == null) return true;

    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return true;

    return DateTime.now().isAfter(expiresAt);
  }
}
