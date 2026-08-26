import 'dart:io';

import 'package:dio/dio.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class MedicineServices extends ApiService {
  //* Add Medicine
  Future<ApiResponse<Map<String, dynamic>>> addMedicine({
    required String name,
    required String expiryDate,
    required String notes,
    required String dosage,
    required String manufacturer,
    required String batchNumber,
    required String type,
    required String purchaseDate,
  }) async {
    return post(
      ApiEndpoints.addMedicine,
      data: {
        "name": name,
        "expiryDate": expiryDate,
        "notes": notes,
        "dosage": dosage,
        "manufacturer": manufacturer,
        "batchNumber": batchNumber,
        "purchaseDate": purchaseDate,
        "type": type,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Method 2: NEW - FormData request (with image)
  Future<ApiResponse<Map<String, dynamic>>> addMedicineWithImage({
    required String name,
    required String expiryDate,
    required String notes,
    required String dosage,
    required String manufacturer,
    required String batchNumber,
    required String type,
    required String purchaseDate,
    required File imageFile,
  }) async {
    // Create FormData
    FormData formData = FormData.fromMap({
      "name": name,
      "expiryDate": expiryDate,
      "notes": notes,
      "dosage": dosage,
      "manufacturer": manufacturer,
      "batchNumber": batchNumber,
      "purchaseDate": purchaseDate,
      "type": type,
      "photo": await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    return post(
      ApiEndpoints.addMedicine,
      data: formData,
      fromJson: (data) => data as Map<String, dynamic>,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
  }

// ==============================================================
// ALTERNATIVE: Single Method with Optional Image Parameter
// ==============================================================

  /// Combined method that handles both cases
  Future<ApiResponse<Map<String, dynamic>>> addMedicineCombined({
    required String name,
    required String expiryDate,
    required String notes,
    required String dosage,
    required String manufacturer,
    required String batchNumber,
    required String type,
    required String purchaseDate,
    File? imageFile, // Optional image parameter
    bool isRecurring = false,
    int? refillIntervalDays,
    String? familyMemberId,
  }) async {
    dynamic requestData;
    Options? options;

    // If image is provided, use FormData
    if (imageFile != null) {
      requestData = FormData.fromMap({
        "name": name,
        "expiryDate": expiryDate,
        "notes": notes,
        "dosage": dosage,
        "manufacturer": manufacturer,
        "batchNumber": batchNumber,
        "purchaseDate": purchaseDate,
        "type": type,
        "isRecurring": isRecurring,
        if (refillIntervalDays != null) "refillIntervalDays": refillIntervalDays,
        if (familyMemberId != null) "familyMemberId": familyMemberId,
        "photo": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      options = Options(
        contentType: 'multipart/form-data',
      );
    } else {
      // If no image, use regular JSON
      requestData = {
        "name": name,
        "expiryDate": expiryDate,
        "notes": notes,
        "dosage": dosage,
        "manufacturer": manufacturer,
        "batchNumber": batchNumber,
        "purchaseDate": purchaseDate,
        "type": type,
        "isRecurring": isRecurring,
        if (refillIntervalDays != null) "refillIntervalDays": refillIntervalDays,
        if (familyMemberId != null) "familyMemberId": familyMemberId,
      };
    }

    return post(
      ApiEndpoints.addMedicine,
      data: requestData,
      fromJson: (data) => data as Map<String, dynamic>,
      options: options,
    );
  }

  //* Get Inventory
  Future<ApiResponse<Map<String, dynamic>>> getInventory() async {
    return get(ApiEndpoints.getInventory,
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Get Deleted Inventory
  Future<ApiResponse<Map<String, dynamic>>> getInventoryDeleted() async {
    return get(ApiEndpoints.getInventoryDeleted,
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Update Medicine
  Future<ApiResponse<Map<String, dynamic>>> updateMedicine(
      {required String medicineId,
      required String name,
      required String expiryDate,
      required String notes,
      required String dosage,
      required String manufacturer,
      required String batchNumber,
      required String type,
      required String purchaseDate,
      bool? isRecurring,
      int? refillIntervalDays,
      String? familyMemberId}) async {
    return put(ApiEndpoints.updateMedicine(medicineId),
        data: {
          "name": name,
          "expiryDate": expiryDate,
          "notes": notes,
          "dosage": dosage,
          "manufacturer": manufacturer,
          "batchNumber": batchNumber,
          "purchaseDate": purchaseDate,
          "type": type,
          if (isRecurring != null) "isRecurring": isRecurring,
          if (refillIntervalDays != null) "refillIntervalDays": refillIntervalDays,
          //* null clears it back to Self — this key must always be sent,
          //* unlike the fields above where omitting means "leave unchanged"
          "familyMemberId": familyMemberId,
        },
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Delete a medicine (Soft Delete )
  Future<ApiResponse<Map<String, dynamic>>> deleteMedicine(
      {required String medicineId}) async {
    return delete(ApiEndpoints.deleteMedicine(medicineId),
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Delete a medicine (Hard Delete )
  Future<ApiResponse<Map<String, dynamic>>> deleteMedicineHard(
      {required String medicineId}) async {
    return delete(ApiEndpoints.deleteMedicineHard(medicineId),
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Delete all Expired Medicine (Soft Delete )
  Future<ApiResponse<Map<String, dynamic>>> deleteAllExpiredMedicines() async {
    return delete(ApiEndpoints.deleteAllExpired,
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Delete all Deleted Medicine (Hard Delete )
  Future<ApiResponse<Map<String, dynamic>>> deleteAllHardMedicines() async {
    return delete(ApiEndpoints.deleteAllHard,
        fromJson: (data) => data as Map<String, dynamic>);
  }
}
