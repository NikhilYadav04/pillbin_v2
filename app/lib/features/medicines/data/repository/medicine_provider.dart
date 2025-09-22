import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/medicines/data/service/medicine_services.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/medicine_model.dart';

class MedicineProvider extends ChangeNotifier {
  //* initialize services
  final MedicineServices _medicineServices = MedicineServices();

  //* medicines list

  List<Medicine> _activeMedicinesInventory = [];
  List<Medicine> get activeMedicinesInventory => _activeMedicinesInventory;

  List<Medicine> _expiringSoonMedicinesInventory = [];
  List<Medicine> get expiringSoonMedicinesInventory =>
      _expiringSoonMedicinesInventory;

  List<Medicine> _expiredMedicinesInventory = [];
  List<Medicine> get expiredMedicinesInventory => _expiredMedicinesInventory;

  void setActiveInventory(List<Medicine> inventory) {
    _activeMedicinesInventory = inventory;
    notifyListeners();
  }

  void setExpiringSoonInventory(List<Medicine> inventory) {
    _expiringSoonMedicinesInventory = inventory;
    notifyListeners();
  }

  void setExpiredInventory(List<Medicine> inventory) {
    _expiredMedicinesInventory = inventory;
    notifyListeners();
  }

  void updateInventory(String status, String medicineId, Medicine updated) {
    List<Medicine> temp = [];

    if (status == 'active') {
      temp = _activeMedicinesInventory;
    } else if (status == 'expiring_soon') {
      temp = _expiringSoonMedicinesInventory;
    } else {
      temp = _expiredMedicinesInventory;
    }

    for (int i = 0; i < temp.length; i++) {
      if (temp[i].id == medicineId) {
        temp[i] = updated;
      }
    }

    if (status == 'active') {
      _activeMedicinesInventory = temp;
    } else if (status == 'expiring_soon') {
      _expiringSoonMedicinesInventory = temp;
    } else {
      _expiredMedicinesInventory = temp;
    }

    notifyListeners();
  }

  void deleteInventory(String status, String medicineId) {
    if (status == 'active') {
      _activeMedicinesInventory.removeWhere((m) => m.id == medicineId);
    } else if (status == 'expiring_soon') {
      _expiringSoonMedicinesInventory.removeWhere((m) => m.id == medicineId);
    } else {
      _expiredMedicinesInventory.removeWhere((m) => m.id == medicineId);
    }
    notifyListeners();
  }

  int countInventory() {
    return _activeMedicinesInventory.length +
        _expiringSoonMedicinesInventory.length +
        _expiredMedicinesInventory.length;
  }

  //* function

  //* Add Medicine
  Future<String> addMedicine({
    required BuildContext context,
    required String name,
    required String expiryDate,
    required String notes,
    required String dosage,
    required String manufacturer,
    required String batchNumber,
  }) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.addMedicine(
              name: name,
              expiryDate: expiryDate,
              notes: notes,
              dosage: dosage,
              manufacturer: manufacturer,
              batchNumber: batchNumber);

      if (response.statusCode == 201) {
        Map<String, dynamic> data = response.data!["medicine"];

        String medicineStatus = data["status"];

        Logger().d(data);

        //* locally add medicine in my list
        Medicine newMedicine = Medicine(
            id: data["_id"],
            userId: data["userId"],
            name: name,
            expiryDate: DateTime.parse(data["expiryDate"]));

        if (medicineStatus == "active") {
          _activeMedicinesInventory.add(newMedicine);
        } else if (medicineStatus == "expiring_soon") {
          _expiringSoonMedicinesInventory.add(newMedicine);
        } else {
          _expiredMedicinesInventory.add(newMedicine);
        }
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
            icon: Icons.medical_information,
            title: "Error adding medicine !");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.medical_information,
          title: "Error adding medicine !");
      Logger().d(e.toString());
      return 'error';
    }
  }

  //* get Inventory
  Future<String> getInventory({required BuildContext context}) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.getInventory();

      if (response.statusCode == 200) {
        Map<String, dynamic> inventory = response.data!["inventory"];

        //* separate each type of medicines in the list
        List<Medicine> activeMedicines =
            (inventory["activeMedicines"] as List<dynamic>? ?? [])
                .map((item) => Medicine.fromJson(item))
                .toList();

        List<Medicine> expiringSoonMedicines =
            (inventory["expiringSoonMedicines"] as List<dynamic>? ?? [])
                .map((item) => Medicine.fromJson(item))
                .toList();

        List<Medicine> expiredMedicines =
            (inventory["expiredMedicines"] as List<dynamic>? ?? [])
                .map((item) => Medicine.fromJson(item))
                .toList();

        setActiveInventory(activeMedicines);

        setExpiringSoonInventory(expiringSoonMedicines);

        setExpiredInventory(expiredMedicines);

        notifyListeners();

        return 'error';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error adding medicine !");
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error fetching inventory !");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.medical_information,
          title: "Error fetching inventory !");
      return 'error';
    }
  }

  //* update medicine
  Future<String> updateMedicine({
    required BuildContext context,
    required String medicineId,
    required String name,
    required String expiryDate,
    required String notes,
    required String dosage,
    required String manufacturer,
    required String batchNumber,
  }) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.updateMedicine(
              medicineId: medicineId,
              name: name,
              expiryDate: expiryDate,
              notes: notes,
              dosage: dosage,
              manufacturer: manufacturer,
              batchNumber: batchNumber);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!["medicine"];

        String medicineStatus = data["status"];

        Medicine updatedMedicine = Medicine(
            id: data["_id"],
            userId: data["userId"],
            name: name,
            expiryDate: DateTime.parse(data["expiryDate"]));

        updateInventory(medicineStatus, medicineId, updatedMedicine);

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'error';
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error updating medicine !");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.medical_information,
          title: "Error updating medicine !");
      return 'error';
    }
  }

  //* delete medicine
  Future<String> deleteMedicine(
      {required BuildContext context, required String medicineId}) async {
    try {
      if (medicineId.length == 0) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Medicine ID is required!");
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.deleteMedicine(medicineId: medicineId);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!["medicine"];

        Logger().d(data);

        deleteInventory(data["status"], medicineId);

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error deleting medicine !");
        return 'error';
      }
    } catch (e) {
      Logger().d(e.toString());
      CustomSnackBar.show(
          context: context,
          icon: Icons.medical_information,
          title: "Error deleting medicine !");
      return 'error';
    }
  }

  //* delete all expired medicines
  Future<String> deleteAllExpiredMedicines(
      {required BuildContext context}) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.deleteAllExpiredMedicines();

      if (response.statusCode == 200) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error deleting expired medicines!");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.medical_information,
          title: "Error deleting expired medicines!");
      return 'error';
    }
  }
}
