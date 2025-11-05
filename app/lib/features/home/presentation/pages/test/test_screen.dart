import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/features/auth/data/repository/auth_provider.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  //* provider
  final AuthProvider _authProvider = AuthProvider();

  // Test phone number for testing
  final String testPhoneNumber = "+1234567890";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            Center(
              child: Text(
                "Authentication Test",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 30),

            // 1. Send OTP for Signup
            _buildTestButton(
              title: "Send OTP for Signup",
              color: Colors.blue,
              onPressed: () {
                _authProvider.register(
                    context: context, email: "byadav1723@gmail.com");
              },
            ),

            SizedBox(height: 15),

            // 2. Verify OTP for Signup
            _buildTestButton(
              title: "Verify OTP for Signup",
              color: Colors.green,
              onPressed: () {
                _authProvider.verifyOTPregister(
                    context: context,
                    email: "byadav1723@gmail.com",
                    otp: "337712");
              },
            ),

            SizedBox(height: 15),

            // 3. Send OTP for Sign In
            _buildTestButton(
              title: "Send OTP for Sign In",
              color: Colors.orange,
              onPressed: () => {
                _authProvider.login(
                    context: context, email: "byadav1723@gmail.com")
              },
            ),

            SizedBox(height: 15),

            // 4. Verify OTP for Sign In
            _buildTestButton(
                title: "Verify OTP for Sign In",
                color: Colors.purple,
                onPressed: () {
                  _authProvider.verifyOTPregister(
                      context: context,
                      email: "byadav1723@gmail.com",
                      otp: "898163");
                }),

            SizedBox(height: 15),

            // 5. Complete Profile
            _buildTestButton(
              title: "Complete Profile",
              color: Colors.teal,
              onPressed: () => _testCompleteProfile(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Test method implementations
  void _testSendOtpSignup() async {
    try {
      print("Testing Send OTP for Signup...");

      // Replace with your actual method call
      // await _authProvider.sendOtpForSignup(testPhoneNumber);
      _showMessage("Send OTP for Signup - Test Called", Colors.blue);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _testVerifyOtpSignup() async {
    try {
      print("Testing Verify OTP for Signup...");
      // Replace with your actual method call
      // await _authProvider.verifyOtpForSignup(testPhoneNumber, "123456");
      _showMessage("Verify OTP for Signup - Test Called", Colors.green);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _testSendOtpSignIn() async {
    try {
      print("Testing Send OTP for Sign In...");
      // Replace with your actual method call
      // await _authProvider.sendOtpForSignIn(testPhoneNumber);
      _showMessage("Send OTP for Sign In - Test Called", Colors.orange);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _testVerifyOtpSignIn() async {
    try {
      print("Testing Verify OTP for Sign In...");
      // Replace with your actual method call
      // await _authProvider.verifyOtpForSignIn(testPhoneNumber, "123456");
      _showMessage("Verify OTP for Sign In - Test Called", Colors.purple);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _testCompleteProfile() async {
    try {
      print("Testing Complete Profile...");
      // Replace with your actual method call
      // await _authProvider.completeProfile(userProfileData);
      _showMessage("Complete Profile - Test Called", Colors.teal);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
