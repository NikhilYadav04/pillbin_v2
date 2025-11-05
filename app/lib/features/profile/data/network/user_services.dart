import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class UserServices extends ApiService {
  //* Complete the Profile
  Future<ApiResponse<Map<String, dynamic>>> completeProfile({
    required String fullName,
    required String phone,
    required List<Map<String, dynamic>> currentMedicines,
    required List<Map<String, dynamic>> medicalConditions,
    required String locationName,
    required double latitude,
    required double longitude,
  }) async {
    return post(
      ApiEndpoints.completeProfile,
      data: {
        "fullName": fullName,
        "phone": phone,
        "currentMedicines": currentMedicines,
        "medicalConditions": medicalConditions,
        "location": {
          "name": locationName,
          "coordinates": {
            "latitude": latitude,
            "longitude": longitude,
          }
        }
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Edit the Profile
  Future<ApiResponse<Map<String, dynamic>>> editProfile({
    String? fullName,
    String? phoneNumber,
    List<Map<String, dynamic>>? currentMedicines,
    List<Map<String, dynamic>>? medicalConditions,
    String? locationName,
    double? latitude,
    double? longitude,
  }) async {
    final Map<String, dynamic> data = {};

    if (fullName != null) data["fullName"] = fullName;
    if (phoneNumber != null) data["phoneNumber"] = phoneNumber;
    if (currentMedicines != null) data["currentMedicines"] = currentMedicines;
    if (medicalConditions != null)
      data["medicalConditions"] = medicalConditions;
    if (locationName != null || latitude != null || longitude != null) {
      data["location"] = {
        if (locationName != null) "name": locationName,
        if (latitude != null)
          "coordinates": {"latitude": latitude, "longitude": longitude}
      };
    }

    return put(
      ApiEndpoints.editProfile,
      data: data,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Get the Profile
  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    return get(ApiEndpoints.getProfile,
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Save Medical Center
  Future<ApiResponse<Map<String, dynamic>>> saveMedicalCenter(
      {required String medicalCenterId}) async {
    return post(ApiEndpoints.saveMedicalCenter,
        data: {"medicalCenterId": medicalCenterId},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Remove Saved Medical Center
  Future<ApiResponse<Map<String, dynamic>>> removeSavedMedicalCenter(
      {required String medicalCenterId}) async {
    return delete(ApiEndpoints.removeSavedMedicalCenter,
        data: {"medicalCenterId": medicalCenterId},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Get Saved Medial Center
  Future<ApiResponse<Map<String, dynamic>>> getSavedMedicalCenters(
      {required int page, required int limit}) {
    return get(ApiEndpoints.getSavedMedicalCenters(page, limit),
        fromJson: (data) => data as Map<String, dynamic>);
  }
}
