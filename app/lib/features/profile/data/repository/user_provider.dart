import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/cache/cache_manager.dart';
import 'package:pillbin/features/profile/data/network/user_services.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/user_model.dart' as userClass;
import 'package:pillbin/network/utils/http_client.dart';

class UserProvider extends ChangeNotifier {
  //* initialize services
  final UserServices _userServices = UserServices();
  final CacheManager _cacheManager = CacheManager();
  final HttpClient _httpClient = HttpClient();

  //* UserModel Methods
  userClass.UserModel? _user;
  userClass.UserModel? get user => _user;

  String? _lastError;
  String? get lastError => _lastError;

  void setUser(userClass.UserModel? user) {
    _user = user;
    notifyListeners();
  }

  void resetUser() {
    _user = null;
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  //* getters and setters for loaders
  bool _isFetching = false;
  bool get isFetching => _isFetching;

  bool _isLoadingFromCache = false;
  bool get isLoadingFromCache => _isLoadingFromCache;

  /// Called by UI after a successful saveMedicalCenter in SavedCentersProvider
  /// to keep the user model's saved-ID list in sync.
  void addSavedId(String medicalCenterId) {
    if (_user != null && !_user!.savedMedicalCenters.contains(medicalCenterId)) {
      _user!.savedMedicalCenters.add(medicalCenterId);
      notifyListeners();
    }
  }

  /// Called by UI after a successful removeSavedMedicalCenter in SavedCentersProvider.
  void removeSavedId(String medicalCenterId) {
    _user?.savedMedicalCenters.remove(medicalCenterId);
    notifyListeners();
  }

  //* complete the profile
  Future<String> completeProfile({
    required String fullName,
    required String phone,
    required List<Map<String, dynamic>> currentMedicines,
    required List<Map<String, dynamic>> medicalConditions,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      _lastError = null;
      ApiResponse<Map<String, dynamic>> response =
          await _userServices.completeProfile(
              fullName: fullName,
              phone: phone,
              currentMedicines: currentMedicines,
              medicalConditions: medicalConditions,
              locationName: locationName,
              latitude: latitude,
              longitude: longitude);

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = response.data!["user"];

        List<userClass.Medicine> medicines = currentMedicines
            .map((m) => userClass.Medicine(
                name: m["name"], dosage: m["dosage"], frequency: m["frequency"]))
            .toList();

        List<userClass.MedicalCondition> conditions = medicalConditions
            .map((c) => userClass.MedicalCondition(
                condition: c["condition"], severity: c["severity"]))
            .toList();

        userClass.UserModel userModel = userClass.UserModel(
            id: userData["id"],
            phoneNumber: userData["phoneNumber"],
            fullName: userData["fullName"],
            email: userData["email"],
            isVerified: true,
            currentMedicines: medicines,
            medicalConditions: conditions,
            medicineCount: 0,
            location: userClass.Location(
                name: locationName,
                coordinates: userClass.Coordinates(
                    latitude: latitude, longitude: longitude)),
            stats: userClass.Stats(
                totalMedicinesTracked: 0,
                expiringSoonCount: 0,
                medicinesDisposedCount: 0,
                campaignsJoinedCount: 0),
            badges: userClass.Badges(
              firstTimer: userClass.Badge(achieved: false),
              ecoHelper: userClass.Badge(achieved: false),
              greenChampion: userClass.Badge(achieved: false),
            ),
            savedMedicalCenters: [],
            profileCompleted: userData["profileCompleted"],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now());

        setUser(userModel);
        await _cacheManager.cacheUserProfile(userData);
        await _httpClient.saveUserData(
            userData["fullName"], userData["phoneNumber"], userData["email"]);

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Server error. Please try again later.';
        return 'error';
      }
    } catch (e) {
      _lastError = 'Server error. Please try again later.';
      print(e.toString());
      return 'error';
    }
  }

  //* Lightweight name-only update (used by vendor onboarding)
  Future<bool> updateFullName(String fullName) async {
    _lastError = null;
    final response = await _userServices.editProfile(fullName: fullName);
    if (response.statusCode == 200) {
      if (_user != null) {
        _user = _user!.copyWith(fullName: fullName);
        notifyListeners();
      }
      return true;
    }
    _lastError = response.message;
    return false;
  }

