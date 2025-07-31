import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  // Token management
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }
  
  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }
  
  Future<void> saveRefreshToken(String refreshToken) async {
    await _prefs.setString(AppConstants.refreshTokenKey, refreshToken);
  }
  
  String? getRefreshToken() {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }
  
  // User data management
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _prefs.setString(AppConstants.userKey, json.encode(userData));
  }
  
  Map<String, dynamic>? getUser() {
    final userJson = _prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      try {
        return json.decode(userJson) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  Future<void> saveUserRole(String role) async {
    await _prefs.setString(AppConstants.userRoleKey, role);
  }
  
  String? getUserRole() {
    return _prefs.getString(AppConstants.userRoleKey);
  }
  
  // App settings
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }
  
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }
  
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs.getString(key);
  }
  
  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }
  
  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }
  
  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }
  
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }
  
  Future<void> saveStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }
  
  List<String> getStringList(String key, {List<String>? defaultValue}) {
    return _prefs.getStringList(key) ?? defaultValue ?? [];
  }
  
  // Cache management
  Future<void> saveCache(String key, Map<String, dynamic> data) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _prefs.setString('cache_$key', json.encode(cacheData));
  }
  
  Map<String, dynamic>? getCache(String key) {
    final cacheJson = _prefs.getString('cache_$key');
    if (cacheJson != null) {
      try {
        final cacheData = json.decode(cacheJson) as Map<String, dynamic>;
        final timestamp = cacheData['timestamp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Check if cache is still valid (within expiry duration)
        if (now - timestamp < AppConstants.cacheExpiry.inMilliseconds) {
          return cacheData['data'] as Map<String, dynamic>;
        } else {
          // Cache expired, remove it
          _prefs.remove('cache_$key');
        }
      } catch (e) {
        // Invalid cache data, remove it
        _prefs.remove('cache_$key');
      }
    }
    return null;
  }
  
  Future<void> clearCache(String key) async {
    await _prefs.remove('cache_$key');
  }
  
  Future<void> clearAllCache() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
  
  // Remove specific key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
  
  // Clear all stored data
  Future<void> clearAll() async {
    await _prefs.clear();
  }
  
  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
  
  // Get all keys
  Set<String> getAllKeys() {
    return _prefs.getKeys();
  }
}