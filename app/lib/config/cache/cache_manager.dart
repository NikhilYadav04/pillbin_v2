import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  static const _secureStorage = FlutterSecureStorage();
  final _logger = Logger();

  //* Cache Keys
  static const String _userProfileKey = 'CACHE_USER_PROFILE';
  static const String _medicinesKey = 'CACHE_MEDICINES';
  static const String _notificationsKey = 'CACHE_NOTIFICATIONS';
  static const String _chatHistoryKey = 'CACHE_CHAT_HISTORY';
  static const String _ragHistoryKey = 'CACHE_RAG_HISTORY';
  static const String _lastSyncKey = 'CACHE_LAST_SYNC';

  //* Cache Timestamps

  //* Cache Expiry (in hours)
  static const int _cacheExpiryHours = 24;

  //* < ---------- GENERIC CACHE METHODS ------------------------------>

  Future<void> _setCacheData(String key, String data) async {
    try {
      await _secureStorage.write(key: key, value: data);
      await _secureStorage.write(
        key: '${key}_TIMESTAMP',
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      _logger.e('Error setting cache for $key: $e');
    }
  }

  Future<String?> _getCacheData(String key) async {
    try {
      final timestamp = await _secureStorage.read(key: '${key}_TIMESTAMP');
      if (timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final now = DateTime.now();
        final difference = now.difference(cacheTime).inHours;

        if (difference < _cacheExpiryHours) {
          return await _secureStorage.read(key: key);
        } else {
          //* Cache expired, delete it
          await _deleteCacheData(key);
        }
      }
    } catch (e) {
      _logger.e('Error getting cache for $key: $e');
    }
    return null;
  }

  Future<void> _deleteCacheData(String key) async {
    try {
      await _secureStorage.delete(key: key);
      await _secureStorage.delete(key: '${key}_TIMESTAMP');
    } catch (e) {
      _logger.e('Error deleting cache for $key: $e');
    }
  }

  //* Check if cache exists and is valid
  Future<bool> _isCacheValid(String key) async {
    try {
      final timestamp = await _secureStorage.read(key: '${key}_TIMESTAMP');
      if (timestamp != null) {
        final cacheTime = DateTime.parse(timestamp);
        final now = DateTime.now();
        final difference = now.difference(cacheTime).inHours;
        return difference < _cacheExpiryHours;
      }
    } catch (e) {
      _logger.e('Error checking cache validity for $key: $e');
    }
    return false;
  }

  //* <--------------- PROFILE CACHE ------------------------------>
  Future<void> cacheUserProfile(Map<String, dynamic> userData) async {
    await _setCacheData(_userProfileKey, jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    final data = await _getCacheData(_userProfileKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> hasValidUserProfileCache() async {
    return await _isCacheValid(_userProfileKey);
  }

  //* MEDICINE INVENTORY CACHE --------------------------->

  Future<void> cacheMedicinesInventory(Map<String, dynamic> inventory) async {
    await _setCacheData(_medicinesKey, jsonEncode(inventory));
  }

  Future<Map<String, dynamic>?> getCachedMedicinesInventory() async {
    final data = await _getCacheData(_medicinesKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> hasValidMedicinesCache() async {
    return await _isCacheValid(_medicinesKey);
  }

  //* <----------------- NOTIFICATIONS CACHE ------------------------------>
  Future<void> cacheNotifications(List<dynamic> notifications) async {
    await _setCacheData(_notificationsKey, jsonEncode(notifications));
  }

  Future<List<dynamic>?> getCachedNotifications() async {
    final data = await _getCacheData(_notificationsKey);
    if (data != null) {
      return jsonDecode(data) as List<dynamic>;
    }
    return null;
  }

  Future<bool> hasValidNotificationsCache() async {
    return await _isCacheValid(_notificationsKey);
  }

  //* < ---------------- CHAT HISTORY CACHE ------------------------- >

  Future<void> cacheChatHistory(Map<String, dynamic> chatData) async {
    await _setCacheData(_chatHistoryKey, jsonEncode(chatData));
  }

  Future<Map<String, dynamic>?> getCachedChatHistory() async {
    final data = await _getCacheData(_chatHistoryKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> hasValidChatHistoryCache() async {
    return await _isCacheValid(_chatHistoryKey);
  }

  //* <------------ RAG HISTORY CACHE ------------------------------>

  Future<void> cacheRagHistory(Map<String, dynamic> ragData) async {
    await _setCacheData(_ragHistoryKey, jsonEncode(ragData));
  }

  Future<Map<String, dynamic>?> getCachedRagHistory() async {
    final data = await _getCacheData(_ragHistoryKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> hasValidRagHistoryCache() async {
    return await _isCacheValid(_ragHistoryKey);
  }

  //*<--------------------- SYNC STATUS ------------------- >

  Future<void> setLastSyncTime() async {
    await _secureStorage.write(
      key: _lastSyncKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<DateTime?> getLastSyncTime() async {
    final timestamp = await _secureStorage.read(key: _lastSyncKey);
    if (timestamp != null) {
      return DateTime.parse(timestamp);
    }
    return null;
  }

  //*<-------------- CLEAR ALL CACHE ---------------------- >
  Future<void> clearAllCache() async {
    await _deleteCacheData(_userProfileKey);
    await _deleteCacheData(_medicinesKey);
    await _deleteCacheData(_notificationsKey);
    await _deleteCacheData(_chatHistoryKey);
    await _deleteCacheData(_ragHistoryKey);
    await _secureStorage.delete(key: _lastSyncKey);
    _logger.i('All cache cleared');
  }

  //* <--------------- CACHE STATISTICS ----------------------->

  Future<Map<String, bool>> getCacheStatus() async {
    return {
      'userProfile': await hasValidUserProfileCache(),
      'medicines': await hasValidMedicinesCache(),
      'notifications': await hasValidNotificationsCache(),
      'chatHistory': await hasValidChatHistoryCache(),
      'ragHistory': await hasValidRagHistoryCache(),
    };
  }
}
