import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/auth/presentation/widgets/otp_widgets.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isLogin;

  const OtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.isLogin,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  // ignore: unused_field
  bool _isResending = false;
  int _resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Auto focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? sw * 0.1 : sw * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: sh * 0.02),
                  buildOTPHeader(sw, sh, isTablet, context),
                  SizedBox(height: sh * 0.04),
                  buildOTPLogo(sw, sh, isTablet),
                  SizedBox(height: sh * 0.05),
                  buildOTPInstructions(sw, sh, isTablet),
                  SizedBox(height: sh * 0.02),
                  _buildOtpInput(sw, sh, isTablet),
                  SizedBox(height: sh * 0.06),
                  Spacer(),
                  _buildVerifyButton(sw, sh, isTablet),
                  SizedBox(height: sh * 0.04),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOtpInput(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Verification Code',
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textPrimary,
          ),
        ),
        SizedBox(height: sh * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return Container(
              width: isTablet ? sw * 0.08 : sw * 0.12,
              height: isTablet ? sw * 0.08 : sw * 0.12,
              decoration: BoxDecoration(
                color: PillBinColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _focusNodes[index].hasFocus
                      ? PillBinColors.primary
                      : PillBinColors.greyLight,
                  width: _focusNodes[index].hasFocus ? 2 : 1,
                ),
                boxShadow: [
                  if (_focusNodes[index].hasFocus)
                    BoxShadow(
                      color: PillBinColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.03 : sw * 0.05,
                  color: PillBinColors.textDark,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  if (value.length == 1) {
                    if (index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else {
                      _focusNodes[index].unfocus();
                    }
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVerifyButton(double sw, double sh, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            PillBinColors.primary,
            PillBinColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: PillBinColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          onTap: _isLoading
              ? null
              : widget.isLogin
                  ? () {
                      Navigator.pushNamed(
                        context,
                        '/bottom-bar-screen',
                        arguments: {
                          'transition': TransitionType.rightToLeft,
                          'duration': 300,
                        },
                      );
                    }
                  : () {
                      Navigator.pushNamed(
                        context,
                        '/complete-profile-screen',
                        arguments: {
                          'transition': TransitionType.rightToLeft,
                          'duration': 300,
                        },
                      );
                    },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? sh * 0.025 : sh * 0.02,
              horizontal: isTablet ? sw * 0.03 : sw * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  SizedBox(
                    width: isTablet ? sw * 0.025 : sw * 0.04,
                    height: isTablet ? sw * 0.025 : sw * 0.04,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: isTablet ? sw * 0.025 : sw * 0.05,
                  ),
                SizedBox(width: sw * 0.03),
                Text(
                  _isLoading ? 'Verifying...' : 'Verify Code',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleVerifyOtp() {
    Navigator.pushNamed(
      context,
      '/complete-profile-screen',
      arguments: {
        'transition': TransitionType.rightToLeft,
        'duration': 300,
      },
    );
  }

  void _handleResendOtp() {
    setState(() {
      _isResending = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification code sent to ${widget.phoneNumber}'),
            backgroundColor: PillBinColors.success,
          ),
        );
      }
    });
  }
}
