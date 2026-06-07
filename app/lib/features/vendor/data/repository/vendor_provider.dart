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

  // ── Requests state ──
  List<DonationRequest> _requests = [];
  List<DonationRequest> get requests => _requests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _requestsTotal = 0;
  int get requestsTotal => _requestsTotal;

  String? _lastError;
  String? get lastError => _lastError;

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
  Future<void> fetchMyCenter() async {
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
  Future<void> fetchRequests(
      {String? status, int page = 1, int limit = 10}) async {
    _isLoading = true;
    notifyListeners();
    final response =
        await _service.getRequests(status: status, page: page, limit: limit);
    _isLoading = false;
    if (response.statusCode == 200) {
      final data = response.data?['requests'] as List?;
      _requests = data != null
          ? data.map((r) => DonationRequest.fromJson(r as Map<String, dynamic>)).toList()
          : [];
      _requestsTotal = response.data?['pagination']?['total'] ?? 0;
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
      final idx = _requests.indexWhere((r) => r.id == requestId);
      if (idx != -1) {
        _requests[idx] = _requests[idx].copyWith(
          status: status,
          vendorNote: vendorNote,
        );
      }
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

  // ── Complete request ──
  Future<bool> completeRequest(String requestId) async {
    _lastError = null;
    final response = await _service.completeRequest(requestId);
    if (response.statusCode == 200) {
      final idx = _requests.indexWhere((r) => r.id == requestId);
      if (idx != -1) {
        _requests[idx] = _requests[idx].copyWith(status: 'completed');
      }
      notifyListeners();
      return true;
    }
    _lastError = response.message;
    notifyListeners();
    return false;
  }
}
