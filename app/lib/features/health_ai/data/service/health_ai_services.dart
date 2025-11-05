import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class HealthAiServices extends ApiService {
  //* upload pdf
  Future<ApiResponse<Map<String, dynamic>>> uploadPDF({
    required String userId,
    required File file,
  }) async {
    String fileName = file.path.split('/').last;

    // * Create FormData to send a multipart request
    FormData formData = FormData.fromMap({
      'user_id': userId,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    return post(
      ApiEndpoints.uploadPDF,
      data: formData,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* ask query
  Future<ApiResponse<Map<String, dynamic>>> askQuery(
      {required String user_id, required String query}) async {
    return post(ApiEndpoints.askQuery,
        data: {"user_id": user_id, "query": query},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* delete index
  Future<ApiResponse<Map<String, dynamic>>> deleteIndex(
      {required String user_id}) async {
    return delete(ApiEndpoints.deleteIndex,
        data: {"user_id": user_id},
        fromJson: (data) => data as Map<String, dynamic>);
  }
}
