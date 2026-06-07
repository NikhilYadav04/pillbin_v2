import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pillbin/config/cache/cache_manager.dart';
import 'package:pillbin/features/donation/data/service/donation_service.dart';
import 'package:pillbin/network/utils/http_client.dart';

class DonationProvider extends ChangeNotifier {
  final DonationService _service = DonationService();
  final CacheManager _cacheManager = CacheManager();
  final HttpClient _httpClient = HttpClient();

  List<Map<String, dynamic>> _myRequests = [];
  List<Map<String, dynamic>> get myRequests => _myRequests;

  // Center inventory cached for the donation form
  Map<String, dynamic>? _centerInventory;
  Map<String, dynamic>? get centerInventory => _centerInventory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _lastError;
  String? get lastError => _lastError;

  // ── Submit a donation request ──
  Future<bool> submitRequest(Map<String, dynamic> data,
      {List<File> photos = const []}) async {
    _isSubmitting = true;
    _lastError = null;
    notifyListeners();
    final response = await _service.submitRequest(data, photos: photos);
    _isSubmitting = false;
    if (response.statusCode == 201) {
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }

  // ── Fetch user's own requests ──
  Future<void> fetchMyRequests({String? status, int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    final isOnline = _httpClient.isOnline;

    // Priority 1: serve from cache when offline or cache is still valid
    // Only cache the full list (status == null); filtered tabs use in-memory data
    if (status == null &&
        (!isOnline || await _cacheManager.hasValidMyDonationsCache())) {
      final cached = await _cacheManager.getCachedMyDonations();
      if (cached != null) {
        _myRequests = List<Map<String, dynamic>>.from(cached);
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    // Priority 2: fetch from API when online
    if (isOnline) {
      try {
        final response =
            await _service.getMyRequests(status: status, page: page);
        _isLoading = false;
        if (response.statusCode == 200) {
          final data = response.data?['requests'];
          _myRequests =
              data != null ? List<Map<String, dynamic>>.from(data) : [];
          // Cache only the full unfiltered list
          if (status == null) {
            await _cacheManager.cacheMyDonations(_myRequests);
          }
        }
        notifyListeners();
        return;
      } catch (_) {
        // fall through to cache fallback
      }
    }

    // Priority 3: fallback — load from cache even if expired
    final cached = await _cacheManager.getCachedMyDonations();
    if (cached != null) {
      _myRequests = List<Map<String, dynamic>>.from(cached);
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Cancel a pending request ──
  Future<bool> cancelRequest(String id) async {
    _lastError = null;
    final response = await _service.cancelRequest(id);
    if (response.statusCode == 200) {
      _myRequests.removeWhere((r) => r['_id'] == id);
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }

  // ── Load inventory for a center (for the donation form) ──
  Future<void> loadCenterInventory(String centerId) async {
    _centerInventory = null;
    notifyListeners();
    final response = await _service.getCenterInventory(centerId);
    if (response.statusCode == 200) {
      _centerInventory = response.data;
    }
    notifyListeners();
  }
}
