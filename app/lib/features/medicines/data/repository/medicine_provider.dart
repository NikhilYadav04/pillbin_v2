import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/medicines/data/service/medicine_services.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/medicine_model.dart';
import 'package:pillbin/network/models/user_model.dart' as userClass;
import 'package:provider/provider.dart';

class MedicineProvider extends ChangeNotifier {
  //* initialize services
  final MedicineServices _medicineServices = MedicineServices();

  //* medicines list

  List<Medicine> _activeMedicinesInventory = [];
  List<Medicine> _expiringSoonMedicinesInventory = [];
  List<Medicine> _expiredMedicinesInventory = [];

  List<Medicine> _filteredActiveMedicinesInventory = [];
  List<Medicine> _filteredExpiringSoonMedicinesInventory = [];
  List<Medicine> _filteredExpiredMedicinesInventory = [];

  List<Medicine> _deletedMedicinesInventory = [];
  List<Medicine> _filteredDeletedMedicinesInventory = [];

  List<Medicine> get activeMedicinesInventory => _isSearchActive
      ? _filteredActiveMedicinesInventory
      : _activeMedicinesInventory;

  List<Medicine> get expiringSoonMedicinesInventory => _isSearchActive
      ? _filteredExpiringSoonMedicinesInventory
      : _expiringSoonMedicinesInventory;

  List<Medicine> get expiredMedicinesInventory => _isSearchActive
      ? _filteredExpiredMedicinesInventory
      : _expiredMedicinesInventory;

  List<Medicine> get deletedMedicinesInventory => _isFilterSearchActive
      ? _filteredDeletedMedicinesInventory
      : _deletedMedicinesInventory;

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

