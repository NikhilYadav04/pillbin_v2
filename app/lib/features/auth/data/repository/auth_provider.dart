import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/auth/data/service/auth_service.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/utils/http_client.dart';

class AuthProvider extends ChangeNotifier {
  //* initialize services
  final AuthService _authService = AuthService();
  final HttpClient _httpClient = HttpClient();

  var logger = Logger();

  //* Register with phone number
  Future<String> register(
      {required BuildContext context, required String email}) async {
    try {
      //* validation
      if (email.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.email,
          title: "Please enter your email address!",
        );
        return 'error';
      }

//* ✅ Email Regex Validation
      final emailRegex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      );

      if (!emailRegex.hasMatch(email)) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.email,
          title: "Please enter a valid email address!",
        );
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response =
          await _authService.signUp(email: email);

      logger.d(response.statusCode);

      if (response.statusCode == 200) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.phone,
            title: "OTP sent successfully to ${email}");
        return 'success';
      } else if (response.statusCode == 400) {
        CustomSnackBar.show(
            context: context, icon: Icons.phone, title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.phone,
            title: "Error sending OTP, Please Try Again !!");
        return 'error';
      }
    } catch (e) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.phone,
          title: "Error sending OTP, Please Try Again !!");
      print(e.toString());
      return "error";
    }
  }

  //* Login with phone number
  Future<String> login(
      {required BuildContext context, required String email}) async {
    try {
      //* validation
      if (email.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.email,
          title: "Please enter your email address!",
        );
        return 'error';
      }

//* ✅ Email Regex Validation
      final emailRegex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      );

      if (!emailRegex.hasMatch(email)) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.email,
          title: "Please enter a valid email address!",
        );
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response =
          await _authService.signIn(email: email);

      if (response.statusCode == 200) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.phone,
            title: "OTP sent successfully to ${email}");
        return 'success';
      } else if (response.statusCode == 404) {
        CustomSnackBar.show(
            context: context, icon: Icons.phone, title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.phone,
            title: "Error sending OTP, Please Try Again !!");
        return 'error';
      }
    } catch (e) {
      print(e.toString());
      CustomSnackBar.show(
          context: context,
          icon: Icons.phone,
          title: "Error sending OTP, Please Try Again !!");
      return "error";
    }
  }

  //* Verify OTP SignUp
  Future<String> verifyOTPlogin(
      {required BuildContext context,
      required String email,
      required String otp}) async {
    try {
      if (otp.isEmpty) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.lock,
            title: "Please enter a 6-digit OTP!");
        return 'error';
      }

      if (otp.length != 6) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.lock,
            title: "OTP must be 6 digits !");
        return 'error';
      }

      if (email.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.email,
          title: "Please enter your email address!",
        );
        return 'error';
      }

//* ✅ Email Regex Validation
      final emailRegex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      );

      if (!emailRegex.hasMatch(email)) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.email,
          title: "Please enter a valid email address!",
        );
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response =
          await _authService.verifyOTPsignIn(email: email, otp: otp);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        //* save tokens to localstorage
        await _httpClient.saveTokens(data["accessToken"], data["refreshToken"]);

        Map<String, dynamic> userData = data["user"];

        await _httpClient.saveUserData(
            userData["fullName"], userData["phoneNumber"], userData["email"]);

        CustomSnackBar.show(
            context: context, icon: Icons.lock, title: response.message);
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context, icon: Icons.lock, title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.lock,
            title: "Unable to verify phone number. Try again later.");
        return 'error';
      }
    } catch (e) {
      print(e.toString());
      CustomSnackBar.show(
          context: context,
          icon: Icons.lock,
          title: "Unable to verify phone number. Try again later.");
      return 'error';
    }
  }

  //* Verify OTP Signin
  Future<String> verifyOTPregister(
      {required BuildContext context,
      required String email,
      required String otp}) async {
    try {
      if (otp.isEmpty) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.lock,
            title: "Please enter a 6-digit OTP!");
        return 'error';
      }

      if (otp.length != 6) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.lock,
            title: "OTP must be 6 digits !");
        return 'error';
      }

      if (email.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.email,
          title: "Please enter your email address!",
        );
        return 'error';
      }

      //* ✅ Email Regex Validation
      final emailRegex = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      );

      if (!emailRegex.hasMatch(email)) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.email,
          title: "Please enter a valid email address!",
        );
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response =
          await _authService.verifyOTPsignUp(email: email, otp: otp);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        //* save tokens to localstorage
        await _httpClient.saveTokens(data["accessToken"], data["refreshToken"]);

        CustomSnackBar.show(
            context: context, icon: Icons.lock, title: response.message);
        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        CustomSnackBar.show(
            context: context, icon: Icons.lock, title: response.message);
        return 'error';
      } else {
        CustomSnackBar.show(
            context: context,
            icon: Icons.lock,
            title: "Unable to verify phone number. Try again later.");
        return 'error';
      }
    } catch (e) {
      print(e.toString());
      CustomSnackBar.show(
          context: context,
          icon: Icons.lock,
          title: "Unable to verify phone number. Try again later.");
      return 'error';
    }
  }
}
