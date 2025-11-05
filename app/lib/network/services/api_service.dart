import 'package:dio/dio.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/utils/http_client.dart';

abstract class ApiService {
  final Dio _dio = HttpClient().dio;

  Future<ApiResponse<T>> handleRequest<T>(
    Future<Response> request,
    T Function(dynamic)? fromJson, {
    bool isDirectJson = false, //* New parameter for direct JSON
  }) async {
    try {
      final response = await request;

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (isDirectJson) {
          return ApiResponse.fromDirectJson(response.data, fromJson);
        } else {
          return ApiResponse.fromJson(response.data, fromJson);
        }
      } else {
        return ApiResponse.error(
          'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiResponse.error('Connection timeout', statusCode: 408);
      case DioExceptionType.sendTimeout:
        return ApiResponse.error('Send timeout', statusCode: 408);
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error('Receive timeout', statusCode: 408);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Bad response';
        return ApiResponse.error(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return ApiResponse.error('Request cancelled');
      case DioExceptionType.connectionError:
        return ApiResponse.error('No internet connection');
      case DioExceptionType.unknown:
        return ApiResponse.error('Unknown error occurred');
      default:
        return ApiResponse.error('Something went wrong');
    }
  }

  // Common HTTP methods
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool isDirectJson = false,
  }) async {
    return handleRequest(
      _dio.get(endpoint, queryParameters: queryParameters),
      fromJson,
      isDirectJson: isDirectJson
    );
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool isDirectJson = false,
  }) async {
    return handleRequest(
      _dio.post(endpoint, data: data, queryParameters: queryParameters),
      fromJson,
      isDirectJson: isDirectJson
    );
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool isDirectJson = false,
  }) async {
    return handleRequest(
      _dio.put(endpoint, data: data, queryParameters: queryParameters),
      fromJson,
      isDirectJson: isDirectJson
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool isDirectJson = false,
  }) async {
    return handleRequest(
      _dio.delete(endpoint, data: data, queryParameters: queryParameters),
      fromJson,
      isDirectJson: isDirectJson
    );
  }
}