  void setDeletedMedicineInventory(List<Medicine> inventory) {
    _deletedMedicinesInventory = inventory;
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

  //* getters and setters for loaders
  bool _isFetching = false;
  bool get isFetching => _isFetching;

  bool _isFetchingDelete = false;
  bool get isFetchingDelete => _isFetchingDelete;

  //* Flag to track if search is active
  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;

  bool _isFilterSearchActive = false;
  bool get iFiltersSearchActive => _isFilterSearchActive;

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

  void deleteInventoryHard(String medicineId) {
    _deletedMedicinesInventory.removeWhere((m) => m.id == medicineId);
    notifyListeners();
  }

  Medicine? findMedicine(String status, String medicineId) {
    if (status == 'active') {
      return _activeMedicinesInventory.firstWhere(
        (m) => m.id == medicineId,
      );
    } else if (status == 'expiring_soon') {
      return _expiringSoonMedicinesInventory.firstWhere(
        (m) => m.id == medicineId,
      );
    } else {
      return _expiredMedicinesInventory.firstWhere(
        (m) => m.id == medicineId,
      );
    }
  }

  int countInventory() {
    return _activeMedicinesInventory.length +
        _expiringSoonMedicinesInventory.length +
        _expiredMedicinesInventory.length;
  }

  //* Method to update filtered inventory
  void updateFilteredInventory({
    required List<Medicine> activeMedicines,
    required List<Medicine> expiringSoonMedicines,
    required List<Medicine> expiredMedicines,
  }) {
    _filteredActiveMedicinesInventory = activeMedicines;
    _filteredExpiringSoonMedicinesInventory = expiringSoonMedicines;
    _filteredExpiredMedicinesInventory = expiredMedicines;
    _isSearchActive = true;
    notifyListeners();
  }

  //* Method to update history filtered inventory
  void updateHistoryFilteredInventory({required List<Medicine> medicine}) {
    _filteredDeletedMedicinesInventory = medicine;
    _isFilterSearchActive = true;
    notifyListeners();
  }

//* Method to clear search filter
  void clearSearchFilter() {
    _isSearchActive = false;
    _isFilterSearchActive = false;
    _filteredActiveMedicinesInventory.clear();
    _filteredExpiringSoonMedicinesInventory.clear();
    _filteredExpiredMedicinesInventory.clear();
    _filteredDeletedMedicinesInventory.clear();
    notifyListeners();
  }

  //* function

  //* Add Medicine
  Future<String> addMedicine(
      {required BuildContext context,
      required String name,
      required String expiryDate,
      required String notes,
      required String dosage,
      required String manufacturer,
      required String batchNumber,
      required String type,
      required String purchaseDate}) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.addMedicine(
              name: name,
              expiryDate: expiryDate,
              notes: notes,
              dosage: dosage,
              manufacturer: manufacturer,
              batchNumber: batchNumber,
              type: type,
              purchaseDate: purchaseDate);

      if (response.statusCode == 201) {
        Map<String, dynamic> data = response.data!["medicine"];

        String medicineStatus = data["status"];

        Logger().d(data);

        //* locally add medicine in my list
        Medicine newMedicine = Medicine(
            id: data["_id"],
            userId: data["userId"],
            name: name,
            expiryDate: DateTime.parse(
              data["expiryDate"],
            ),
            purchaseDate: DateTime.parse(data["purchaseDate"]),
            addedDate: DateTime.parse(data["addedDate"]),
            type: data["type"],
            dosage: data["dosage"],
            status: medicineStatus == "active"
                ? MedicineStatus.active
                : medicineStatus == "expired"
                    ? MedicineStatus.expired
                    : MedicineStatus.expiringSoon,
            batchNumber: data['batchNumber'],
            manufacturer: data["manufacturer"],
            notes: notes);

        if (medicineStatus == "active") {
          _activeMedicinesInventory.add(newMedicine);
        } else if (medicineStatus == "expiring_soon") {
          _expiringSoonMedicinesInventory.add(newMedicine);
        } else {
          _expiredMedicinesInventory.add(newMedicine);
        }

        UserProvider? user = context.read<UserProvider>();
        userClass.UserModel? userModel = user.user;

        userModel?.stats.totalMedicinesTracked += 1;
        userModel?.stats.expiringSoonCount =
            _expiringSoonMedicinesInventory.length;
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
      _isFetching = true;
      notifyListeners();

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

        _isFetching = false;

        UserProvider? user = context.read<UserProvider>();
        userClass.UserModel? userModel = user.user;

        userModel?.stats.expiringSoonCount =
            _expiringSoonMedicinesInventory.length;
        notifyListeners();

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _isFetching = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error fetching inventory !");
        return 'error';
      } else {
        _isFetching = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error fetching inventory !");
        return 'error';
      }
    } catch (e) {
      _isFetching = false;
      notifyListeners();

      CustomSnackBar.show(
          context: context,
          icon: Icons.medical_information,
          title: "Error fetching inventory !");
      return 'error';
    }
  }

  //* get deleted medicines inventory
  Future<String> getDeletedMedicinesInventory(
      {required BuildContext context}) async {
    try {
      _isFetchingDelete = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.getInventoryDeleted();

      if (response.statusCode == 200) {
        Map<String, dynamic> inventory = response.data!;

        //* separate each type of medicines in the list
        List<Medicine> list = (inventory["medicines"] as List<dynamic>? ?? [])
            .map((item) => Medicine.fromJson(item))
            .toList();

        Logger().d(inventory["medicines"]);

        setDeletedMedicineInventory(list);

        _isFetchingDelete = false;

        notifyListeners();

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _isFetchingDelete = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error fetching inventory !");
        return 'error';
      } else {
        _isFetchingDelete = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error fetching inventory !");
        return 'error';
      }
    } catch (e) {
      _isFetchingDelete = false;
      notifyListeners();

      CustomSnackBar.show(
          context: context,
          icon: Icons.medical_information,
          title: "Error fetching inventory !");
      return 'error';
    }
  }

  //* update medicine
  Future<String> updateMedicine(
      {required BuildContext context,
      required String medicineId,
      required String name,
      required String expiryDate,
      required String notes,
      required String dosage,
      required String manufacturer,
      required String batchNumber,
      required String type,
      required String purchaseDate}) async {
    try {
      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.updateMedicine(
              medicineId: medicineId,
              name: name,
              expiryDate: expiryDate,
              notes: notes,
              dosage: dosage,
              manufacturer: manufacturer,
              batchNumber: batchNumber,
              type: type,
              purchaseDate: purchaseDate);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!["medicine"];

        String medicineStatus = data["status"];

        Medicine updatedMedicine = Medicine(
          id: data["_id"],
          userId: data["userId"],
          name: name,
          expiryDate: DateTime.parse(
            data["expiryDate"],
          ),
          purchaseDate: DateTime.parse(data["purchaseDate"]),
          addedDate: DateTime.parse(data["addedDate"]),
          type: data["type"],
          dosage: data["dosage"],
          batchNumber: data['batchNumber'],
          manufacturer: data["manufacturer"],
          notes: data["notes"],
          status: medicineStatus == "active"
              ? MedicineStatus.active
              : medicineStatus == "expired"
                  ? MedicineStatus.expired
                  : MedicineStatus.expiringSoon,
        );

        updateInventory(medicineStatus, medicineId, updatedMedicine);

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
        print(response.message);
        return 'error';
      } else {
        print(response.message);
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error updating medicine !");
        return 'error';
      }
    } catch (e) {
      print(e.toString());
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

      _isFetching = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.deleteMedicine(medicineId: medicineId);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!["medicine"];

        Logger().d(data);

        //* Get the medicine to add to history medicines list
        Medicine? med = findMedicine(data["status"], medicineId);

        //* delete from inventory locally also
        deleteInventory(data["status"], medicineId);

        //* Update user stats
        UserProvider? user = context.read<UserProvider>();
        userClass.UserModel? userModel = user.user;

        if (data["status"] == "expiring_soon") {
          userModel?.stats.expiringSoonCount -= 1;
        }

        //   userModel?.stats.totalMedicinesTracked -= 1;

        //* add medicine in history list
        _deletedMedicinesInventory.add(med!);

        _isFetching = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        _isFetching = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'error';
      } else {
        _isFetching = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error deleting medicine !");
        return 'error';
      }
    } catch (e) {
      _isFetching = false;
      notifyListeners();

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
      if (expiredMedicinesInventory.isEmpty) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "No Expired Medicines Found");
        return 'error';
      }

      _isFetching = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.deleteAllExpiredMedicines();

      if (response.statusCode == 200) {
        //* add meds in history list
        _deletedMedicinesInventory.addAll(_expiredMedicinesInventory);

        //* empty expiry medicines list
        _expiredMedicinesInventory = [];

        _isFetching = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        _isFetching = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'error';
      } else {
        _isFetching = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error deleting expired medicines!");
        return 'error';
      }
    } catch (e) {
      _isFetching = false;
      notifyListeners();

      CustomSnackBar.show(
          context: context,
          icon: Icons.medical_information,
          title: "Error deleting expired medicines!");
      return 'error';
    }
  }

  //* delete medicine ( hard )
  Future<String> deleteMedicineHard(
      {required BuildContext context, required String medicineId}) async {
    try {
      if (medicineId.length == 0) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Medicine ID is required!");
        return 'error';
      }

      _isFetchingDelete = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.deleteMedicineHard(medicineId: medicineId);

      if (response.statusCode == 200) {
        //* remove medicine from history list locally
        deleteInventoryHard(medicineId);

        _isFetching = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        _isFetchingDelete = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'error';
      } else {
        _isFetchingDelete = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error deleting medicine !");
        return 'error';
      }
    } catch (e) {
      _isFetchingDelete = false;
      notifyListeners();

      Logger().d(e.toString());
      CustomSnackBar.show(
          context: context,
          icon: Icons.medical_information,
          title: "Error deleting medicine !");
      return 'error';
    }
  }

  //* delete all medicines (hard )
  Future<String> deleteAllHardMedicines({required BuildContext context}) async {
    try {
      _isFetchingDelete = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.deleteAllHardMedicines();

      if (response.statusCode == 200) {
        //* clear history list
        _deletedMedicinesInventory = [];

        _isFetchingDelete = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'success';
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        _isFetchingDelete = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: response.message);
        return 'error';
      } else {
        _isFetchingDelete = false;
        notifyListeners();

        CustomSnackBar.show(
            context: context,
            icon: Icons.medical_information,
            title: "Error deleting medicines!");
        return 'error';
      }
    } catch (e) {
      _isFetchingDelete = false;
      notifyListeners();

      CustomSnackBar.show(
          context: context,
          icon: Icons.medical_information,
          title: "Error deleting medicines!");
      return 'error';
    }
  }

  //* <-------------Reset--------------------------->
  Future<void> reset() async{
    _activeMedicinesInventory.clear();
    _expiringSoonMedicinesInventory.clear();
    _expiredMedicinesInventory.clear();
    _deletedMedicinesInventory.clear();

    _filteredActiveMedicinesInventory.clear();
    _filteredExpiringSoonMedicinesInventory.clear();
    _filteredExpiredMedicinesInventory.clear();
    _filteredDeletedMedicinesInventory.clear();

    _isFetching = false;
    _isFetchingDelete = false;
    _isSearchActive = false;
    _isFilterSearchActive = false;

    notifyListeners();
  }
}
