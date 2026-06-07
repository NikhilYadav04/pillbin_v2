import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/cache/cache_manager.dart';
import 'package:pillbin/features/locations/data/network/medical_center_services.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/user_model.dart';
import 'package:pillbin/network/utils/http_client.dart';

import '../../../../network/models/medical_center_model.dart';

class MedicalCenterProvider extends ChangeNotifier {
  //* service
  final MedicalCenterServices _medicalCenterServices = MedicalCenterServices();
  final CacheManager _cacheManager = CacheManager();
  final HttpClient _httpClient = HttpClient();

  String? _lastError;
  String? get lastError => _lastError;

  //* For fetched centers by distance
  List<MedicalCenter> _fetchedCenters = [];
  List<MedicalCenter> _filteredFetchCenters = [];
  List<MedicalCenter> get fetchedCenters =>
      _isSearchActiveFetch ? _filteredFetchCenters : _fetchedCenters;

  bool _isSearchActiveFetch = false;
  bool get isSearchActiveFetch => _isSearchActiveFetch;

  void updateFilterSearchFetch(List<MedicalCenter> centers) {
    _isSearchActiveFetch = true;
    _filteredFetchCenters = centers;
    notifyListeners();
  }

  void clearFilterSearchFetch() {
    _isSearchActiveFetch = false;
    notifyListeners();
  }

  //* For all centers api
  List<MedicalCenter> _allCenters = [];
  List<MedicalCenter> _filteredAllCenters = [];
  List<MedicalCenter> get allCenters =>
      _isSearchActive ? _filteredAllCenters : _allCenters;

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  bool _isSearchAPI = false;
  bool get isSearchAPI => _isSearchAPI;

  void updateFilterSearch(List<MedicalCenter> centers) {
    _isSearchActive = true;
    _filteredAllCenters = centers;
    notifyListeners();
  }

  void clearFilterSearch() {
    _isSearchActive = false;
    notifyListeners();
  }

  int _totalCount = 0;
  int get totalCount => _totalCount;

  int _fetchedCount = 0;
  int get fetchedCount => _fetchedCount;

  double _latitude = 0.0;
  double get latitude => _latitude;

  double _longitude = 0.0;
  double get longitude => _longitude;

  String _placeName = "";
  String get placeName => _placeName;

  //* pagination
  int _page = 1;
  int get page => _page;

  int _limit = 3;
  int get limit => _limit;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _pageFetch = 1;
  int get pageFetch => _pageFetch;

  int _limitFetch = 3;
  int get limitFetch => _limitFetch;

  bool _hasMoreFetch = true;
  bool get hasMoreFetch => _hasMoreFetch;

  bool _isLoadingFetch = false;
  bool get isLoadingFetch => _isLoadingFetch;

  bool _isLoadingNearby = false;
  bool get isLoadingNearby => _isLoadingNearby;

  void resetAllCenters() {
    _isSearchAPI = false;
    _isLoading = false;
    _allCenters = [];
    _hasMore = true;
    _page = 1;
    notifyListeners();
  }

  void resetFetch() {
    _isLoadingNearby = false;
    _isLoadingFetch = false;
    _fetchedCenters = [];
    _hasMoreFetch = true;
    _pageFetch = 1;
    notifyListeners();
  }

