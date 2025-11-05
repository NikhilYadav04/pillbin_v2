import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/auth/data/repository/auth_provider.dart';

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
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  //* auth provider
  final AuthProvider _authProvider = AuthProvider();

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

  Widget _buildFooter(double sw, double sh, bool isTablet) {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our Terms of Service\nand Privacy Policy',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.018 : sw * 0.028,
            color: PillBinColors.textLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleAuth(String email, bool login) async {
    setState(() {
      _isLoading = true;
    });

    //* Start pulsing animation
    _animationController.repeat(reverse: true);

    try {
      String response = login
          ? await _authProvider.login(context: context, email: email)
          : await _authProvider.register(context: context, email: email);

      if (response == 'success') {
        //* Stop animation
        _animationController.stop();
        _animationController.reset();

        setState(() {
          _isLoading = false;
        });

        //* Navigate to OTP screen
        if (login) {
          Navigator.pushNamed(
            context,
            '/otp-field-screen',
            arguments: {
              'email': email,
              'login': true,
              'transition': TransitionType.rightToLeft,
              'duration': 300,
            },
          );
        } else {
          Navigator.pushNamed(
            context,
            '/otp-field-screen',
            arguments: {
              'email': email,
              'login': false,
              'transition': TransitionType.rightToLeft,
              'duration': 300,
            },
          );
        }
      } else {
        //* Stop animation
        _animationController.stop();
        _animationController.reset();

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      //* Handle error
      _animationController.stop();
      _animationController.reset();

      setState(() {
        _isLoading = false;
      });
    }
  }
}
