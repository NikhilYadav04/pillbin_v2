import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class AuthService extends ApiService {
  //* register with phone
  Future<ApiResponse<Map<String, dynamic>>> signUp(
      {required String phoneNumber}) async {
    return post(ApiEndpoints.signUp,
        data: {"phoneNumber": phoneNumber},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* verify OTP ( signup )
  Future<ApiResponse<Map<String, dynamic>>> verifyOTPsignUp(
      {required String phoneNumber, required String otp}) async {
    return post(ApiEndpoints.verifyOTPsignUp,
        data: {"phoneNumber": phoneNumber, "otp": otp},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* login with phone
  Future<ApiResponse<Map<String, dynamic>>> signIn(
      {required String phoneNumber}) async {
    return post(ApiEndpoints.signin,
        data: {"phoneNumber": phoneNumber},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* verify OTP (signin)
  Future<ApiResponse<Map<String, dynamic>>> verifyOTPsignIn(
      {required String phoneNumber, required String otp}) async {
    return post(ApiEndpoints.verifyOTPsignIn,
        data: {"phoneNumber": phoneNumber, "otp": otp},
        fromJson: (data) => data as Map<String, dynamic>);
  }
}
