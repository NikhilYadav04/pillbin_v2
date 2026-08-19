import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pillbin/config/notifications/fcm_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:pillbin/features/auth/data/service/auth_service.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/utils/http_client.dart';

class AuthProvider extends ChangeNotifier {
  //* initialize services
  final AuthService _authService = AuthService();
  final HttpClient _httpClient = HttpClient();

  var logger = Logger();

  //* Role selected during signup ('user' or 'vendor')
  String _selectedRole = 'user';
  String get selectedRole => _selectedRole;

  String? _lastError;
  String? get lastError => _lastError;

  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void reset() {
    _selectedRole = 'user';
    _lastError = null;
    notifyListeners();
  }

  //* <-------------- GOOGLE SIGN IN --------------------->

  bool _googleInitialized = false;

  Future<void> _initGoogle() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: dotenv.env["GOOGLE_SERVER_CLIENT_ID"],
    );
    _googleInitialized = true;
  }

  //* Returns 'success', 'cancelled' or 'error'
  Future<String> signInWithGoogle() async {
    try {
      _lastError = null;
      await _initGoogle();

      final GoogleSignInAccount account =
          await GoogleSignIn.instance.authenticate();
      final String? idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        _lastError = 'Google did not return a token. Try again.';
        return 'error';
      }

      final ApiResponse<Map<String, dynamic>> response =
          await _authService.googleAuth(idToken: idToken, role: _selectedRole);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data!;

        await _httpClient.saveTokens(data["accessToken"], data["refreshToken"]);

        final Map<String, dynamic> userData = data["user"];
        await _httpClient.saveUserData(userData["fullName"] ?? "",
            userData["phoneNumber"] ?? "", userData["email"] ?? "");

        await _httpClient.saveRole(userData["role"] as String? ?? 'user');
        await _httpClient
            .saveVendorCenterId(userData["vendorCenterId"] as String?);

        unawaited(FcmService().autoRegister(force: true));

        return 'success';
      }

      _lastError = response.message.isNotEmpty
          ? response.message
          : 'Google sign-in failed. Try again.';
      return 'error';
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return 'cancelled';
      logger.e(e);
      _lastError = 'Google sign-in failed. Try again.';
      return 'error';
    } catch (e) {
      logger.e(e);
      _lastError = 'Google sign-in failed. Try again.';
      return 'error';
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _initGoogle();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      //* Never block logout on the Google SDK
    }
  }

  //* <-------------- EMAIL SERVICE --------------------->

  //* send email
  Future<void> sendMailFromGmail(String sender, String sub, String text) async {
    //* Create the email message
    final message = Message()
      ..from = Address(dotenv.env["GMAIL_MAIL"]!, sub)
      ..recipients.add(sender)
      ..subject = sub
      ..text = text;

    //* Create Gmail SMTP server
    final gmailSmtp =
        gmail(dotenv.env["GMAIL_MAIL"]!, dotenv.env["GMAIL_PASSWORD"]!);

    try {
      //* Send the email
      final sendReport = await send(message, gmailSmtp);
      print('✅ Message sent: $sendReport');
    } on MailerException catch (e) {
      //* Handle sending errors
      print('❌ Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  //* prompt
  String buildOtpEmail(String email, String otpCode) {
    final text = '''
Hi ${email.isNotEmpty ? email : 'there'},

Welcome to PillBin! 🎉
We're excited to have you on board. Use the OTP below to complete your signup:

$otpCode

This OTP is valid for the next 10 minutes. Please do not share it with anyone.

Best regards,
The PillBin Team
''';

    return text;
  }

  //* <----------------END------------------------------>

  //* <---------------SESSION MANAGEMENT--------------->

  static const _secureStorage = FlutterSecureStorage();

  final String SESSION_KEY = dotenv.env["SESSION"]!;

  //* <----------------------------------------------->

  //* Register with phone number
  Future<String> register({required String email}) async {
    try {
      _lastError = null;

      //* validation
      if (email.isEmpty) {
        _lastError = 'Please enter your email address!';
        return 'error';
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _lastError = 'Please enter a valid email address!';
        return 'error';
      }

      //* Check for session count
      final listUsers = await _secureStorage.read(key: SESSION_KEY);
      List<String> users = [];
      if (listUsers != null) {
        users = List<String>.from(jsonDecode(listUsers));
      }

      //* Allow max 2 users per device
      if (users.length >= 2 && !users.contains(email)) {
        _lastError =
            '⚠️ Login limit reached. Only two users can log in on this device.';
        return 'revoke';
      }

      //* Add user if not already present
      if (!users.contains(email)) {
        users.add(email);
        await _secureStorage.write(key: SESSION_KEY, value: jsonEncode(users));
      }

      ApiResponse<Map<String, dynamic>> response =
          await _authService.signUp(email: email, role: _selectedRole);

      logger.d(response.statusCode);

      if (response.statusCode == 200) {
        String otp = response.data!["otp"];
        String prompt = buildOtpEmail(email, otp.toString());
        await sendMailFromGmail(
          email,
          "Welcome to PillBin – Your OTP for Signup",
          prompt,
        );
        await Future.delayed(const Duration(seconds: 1));
        return 'success';
      } else if (response.statusCode == 400) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Error sending OTP, Please Try Again!!';
        return 'error';
      }
    } catch (e) {
      _lastError = 'Error sending OTP, Please Try Again!!';
      print(e.toString());
      return 'error';
    }
  }

  //* Login with phone number
  Future<String> login({required String email}) async {
    try {
      _lastError = null;

      //* validation
      if (email.isEmpty) {
        _lastError = 'Please enter your email address!';
        return 'error';
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _lastError = 'Please enter a valid email address!';
        return 'error';
      }

      //* Check for session count
      final listUsers = await _secureStorage.read(key: SESSION_KEY);
      List<String> users = [];
      if (listUsers != null) {
        users = List<String>.from(jsonDecode(listUsers));
      }

      //* Allow max 2 users per device
      if (users.length >= 2 && !users.contains(email)) {
        _lastError =
            '⚠️ Login limit reached. Only two users can log in on this device.';
        return 'revoke';
      }

      //* Add user if not already present
      if (!users.contains(email)) {
        users.add(email);
        await _secureStorage.write(key: SESSION_KEY, value: jsonEncode(users));
      }

      ApiResponse<Map<String, dynamic>> response =
          await _authService.signIn(email: email);

      if (response.statusCode == 200) {
        String otp = response.data!["otp"];
        String prompt = buildOtpEmail(email, otp.toString());
        await sendMailFromGmail(
          email,
          "Welcome to PillBin – Your OTP for Signup",
          prompt,
        );
        await Future.delayed(const Duration(seconds: 1));
        return 'success';
      } else if (response.statusCode == 404) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Error sending OTP, Please Try Again!!';
        return 'error';
      }
    } catch (e) {
      print(e.toString());
      _lastError = 'Error sending OTP, Please Try Again!!';
      return 'error';
    }
  }

  //* Verify OTP SignUp
  Future<String> verifyOTPlogin(
      {required String email, required String otp}) async {
    try {
      _lastError = null;

      if (otp.isEmpty) {
        _lastError = 'Please enter a 6-digit OTP!';
        return 'error';
      }
      if (otp.length != 6) {
        _lastError = 'OTP must be 6 digits!';
        return 'error';
      }
      if (email.isEmpty) {
        _lastError = 'Please enter your email address!';
        return 'error';
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _lastError = 'Please enter a valid email address!';
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response =
          await _authService.verifyOTPsignIn(email: email, otp: otp);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        //* save tokens to localstorage
        await _httpClient.saveTokens(data["accessToken"], data["refreshToken"]);

        Map<String, dynamic> userData = data["user"];

        await _httpClient.saveUserData(userData["fullName"] ?? "",
            userData["phoneNumber"] ?? "", userData["email"] ?? "");

        //* save role and vendorCenterId
        final role = userData["role"] as String? ?? 'user';
        final vendorCenterId = userData["vendorCenterId"] as String?;
        await _httpClient.saveRole(role);
        await _httpClient.saveVendorCenterId(vendorCenterId);

        unawaited(FcmService().autoRegister(force: true));

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Unable to verify OTP. Try again later.';
        return 'error';
      }
    } catch (e) {
      print(e.toString());
      _lastError = 'Unable to verify OTP. Try again later.';
      return 'error';
    }
  }

  //* Verify OTP Signin
  Future<String> verifyOTPregister(
      {required String email, required String otp}) async {
    try {
      _lastError = null;

      if (otp.isEmpty) {
        _lastError = 'Please enter a 6-digit OTP!';
        return 'error';
      }
      if (otp.length != 6) {
        _lastError = 'OTP must be 6 digits!';
        return 'error';
      }
      if (email.isEmpty) {
        _lastError = 'Please enter your email address!';
        return 'error';
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _lastError = 'Please enter a valid email address!';
        return 'error';
      }

      ApiResponse<Map<String, dynamic>> response =
          await _authService.verifyOTPsignUp(email: email, otp: otp);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data!;

        //* save tokens to localstorage
        await _httpClient.saveTokens(data["accessToken"], data["refreshToken"]);

        //* save role and vendorCenterId
        final userData = data["user"] as Map<String, dynamic>? ?? {};
        final role = userData["role"] as String? ?? 'user';
        final vendorCenterId = userData["vendorCenterId"] as String?;
        await _httpClient.saveRole(role);
        await _httpClient.saveVendorCenterId(vendorCenterId);

        unawaited(FcmService().autoRegister(force: true));

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _lastError = response.message;
        return 'error';
      } else {
        _lastError = 'Unable to verify OTP. Try again later.';
        return 'error';
      }
    } catch (e) {
      print(e.toString());
      _lastError = 'Unable to verify OTP. Try again later.';
      return 'error';
    }
  }
}
