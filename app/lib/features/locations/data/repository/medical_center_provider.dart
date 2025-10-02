import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/locations/data/network/medical_center_services.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/user_model.dart';
import 'package:provider/provider.dart';

import '../../../../network/models/medical_center_model.dart';

class MedicalCenterProvider extends ChangeNotifier {
  //* service
  final MedicalCenterServices _medicalCenterServices = MedicalCenterServices();

  //* setters and getters

  //* For fetched centers by distance

  //* < --------------------------------->

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

  //* < ------------------------------ >

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

  //* < ------------------------------ >

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
  Future<void> setLocation(bool current, BuildContext context) async {
    UserModel userModel = context.read<UserProvider>().user!;
    _placeName = userModel.location?.name ?? "Mr. X";

    if (current) {
      bool serviceEnabled;
      LocationPermission permission;

      //* 1. Check if location service enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.map,
          title: 'Please enable location services first.',
        );
        return;
      }

      //* 2. Check permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.map,
            title: 'Location permission is required.',
          );
          return;
        }
      }

      //* 3. If denied forever
      if (permission == LocationPermission.deniedForever) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.map,
          title:
              'Location permission is permanently denied. Please enable it from settings.',
        );
        return;
      }

      //* 4. Safe to fetch position
      Position location = await Geolocator.getCurrentPosition();

      _latitude = location.latitude;
      _longitude = location.longitude;

      notifyListeners();
    } else {
      _latitude = userModel.location?.coordinates?.latitude ?? 0.0;
      _longitude = userModel.location?.coordinates?.longitude ?? 0.0;

      notifyListeners();
    }
  }

  //* Add medical Center
  Future<String> addMedicalCenter({
    required BuildContext context,
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
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 400) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: "Error adding medical center !");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.shop_rounded,
          title: "Error adding medical center !");
      Logger().d(e.toString());
      return 'error';
    }
  }

  //* Update Medical center
  Future<String> updateMedicalCenter({
    required BuildContext context,
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
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: "Error updating medical center !");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.shop_rounded,
          title: "Error adding medical center !");
      print(e.toString());
      return 'error';
    }
  }

  //* Delete Medical center
  Future<String> deleteMedicalCenter(
      {required BuildContext context, required String medicalCenterId}) async {
    try {
      if (medicalCenterId.length == 0) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: "ID is required !!");
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response = await _medicalCenterServices
          .deleteMedicalCenter(medicalCenterId: medicalCenterId);

      if (response.statusCode == 200) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: "Error deleting medical center !");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.shop_rounded,
          title: "Error deleting medical center !");
      print(e.toString());
      return 'error';
    }
  }

  //* Get All Medical Centers
  Future<String> getAllMedicalCenters({required BuildContext context}) async {
    try {
      _isLoading = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response = await _medicalCenterServices
          .getAllMedicalCenters(page: _page, limit: _limit);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        List<MedicalCenter> medicalCenters = (data["medicalCenters"] as List)
            .map((item) => MedicalCenter.fromJson(item as Map<String, dynamic>))
            .toList();

        _totalCount = data["pagination"]["totalCenters"];

        Logger().d(medicalCenters);

        _allCenters.addAll(medicalCenters);

        Logger().d(_allCenters);

        Logger().d(isSearchActive);

        int currentPage = data["pagination"]["currentPage"];

        int totalPage = data["pagination"]["totalPages"];

        if (currentPage >= totalPage) {
          _hasMore = false;
        } else {
          _page++;
        }
        notifyListeners();

        Logger().d("Size is ${allCenters.length}");
        Logger().d("Size is ${_allCenters.length}");

        _isLoading = false;
        notifyListeners();

        return 'success';
      } else {
        _isLoading = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: "Error displaying medical centers !");
        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      CustomSnackBar.show(
          context: context,
          icon: Icons.shop_rounded,
          title: "Error displaying medical centers !");
      print(e.toString());
      return 'error';
    }
  }

  //* Get Nearby Medical Centers
  Future<String> getNearbyMedicalCenters({
    required BuildContext context,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    try {
      _isLoadingFetch = true;
      _isLoadingNearby = true;
      notifyListeners();

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
            .toList();

        _fetchedCenters = medicalCenters;

        _fetchedCount = data["pagination"]["totalFound"];

        Logger().d(_fetchedCount);

        int currentPage = data["pagination"]["currentPage"];
        int totalPage = data["pagination"]["totalPages"];

        if (currentPage >= totalPage) {
          _hasMoreFetch = false;
        } else {
          _pageFetch++;
        }

        Logger().d(hasMoreFetch);

        _isLoadingFetch = false;
        _isLoadingNearby = false;
        notifyListeners();

        return 'success';
      } else if (response.statusCode == 400) {
        _isLoadingNearby = false;
        _isLoadingFetch = false;
        notifyListeners();
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: response.message);
        return 'error';
      } else {
        _isLoadingNearby = false;
        _isLoadingFetch = false;
        notifyListeners();
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: "Error searching medical centers !!");
        return 'error';
      }
    } catch (e) {
      _isLoadingNearby = false;
      _isLoadingFetch = false;
      notifyListeners();
      CustomSnackBar.show(
          context: context,
          icon: Icons.shop_rounded,
          title: "Error searching medical centers !!");
      print(e.toString());
      return 'error';
    }
  }

  //* Search medical Centers
  Future<String> searchMedicalCenters({
    required BuildContext context,
    required String query,
    required String facilityType,
  }) async {
    try {
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
            .toList();

        _allCenters = medicalCenters;

        _fetchedCount = data["pagination"]["totalFound"];
        Logger().d(_fetchedCount);

        int currentPage = data["pagination"]["currentPage"];
        int totalPgae = data["pagination"]["totalPages"];

        if (currentPage >= totalPgae) {
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
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: response.message);
        return 'error';
      } else {
        _isSearchAPI = false;
        _isLoadingFetch = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: "Error searching medical centers !!");
        return 'error';
      }
    } catch (e) {
      _isSearchAPI = false;
      _isLoadingFetch = false;
      notifyListeners();

      CustomSnackBar.show(
          context: context,
          icon: Icons.shop_rounded,
          title: "Error searching medical centers !!");
      print(e.toString());
      return 'error';
    }
  }

  //* Get medical center by Id
  Future<String> getMedicalCenterbyId(
      {required BuildContext context, required String medicalCenterId}) async {
    try {
      if (medicalCenterId.length == 0) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: "Error getting details !!");
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response = await _medicalCenterServices
          .getMedicalCenterbyID(medicalCenterId: medicalCenterId);

      if (response.statusCode == 200) {
        //* Return response for now

        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: response.message);

        return 'success';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: response.message);

        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.shop_rounded,
          title: "Error getting details !!");
      print(e.toString());
      return 'error';
    }
  }
}
