import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/profile/data/network/user_services.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/medical_center_model.dart';
import 'package:pillbin/network/models/user_model.dart' as userClass;

class UserProvider extends ChangeNotifier {
  //* initialize services
  final UserServices _userServices = UserServices();

  //* UserModel Methods
  userClass.UserModel? _user;

  userClass.UserModel? get user => _user;

  void setUser(userClass.UserModel? user) {
    _user = user;
    notifyListeners();
  }

  //* Medical center methods

  List<MedicalCenter>? _medicalCenter;

  List<MedicalCenter>? get medicalCenter => _medicalCenter;

  void setMedicalCenter(List<MedicalCenter> centers) {
    _medicalCenter = medicalCenter;
    notifyListeners();
  }

  //* pagination
  int _page = 1;
  int get page => _page;

  int _limit = 10;
  int get limit => _limit;

  //* functions

  //* complete the profile
  Future<String> completeProfile({
    required BuildContext context,
    required String fullName,
    required String email,
    required List<Map<String, dynamic>> currentMedicines,
    required List<Map<String, dynamic>> medicalConditions,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _userServices.completeProfile(
              fullName: fullName,
              email: email,
              currentMedicines: currentMedicines,
              medicalConditions: medicalConditions,
              locationName: locationName,
              latitude: latitude,
              longitude: longitude);

      if (response.statusCode == 200) {
        Map<String, dynamic> userData = jsonDecode(response.message)["user"];

        List<userClass.Medicine> medicines = [];

        for (int i = 0; i < currentMedicines.length; i++) {
          userClass.Medicine medicine = userClass.Medicine(
              name: currentMedicines[i]["name"],
              dosage: currentMedicines[i]["dosage"],
              frequency: currentMedicines[i]["frequency"]);

          medicines.add(medicine);
        }

        List<userClass.MedicalCondition> conditions = [];

        for (int i = 0; i < medicalConditions.length; i++) {
          userClass.MedicalCondition condition = userClass.MedicalCondition(
              condition: medicalConditions[i]["condition"],
              severity: medicalConditions[i]["severity"]);

          conditions.add(condition);
        }

        userClass.UserModel user = userClass.UserModel(
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
              firstTimer: userClass.Badge(
                achieved: false,
              ),
              ecoHelper: userClass.Badge(
                achieved: false,
              ),
              greenChampion: userClass.Badge(
                achieved: false,
              ),
            ),
            savedMedicalCenters: [],
            profileCompleted: userData["profileCompleted"],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now());

        setUser(user);

        CustomSnackBar.show(
            context: context,
            icon: Icons.person,
            title: "Profile Completed Successfully !");
        return 'error';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context, icon: Icons.person, title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.person,
            title: "Server error. Please try again later");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.person,
          title: "Server error. Please try again later");
      print(e.toString());
      return 'error';
    }
  }

  //* edit the profile
  Future<String> editProfile({
    required BuildContext context,
    required String fullName,
    required String email,
    required List<Map<String, dynamic>> currentMedicines,
    required List<Map<String, dynamic>> medicalConditions,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _userServices.editProfile(
              fullName: fullName,
              email: email,
              currentMedicines: currentMedicines,
              medicalConditions: medicalConditions,
              locationName: locationName,
              latitude: latitude,
              longitude: longitude);

      if (response.statusCode == 200) {
        List<userClass.Medicine> medicines = [];

        for (int i = 0; i < currentMedicines.length; i++) {
          userClass.Medicine medicine = userClass.Medicine(
              name: currentMedicines[i]["name"],
              dosage: currentMedicines[i]["dosage"],
              frequency: currentMedicines[i]["frequency"]);

          medicines.add(medicine);
        }

        List<userClass.MedicalCondition> conditions = [];

        for (int i = 0; i < medicalConditions.length; i++) {
          userClass.MedicalCondition condition = userClass.MedicalCondition(
              condition: medicalConditions[i]["condition"],
              severity: medicalConditions[i]["severity"]);

          conditions.add(condition);
        }

        userClass.UserModel updatedModel = user!.copyWith(
          fullName: fullName,
          email: email,
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

        CustomSnackBar.show(
            context: context,
            icon: Icons.person,
            title: "Profile Edited Successfully !");
        return 'error';
      } else if (response.statusCode == 404) {
        CustomSnackBar.show(
            context: context, icon: Icons.person, title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.person,
            title: "Server error. Please try again later");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.person,
          title: "Server error. Please try again later");
      print(e.toString());
      return 'error';
    }
  }

  //* get profile
  Future<String> getProfile({required BuildContext context}) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _userServices.getProfile();

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = response.data!;

        userClass.UserModel userData =
            userClass.UserModel.fromJson(responseData["user"]);

        setUser(userData);
        notifyListeners();

        return 'success';
      } else if (response.statusCode == 404) {
        CustomSnackBar.show(
            context: context, icon: Icons.person, title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.person,
            title: "Error fetching profile details, please try again !!");

        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.person,
          title: "Error fetching profile details, please try again !!");
      print(e.toString());
      return 'error';
    }
  }

  //* save medical center
  Future<String> saveMedicalCenter(
      {required BuildContext context, required String medicalCenterId}) async {
    try {
      if (medicalCenterId.isEmpty) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Medical center ID is required to proceed. !");
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response = await _userServices
          .saveMedicalCenter(medicalCenterId: medicalCenterId);

      if (response.statusCode == 200) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.person,
            title: "Error saving center, please try again !!");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.person,
          title: "Error saving center, please try again !!");
      print(e.toString());
      return 'error';
    }
  }

  //* remove saved medical center
  Future<String> removeSavedMedicalCenter(
      {required BuildContext context, required String medicalCenterId}) async {
    try {
      if (medicalCenterId.isEmpty) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Medical center ID is required to proceed. !");
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response = await _userServices
          .removeSavedMedicalCenter(medicalCenterId: medicalCenterId);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        String removedId = data["removedMedicalCenter"];

        user?.removeMedicalCenter(removedId);

        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.person,
            title: "Error saving center, please try again !!");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.person,
          title: "Error removing center, please try again !!");
      print(e.toString());
      return 'error';
    }
  }

  //* get saved medical center
  Future<String> getSavedMedicalCenters({required BuildContext context}) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _userServices.getSavedMedicalCenters(page: page, limit: limit);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        List<dynamic> dataList = data["savedMedicalCenters"];

        List<MedicalCenter> medicalCenters =
            dataList.map((item) => MedicalCenter.fromJson(item)).toList();

        setMedicalCenter(medicalCenters);

        return 'success';
      } else if (response.statusCode == 404) {
        CustomSnackBar.show(
            context: context, icon: Icons.person, title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.person,
            title: "Error fetching saved centers, please try again !!");

        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.person,
          title: "Error fetching saved centers, please try again !!");
      print(e.toString());
      return 'error';
    }
  }
}
