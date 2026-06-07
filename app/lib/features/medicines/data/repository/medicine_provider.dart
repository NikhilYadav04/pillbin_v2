import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/cache/cache_manager.dart';
import 'package:pillbin/config/notifications/notification_config.dart';
import 'package:pillbin/config/notifications/notification_model.dart';
import 'package:pillbin/core/cards/unlocked_cards.dart';
import 'package:pillbin/features/medicines/data/service/medicine_services.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/medicine_model.dart';
import 'package:pillbin/network/models/user_model.dart' as userClass;
import 'package:pillbin/network/utils/http_client.dart';

class MedicineProvider extends ChangeNotifier {
  //* initialize services
  final MedicineServices _medicineServices = MedicineServices();
  final CacheManager _cacheManager = CacheManager();
  final HttpClient _httpClient = HttpClient();

  String? _lastError;
  String? get lastError => _lastError;

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

  void updateHistoryFilteredInventory({required List<Medicine> medicine}) {
    _filteredDeletedMedicinesInventory = medicine;
    _isFilterSearchActive = true;
    notifyListeners();
  }

  void clearSearchFilter() {
    _isSearchActive = false;
    _isFilterSearchActive = false;
    _filteredActiveMedicinesInventory.clear();
    _filteredExpiringSoonMedicinesInventory.clear();
    _filteredExpiredMedicinesInventory.clear();
    _filteredDeletedMedicinesInventory.clear();
    notifyListeners();
  }

