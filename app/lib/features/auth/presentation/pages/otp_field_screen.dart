import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/auth/data/repository/auth_provider.dart';
import 'package:pillbin/features/auth/presentation/widgets/otp_widgets.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final bool isLogin;

  const OtpScreen({
    Key? key,
    required this.email,
    required this.isLogin,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 30;
  Timer? _timer;

  //* provider
  final AuthProvider _authProvider = AuthProvider();

  // Animation controllers
  late AnimationController _verifyAnimationController;
  late AnimationController _resendAnimationController;
  late Animation<double> _verifyPulseAnimation;
  late Animation<double> _verifyScaleAnimation;
  late Animation<double> _resendPulseAnimation;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // Initialize animation controllers
    _verifyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _resendAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _verifyPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _verifyAnimationController,
      curve: Curves.easeInOut,
    ));

    _verifyScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _verifyAnimationController,
      curve: Curves.easeInOut,
    ));

    _resendPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _resendAnimationController,
      curve: Curves.elasticOut,
    ));

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
    _verifyAnimationController.dispose();
    _resendAnimationController.dispose();
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

  String _getOtpValue() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  bool _isOtpComplete() {
    return _getOtpValue().length == 6;
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: PillBinColors.background,
      body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? sw * 0.1 : sw * 0.06),
                child: Column(
                  children: [
                    SizedBox(height: sh * 0.02),
                    buildOTPHeader(sw, sh, isTablet, context),
                    SizedBox(height: sh * 0.04),
                    buildOTPLogo(sw, sh, isTablet),
                    SizedBox(height: sh * 0.05),
                    buildOTPInstructions(sw, sh, widget.email, isTablet),
                    SizedBox(height: sh * 0.02),
                    _buildOtpInput(sw, sh, isTablet),
                    SizedBox(height: sh * 0.04),
                    _buildResendSection(sw, sh, isTablet),
                    Spacer(),
                    _buildVerifyButton(sw, sh, isTablet),
                    SizedBox(height: sh * 0.04),
                  ],
                ),
              ),
            ),
          ),
        );
      })),
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
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isTablet ? sw * 0.08 : sw * 0.12,
              height: isTablet ? sw * 0.08 : sw * 0.12,
              decoration: BoxDecoration(
                color: PillBinColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _focusNodes[index].hasFocus
                      ? PillBinColors.primary
                      : _otpControllers[index].text.isNotEmpty
                          ? PillBinColors.success
                          : PillBinColors.greyLight,
                  width: _focusNodes[index].hasFocus ? 2 : 1,
                ),
                boxShadow: [
                  if (_focusNodes[index].hasFocus)
                    BoxShadow(
                      color: PillBinColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  if (_otpControllers[index].text.isNotEmpty &&
                      !_focusNodes[index].hasFocus)
                    BoxShadow(
                      color: PillBinColors.success.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Center(
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
                    setState(() {}); // Rebuild to update button state

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
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildResendSection(double sw, double sh, bool isTablet) {
    return Center(
      child: Column(
        children: [
          if (_resendTimer > 0) ...[
            Text(
              'Didn\'t receive the code?',
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                color: PillBinColors.textSecondary,
              ),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              'Resend in ${_resendTimer}s',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                color: PillBinColors.primary,
              ),
            ),
          ] else ...[
            AnimatedBuilder(
              animation: _resendAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isResending ? _resendPulseAnimation.value : 1.0,
                  child: TextButton(
                    onPressed: _isResending ? null : _handleResendOtp,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? sw * 0.04 : sw * 0.06,
                        vertical: isTablet ? sh * 0.015 : sh * 0.012,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isResending) ...[
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                PillBinColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: sw * 0.02),
                        ] else
                          Icon(
                            Icons.refresh,
                            size: isTablet ? sw * 0.02 : sw * 0.04,
                            color: PillBinColors.primary,
                          ),
                        SizedBox(width: sw * 0.02),
                        Text(
                          _isResending ? 'Sending...' : 'Resend Code',
                          style: PillBinMedium.style(
                            fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                            color: PillBinColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifyButton(double sw, double sh, bool isTablet) {
    final bool canVerify = _isOtpComplete() && !_isLoading;

    return AnimatedBuilder(
      animation: _verifyAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isLoading ? _verifyScaleAnimation.value : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: canVerify
                    ? _isLoading
                        ? [
                            PillBinColors.primary.withOpacity(0.8),
                            PillBinColors.primaryLight.withOpacity(0.8),
                          ]
                        : [
                            PillBinColors.primary,
                            PillBinColors.primaryLight,
                          ]
                    : [
                        PillBinColors.greyLight,
                        PillBinColors.greyLight,
                      ],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              boxShadow: canVerify
                  ? [
                      BoxShadow(
                        color: PillBinColors.primary.withOpacity(
                          _isLoading ? 0.6 * _verifyPulseAnimation.value : 0.4,
                        ),
                        blurRadius:
                            _isLoading ? 15 * _verifyPulseAnimation.value : 12,
                        offset: const Offset(0, 4),
                        spreadRadius:
                            _isLoading ? 2 * _verifyPulseAnimation.value : 0,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                onTap: canVerify ? _handleVerifyOtp : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? sh * 0.025 : sh * 0.02,
                    horizontal: isTablet ? sw * 0.03 : sw * 0.05,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading) ...[
                        SizedBox(
                          width: isTablet ? sw * 0.025 : sw * 0.04,
                          height: isTablet ? sw * 0.025 : sw * 0.04,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        // Animated dots
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < 3; i++)
                              AnimatedContainer(
                                duration:
                                    Duration(milliseconds: 300 + (i * 100)),
                                margin: EdgeInsets.symmetric(horizontal: 1),
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                    0.3 +
                                        (0.7 *
                                            (((_verifyAnimationController
                                                        .value +
                                                    i * 0.3) %
                                                1.0))),
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                          ],
                        ),
                      ] else
                        Icon(
                          canVerify ? Icons.verified_user : Icons.lock_outline,
                          color: canVerify
                              ? Colors.white
                              : PillBinColors.textLight,
                          size: isTablet ? sw * 0.025 : sw * 0.05,
                        ),
                      SizedBox(width: sw * 0.03),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                          color: canVerify
                              ? Colors.white.withOpacity(_isLoading ? 0.8 : 1.0)
                              : PillBinColors.textLight,
                        ),
                        child: Text(
                          _isLoading
                              ? 'Verifying OTP...'
                              : canVerify
                                  ? 'Verify Code'
                                  : 'Enter Complete Code',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleVerifyOtp() async {
    if (!_isOtpComplete()) return;

    setState(() {
      _isLoading = true;
    });

    // Start verification animation
    _verifyAnimationController.repeat(reverse: true);

    try {
      String otp = _otpControllers.map((controller) => controller.text).join();
      // Simulate API call
      String response = widget.isLogin
          ? await _authProvider.verifyOTPlogin(
              context: context, email: widget.email, otp: otp)
          : await _authProvider.verifyOTPregister(
              context: context, email: widget.email, otp: otp);

      // Stop animation
      _verifyAnimationController.stop();
      _verifyAnimationController.reset();

      setState(() {
        _isLoading = false;
      });

      if (response == "success") {
        // Navigate based on login status
        if (widget.isLogin) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/bottom-bar-screen',
            (Route<dynamic> route) => false,
            arguments: {
              'transition': TransitionType.rightToLeft,
              'duration': 300,
            },
          );
        } else {
          Navigator.pushNamed(
            context,
            '/complete-profile-screen',
            arguments: {
              'transition': TransitionType.rightToLeft,
              'duration': 300,
              'phone': widget.email,
            },
          );
        }
      } else {
        return;
      }
    } catch (e) {
      // Handle error
      _verifyAnimationController.stop();
      _verifyAnimationController.reset();

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleResendOtp() async {
    setState(() {
      _isResending = true;
    });

    // Start resend animation
    _resendAnimationController.forward().then((_) {
      _resendAnimationController.reverse();
    });

    try {
      // Simulate API call
      await _authProvider.login(context: context, email: widget.email);

      setState(() {
        _isResending = false;
      });

      // Restart timer
      _startResendTimer();

      // Clear OTP fields for new code
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    } catch (e) {
      setState(() {
        _isResending = false;
      });
    }
  }
}
