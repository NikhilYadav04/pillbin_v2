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
  }) async {
    return post(ApiEndpoints.addMedicine,
        data: {
          "name": name,
          "expiryDate": expiryDate,
          "notes": notes,
          "dosage": dosage,
          "manufacturer": manufacturer,
          "batchNumber": batchNumber
        },
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Get Inventory
  Future<ApiResponse<Map<String, dynamic>>> getInventory() async {
    return get(ApiEndpoints.getInventory,
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Update Medicine
  Future<ApiResponse<Map<String, dynamic>>> updateMedicine({
    required String medicineId,
    required String name,
    required String expiryDate,
    required String notes,
    required String dosage,
    required String manufacturer,
    required String batchNumber,
  }) async {
    return put(ApiEndpoints.updateMedicine(medicineId),
        data: {
          "name": name,
          "expiryDate": expiryDate,
          "notes": notes,
          "dosage": dosage,
          "manufacturer": manufacturer,
          "batchNumber": batchNumber
        },
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Delete a medicine
  Future<ApiResponse<Map<String, dynamic>>> deleteMedicine(
      {required String medicineId}) async {
    return delete(ApiEndpoints.deleteMedicine(medicineId),
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Delete all Expired Medicine
  Future<ApiResponse<Map<String, dynamic>>> deleteAllExpiredMedicines() async {
    return delete(ApiEndpoints.deleteAllExpired,
        fromJson: (data) => data as Map<String, dynamic>);
  }
}
