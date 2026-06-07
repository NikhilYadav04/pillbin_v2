import 'package:flutter/material.dart';
import 'package:pillbin/features/profile/data/network/user_services.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/medical_center_model.dart';

class SavedCentersProvider extends ChangeNotifier {
  final UserServices _userServices = UserServices();

  List<MedicalCenter> _centers = [];
  List<MedicalCenter> _filteredCenters = [];

  List<MedicalCenter>? get centers =>
      _isSearchActive ? _filteredCenters : _centers;

  int _savedTotal = 0;
  int get savedTotal => _savedTotal;

  int _page = 1;
  int get page => _page;

  final int _limit = 10;
  int get limit => _limit;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDelete = false;
  bool get isDelete => _isDelete;

  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  String? _lastError;
  String? get lastError => _lastError;

  void updateFilterSearch(List<MedicalCenter> filtered) {
    _isSearchActive = true;
    _filteredCenters = filtered;
    notifyListeners();
  }

  void clearFilterSearch() {
    _isSearchActive = false;
    notifyListeners();
  }

  void removeCenter(String medicalCenterId) {
    _centers.removeWhere((c) => c.id == medicalCenterId);
    if (_savedTotal > 0) _savedTotal--;
    notifyListeners();
  }

  void resetAllCenters() {
    _isLoading = false;
    _centers = [];
    _hasMore = true;
    _page = 1;
    notifyListeners();
  }

  Future<String> getSavedMedicalCenters() async {
    try {
      _lastError = null;
      _isLoading = true;
      notifyListeners();

      final ApiResponse<Map<String, dynamic>> response =
          await _userServices.getSavedMedicalCenters(page: _page, limit: _limit);

      if (response.statusCode == 200) {
        final data = response.data!;
        final fetched = (data['savedMedicalCenters'] as List)
            .map((item) => MedicalCenter.fromJson(item))
            .toList();

        _centers.addAll(fetched);

        final pagination = data['pagination'];
        final currentPage = pagination['currentPage'] as int;
        final totalPages = pagination['totalPages'] as int;
        _savedTotal = pagination['total'] ?? _centers.length;

        if (currentPage >= totalPages) {
          _hasMore = false;
        } else {
          _page++;
        }

        _isLoading = false;
        notifyListeners();
        return 'success';
      } else if (response.statusCode == 404) {
        _isLoading = false;
        _lastError = response.message;
        notifyListeners();
        return 'error';
      } else {
        _isLoading = false;
        _lastError = 'Error fetching saved centers, please try again!!';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      _lastError = 'Error fetching saved centers, please try again!!';
      notifyListeners();
      return 'error';
    }
  }

  Future<String> saveMedicalCenter({required String medicalCenterId}) async {
    try {
      _lastError = null;
      if (medicalCenterId.isEmpty) {
        _lastError = 'Medical center ID is required to proceed.';
        return 'error';
      }

      final ApiResponse<Map<String, dynamic>> response =
          await _userServices.saveMedicalCenter(medicalCenterId: medicalCenterId);

      if (response.statusCode == 200) {
        _savedTotal++;
        notifyListeners();
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Error saving center, please try again!!';
        return 'error';
      }
    } catch (e) {
      _lastError = 'Error saving center, please try again!!';
      return 'error';
    }
  }

  Future<String> removeSavedMedicalCenter(
      {required String medicalCenterId}) async {
    try {
      _lastError = null;
      if (medicalCenterId.isEmpty) {
        _lastError = 'Medical center ID is required to proceed.';
        return 'error';
      }

      if (_isDelete) return '';

      _isDelete = true;
      notifyListeners();

      final ApiResponse<Map<String, dynamic>> response = await _userServices
          .removeSavedMedicalCenter(medicalCenterId: medicalCenterId);

      if (response.statusCode == 200) {
        final removedId = response.data!['removedMedicalCenter'] as String;
        removeCenter(removedId);
        _isDelete = false;
        notifyListeners();
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _isDelete = false;
        notifyListeners();
        _lastError = response.message;
        return 'error';
      } else {
        _isDelete = false;
        notifyListeners();
        _lastError = 'Error removing center, please try again!!';
        return 'error';
      }
    } catch (e) {
      _isDelete = false;
      notifyListeners();
      _lastError = 'Error removing center, please try again!!';
      return 'error';
    }
  }

  void reset() {
    _centers = [];
    _filteredCenters = [];
    _savedTotal = 0;
    _page = 1;
    _hasMore = true;
    _isLoading = false;
    _isDelete = false;
    _isSearchActive = false;
    _lastError = null;
    notifyListeners();
  }
}
