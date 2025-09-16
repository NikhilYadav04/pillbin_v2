class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'],
      statusCode: json['statusCode'],
      errors: json['errors'],
    );
  }

  //* Success response
  factory ApiResponse.fromDirectJson(
      dynamic json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: true,
      message: 'Success',
      data: fromJsonT != null && json != null ? fromJsonT(json) : json,
      statusCode: 200,
      errors: null,
    );
  }

  //* Success response
  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: 200,
    );
  }

  //* Error response
  factory ApiResponse.error(String message,
      {int? statusCode, Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}
