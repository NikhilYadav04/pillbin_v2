import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/auth/data/repository/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:pillbin/network/utils/http_client.dart';
import 'package:url_launcher/url_launcher.dart';

const String _privacyUrl = 'https://nikhilyadav04.github.io/privacy-policy/';
const String _termsUrl = 'https://nikhilyadav04.github.io/privacy-policy/';

class EmailAuthScreen extends StatefulWidget {
  final bool isLogin;

  const EmailAuthScreen({Key? key, required this.isLogin}) : super(key: key);

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
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
                        SizedBox(height: sh * 0.08),
                        _buildLogo(sw, sh, isTablet),
                        SizedBox(height: sh * 0.06),
                        _buildWelcomeSection(sw, sh, isTablet),
                        SizedBox(height: sh * 0.08),
                        _buildEmailInputSection(sw, sh, isTablet),
                        SizedBox(height: sh * 0.04),
                        _buildActionButton(sw, sh, isTablet),
                        SizedBox(height: sh * 0.025),
                        _buildDivider(sw, sh, isTablet),
                        SizedBox(height: sh * 0.025),
                        _buildGoogleButton(sw, sh, isTablet),
                        Expanded(child: Container()),
                        _buildFooter(sw, sh, isTablet),
                        SizedBox(height: sh * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo(double sw, double sh, bool isTablet) {
    return Container(
      width: isTablet ? sw * 0.25 : sw * 0.35,
      height: isTablet ? sw * 0.25 : sw * 0.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.06 : sw * 0.08),
        boxShadow: [
          BoxShadow(
            color: PillBinColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.06 : sw * 0.08),
        child: Image.asset(
          'assets/images/logo.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(double sw, double sh, bool isTablet) {
    return Column(
      children: [
        Text(
          widget.isLogin ? 'Welcome Back!' : 'Get Started',
          style: PillBinBold.style(
            fontSize: isTablet ? sw * 0.04 : sw * 0.07,
            color: PillBinColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: sh * 0.02),
        Text(
          widget.isLogin
              ? 'Sign in to continue managing your medicines safely'
              : 'Create your account to start tracking medicines and join disposal campaigns',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailInputSection(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textPrimary,
          ),
        ),
        SizedBox(height: sh * 0.015),
        Container(
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(color: PillBinColors.greyLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                  vertical: isTablet ? sh * 0.02 : sh * 0.015,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: PillBinColors.greyLight),
                  ),
                ),
                child: Icon(
                  Icons.email_outlined,
                  color: PillBinColors.textSecondary,
                  size: isTablet ? sw * 0.025 : sw * 0.05,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    hintStyle: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                      color: PillBinColors.textLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                      vertical: isTablet ? sh * 0.02 : sh * 0.015,
                    ),
                  ),
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                    color: PillBinColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sh * 0.015),
        Text(
          'We\'ll send you a verification code via email',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.02 : sw * 0.03,
            color: PillBinColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(double sw, double sh, bool isTablet) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isLoading ? _scaleAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: _isLoading
                    ? [
                        PillBinColors.primary.withOpacity(0.8),
                        PillBinColors.primaryLight.withOpacity(0.8),
                      ]
                    : [
                        PillBinColors.primary,
                        PillBinColors.primaryLight,
                      ],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              boxShadow: [
                BoxShadow(
                  color: PillBinColors.primary.withOpacity(
                      _isLoading ? 0.6 * _pulseAnimation.value : 0.4),
                  blurRadius: _isLoading ? 15 * _pulseAnimation.value : 12,
                  offset: const Offset(0, 4),
                  spreadRadius: _isLoading ? 2 * _pulseAnimation.value : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                onTap: _isLoading
                    ? null
                    : () {
                        _handleAuth(
                            _emailController.text.toString(), widget.isLogin);
                      },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? sh * 0.02 : sh * 0.018,
                    horizontal: isTablet ? sw * 0.03 : sw * 0.05,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading) ...[
                        // Custom animated loading indicator
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
                                            (((_animationController.value +
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
                          widget.isLogin ? Icons.login : Icons.person_add,
                          color: Colors.white,
                          size: isTablet ? sw * 0.025 : sw * 0.05,
                        ),
                      SizedBox(width: sw * 0.03),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                          color:
                              Colors.white.withOpacity(_isLoading ? 0.8 : 1.0),
                        ),
                        child: Text(
                          _isLoading
                              ? 'Sending OTP...'
                              : widget.isLogin
                                  ? 'Sign In'
                                  : 'Create Account',
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

  Widget _buildDivider(double sw, double sh, bool isTablet) {
    return Row(
      children: [
        Expanded(child: Divider(color: PillBinColors.greyLight, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.03),
          child: Text('or',
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                color: PillBinColors.textLight,
              )),
        ),
        Expanded(child: Divider(color: PillBinColors.greyLight, thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton(double sw, double sh, bool isTablet) {
    //* Fixed height rather than a percentage of screen height — the percentage
    //* made this tower over the email field on tall devices
    final radius = BorderRadius.circular(isTablet ? 14 : 10);
    final disabled = _isGoogleLoading || _isLoading;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: isTablet ? 56 : 48,
          child: Material(
            color: PillBinColors.surface,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: disabled ? null : _handleGoogleAuth,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: PillBinColors.greyLight, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isGoogleLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              PillBinColors.primary),
                        ),
                      )
                    else
                      Image.asset(
                        'assets/images/google_g.png',
                        width: isTablet ? 22 : 20,
                        height: isTablet ? 22 : 20,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.g_mobiledata_rounded,
                          size: isTablet ? 26 : 24,
                          color: PillBinColors.textDark,
                        ),
                      ),
                    SizedBox(width: sw * 0.025),
                    Text(
                      _isGoogleLoading
                          ? 'Signing in...'
                          : 'Continue with Google',
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.022 : sw * 0.037,
                        color: PillBinColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: sh * 0.012),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: isTablet ? 13 : 12, color: PillBinColors.textLight),
            SizedBox(width: sw * 0.015),
            Text(
              'Secured by Google',
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.017 : sw * 0.028,
                color: PillBinColors.textLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleGoogleAuth() async {
    setState(() => _isGoogleLoading = true);

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.signInWithGoogle();

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (result == 'cancelled') return;

    if (result != 'success') {
      CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: authProvider.lastError ?? 'Google sign-in failed');
      return;
    }

    final role = await HttpClient().getRole();
    final vendorCenterId = await HttpClient().getVendorCenterId();
    if (!mounted) return;

    final destination = role == 'vendor'
        ? ((vendorCenterId != null && vendorCenterId.isNotEmpty)
            ? '/vendor-bottom-bar-screen'
            : '/vendor-onboarding-screen')
        : '/bottom-bar-screen';

    Navigator.pushNamedAndRemoveUntil(
      context,
      destination,
      (Route<dynamic> route) => false,
      arguments: {
        'transition': TransitionType.rightToLeft,
        'duration': 300,
      },
    );
  }

  Widget _buildFooter(double sw, double sh, bool isTablet) {
    final base = PillBinRegular.style(
      fontSize: isTablet ? sw * 0.018 : sw * 0.028,
      color: PillBinColors.textLight,
    );
    final link = base.copyWith(
      color: PillBinColors.primary,
      decoration: TextDecoration.underline,
      decorationColor: PillBinColors.primary,
    );

    return Column(
      children: [
        Text.rich(
          TextSpan(
            style: base,
            children: [
              const TextSpan(text: 'By continuing, you agree to our '),
              TextSpan(
                text: 'Terms of Service',
                style: link,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _openUrl(_termsUrl),
              ),
              const TextSpan(text: '\nand '),
              TextSpan(
                text: 'Privacy Policy',
                style: link,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _openUrl(_privacyUrl),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        icon: Icons.error_outline,
        title: 'Could not open the link',
      );
    }
  }

  void _handleAuth(String email, bool login) async {
    setState(() => _isLoading = true);
    _animationController.repeat(reverse: true);

    final authProvider = context.read<AuthProvider>();
    final response = login
        ? await authProvider.login(email: email)
        : await authProvider.register(email: email);

    _animationController.stop();
    _animationController.reset();
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response == 'success') {
      CustomSnackBar.show(
          context: context,
          icon: Icons.email_outlined,
          title: 'OTP sent successfully to $email');
      Navigator.pushNamed(
        context,
        '/otp-field-screen',
        arguments: {
          'email': email,
          'login': login,
          'transition': TransitionType.rightToLeft,
          'duration': 300,
        },
      );
    } else {
      CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: authProvider.lastError ?? 'Something went wrong');
    }
  }
}
