import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pillbin/config/cache/cache_manager.dart';
import 'package:pillbin/features/donation/data/service/donation_service.dart';
import 'package:pillbin/network/models/medicine_model.dart';

class DonationProvider extends ChangeNotifier {
  final DonationService _service = DonationService();
  final CacheManager _cacheManager = CacheManager();

  // ── My requests, one page stack per status tab ──
  static const int _requestsPageSize = 20;

  final Map<String, List<Map<String, dynamic>>> _requestsByStatus = {};
  final Map<String, int> _requestsPage = {};
  final Map<String, bool> _requestsHasMore = {};
  final Map<String, int> _requestsTotal = {};

  String _statusKey(String? status) => status ?? 'all';

  List<Map<String, dynamic>> requestsFor(String? status) =>
      _requestsByStatus[_statusKey(status)] ?? const [];

  bool hasMoreRequests(String? status) =>
      _requestsHasMore[_statusKey(status)] ?? true;

  int requestsTotal(String? status) => _requestsTotal[_statusKey(status)] ?? 0;

  List<Map<String, dynamic>> get myRequests => requestsFor(null);

  //* A cancel or a new review can land on a row held in several tabs, so the
  //* patch has to reach every cached list
  void _patchRequest(
      String id, Map<String, dynamic> Function(Map<String, dynamic>) update) {
    for (final entry in _requestsByStatus.entries) {
      final index = entry.value.indexWhere((r) => r['_id'] == id);
      if (index != -1) entry.value[index] = update(entry.value[index]);
    }
  }

  void invalidateRequests() {
    _requestsByStatus.clear();
    _requestsPage.clear();
    _requestsHasMore.clear();
    _requestsTotal.clear();
  }

  // Center inventory cached for the donation form
  Map<String, dynamic>? _centerInventory;
  Map<String, dynamic>? get centerInventory => _centerInventory;

  // Medicines staged from the inventory screens, consumed once the
  // donation form opens (the user picks the center in between).
  List<Medicine> _stagedMedicines = [];

  void stageMedicines(List<Medicine> medicines) {
    _stagedMedicines = List<Medicine>.from(medicines);
  }

