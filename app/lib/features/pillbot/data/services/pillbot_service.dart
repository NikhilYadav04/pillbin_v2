import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';
import 'package:pillbin/network/utils/http_client.dart';

class PillbotService {
  final Dio _dio = HttpClient().dio;

  //* Query Agent (Text + Optional File)
  Future<Map<String, dynamic>> queryAgent({
    required String token,
    required String userMessage,
    String latitude = "",
    String longitude = "",
    File? file,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "token": token,
        "user_message": userMessage,
        "latitude": latitude,
        "longitude": longitude,
      });

      if (file != null) {
        formData.files.add(
          MapEntry(
            "file",
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        ApiEndpoints.queryAgent,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      bool isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      return {
        "success": isSuccess,
        "data": response.data,
        "statusCode": response.statusCode,
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "error": e.response?.data ?? e.message,
        "statusCode": e.response?.statusCode,
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  //* Get Chat History (Paginated)
  Future<Map<String, dynamic>> getHistory({
    required String token,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(ApiEndpoints.getHistory(
        token: token,
        page: page,
        limit: limit,
      ));

      bool isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      return {
        "success": isSuccess,
        "data": response.data,
        "statusCode": response.statusCode,
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "error": e.response?.data ?? e.message,
        "statusCode": e.response?.statusCode,
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  //* Clear Chat History
  Future<Map<String, dynamic>> clearHistory(String token) async {
    try {
      final response = await _dio.delete(ApiEndpoints.clearHistory(token));

      bool isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      return {
        "success": isSuccess,
        "data": response.data,
        "statusCode": response.statusCode,
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "error": e.response?.data ?? e.message,
        "statusCode": e.response?.statusCode,
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  //* Clear RAG Knowledge (Maintenance)
  Future<Map<String, dynamic>> clearKnowledge(String token) async {
    try {
      final response = await _dio.post(ApiEndpoints.clearKnowledge(token));

      bool isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      return {
        "success": isSuccess,
        "data": response.data,
        "statusCode": response.statusCode,
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "error": e.response?.data ?? e.message,
        "statusCode": e.response?.statusCode,
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  //* Clear sqlite memory (Maintenance)
  Future<Map<String, dynamic>> clearMemory(String token) async {
    try {
      final response = await _dio.post(ApiEndpoints.clearMemory(token));

      bool isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      return {
        "success": isSuccess,
        "data": response.data,
        "statusCode": response.statusCode,
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "error": e.response?.data ?? e.message,
        "statusCode": e.response?.statusCode,
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }

  //* Health Check
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _dio.get(ApiEndpoints.health);

      bool isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      return {
        "success": isSuccess,
        "data": response.data,
        "statusCode": response.statusCode,
      };
    } on DioException catch (e) {
      return {
        "success": false,
        "error": e.response?.data ?? e.message,
        "statusCode": e.response?.statusCode,
      };
    } catch (e) {
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }
}
