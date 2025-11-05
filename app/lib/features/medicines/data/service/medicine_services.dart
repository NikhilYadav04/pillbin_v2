import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class MedicineServices extends ApiService {
  //* Add Medicine
  Future<ApiResponse<Map<String, dynamic>>> addMedicine(
      {required String name,
      required String expiryDate,
      required String notes,
      required String dosage,
      required String manufacturer,
      required String batchNumber,
      required String type,
      required String purchaseDate}) async {
    return post(ApiEndpoints.addMedicine,
        data: {
          "name": name,
          "expiryDate": expiryDate,
          "notes": notes,
          "dosage": dosage,
          "manufacturer": manufacturer,
          "batchNumber": batchNumber,
          "purchaseDate": purchaseDate,
          "type": type,
          "note": notes
        },
        fromJson: (data) => data as Map<String, dynamic>);
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
      required String purchaseDate}) async {
    return put(ApiEndpoints.updateMedicine(medicineId),
        data: {
          "name": name,
          "expiryDate": expiryDate,
          "notes": notes,
          "dosage": dosage,
          "manufacturer": manufacturer,
          "batchNumber": batchNumber,
          "purchaseDate": purchaseDate,
          "type": type
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
