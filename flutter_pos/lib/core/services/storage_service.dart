import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Token Management
  static Future<void> saveToken(String token) async {
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    return prefs.getString('auth_token');
  }

  static Future<void> removeToken() async {
    await prefs.remove('auth_token');
  }

  // Refresh Token Management
  static Future<void> saveRefreshToken(String refreshToken) async {
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    return prefs.getString('refresh_token');
  }

  static Future<void> removeRefreshToken() async {
    await prefs.remove('refresh_token');
  }

  // User Data Management
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await prefs.setString('user_data', jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> removeUser() async {
    await prefs.remove('user_data');
  }

  // Clear all authentication data
  static Future<void> clearAuthData() async {
    await removeToken();
    await removeRefreshToken();
    await removeUser();
  }

  // App Settings
  static Future<void> saveSettings(String key, dynamic value) async {
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      await prefs.setString(key, jsonEncode(value));
    }
  }

  static T? getSettings<T>(String key) {
    final value = prefs.get(key);
    if (value is T) {
      return value;
    }
    return null;
  }

  static Future<void> removeSettings(String key) async {
    await prefs.remove(key);
  }

  // Cache Management
  static Future<void> cacheData(String key, Map<String, dynamic> data, {Duration? ttl}) async {
    final cacheItem = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    };
    await prefs.setString('cache_$key', jsonEncode(cacheItem));
  }

  static Future<Map<String, dynamic>?> getCachedData(String key) async {
    final cachedItem = prefs.getString('cache_$key');
    if (cachedItem == null) return null;

    final cache = jsonDecode(cachedItem) as Map<String, dynamic>;
    final timestamp = cache['timestamp'] as int;
    final ttl = cache['ttl'] as int?;

    if (ttl != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(timestamp + ttl);
      if (DateTime.now().isAfter(expiry)) {
        await removeCachedData(key);
        return null;
      }
    }

    return cache['data'] as Map<String, dynamic>;
  }

  static Future<void> removeCachedData(String key) async {
    await prefs.remove('cache_$key');
  }

  static Future<void> clearCache() async {
    final keys = prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // Offline Data Queue
  static Future<void> addToOfflineQueue(Map<String, dynamic> request) async {
    final queue = await getOfflineQueue();
    queue.add(request);
    await prefs.setString('offline_queue', jsonEncode(queue));
  }

  static Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    final queueData = prefs.getString('offline_queue');
    if (queueData != null) {
      final List<dynamic> list = jsonDecode(queueData);
      return list.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> removeFromOfflineQueue(int index) async {
    final queue = await getOfflineQueue();
    if (index >= 0 && index < queue.length) {
      queue.removeAt(index);
      await prefs.setString('offline_queue', jsonEncode(queue));
    }
  }

  static Future<void> clearOfflineQueue() async {
    await prefs.remove('offline_queue');
  }
}