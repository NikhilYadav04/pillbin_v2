
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/locations/data/network/medical_center_services.dart';
import 'package:pillbin/network/models/api_response.dart';

import '../../../../network/models/medical_center_model.dart';

class MedicalCenterProvider extends ChangeNotifier {
  //* service
  final MedicalCenterServices _medicalCenterServices = MedicalCenterServices();

  //* setters and getters
  List<MedicalCenter> _fetchedCenters = [];
  List<MedicalCenter> get fetchedCenters => _fetchedCenters;

  List<MedicalCenter> _allCenters = [];
  List<MedicalCenter> get allCenters => _allCenters;

  int _totalCount = 0;
  int get totalCount => _totalCount;

  int _fetchedCount = 0;
  int get fetchedCount => _fetchedCount;

  //* pagination
  int _page = 1;
  int get page => _page;

  int _limit = 10;
  int get limit => _limit;

  int _pageFetch = 1;
  int get pageFetch => _pageFetch;

  int _limitFetch = 10;
  int get limitFetch => _limitFetch;

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
              facilityType: facilityType);

      if (response.statusCode == 200) {
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
      print(e.toString());
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
      ApiResponse<Map<String, dynamic>> response = await _medicalCenterServices
          .getAllMedicalCenters(page: _page, limit: _limit);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        List<MedicalCenter> medicalCenters = data["medicalCenters"]
            .map((item) => MedicalCenter.fromJson(item))
            .toList();

        _totalCount = data["pagination"]["totalCenters"];

        _allCenters = medicalCenters;
        notifyListeners();

        _page++;

        return 'success';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.shop_rounded,
            title: "Error displaying medical centers !");
        return 'error';
      }
    } catch (e) {
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
      ApiResponse<Map<String, dynamic>> response =
          await _medicalCenterServices.getNearByMedicalCenters(
              latitude: latitude,
              longitude: longitude,
              radius: radius,
              page: _pageFetch,
              limit: _limitFetch);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        List<MedicalCenter> medicalCenters = data["medicalCenters"]
            .map((item) => MedicalCenter.fromJson(item))
            .toList();

        _fetchedCenters = medicalCenters;

        _fetchedCount = data["pagination"]["totalFound"];

        _pageFetch++;

        notifyListeners();

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
            title: "Error searching medical centers !!");
        return 'error';
      }
    } catch (e) {
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
      ApiResponse<Map<String, dynamic>> response =
          await _medicalCenterServices.searchMedicalCenters(
              query: query,
              facilityType: facilityType,
              page: _pageFetch,
              limit: _limitFetch);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        List<MedicalCenter> medicalCenters = data["medicalCenters"]
            .map((item) => MedicalCenter.fromJson(item))
            .toList();

        _fetchedCenters = medicalCenters;

        _fetchedCount = data["pagination"]["totalFound"];
        _pageFetch++;

        notifyListeners();

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
            title: "Error searching medical centers !!");
        return 'error';
      }
    } catch (e) {
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
