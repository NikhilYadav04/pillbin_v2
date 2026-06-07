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
  static const String _medicinesHistoryKey = 'CACHE_MEDICINES_HISTORY';
  static const String _notificationsKey = 'CACHE_NOTIFICATIONS';
  static const String _blogsKey = 'CACHE_BLOGS';
  static const String _userBlogsKey = 'CACHE_USER_BLOGS';
  static const String _chatHistoryKey = 'CACHE_CHAT_HISTORY';
  static const String _ragHistoryKey = 'CACHE_RAG_HISTORY';
  static const String _lastSyncKey = 'CACHE_LAST_SYNC';
  static const String _myDonationsKey = 'CACHE_MY_DONATIONS';
  static const String _medicalCentersAllKey = 'CACHE_MEDICAL_CENTERS_ALL';
  static const String _medicalCentersNearbyKey =
      'CACHE_MEDICAL_CENTERS_NEARBY';

  //* Cache Expiry (in hours)
  static const int _cacheExpiryHours = 24;

  //* Cache Limits
  static const int _maxBlogsCache = 10;

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

  //* deleted medicines
  Future<void> cacheMedicinesHistory(Map<String, dynamic> inventory) async {
    await _setCacheData(_medicinesHistoryKey, jsonEncode(inventory));
  }

  Future<Map<String, dynamic>?> getCachedMedicinesHistory() async {
    final data = await _getCacheData(_medicinesHistoryKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> hasValidMedicHistory() async {
    return await _isCacheValid(_medicinesHistoryKey);
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

  //* <----------------- ALL BLOGS CACHE (excluding user's blogs) ------------------------------>

  /// Cache all blogs (limited to max 10 blogs)
  Future<void> cacheBlogs(List<dynamic> blogs) async {
    try {
      // Limit to maximum 10 blogs
      final blogsToCache = blogs.take(_maxBlogsCache).toList();
      await _setCacheData(_blogsKey, jsonEncode(blogsToCache));
      _logger.d('Cached ${blogsToCache.length} all blogs');
    } catch (e) {
      _logger.e('Error caching all blogs: $e');
    }
  }

  /// Get cached all blogs
  Future<List<dynamic>?> getCachedBlogs() async {
    try {
      final data = await _getCacheData(_blogsKey);
      if (data != null) {
        final blogs = jsonDecode(data) as List<dynamic>;
        _logger.d('Retrieved ${blogs.length} cached all blogs');
        return blogs;
      }
    } catch (e) {
      _logger.e('Error getting cached all blogs: $e');
    }
    return null;
  }

  /// Check if all blogs cache is valid
  Future<bool> hasValidBlogsCache() async {
    return await _isCacheValid(_blogsKey);
  }

  /// Clear all blogs cache
  Future<void> clearBlogsCache() async {
    await _deleteCacheData(_blogsKey);
    _logger.i('All blogs cache cleared');
  }

  //* <----------------- USER BLOGS CACHE ------------------------------>

  /// Cache user's blogs (limited to max 10 blogs)
  Future<void> cacheUserBlogs(List<dynamic> userBlogs) async {
    try {
      // Limit to maximum 10 blogs
      final blogsToCache = userBlogs.take(_maxBlogsCache).toList();
      await _setCacheData(_userBlogsKey, jsonEncode(blogsToCache));
      _logger.d('Cached ${blogsToCache.length} user blogs');
    } catch (e) {
      _logger.e('Error caching user blogs: $e');
    }
  }

  /// Get cached user blogs
  Future<List<dynamic>?> getCachedUserBlogs() async {
    try {
      final data = await _getCacheData(_userBlogsKey);
      if (data != null) {
        final blogs = jsonDecode(data) as List<dynamic>;
        _logger.d('Retrieved ${blogs.length} cached user blogs');
        return blogs;
      }
    } catch (e) {
      _logger.e('Error getting cached user blogs: $e');
    }
    return null;
  }

  /// Check if user blogs cache is valid
  Future<bool> hasValidUserBlogsCache() async {
    return await _isCacheValid(_userBlogsKey);
  }

  /// Clear user blogs cache
  Future<void> clearUserBlogsCache() async {
    await _deleteCacheData(_userBlogsKey);
    _logger.i('User blogs cache cleared');
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

  //* <----------------- MY DONATIONS CACHE ------------------------------>

  Future<void> cacheMyDonations(List<dynamic> requests) async {
    await _setCacheData(_myDonationsKey, jsonEncode(requests));
  }

  Future<List<dynamic>?> getCachedMyDonations() async {
    final data = await _getCacheData(_myDonationsKey);
    if (data != null) return jsonDecode(data) as List<dynamic>;
    return null;
  }

  Future<bool> hasValidMyDonationsCache() async {
    return await _isCacheValid(_myDonationsKey);
  }

  Future<void> clearMyDonationsCache() async {
    await _deleteCacheData(_myDonationsKey);
  }

  //* <----------------- MEDICAL CENTERS ALL CACHE ------------------------------>

  Future<void> cacheMedicalCentersAll(List<dynamic> centers) async {
    await _setCacheData(_medicalCentersAllKey, jsonEncode(centers));
  }

  Future<List<dynamic>?> getCachedMedicalCentersAll() async {
    final data = await _getCacheData(_medicalCentersAllKey);
    if (data != null) return jsonDecode(data) as List<dynamic>;
    return null;
  }

  Future<bool> hasValidMedicalCentersAllCache() async {
    return await _isCacheValid(_medicalCentersAllKey);
  }

  Future<void> clearMedicalCentersAllCache() async {
    await _deleteCacheData(_medicalCentersAllKey);
  }

  //* <----------------- MEDICAL CENTERS NEARBY CACHE ------------------------------>

  Future<void> cacheMedicalCentersNearby(List<dynamic> centers) async {
    await _setCacheData(_medicalCentersNearbyKey, jsonEncode(centers));
  }

  Future<List<dynamic>?> getCachedMedicalCentersNearby() async {
    final data = await _getCacheData(_medicalCentersNearbyKey);
    if (data != null) return jsonDecode(data) as List<dynamic>;
    return null;
  }

  Future<bool> hasValidMedicalCentersNearbyCache() async {
    return await _isCacheValid(_medicalCentersNearbyKey);
  }

  Future<void> clearMedicalCentersNearbyCache() async {
    await _deleteCacheData(_medicalCentersNearbyKey);
  }

  //*<-------------- CLEAR ALL CACHE ---------------------- >
  Future<void> clearAllCache() async {
    await _deleteCacheData(_userProfileKey);
    await _deleteCacheData(_medicinesKey);
    await _deleteCacheData(_medicinesHistoryKey);
    await _deleteCacheData(_notificationsKey);
    await _deleteCacheData(_blogsKey);
    await _deleteCacheData(_userBlogsKey);
    await _deleteCacheData(_chatHistoryKey);
    await _deleteCacheData(_ragHistoryKey);
    await _deleteCacheData(_myDonationsKey);
    await _deleteCacheData(_medicalCentersAllKey);
    await _deleteCacheData(_medicalCentersNearbyKey);
    await _secureStorage.delete(key: _lastSyncKey);
    _logger.i('All cache cleared');
  }

  //* <--------------- CACHE STATISTICS ----------------------->

  Future<Map<String, bool>> getCacheStatus() async {
    return {
      'userProfile': await hasValidUserProfileCache(),
      'medicines': await hasValidMedicinesCache(),
      'medicinesHistory': await hasValidMedicHistory(),
      'notifications': await hasValidNotificationsCache(),
      'blogs': await hasValidBlogsCache(),
      'userBlogs': await hasValidUserBlogsCache(),
      'chatHistory': await hasValidChatHistoryCache(),
      'ragHistory': await hasValidRagHistoryCache(),
      'myDonations': await hasValidMyDonationsCache(),
      'medicalCentersAll': await hasValidMedicalCentersAllCache(),
      'medicalCentersNearby': await hasValidMedicalCentersNearbyCache(),
    };
  }

  //* <--------------- CACHE SIZE INFO ----------------------->

  /// Get information about cached data sizes
  Future<Map<String, int>> getCacheSizes() async {
    try {
      final blogs = await getCachedBlogs();
      final userBlogs = await getCachedUserBlogs();
      final notifications = await getCachedNotifications();

      return {
        'blogsCount': blogs?.length ?? 0,
        'userBlogsCount': userBlogs?.length ?? 0,
        'notificationsCount': notifications?.length ?? 0,
      };
    } catch (e) {
      _logger.e('Error getting cache sizes: $e');
      return {
        'blogsCount': 0,
        'userBlogsCount': 0,
        'notificationsCount': 0,
      };
    }
  }
}
