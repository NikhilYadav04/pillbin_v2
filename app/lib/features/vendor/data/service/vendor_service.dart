import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class VendorService extends ApiService {
  Future<ApiResponse<Map<String, dynamic>>> registerCenter(
      Map<String, dynamic> data) async {
    return post(ApiEndpoints.vendorRegisterCenter,
        data: data, fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> getMyCenter() async {
    return get(ApiEndpoints.vendorMyCenter,
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateMyCenter(
      Map<String, dynamic> data) async {
    return put(ApiEndpoints.vendorMyCenter,
        data: data, fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateInventory(
      List<Map<String, dynamic>> inventory) async {
    return put(ApiEndpoints.vendorInventory,
        data: {'inventory': inventory},
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> getRequests(
      {String? status, int page = 1, int limit = 10}) async {
    return get(ApiEndpoints.vendorRequests(status: status, page: page, limit: limit),
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateRequestStatus(
      String requestId, String status, {String? vendorNote}) async {
    return put(ApiEndpoints.vendorRequestUpdate(requestId),
        data: {'status': status, if (vendorNote != null) 'vendorNote': vendorNote},
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> completeRequest(
      String requestId) async {
    return put(ApiEndpoints.vendorRequestComplete(requestId),
        data: {}, fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> claimCenter(String centerId) async {
    return post(ApiEndpoints.vendorRegisterCenter,
        data: {'centerId': centerId},
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCenterImages(
      List<File> images, {List<String> keepPublicIds = const []}) async {
    final formData = FormData();
    for (final file in images) {
      formData.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      ));
    }
    formData.fields.add(MapEntry('keepPublicIds', keepPublicIds.isEmpty
        ? '[]'
        : '[${keepPublicIds.map((id) => '"$id"').join(',')}]'));
    return put(ApiEndpoints.vendorCenterImages,
        data: formData,
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> uploadVerificationDocs(
      List<File> docs) async {
    final formData = FormData();
    for (final file in docs) {
      formData.files.add(MapEntry(
        'documents',
        await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      ));
    }
    return post(ApiEndpoints.vendorUploadVerificationDocs,
        data: formData,
        fromJson: (d) => d as Map<String, dynamic>);
  }
}
