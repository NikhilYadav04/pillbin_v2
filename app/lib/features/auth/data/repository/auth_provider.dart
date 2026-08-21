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
  Future<void> sendMailFromGmail(String sender, String sub, String text,
      {String? html}) async {
    //* Create the email message
    final message = Message()
      ..from = Address(dotenv.env["GMAIL_MAIL"]!, 'PillBin')
      ..recipients.add(sender)
      ..subject = sub
      ..text = text;

    if (html != null) message.html = html;

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

  //* Signing up and signing back in are different moments — a returning user
  //* should not be welcomed aboard again
  ({String subject, String text, String html}) buildOtpEmail(
    String email,
    String otpCode, {
    required bool isLogin,
  }) {
    final greeting = email.isNotEmpty ? email : 'there';

    final subject =
        isLogin ? 'Your PillBin sign-in code' : 'Verify your PillBin email';

    final headline = isLogin ? 'Sign in to PillBin' : 'Welcome to PillBin';

    final intro = isLogin
        ? 'Use the code below to sign in to your account.'
        : 'You are almost set up. Use the code below to verify your email and '
            'finish creating your account.';

    final text = '''
Hi $greeting,

$headline

$intro

$otpCode

This code expires in 10 minutes. Do not share it with anyone.
If you did not request it, you can safely ignore this email.

The PillBin Team
''';

    final html = '''
<!doctype html>
<html>
<body style="margin:0;padding:0;background:#F1F5F9;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0"
         style="background:#F1F5F9;padding:32px 16px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellpadding="0" cellspacing="0"
               style="max-width:480px;background:#FFFFFF;border-radius:12px;
                      overflow:hidden;font-family:-apple-system,BlinkMacSystemFont,
                      'Segoe UI',Roboto,Arial,sans-serif;">
          <tr>
            <td style="background:#2563EB;padding:24px 28px;">
              <div style="font-size:22px;font-weight:700;color:#FFFFFF;">PillBin</div>
              <div style="font-size:13px;color:#DBEAFE;margin-top:4px;">
                Safe medicine disposal and donation
              </div>
            </td>
          </tr>
          <tr>
            <td style="padding:28px;">
              <div style="font-size:18px;font-weight:600;color:#0F172A;">
                $headline
              </div>
              <div style="font-size:14px;color:#475569;line-height:1.6;margin-top:10px;">
                Hi $greeting,<br/>$intro
              </div>
              <div style="margin:24px 0;padding:18px;background:#EFF6FF;
                          border:1px solid #DBEAFE;border-radius:10px;text-align:center;">
                <div style="font-size:11px;letter-spacing:1.5px;color:#64748B;
                            text-transform:uppercase;font-weight:600;">
                  Your code
                </div>
                <div style="font-size:32px;font-weight:700;letter-spacing:8px;
                            color:#2563EB;margin-top:8px;">
                  $otpCode
                </div>
              </div>
              <div style="font-size:13px;color:#64748B;line-height:1.6;">
                This code expires in <b>10 minutes</b>. Do not share it with anyone.
              </div>
              <div style="font-size:13px;color:#94A3B8;line-height:1.6;margin-top:14px;">
                If you did not request this, you can safely ignore this email.
              </div>
            </td>
          </tr>
          <tr>
            <td style="padding:16px 28px;border-top:1px solid #E2E8F0;
                       font-size:12px;color:#94A3B8;">
              Sent by PillBin
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';

    return (subject: subject, text: text, html: html);
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
        final mail = buildOtpEmail(email, otp.toString(), isLogin: false);
        await sendMailFromGmail(
          email,
          mail.subject,
          mail.text,
          html: mail.html,
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
        final mail = buildOtpEmail(email, otp.toString(), isLogin: true);
        await sendMailFromGmail(
          email,
          mail.subject,
          mail.text,
          html: mail.html,
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
