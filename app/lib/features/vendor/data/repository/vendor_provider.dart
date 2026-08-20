import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pillbin/features/vendor/data/models/vendor_models.dart';
import 'package:pillbin/features/vendor/data/service/vendor_service.dart';

class VendorProvider extends ChangeNotifier {
  final VendorService _service = VendorService();

  // ── Center state ──
  VendorCenter? _center;
  VendorCenter? get center => _center;

  // ── Inventory state ──
  List<InventoryItem> _inventory = [];
  List<InventoryItem> get inventory => _inventory;

  // ── Requests state, one page stack per status tab ──
  static const int _requestsPageSize = 20;

  final Map<String, List<DonationRequest>> _requestsByStatus = {};
  final Map<String, int> _requestsPage = {};
  final Map<String, bool> _requestsHasMore = {};
  final Map<String, int> _requestsTotal = {};

  String _statusKey(String? status) => status ?? 'all';

  List<DonationRequest> requestsFor(String? status) =>
      _requestsByStatus[_statusKey(status)] ?? const [];

  bool hasMoreRequests(String? status) =>
      _requestsHasMore[_statusKey(status)] ?? true;

  int requestsTotal(String? status) =>
      _requestsTotal[_statusKey(status)] ?? 0;

  //* Server count, not the loaded rows — the badge stays right past page one
  int get pendingCount => _requestsTotal['pending'] ?? 0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _lastError;
  String? get lastError => _lastError;

  final Map<String, DateTime> _lastFetch = {};

  bool _fresh(String key, Duration ttl) {
    final last = _lastFetch[key];
    return last != null && DateTime.now().difference(last) < ttl;
  }

  void _stamp(String key) => _lastFetch[key] = DateTime.now();

  void invalidate() {
    _lastFetch.clear();
  }

  //* Everything here is scoped to one vendor account, including the throttle
  //* stamps — leaving those set would make the next account's data look fresh
  //* and skip the fetch entirely
  void reset() {
    _center = null;
    _inventory = [];
    invalidateRequests();
    _isLoading = false;
    _lastError = null;

    _analytics = null;
    _isLoadingAnalytics = false;
    _analyticsMonths = 6;

    _reviews = [];
    _isLoadingReviews = false;
    _allReviews = [];
    _reviewsPage = 1;
    _hasMoreReviews = true;
    _isLoadingMoreReviews = false;
    _reviewsFilter = null;

    _donatedMedicines = [];
    _medicinesPage = 1;
    _hasMoreMedicines = true;
    _isLoadingMedicines = false;

    invalidate();
    notifyListeners();
  }

  // ── Register / claim center ──
  Future<bool> registerCenter(Map<String, dynamic> data) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    final response = await _service.registerCenter(data);
    _isLoading = false;
    if (response.statusCode == 201) {
      final raw = response.data?['medicalCenter'];
      if (raw != null) _center = VendorCenter.fromJson(raw);
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }

  // ── Fetch own center ──
  Future<void> fetchMyCenter({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _center != null &&
        _fresh('center', const Duration(seconds: 60))) {
      return;
    }
    _isLoading = true;
    notifyListeners();
    final response = await _service.getMyCenter();
    _isLoading = false;
    if (response.statusCode == 200) {
      final raw = response.data?['medicalCenter'];
      if (raw != null) {
        _center = VendorCenter.fromJson(raw);
        final inv = raw['inventory'] as List?;
        _inventory = inv != null
            ? inv.map((i) => InventoryItem.fromJson(i as Map<String, dynamic>)).toList()
            : [];
      }
      _stamp('center');
    }
    notifyListeners();
  }