  //* Update user badges
  /// [userModel] must be read from UserProvider by the caller.
  /// [context] is required only for showing the achievement dialog.
  void updateUserBadges(
      userClass.UserModel? userModel, BuildContext context) {
    if (userModel == null) return;

    int getRandomId() => Random().nextInt(100000);

    if (userModel.stats.totalMedicinesTracked >= 1 &&
        !userModel.badges.firstTimer.achieved) {
      userModel.badges.firstTimer.achieved = true;
      userModel.badges.firstTimer.unlockedAt = DateTime.now();

      NotificationConfig().showInstantNotification(
        notify: PushNotificationModel(
          id: getRandomId().toString(),
          title: "🏆 First Step Complete!",
          body:
              "You've tracked your first medicine! 🌱 Check your achievements.",
        ),
      );

      Future.delayed(Duration(milliseconds: 800), () {
        showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (context) => UnlockedAchievementCard(
                  type: AchievementType.firstTimer,
                  title: 'First Step Complete!',
                  description: 'You\'ve tracked your first medicine!',
                  icon: Icons.eco,
                  onDismiss: () => Navigator.pop(context),
                ));
      });
    } else if (userModel.stats.totalMedicinesTracked >= 5 &&
        !userModel.badges.ecoHelper.achieved) {
      userModel.badges.ecoHelper.achieved = true;
      userModel.badges.ecoHelper.unlockedAt = DateTime.now();

      NotificationConfig().showInstantNotification(
        notify: PushNotificationModel(
          id: getRandomId().toString(),
          title: "🌿 Eco Helper Unlocked!",
          body: "You've tracked 5 medicines. Great job! ♻️",
        ),
      );

      Future.delayed(Duration(milliseconds: 800), () {
        showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (context) => UnlockedAchievementCard(
                  type: AchievementType.ecoHelper,
                  title: 'Eco Helper!',
                  description: 'You\'ve tracked 5 medicines. Keep it up!',
                  icon: Icons.recycling,
                  onDismiss: () => Navigator.pop(context),
                ));
      });
    } else if (userModel.stats.totalMedicinesTracked >= 20 &&
        !userModel.badges.greenChampion.achieved) {
      userModel.badges.greenChampion.achieved = true;
      userModel.badges.greenChampion.unlockedAt = DateTime.now();

      NotificationConfig().showInstantNotification(
        notify: PushNotificationModel(
          id: getRandomId().toString(),
          title: "👑 Green Champion!",
          body: "Amazing! You've tracked 20 medicines! 🌍✨",
        ),
      );

      Future.delayed(Duration(milliseconds: 800), () {
        showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (context) => UnlockedAchievementCard(
                  type: AchievementType.greenChampion,
                  title: 'Green Champion!',
                  description: 'Amazing! You\'ve tracked 20 medicines!',
                  icon: Icons.emoji_events,
                  onDismiss: () => Navigator.pop(context),
                ));
      });
    }
  }

  //* Add Medicine
  /// Pass [userModel] from UserProvider (via context.read in UI) for stats/badge update.
  /// Pass [context] only when badge achievement dialog should be shown.
  Future<String> addMedicine({
    required String name,
    required String expiryDate,
    required String notes,
    required String dosage,
    required String manufacturer,
    required String batchNumber,
    required String type,
    required String purchaseDate,
    File? imageFile,
    userClass.UserModel? userModel,
    BuildContext? context,
  }) async {
    try {
      _lastError = null;
      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.addMedicineCombined(
        name: name,
        expiryDate: expiryDate,
        notes: notes,
        dosage: dosage,
        manufacturer: manufacturer,
        batchNumber: batchNumber,
        type: type,
        purchaseDate: purchaseDate,
        imageFile: imageFile,
      );

      if (response.statusCode == 201) {
        Map<String, dynamic> data = response.data!["medicine"];
        String medicineStatus = data["status"];

        Logger().d(data);

        MedicineImage? medicineImage;
        if (data["image"] != null && data["image"]["url"] != null) {
          medicineImage = MedicineImage.fromJson(data["image"]);
        }

        ProductLinks? productLinks;
        if (data["productLinks"] != null) {
          productLinks = ProductLinks.fromJson(data["productLinks"]);
        }

        Medicine newMedicine = Medicine(
          id: data["_id"],
          userId: data["userId"],
          name: name,
          expiryDate: DateTime.parse(data["expiryDate"]),
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
          notes: notes,
          image: medicineImage,
          productLinks: productLinks,
          isDeleted: data["isDeleted"] ?? false,
          createdAt: data["createdAt"] != null
              ? DateTime.parse(data["createdAt"])
              : DateTime.now(),
          updatedAt: data["updatedAt"] != null
              ? DateTime.parse(data["updatedAt"])
              : DateTime.now(),
        );

        if (medicineStatus == "active") {
          _activeMedicinesInventory.add(newMedicine);
        } else if (medicineStatus == "expiring_soon") {
          _expiringSoonMedicinesInventory.add(newMedicine);
        } else {
          _expiredMedicinesInventory.add(newMedicine);
        }

        if (userModel != null) {
          userModel.stats.totalMedicinesTracked += 1;
          userModel.stats.expiringSoonCount =
              _expiringSoonMedicinesInventory.length;

          if (context != null) {
            updateUserBadges(userModel, context);
          }
        }

        notifyListeners();
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Error adding medicine!';
        return 'error';
      }
    } catch (e) {
      _lastError = 'Error adding medicine!';
      Logger().d(e.toString());
      return 'error';
    }
  }

  //* get Inventory
  /// Returns 'success', 'success_cache', or 'error'.
  Future<String> getInventory({bool forceRefresh = false}) async {
    try {
      _lastError = null;
      _isFetching = true;
      notifyListeners();

      final isOnline = _httpClient.isOnline;

      if (!forceRefresh &&
          (!isOnline || await _cacheManager.hasValidMedicinesCache())) {
        final cachedData = await _cacheManager.getCachedMedicinesInventory();

        if (cachedData != null) {
          Logger().i("Loading medicines from cache");

          List<Medicine> activeMedicines =
              (cachedData["activeMedicines"] as List<dynamic>? ?? [])
                  .map((item) => Medicine.fromJson(item))
                  .toList();

          List<Medicine> expiringSoonMedicines =
              (cachedData["expiringSoonMedicines"] as List<dynamic>? ?? [])
                  .map((item) => Medicine.fromJson(item))
                  .toList();

          List<Medicine> expiredMedicines =
              (cachedData["expiredMedicines"] as List<dynamic>? ?? [])
                  .map((item) => Medicine.fromJson(item))
                  .toList();

          setActiveInventory(activeMedicines);
          setExpiringSoonInventory(expiringSoonMedicines);
          setExpiredInventory(expiredMedicines);

          _isFetching = false;
          notifyListeners();

          return isOnline ? 'success' : 'success_cache';
        }
      }

      if (isOnline || forceRefresh) {
        ApiResponse<Map<String, dynamic>> response =
            await _medicineServices.getInventory();

        if (response.statusCode == 200) {
          Map<String, dynamic> inventory = response.data!["inventory"];

          await _cacheManager.cacheMedicinesInventory(inventory);
          await _cacheManager.setLastSyncTime();

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
          notifyListeners();
          return 'success';
        } else {
          _isFetching = false;
          _lastError = 'Error fetching inventory!';
          notifyListeners();
          return 'error';
        }
      } else {
        _isFetching = false;
        _lastError = 'No internet connection';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      _isFetching = false;
      notifyListeners();

      final cachedData = await _cacheManager.getCachedMedicinesInventory();
      if (cachedData != null) {
        List<Medicine> activeMedicines =
            (cachedData["activeMedicines"] as List<dynamic>? ?? [])
                .map((item) => Medicine.fromJson(item))
                .toList();
        List<Medicine> expiringSoonMedicines =
            (cachedData["expiringSoonMedicines"] as List<dynamic>? ?? [])
                .map((item) => Medicine.fromJson(item))
                .toList();
        List<Medicine> expiredMedicines =
            (cachedData["expiredMedicines"] as List<dynamic>? ?? [])
                .map((item) => Medicine.fromJson(item))
                .toList();
        setActiveInventory(activeMedicines);
        setExpiringSoonInventory(expiringSoonMedicines);
        setExpiredInventory(expiredMedicines);
        return 'success_cache';
      }

      Logger().e(e.toString());
      _lastError = 'Error fetching inventory!';
      return 'error';
    }
  }

  //* get deleted medicines inventory
  /// Returns 'success', 'success_cache', or 'error'.
  Future<String> getDeletedMedicinesInventory(
      {bool forceRefresh = false}) async {
    try {
      _lastError = null;
      _isFetchingDelete = true;
      notifyListeners();

      final isOnline = _httpClient.isOnline;

      if (!forceRefresh &&
          (!isOnline || await _cacheManager.hasValidMedicHistory())) {
        final cachedData = await _cacheManager.getCachedMedicinesHistory();

        if (cachedData != null) {
          Logger().i("Loading deleted medicines from cache");

          List<Medicine> list =
              (cachedData["medicines"] as List<dynamic>? ?? [])
                  .map((item) => Medicine.fromJson(item))
                  .toList();

          setDeletedMedicineInventory(list);

          _isFetchingDelete = false;
          notifyListeners();

          return isOnline ? 'success' : 'success_cache';
        }
      }

      if (isOnline || forceRefresh) {
        ApiResponse<Map<String, dynamic>> response =
            await _medicineServices.getInventoryDeleted();

        if (response.statusCode == 200) {
          Map<String, dynamic> inventory = response.data!;

          await _cacheManager.cacheMedicinesHistory(inventory);

          List<Medicine> list =
              (inventory["medicines"] as List<dynamic>? ?? [])
                  .map((item) => Medicine.fromJson(item))
                  .toList();

          Logger().d("Fetched ${list.length} deleted medicines from API");

          setDeletedMedicineInventory(list);

          _isFetchingDelete = false;
          notifyListeners();
          return 'success';
        } else {
          _isFetchingDelete = false;
          _lastError = 'Error fetching history!';
          notifyListeners();
          return 'error';
        }
      } else {
        _isFetchingDelete = false;
        _lastError = 'No internet connection';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      _isFetchingDelete = false;
      notifyListeners();

      Logger().e("Exception in getDeletedMedicinesInventory: $e");

      final cachedData = await _cacheManager.getCachedMedicinesHistory();
      if (cachedData != null) {
        List<Medicine> list =
            (cachedData["medicines"] as List<dynamic>? ?? [])
                .map((item) => Medicine.fromJson(item))
                .toList();
        setDeletedMedicineInventory(list);
        return 'success_cache';
      }

      _lastError = 'Error fetching history!';
      return 'error';
    }
  }

  //* update medicine
  Future<String> updateMedicine({
    required String medicineId,
    required String name,
    required String expiryDate,
    required String notes,
    required String dosage,
    required String manufacturer,
    required String batchNumber,
    required String type,
    required String purchaseDate,
  }) async {
    try {
      _lastError = null;
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
          expiryDate: DateTime.parse(data["expiryDate"]),
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
        return 'success';
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Error updating medicine!';
        return 'error';
      }
    } catch (e) {
      _lastError = 'Error updating medicine!';
      print(e.toString());
      return 'error';
    }
  }

  //* delete medicine
  /// Pass [userModel] from UserProvider (via context.read in UI) for stats update.
  Future<String> deleteMedicine({
    required String medicineId,
    userClass.UserModel? userModel,
  }) async {
    try {
      _lastError = null;
      if (medicineId.isEmpty) {
        _lastError = 'Medicine ID is required!';
        return 'error';
      }

      _isFetching = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.deleteMedicine(medicineId: medicineId);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!["medicine"];

        Logger().d(data);

        Medicine? med = findMedicine(data["status"], medicineId);

        deleteInventory(data["status"], medicineId);

        if (userModel != null && data["status"] == "expiring_soon") {
          userModel.stats.expiringSoonCount -= 1;
        }

        _deletedMedicinesInventory.add(med!);

        _isFetching = false;
        notifyListeners();
        return 'success';
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        _isFetching = false;
        _lastError = response.message;
        notifyListeners();
        return 'error';
      } else {
        _isFetching = false;
        _lastError = 'Error deleting medicine!';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      _isFetching = false;
      _lastError = 'Error deleting medicine!';
      notifyListeners();
      Logger().d(e.toString());
      return 'error';
    }
  }

  //* delete all expired medicines
  Future<String> deleteAllExpiredMedicines() async {
    try {
      _lastError = null;
      if (expiredMedicinesInventory.isEmpty) {
        _lastError = 'No Expired Medicines Found';
        return 'error';
      }

      _isFetching = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.deleteAllExpiredMedicines();

      if (response.statusCode == 200) {
        _deletedMedicinesInventory.addAll(_expiredMedicinesInventory);
        _expiredMedicinesInventory = [];

        _isFetching = false;
        notifyListeners();
        return 'success';
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        _isFetching = false;
        _lastError = response.message;
        notifyListeners();
        return 'error';
      } else {
        _isFetching = false;
        _lastError = 'Error deleting expired medicines!';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      _isFetching = false;
      _lastError = 'Error deleting expired medicines!';
      notifyListeners();
      return 'error';
    }
  }

  //* delete medicine (hard)
  Future<String> deleteMedicineHard({required String medicineId}) async {
    try {
      _lastError = null;
      if (medicineId.isEmpty) {
        _lastError = 'Medicine ID is required!';
        return 'error';
      }

      _isFetchingDelete = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.deleteMedicineHard(medicineId: medicineId);

      if (response.statusCode == 200) {
        deleteInventoryHard(medicineId);

        _isFetching = false;
        notifyListeners();
        return 'success';
      } else if (response.statusCode == 403 || response.statusCode == 404) {
        _isFetchingDelete = false;
        _lastError = response.message;
        notifyListeners();
        return 'error';
      } else {
        _isFetchingDelete = false;
        _lastError = 'Error deleting medicine!';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      _isFetchingDelete = false;
      _lastError = 'Error deleting medicine!';
      notifyListeners();
      Logger().d(e.toString());
      return 'error';
    }
  }

  //* delete all medicines (hard)
  Future<String> deleteAllHardMedicines() async {
    try {
      _lastError = null;
      _isFetchingDelete = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _medicineServices.deleteAllHardMedicines();

      if (response.statusCode == 200) {
        _deletedMedicinesInventory = [];

        _isFetchingDelete = false;
        notifyListeners();
        return 'success';
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        _isFetchingDelete = false;
        _lastError = response.message;
        notifyListeners();
        return 'error';
      } else {
        _isFetchingDelete = false;
        _lastError = 'Error deleting medicines!';
        notifyListeners();
        return 'error';
      }
    } catch (e) {
      _isFetchingDelete = false;
      _lastError = 'Error deleting medicines!';
      notifyListeners();
      return 'error';
    }
  }

  //* <-------------Reset---------------------------->
  Future<void> reset() async {
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