  //* edit the profile
  Future<String> editProfile({
    required String fullName,
    required String phone,
    required List<Map<String, dynamic>> currentMedicines,
    required List<Map<String, dynamic>> medicalConditions,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      _lastError = null;
      ApiResponse<Map<String, dynamic>> response =
          await _userServices.editProfile(
              fullName: fullName,
              phoneNumber: phone,
              currentMedicines: currentMedicines,
              medicalConditions: medicalConditions,
              locationName: locationName,
              latitude: latitude,
              longitude: longitude);

      if (response.statusCode == 200) {
        List<userClass.Medicine> medicines = currentMedicines
            .map((m) => userClass.Medicine(
                name: m["name"], dosage: m["dosage"], frequency: m["frequency"]))
            .toList();

        List<userClass.MedicalCondition> conditions = medicalConditions
            .map((c) => userClass.MedicalCondition(
                condition: c["condition"], severity: c["severity"]))
            .toList();

        Logger().d("profile edited");

        userClass.UserModel? updatedModel = user?.copyWith(
          fullName: fullName,
          phone: phone,
          currentMedicines: medicines,
          medicalConditions: conditions,
          location: userClass.Location(
              name: locationName,
              coordinates: userClass.Coordinates(
                  latitude: latitude, longitude: longitude)),
          profileCompleted: true,
          updatedAt: DateTime.now(),
        );

        setUser(updatedModel);
        if (updatedModel != null) {
          await _cacheManager.cacheUserProfile(updatedModel.toJson());
        }
        return 'success';
      } else if (response.statusCode == 404) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Server error. Please try again later.';
        return 'error';
      }
    } catch (e) {
      _lastError = 'Server error. Please try again later.';
      print(e.toString());
      return 'error';
    }
  }

  //* get profile
  /// Returns 'success', 'success_cache', or 'error'.
  /// On 'success_cache' the UI should show an offline/cache notice.
  Future<String> getProfile({bool forceRefresh = false}) async {
    try {
      _lastError = null;
      _isFetching = true;
      notifyListeners();

      final isOnline = _httpClient.isOnline;

      //* If offline or not forcing refresh, try to load from cache first
      if (!forceRefresh &&
          (!isOnline || await _cacheManager.hasValidUserProfileCache())) {
        final cachedData = await _cacheManager.getCachedUserProfile();

        if (cachedData != null) {
          Logger().i("Loading user profile from cache");
          _isLoadingFromCache = true;
          userClass.UserModel userData =
              userClass.UserModel.fromJson(cachedData);
          setUser(userData);
          _isFetching = false;
          _isLoadingFromCache = false;
          notifyListeners();
          // 'success_cache' tells the UI to show an offline notice if needed
          return isOnline ? 'success' : 'success_cache';
        }
      }

      //* Fetch from API
      if (isOnline || forceRefresh) {
        ApiResponse<Map<String, dynamic>> response =
            await _userServices.getProfile();

        if (response.statusCode == 200) {
          await _cacheManager.cacheUserProfile(response.data!["user"]);
          await _cacheManager.setLastSyncTime();
          userClass.UserModel userData =
              userClass.UserModel.fromJson(response.data!["user"]);
          setUser(userData);
          _isFetching = false;
          notifyListeners();
          return 'success';
        } else if (response.statusCode == 404) {
          _isFetching = false;
          _lastError = response.message;
          notifyListeners();
          return 'error';
        } else {
          _isFetching = false;
          _lastError = 'Error fetching profile details';
          notifyListeners();
          return 'error';
        }
      } else {
        _isFetching = false;
        _lastError = 'No internet connection and no cached data available';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      _isFetching = false;
      notifyListeners();

      Logger().e("Error in getProfile: $e");

      //* Try to load from cache as fallback
      final cachedData = await _cacheManager.getCachedUserProfile();
      if (cachedData != null) {
        userClass.UserModel userData = userClass.UserModel.fromJson(cachedData);
        setUser(userData);
        return 'success_cache';
      }

      _lastError = 'Error fetching profile details';
      notifyListeners();
      return 'error';
    }
  }

  //* <----------------Reset----------------->
  Future<void> reset() async {
    resetUser();
    _isFetching = false;
    _isLoadingFromCache = false;
    _lastError = null;
    notifyListeners();
  }
}
