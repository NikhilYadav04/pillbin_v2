import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/auth/data/service/auth_service.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/utils/http_client.dart';

class AuthProvider extends ChangeNotifier {
  //* initialize services
  final AuthService _authService = AuthService();
  final HttpClient _httpClient = HttpClient();

  var logger = Logger();

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
We’re excited to have you on board. Use the OTP below to complete your signup:

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

      // //* Check for session count
      final listUsers = await _secureStorage.read(key: SESSION_KEY);
      List<String> users = [];

      if (listUsers != null) {
        users = List<String>.from(jsonDecode(listUsers));
      }

      //* ✅ Allow max 2 users per device
      if (users.length >= 2 && !users.contains(email)) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.warning,
          title:
              "⚠️ Login limit reached. Only two users can log in on this device.",
        );
        return 'revoke';
      }

      //* ✅ Add user if not already present
      if (!users.contains(email)) {
        users.add(email);
        await _secureStorage.write(key: SESSION_KEY, value: jsonEncode(users));
      }

      ApiResponse<Map<String, dynamic>> response =
          await _authService.signUp(email: email);

      logger.d(response.statusCode);

      if (response.statusCode == 200) {
        String otp = response.data!["otp"];

        String prompt = buildOtpEmail(email, otp.toString());

        //* 🔥 IMPORTANT FIXES
        await sendMailFromGmail(
          email,
          "Welcome to PillBin – Your OTP for Signup",
          prompt,
        );

        //* Optional small delay (now actually works)
        await Future.delayed(const Duration(seconds: 1));

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

      // //* Check for session count
      final listUsers = await _secureStorage.read(key: SESSION_KEY);
      List<String> users = [];

      if (listUsers != null) {
        users = List<String>.from(jsonDecode(listUsers));
      }

      //* ✅ Allow max 2 users per device
      if (users.length >= 2 && !users.contains(email)) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.warning,
          title:
              "⚠️ Login limit reached. Only two users can log in on this device.",
        );
        return 'revoke';
      }

      //* ✅ Add user if not already present
      if (!users.contains(email)) {
        users.add(email);
        await _secureStorage.write(key: SESSION_KEY, value: jsonEncode(users));
      }

      ApiResponse<Map<String, dynamic>> response =
          await _authService.signIn(email: email);

      if (response.statusCode == 200) {
        String otp = response.data!["otp"];

        String prompt = buildOtpEmail(email, otp.toString());

        //* 🔥 IMPORTANT FIXES
        await sendMailFromGmail(
          email,
          "Welcome to PillBin – Your OTP for Signup",
          prompt,
        );

        //* Optional small delay (now actually works)
        await Future.delayed(const Duration(seconds: 1));

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