  List<Medicine> consumeStagedMedicines() {
    final staged = _stagedMedicines;
    _stagedMedicines = [];
    return staged;
  }

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
  Future<void> _fetchRequestsPage(String? status, int page,
      {bool replace = false}) async {
    final key = _statusKey(status);
    _isLoading = true;
    notifyListeners();

    //* Only the unfiltered first page can be answered from cache, and only as
    //* a fast path — never as a reason to skip the network
    if (status == null &&
        page == 1 &&
        await _cacheManager.hasValidMyDonationsCache()) {
      final cached = await _cacheManager.getCachedMyDonations();
      if (cached != null) {
        _requestsByStatus[key] = _fromCache(cached, status);
        _requestsPage[key] = 1;
        _requestsHasMore[key] = false;
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    //* Always attempt the request. HttpClient.isOnline is sticky — one timeout
    //* leaves it false until a request succeeds, so gating on it here would
    //* mean never trying again and never recovering.
    try {
      final response = await _service.getMyRequests(
          status: status, page: page, limit: _requestsPageSize);
      _isLoading = false;

      if (response.statusCode == 200) {
        final data = response.data?['requests'] as List? ?? [];
        final incoming =
            data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        final pagination = response.data?['pagination'] as Map? ?? const {};
        final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;

        _requestsByStatus[key] = replace
            ? incoming
            : [...(_requestsByStatus[key] ?? []), ...incoming];
        _requestsTotal[key] =
            (pagination['total'] as num?)?.toInt() ?? incoming.length;
        _requestsPage[key] = page;
        _requestsHasMore[key] = page < totalPages;

        //* Cache page one of the unfiltered list for offline use
        if (status == null && page == 1) {
          await _cacheManager.cacheMyDonations(_requestsByStatus[key]!);
        }
        notifyListeners();
        return;
      }

      _lastError = response.message;
    } catch (_) {
      // fall through to the stale-cache fallback
      _isLoading = false;
    }

    //* Genuinely unreachable: show whatever the cache holds for this tab
    final cached = await _cacheManager.getCachedMyDonations();
    if (page == 1 && cached != null) {
      _requestsByStatus[key] = _fromCache(cached, status);
      _requestsHasMore[key] = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _fromCache(List cached, String? status) {
    final rows = cached.map((e) => Map<String, dynamic>.from(e as Map));
    return status == null
        ? rows.toList()
        : rows.where((r) => r['status'] == status).toList();
  }

  //* Loads page one only if this tab has never been loaded, so switching back
  //* to an already-visited tab costs nothing
  Future<void> ensureMyRequests({String? status}) async {
    if (_isLoading) return;
    if (_requestsByStatus.containsKey(_statusKey(status))) return;
    await _fetchRequestsPage(status, 1, replace: true);
  }

  Future<void> loadMoreMyRequests({String? status}) async {
    final key = _statusKey(status);
    if (_isLoading) return;
    if (!(_requestsHasMore[key] ?? true)) return;
    await _fetchRequestsPage(status, (_requestsPage[key] ?? 1) + 1);
  }

  Future<void> refreshMyRequests({String? status}) async {
    if (_isLoading) return;
    await _fetchRequestsPage(status, 1, replace: true);
  }

  // ── Cancel a pending request ──
  Future<bool> cancelRequest(String id) async {
    _lastError = null;
    final response = await _service.cancelRequest(id);
    if (response.statusCode == 200) {
      //* The request is kept server-side as 'cancelled', not deleted — and it
      //* moves between tabs, so every cached page is stale
      invalidateRequests();
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }

  // ── Review a completed donation ──
  Future<bool> submitReview(String requestId,
      {required int rating, String? comment}) async {
    _lastError = null;
    final response = await _service.submitReview(requestId,
        rating: rating, comment: comment);

    if (response.statusCode == 201) {
      final created = response.data?['review'];
      _patchRequest(requestId, (r) => {
            ...r,
            'myReview': {
              if (created is Map) '_id': created['_id'],
              'rating': rating,
              'comment': comment,
            },
          });
      _clearReviewCache();
      notifyListeners();
      return true;
    }

    _lastError = response.message;
    notifyListeners();
    return false;
  }

  void reset() {
    invalidateRequests();
    _centerInventory = null;
    _stagedMedicines = [];
    _isLoading = false;
    _isSubmitting = false;
    _lastError = null;
    _clearReviewCache();
    _reviewSummary.clear();
    notifyListeners();
  }

  // ── Center reviews, paginated per center and per star filter ──
  final Map<String, List<Map<String, dynamic>>> _reviews = {};
  final Map<String, int> _reviewPage = {};
  final Map<String, bool> _reviewHasMore = {};
  final Map<String, Map<String, dynamic>> _reviewSummary = {};

  bool _isLoadingReviews = false;
  bool get isLoadingReviews => _isLoadingReviews;

  //* Filter is part of the key — a 5-star list and an all list are separate
  //* pages, so mixing them would corrupt both
  String _reviewKey(String centerId, int? rating) => '$centerId|${rating ?? 0}';

  List<Map<String, dynamic>> reviewsFor(String centerId, {int? rating}) =>
      _reviews[_reviewKey(centerId, rating)] ?? const [];

  bool hasMoreReviews(String centerId, {int? rating}) =>
      _reviewHasMore[_reviewKey(centerId, rating)] ?? true;

  Map<String, dynamic>? reviewSummary(String centerId) =>
      _reviewSummary[centerId];

  void _clearReviewCache() {
    _reviews.clear();
    _reviewPage.clear();
    _reviewHasMore.clear();
  }

  Future<void> loadCenterReviews(String centerId,
      {int? rating, bool reset = false}) async {
    final key = _reviewKey(centerId, rating);
    if (_isLoadingReviews) return;

    if (reset) {
      _reviews[key] = [];
      _reviewPage[key] = 1;
      _reviewHasMore[key] = true;
    }
    if (!(_reviewHasMore[key] ?? true)) return;

    _isLoadingReviews = true;
    notifyListeners();

    final page = _reviewPage[key] ?? 1;
    final response = await _service.getCenterReviews(centerId,
        page: page, rating: rating);
    _isLoadingReviews = false;

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data!;
      final incoming = (data['reviews'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      final pagination = data['pagination'] as Map? ?? const {};
      final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;

      _reviews[key] = [...(_reviews[key] ?? []), ...incoming];
      _reviewPage[key] = page + 1;
      _reviewHasMore[key] = page < totalPages;

      final summary = data['summary'];
      if (summary is Map) {
        _reviewSummary[centerId] = Map<String, dynamic>.from(summary);
      }
    } else {
      _lastError = response.message;
    }
    notifyListeners();
  }

  //* Short-lived token the donor renders as a QR at the counter
  Future<String?> fetchHandoffToken(String requestId) async {
    _lastError = null;
    final response = await _service.getHandoffToken(requestId);

    if (response.statusCode == 200) {
      return response.data?['token'] as String?;
    }

    _lastError = response.message;
    notifyListeners();
    return null;
  }

  Future<bool> deleteReview(String reviewId) async {
    _lastError = null;
    final response = await _service.deleteReview(reviewId);

    if (response.statusCode == 200) {
      for (final list in _requestsByStatus.values) {
        for (var i = 0; i < list.length; i++) {
          if ((list[i]['myReview'] as Map?)?['_id'] == reviewId) {
            final copy = Map<String, dynamic>.from(list[i]);
            copy.remove('myReview');
            list[i] = copy;
          }
        }
      }
      _clearReviewCache();
      _reviewSummary.clear();
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
