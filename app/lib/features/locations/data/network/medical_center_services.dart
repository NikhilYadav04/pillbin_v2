import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class MedicalCenterServices extends ApiService {
  //* Get All Medical Centers
  Future<ApiResponse<Map<String, dynamic>>> getAllMedicalCenters({
    required int page,
    required int limit,
  }) async {
    return get(ApiEndpoints.getAllMedicalCenters(page, limit),
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Get Nearby Medical Centers
  Future<ApiResponse<Map<String, dynamic>>> getNearByMedicalCenters({
    required double latitude,
    required double longitude,
    required int radius,
    required int page,
    required int limit,
  }) async {
    return get(
        ApiEndpoints.getNearbyMedicalCenters(
            latitude, longitude, radius, page, limit),
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Search Medical Centers
  Future<ApiResponse<Map<String, dynamic>>> searchMedicalCenters({
    required String query,
    required String facilityType,
    required int page,
    required int limit,
  }) async {
    return get(
        ApiEndpoints.searchMedicalCenters(query, facilityType, page, limit),
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Get Medical Center by ID
  Future<ApiResponse<Map<String, dynamic>>> getMedicalCenterbyID(
      {required String medicalCenterId}) async {
    return get(ApiEndpoints.getMedicalCenterbyID(medicalCenterId),
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* Add Medical Center
  Future<ApiResponse<Map<String, dynamic>>> addMedicalCenter({
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
    return post(
      ApiEndpoints.addMedicalCenter,
      data: {
        "name": name,
        "address": address,
        "phoneNumber": phoneNumber,
        "location": {
          "latitude": latitude,
          "longitude": longitude,
        },
        "acceptedMedicineTypes": acceptedMedicineTypes,
        "operatingHours": operatingHours,
        "facilityType": facilityType,
        if (website != null) "website": website,
        if (email != null) "email": email,
        if (specialServices != null) "specialServices": specialServices,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Update Medical Center
  Future<ApiResponse<Map<String, dynamic>>> editMedicalCenter({
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
    final Map<String, dynamic> data = {};

    if (name != null) data["name"] = name;
    if (address != null) data["address"] = address;
    if (phoneNumber != null) data["phoneNumber"] = phoneNumber;
    if (latitude != null || longitude != null) {
      data["location"] = {
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
      };
    }
    if (acceptedMedicineTypes != null) {
      data["acceptedMedicineTypes"] = acceptedMedicineTypes;
    }
    if (operatingHours != null) data["operatingHours"] = operatingHours;
    if (facilityType != null) data["facilityType"] = facilityType;
    if (website != null) data["website"] = website;
    if (email != null) data["email"] = email;
    if (specialServices != null) data["specialServices"] = specialServices;

    return put(
      ApiEndpoints.updateMedicalCenter(medicalCenterId),
      data: data,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Delete Medical Center
  Future<ApiResponse<Map<String, dynamic>>> deleteMedicalCenter(
      {required String medicalCenterId}) async {
    return delete(ApiEndpoints.deleteMedicalCenter(medicalCenterId),
        fromJson: (data) => data as Map<String, dynamic>);
  }
}
