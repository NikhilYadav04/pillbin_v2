import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class DonationService extends ApiService {
  Future<ApiResponse<Map<String, dynamic>>> submitRequest(
      Map<String, dynamic> data, {List<File> photos = const []}) async {
    if (photos.isEmpty) {
      return post(ApiEndpoints.submitDonation,
          data: data, fromJson: (d) => d as Map<String, dynamic>);
    }

    // Multipart when photos attached
    final formData = FormData.fromMap({
      ...data,
      'medicines': data['medicines'], // already a List, Dio handles it
    });
    for (final file in photos) {
      formData.files.add(MapEntry(
        'medicinePhotos',
        await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      ));
    }
    return post(ApiEndpoints.submitDonation,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> getMyRequests(
      {String? status, int page = 1, int limit = 10}) async {
    return get(
        ApiEndpoints.myDonationRequests(
            status: status, page: page, limit: limit),
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> getById(String id) async {
    return get(ApiEndpoints.donationById(id),
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> cancelRequest(String id) async {
    return delete(ApiEndpoints.donationById(id),
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> submitReview(String requestId,
      {required int rating, String? comment}) async {
    return post(ApiEndpoints.reviewDonation(requestId),
        data: {
          'rating': rating,
          if (comment != null && comment.trim().isNotEmpty) 'comment': comment,
        },
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> getCenterReviews(String centerId,
      {int page = 1, int limit = 10, int? rating}) async {
    return get(
        ApiEndpoints.centerReviews(centerId,
            page: page, limit: limit, rating: rating),
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> getHandoffToken(String id) async {
    return get(ApiEndpoints.handoffToken(id),
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteReview(
      String reviewId) async {
    return delete(ApiEndpoints.deleteReview(reviewId),
        fromJson: (d) => d as Map<String, dynamic>);
  }

  Future<ApiResponse<Map<String, dynamic>>> getCenterInventory(
      String centerId) async {
    return get(ApiEndpoints.medicalCenterInventory(centerId),
        fromJson: (d) => d as Map<String, dynamic>);
  }
}
