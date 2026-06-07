import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class AuthService extends ApiService {
  //* register with email (role: 'user' or 'vendor')
  Future<ApiResponse<Map<String, dynamic>>> signUp(
      {required String email, String role = 'user'}) async {
    return post(ApiEndpoints.signUp,
        data: {"email": email, "role": role},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* verify OTP ( signup )
  Future<ApiResponse<Map<String, dynamic>>> verifyOTPsignUp(
      {required String email, required String otp}) async {
    return post(ApiEndpoints.verifyOTPsignUp,
        data: {"email": email, "otp": otp},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* login with phone
  Future<ApiResponse<Map<String, dynamic>>> signIn(
      {required String email}) async {
    return post(ApiEndpoints.signin,
        data: {"email": email},
        fromJson: (data) => data as Map<String, dynamic>);
  }

  //* verify OTP (signin)
  Future<ApiResponse<Map<String, dynamic>>> verifyOTPsignIn(
      {required String email, required String otp}) async {
    return post(ApiEndpoints.verifyOTPsignIn,
        data: {"email": email, "otp": otp},
        fromJson: (data) => data as Map<String, dynamic>);
  }
}