  // ── Update center info ──
  Future<bool> updateCenter(Map<String, dynamic> data) async {
    _lastError = null;
    final response = await _service.updateMyCenter(data);
    if (response.statusCode == 200) {
      final raw = response.data?['medicalCenter'];
      if (raw != null) _center = VendorCenter.fromJson(raw);
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }

  // ── Update center images (max 3) ──
  Future<bool> updateCenterImages(List<File> images,
      {List<String> keepPublicIds = const []}) async {
    _lastError = null;
    final response =
        await _service.updateCenterImages(images, keepPublicIds: keepPublicIds);
    if (response.statusCode == 200) {
      final newImages = response.data?['images'] as List?;
      if (_center != null && newImages != null) {
        _center = _center!.copyWith(
          images: newImages
              .map((img) => VendorCenterImage.fromJson(img as Map<String, dynamic>))
              .toList(),
        );
        notifyListeners();
      }
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }

  // ── Update inventory ──
  Future<bool> updateInventory(List<InventoryItem> inventory) async {
    _lastError = null;
    final response =
        await _service.updateInventory(inventory.map((i) => i.toJson()).toList());
    if (response.statusCode == 200) {
      _inventory = inventory;
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }

  // ── Fetch donation requests ──
  Future<void> _fetchRequestsPage(String? status, int page,
      {bool replace = false}) async {
    final key = _statusKey(status);
    _isLoading = true;
    notifyListeners();

    final response = await _service.getRequests(
        status: status, page: page, limit: _requestsPageSize);
    _isLoading = false;

    if (response.statusCode == 200) {
      final data = response.data?['requests'] as List? ?? [];
      final incoming = data
          .map((r) => DonationRequest.fromJson(r as Map<String, dynamic>))
          .toList();
      final pagination = response.data?['pagination'] as Map? ?? const {};
      final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;

      _requestsByStatus[key] = replace
          ? incoming
          : [...(_requestsByStatus[key] ?? []), ...incoming];
      _requestsTotal[key] =
          (pagination['total'] as num?)?.toInt() ?? incoming.length;
      _requestsPage[key] = page;
      _requestsHasMore[key] = page < totalPages;
    } else {
      _lastError = response.message;
    }
    notifyListeners();
  }

  //* Loads page one only if this tab has never been loaded, so switching back
  //* to an already-visited tab costs nothing
  Future<void> ensureRequests({String? status}) async {
    if (_isLoading) return;
    if (_requestsByStatus.containsKey(_statusKey(status))) return;
    await _fetchRequestsPage(status, 1, replace: true);
  }

  Future<void> loadMoreRequests({String? status}) async {
    final key = _statusKey(status);
    if (_isLoading) return;
    if (!(_requestsHasMore[key] ?? true)) return;
    await _fetchRequestsPage(status, (_requestsPage[key] ?? 1) + 1);
  }

  Future<void> refreshRequests({String? status}) async {
    if (_isLoading) return;
    await _fetchRequestsPage(status, 1, replace: true);
  }

  //* A status change moves a request between tabs, so every cached tab is
  //* stale — drop them all and let the visible one reload
  void invalidateRequests() {
    _requestsByStatus.clear();
    _requestsPage.clear();
    _requestsHasMore.clear();
    _requestsTotal.clear();
  }

  // ── Analytics ──
  VendorAnalytics? _analytics;
  VendorAnalytics? get analytics => _analytics;

  bool _isLoadingAnalytics = false;
  bool get isLoadingAnalytics => _isLoadingAnalytics;

  int _analyticsMonths = 6;
  int get analyticsMonths => _analyticsMonths;

  Future<void> fetchAnalytics(
      {int months = 6, bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _analytics != null &&
        _analyticsMonths == months &&
        _fresh('analytics', const Duration(minutes: 2))) {
      return;
    }
    _isLoadingAnalytics = true;
    notifyListeners();

    final response = await _service.getAnalytics(months: months);
    _isLoadingAnalytics = false;

    if (response.statusCode == 200 && response.data != null) {
      _analytics = VendorAnalytics.fromJson(response.data!);
      _analyticsMonths = months;
      _stamp('analytics');
    } else {
      _lastError = response.message;
    }
    notifyListeners();
  }

  // ── Reviews left by donors ──
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> get reviews => _reviews;

  bool _isLoadingReviews = false;
  bool get isLoadingReviews => _isLoadingReviews;

  Future<void> fetchReviews({bool forceRefresh = false}) async {
    final centerId = _center?.id;
    if (centerId == null || centerId.isEmpty) return;
    if (!forceRefresh && _fresh('reviews', const Duration(minutes: 2))) return;

    _isLoadingReviews = true;
    notifyListeners();

    final response = await _service.getCenterReviews(centerId);
    _isLoadingReviews = false;

    if (response.statusCode == 200) {
      final data = response.data?['reviews'];
      _reviews = data != null ? List<Map<String, dynamic>>.from(data) : [];
      _stamp('reviews');
    }
    notifyListeners();
  }

  // ── Paged reviews for the reviews screen ──
  List<Map<String, dynamic>> _allReviews = [];
  List<Map<String, dynamic>> get allReviews => _allReviews;
  int _reviewsPage = 1;
  bool _hasMoreReviews = true;
  bool get hasMoreReviews => _hasMoreReviews;
  bool _isLoadingMoreReviews = false;
  bool get isLoadingMoreReviews => _isLoadingMoreReviews;

  //* Star filter lives on the server — filtering the loaded pages client-side
  //* would only ever search the reviews already fetched
  int? _reviewsFilter;
  int? get reviewsFilter => _reviewsFilter;

  Future<void> loadReviewsPage({bool reset = false, int? rating}) async {
    final centerId = _center?.id;
    if (centerId == null || centerId.isEmpty) return;
    if (_isLoadingMoreReviews) return;

    if (reset || rating != _reviewsFilter) {
      _reviewsFilter = rating;
      _reviewsPage = 1;
      _hasMoreReviews = true;
      _allReviews = [];
    }
    if (!_hasMoreReviews) return;

    _isLoadingMoreReviews = true;
    notifyListeners();

    final response = await _service.getCenterReviews(centerId,
        page: _reviewsPage, rating: _reviewsFilter);
    _isLoadingMoreReviews = false;

    if (response.statusCode == 200) {
      final data = response.data?['reviews'] as List? ?? [];
      _allReviews.addAll(List<Map<String, dynamic>>.from(data));
      final pagination = response.data?['pagination'] as Map<String, dynamic>?;
      final totalPages = pagination?['totalPages'] as int? ?? 1;
      _hasMoreReviews = _reviewsPage < totalPages;
      _reviewsPage++;
    }
    notifyListeners();
  }

  // ── Paged donated-medicine ranking ──
  List<Map<String, dynamic>> _donatedMedicines = [];
  List<Map<String, dynamic>> get donatedMedicines => _donatedMedicines;
  int _medicinesPage = 1;
  bool _hasMoreMedicines = true;
  bool get hasMoreMedicines => _hasMoreMedicines;
  bool _isLoadingMedicines = false;
  bool get isLoadingMedicines => _isLoadingMedicines;

  Future<void> loadDonatedMedicines({bool reset = false}) async {
    if (_isLoadingMedicines) return;
    if (reset) {
      _medicinesPage = 1;
      _hasMoreMedicines = true;
      _donatedMedicines = [];
    }
    if (!_hasMoreMedicines) return;

    _isLoadingMedicines = true;
    notifyListeners();

    final response = await _service.getDonatedMedicines(page: _medicinesPage);
    _isLoadingMedicines = false;

    if (response.statusCode == 200) {
      final data = response.data?['medicines'] as List? ?? [];
      _donatedMedicines.addAll(List<Map<String, dynamic>>.from(data));
      final pagination = response.data?['pagination'] as Map<String, dynamic>?;
      final totalPages = pagination?['totalPages'] as int? ?? 1;
      _hasMoreMedicines = _medicinesPage < totalPages;
      _medicinesPage++;
    }
    notifyListeners();
  }

  // ── Approve / reject request ──
  Future<bool> updateRequestStatus(String requestId, String status,
      {String? vendorNote}) async {
    _lastError = null;
    final response = await _service.updateRequestStatus(requestId, status,
        vendorNote: vendorNote);
    if (response.statusCode == 200) {
      invalidateRequests();
      invalidate();
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }

  // ── Claim existing center ──
  Future<bool> claimCenter(String centerId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    final response = await _service.claimCenter(centerId);
    _isLoading = false;
    if (response.statusCode == 201) {
      final raw = response.data?['medicalCenter'];
      if (raw != null) _center = VendorCenter.fromJson(raw);
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }

  // ── Upload verification documents ──
  Future<bool> uploadVerificationDocs(List<File> docs) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    final response = await _service.uploadVerificationDocs(docs);
    _isLoading = false;
    if (response.statusCode == 200) {
      final newStatus = response.data?['verificationStatus'] as String?;
      if (_center != null && newStatus != null) {
        _center = _center!.copyWith(verificationStatus: newStatus);
      }
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }

  //* Completing by QR — same server path as the button, so the cached tabs
  //* are just as stale afterwards
  Future<String?> scanHandoff(String token) async {
    _lastError = null;
    final response = await _service.scanHandoff(token);

    if (response.statusCode == 200) {
      invalidateRequests();
      invalidate();
      notifyListeners();
      return null;
    }

    _lastError = response.message;
    notifyListeners();
    return response.message.isNotEmpty
        ? response.message
        : 'Could not read that code';
  }

  // ── Complete request ──
  Future<bool> completeRequest(String requestId) async {
    _lastError = null;
    final response = await _service.completeRequest(requestId);
    if (response.statusCode == 200) {
      invalidateRequests();
      invalidate();
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }
}