  //* Location methods
  /// [userModel] is passed from the UI (read from UserProvider there) to avoid
  /// provider-to-provider context dependency.
  /// Returns 'denied' | 'denied_forever' | 'disabled' | 'success'
  Future<String> setLocation(bool current, UserModel userModel) async {
    _lastError = null;
    _placeName = userModel.location?.name ?? "Mr. X";

    if (current) {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _lastError = 'Please enable location services first.';
        return 'disabled';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _lastError = 'Location permission is required.';
          return 'denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _lastError =
            'Location permission is permanently denied. Please enable it from settings.';
        return 'denied_forever';
      }

      Position location = await Geolocator.getCurrentPosition();
      _latitude = location.latitude;
      _longitude = location.longitude;
      notifyListeners();
    } else {
      _latitude = userModel.location?.coordinates?.latitude ?? 0.0;
      _longitude = userModel.location?.coordinates?.longitude ?? 0.0;
      notifyListeners();
    }
    return 'success';
  }

  //* Add medical Center
  Future<String> addMedicalCenter({
    required String name,
    required String address,
    required String phoneNumber,
    required double latitude,
    required double longitude,
    required List<String> acceptedMedicineTypes,
    required Map<String, Map<String, String>> operatingHours,
    required String facilityType,
    String? website,
    String? email,
    List<String>? specialServices,
  }) async {
    try {
      _lastError = null;
      ApiResponse<Map<String, dynamic>> response =
          await _medicalCenterServices.addMedicalCenter(
              name: name,
              address: address,
              phoneNumber: phoneNumber,
              latitude: latitude,
              longitude: longitude,
              acceptedMedicineTypes: acceptedMedicineTypes,
              operatingHours: operatingHours,
              facilityType: facilityType,
              specialServices: specialServices,
              email: email,
              website: website);

      if (response.statusCode == 201) {
        return 'success';
      } else if (response.statusCode == 400) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Error adding medical center!';
        return 'error';
      }
    } catch (e) {
      _lastError = 'Error adding medical center!';
      Logger().d(e.toString());
      return 'error';
    }
  }

  //* Update Medical center
  Future<String> updateMedicalCenter({
    required String medicalCenterId,
    String? name,
    String? address,
    String? phoneNumber,
    double? latitude,
    double? longitude,
    List<String>? acceptedMedicineTypes,
    Map<String, Map<String, String>>? operatingHours,
    String? facilityType,
    String? website,
    String? email,
    List<String>? specialServices,
  }) async {
    try {
      _lastError = null;
      ApiResponse<Map<String, dynamic>> response =
          await _medicalCenterServices.editMedicalCenter(
              medicalCenterId: medicalCenterId,
              name: name,
              address: address,
              phoneNumber: phoneNumber,
              latitude: latitude,
              longitude: longitude,
              acceptedMedicineTypes: acceptedMedicineTypes,
              operatingHours: operatingHours,
              facilityType: facilityType,
              website: website,
              email: email,
              specialServices: specialServices);

      if (response.statusCode == 200) {
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Error updating medical center!';
        return 'error';
      }
    } catch (e) {
      _lastError = 'Error updating medical center!';
      print(e.toString());
      return 'error';
    }
  }

  //* Delete Medical center
  Future<String> deleteMedicalCenter({required String medicalCenterId}) async {
    try {
      _lastError = null;
      if (medicalCenterId.isEmpty) {
        _lastError = 'ID is required!';
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response = await _medicalCenterServices
          .deleteMedicalCenter(medicalCenterId: medicalCenterId);

      if (response.statusCode == 200) {
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Error deleting medical center!';
        return 'error';
      }
    } catch (e) {
      _lastError = 'Error deleting medical center!';
      print(e.toString());
      return 'error';
    }
  }

  //* Get All Medical Centers
  Future<String> getAllMedicalCenters() async {
    try {
      _lastError = null;
      _isLoading = true;
      notifyListeners();

      final isOnline = _httpClient.isOnline;

      // Priority 1: serve from cache on first page when offline or cache valid
      if (_page == 1 &&
          (!isOnline ||
              await _cacheManager.hasValidMedicalCentersAllCache())) {
        final cached = await _cacheManager.getCachedMedicalCentersAll();
        if (cached != null) {
          _allCenters = cached
              .map((item) =>
                  MedicalCenter.fromJson(item as Map<String, dynamic>))
              .where((c) =>
                  c.verificationStatus == null ||
                  c.verificationStatus == 'approved')
              .toList();
          _hasMore = false;
          _isLoading = false;
          Logger().d('Medical centers loaded from cache: ${_allCenters.length}');
          notifyListeners();
          return isOnline ? 'success' : 'success_cache';
        }
      }

      // Priority 2: fetch from API
      ApiResponse<Map<String, dynamic>> response = await _medicalCenterServices
          .getAllMedicalCenters(page: _page, limit: _limit);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        List<MedicalCenter> medicalCenters = (data["medicalCenters"] as List)
            .map((item) => MedicalCenter.fromJson(item as Map<String, dynamic>))
            .where((c) =>
                c.verificationStatus == null ||
                c.verificationStatus == 'approved')
            .toList();

        _totalCount = data["pagination"]["totalCenters"];
        _allCenters.addAll(medicalCenters);

        int currentPage = data["pagination"]["currentPage"];
        int totalPage = data["pagination"]["totalPages"];

        if (currentPage >= totalPage) {
          _hasMore = false;
          // Cache the full accumulated list once all pages are loaded
          await _cacheManager.cacheMedicalCentersAll(
              _allCenters.map((c) => c.toJson()).toList());
        } else {
          _page++;
        }

        _isLoading = false;
        notifyListeners();
        Logger().d('All centers size: ${allCenters.length}');
        return 'success';
      } else {
        // Priority 3: fallback to cache on API error
        final cached = await _cacheManager.getCachedMedicalCentersAll();
        if (cached != null && _allCenters.isEmpty) {
          _allCenters = cached
              .map((item) =>
                  MedicalCenter.fromJson(item as Map<String, dynamic>))
              .where((c) =>
                  c.verificationStatus == null ||
                  c.verificationStatus == 'approved')
              .toList();
          _hasMore = false;
          _isLoading = false;
          notifyListeners();
          return 'success_cache';
        }
        _isLoading = false;
        _lastError = 'Error displaying medical centers!';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      // Priority 3: fallback to cache on exception
      final cached = await _cacheManager.getCachedMedicalCentersAll();
      if (cached != null && _allCenters.isEmpty) {
        _allCenters = cached
            .map((item) => MedicalCenter.fromJson(item as Map<String, dynamic>))
            .where((c) =>
                c.verificationStatus == null ||
                c.verificationStatus == 'approved')
            .toList();
        _hasMore = false;
        _isLoading = false;
        notifyListeners();
        return 'success_cache';
      }
      _isLoading = false;
      _lastError = 'Error displaying medical centers!';
      notifyListeners();
      Logger().e(e.toString());
      return 'error';
    }
  }

  //* Get Nearby Medical Centers
  Future<String> getNearbyMedicalCenters({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    try {
      _lastError = null;
      if (_isLoadingNearby || !_hasMoreFetch) return 'blocked';

      if (_pageFetch == 1) {
        _isLoadingFetch = true;
      } else {
        _isLoadingNearby = true;
      }
      notifyListeners();

      final isOnline = _httpClient.isOnline;

      // Priority 1: serve from cache on first page when offline
      if (_pageFetch == 1 && !isOnline) {
        final cached = await _cacheManager.getCachedMedicalCentersNearby();
        if (cached != null) {
          _fetchedCenters = cached
              .map((item) => MedicalCenter.fromJson(item as Map<String, dynamic>))
              .where((c) =>
                  c.verificationStatus == null ||
                  c.verificationStatus == 'approved')
              .toList();
          _hasMoreFetch = false;
          _isLoadingFetch = false;
          _isLoadingNearby = false;
          Logger().d('Nearby centers loaded from cache: ${_fetchedCenters.length}');
          notifyListeners();
          return 'success_cache';
        }
      }

      // Priority 2: fetch from API
      ApiResponse<Map<String, dynamic>> response =
          await _medicalCenterServices.getNearByMedicalCenters(
              latitude: latitude,
              longitude: longitude,
              radius: radius,
              page: _pageFetch,
              limit: _limitFetch);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        List<MedicalCenter> medicalCenters = (data["medicalCenters"] as List)
            .map((item) => MedicalCenter.fromJson(item))
            .where((c) =>
                c.verificationStatus == null ||
                c.verificationStatus == 'approved')
            .toList();

        if (_pageFetch == 1) {
          _fetchedCenters = medicalCenters;
          // Cache the first page of nearby results
          await _cacheManager.cacheMedicalCentersNearby(
              medicalCenters.map((c) => c.toJson()).toList());
        } else {
          _fetchedCenters.addAll(medicalCenters);
        }

        _fetchedCount = data["pagination"]["totalFound"];

        int currentPage = data["pagination"]["currentPage"];
        int totalPage = data["pagination"]["totalPages"];

        if (currentPage >= totalPage) {
          _hasMoreFetch = false;
        } else {
          _pageFetch++;
        }

        _isLoadingFetch = false;
        _isLoadingNearby = false;
        notifyListeners();
        return 'success';
      } else if (response.statusCode == 400) {
        // Priority 3: fallback to cache on error
        if (_pageFetch == 1 && _fetchedCenters.isEmpty) {
          final cached = await _cacheManager.getCachedMedicalCentersNearby();
          if (cached != null) {
            _fetchedCenters = cached
                .map((item) =>
                    MedicalCenter.fromJson(item as Map<String, dynamic>))
                .where((c) =>
                    c.verificationStatus == null ||
                    c.verificationStatus == 'approved')
                .toList();
            _hasMoreFetch = false;
            _isLoadingFetch = false;
            _isLoadingNearby = false;
            notifyListeners();
            return 'success_cache';
          }
        }
        _isLoadingNearby = false;
        _isLoadingFetch = false;
        _lastError = response.message;
        notifyListeners();
        return 'error';
      } else {
        _isLoadingNearby = false;
        _isLoadingFetch = false;
        _lastError = 'Error searching medical centers!';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      // Priority 3: fallback to cache on exception
      if (_pageFetch == 1 && _fetchedCenters.isEmpty) {
        final cached = await _cacheManager.getCachedMedicalCentersNearby();
        if (cached != null) {
          _fetchedCenters = cached
              .map((item) =>
                  MedicalCenter.fromJson(item as Map<String, dynamic>))
              .where((c) =>
                  c.verificationStatus == null ||
                  c.verificationStatus == 'approved')
              .toList();
          _hasMoreFetch = false;
          _isLoadingFetch = false;
          _isLoadingNearby = false;
          notifyListeners();
          return 'success_cache';
        }
      }
      _isLoadingNearby = false;
      _isLoadingFetch = false;
      _lastError = 'Error searching medical centers!';
      notifyListeners();
      Logger().e(e.toString());
      return 'error';
    }
  }

  //* Search medical Centers
  Future<String> searchMedicalCenters({
    required String query,
    required String facilityType,
  }) async {
    try {
      _lastError = null;
      _isLoadingFetch = true;
      _isSearchActive = false;
      _isSearchAPI = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _medicalCenterServices.searchMedicalCenters(
              query: query,
              facilityType: facilityType,
              page: _page,
              limit: _limit);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        List<MedicalCenter> medicalCenters = (data["medicalCenters"] as List)
            .map((item) => MedicalCenter.fromJson(item))
            .where((c) =>
                c.verificationStatus == null ||
                c.verificationStatus == 'approved')
            .toList();

        _allCenters = medicalCenters;

        _fetchedCount = data["pagination"]["totalFound"];

        int currentPage = data["pagination"]["currentPage"];
        int totalPage = data["pagination"]["totalPages"];

        if (currentPage >= totalPage) {
          _hasMore = false;
        } else {
          _pageFetch++;
        }

        _isLoadingFetch = false;
        notifyListeners();
        return 'success';
      } else if (response.statusCode == 400) {
        _isSearchAPI = false;
        _isLoadingFetch = false;
        _lastError = response.message;
        notifyListeners();
        return 'error';
      } else {
        _isSearchAPI = false;
        _isLoadingFetch = false;
        _lastError = 'Error searching medical centers!';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      _isSearchAPI = false;
      _isLoadingFetch = false;
      _lastError = 'Error searching medical centers!';
      notifyListeners();
      print(e.toString());
      return 'error';
    }
  }

  //* Get medical center by Id
  Future<String> getMedicalCenterbyId({required String medicalCenterId}) async {
    try {
      _lastError = null;
      if (medicalCenterId.isEmpty) {
        _lastError = 'Error getting details!';
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response = await _medicalCenterServices
          .getMedicalCenterbyID(medicalCenterId: medicalCenterId);

      if (response.statusCode == 200) {
        return 'success';
      } else {
        _lastError = response.message;
        return 'error';
      }
    } catch (e) {
      _lastError = 'Error getting details!';
      print(e.toString());
      return 'error';
    }
  }

  //* <---------Reset-------------->
  Future<void> reset() async {
    _fetchedCenters.clear();
    _filteredFetchCenters.clear();
    _allCenters.clear();
    _filteredAllCenters.clear();

    _isSearchActiveFetch = false;
    _isSearchActive = false;
    _isSearchAPI = false;
    _isLoading = false;
    _isLoadingFetch = false;
    _isLoadingNearby = false;

    _page = 1;
    _limit = 3;
    _hasMore = true;

    _pageFetch = 1;
    _limitFetch = 3;
    _hasMoreFetch = true;

    _totalCount = 0;
    _fetchedCount = 0;

    _latitude = 0.0;
    _longitude = 0.0;
    _placeName = "";

    notifyListeners();
  }
}
