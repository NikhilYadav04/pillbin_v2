import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.bounceOut));

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );
  }

  void _startAnimations() async {
    await _logoController.forward();
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
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
                        SizedBox(
                            height:
                                sh * 0.05), // Reduced from 0.08 to move logo up
                        _buildAnimatedLogo(sw, sh, isTablet),
                        SizedBox(height: sh * 0.06),
                        _buildHeroSection(sw, sh, isTablet),
                        SizedBox(height: sh * 0.04),
                        _buildActionButtons(sw, sh, isTablet),
                        SizedBox(height: sh * 0.04),
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

  Widget _buildAnimatedLogo(double sw, double sh, bool isTablet) {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value * 0.1,
            child: Container(
              width: isTablet ? sw * 0.3 : sw * 0.4,
              height: isTablet ? sw * 0.3 : sw * 0.4,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(isTablet ? sw * 0.08 : sw * 0.1),
                boxShadow: [
                  BoxShadow(
                    color: PillBinColors.primary.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Image covering the whole shape
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          isTablet ? sw * 0.08 : sw * 0.1),
                      child: Image.asset(
                        'assets/images/logo.jpg', // Your logo image path
                        fit: BoxFit.cover, // Covers the entire container
                      ),
                    ),
                  ),
                  // Shimmer effect on top
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                isTablet ? sw * 0.08 : sw * 0.1),
                            gradient: LinearGradient(
                              begin: Alignment(
                                -1 + (_logoController.value * 2),
                                -1 + (_logoController.value * 2),
                              ),
                              end: Alignment(
                                0 + (_logoController.value * 2),
                                0 + (_logoController.value * 2),
                              ),
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(double sw, double sh, bool isTablet) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Text(
              'Welcome to PillBin',
              style: PillBinBold.style(
                fontSize: isTablet ? sw * 0.05 : sw * 0.08,
                color: PillBinColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sh * 0.02),
            Text(
              'Dispose Them Properly\nSaving The Environment',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.03 : sw * 0.05,
                color: PillBinColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sh * 0.025),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? sw * 0.04 : sw * 0.06,
                vertical: isTablet ? sh * 0.015 : sh * 0.02,
              ),
              decoration: BoxDecoration(
                color: PillBinColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: PillBinColors.primaryLight.withOpacity(0.3),
                ),
              ),
              child: Text(
                'Track • Remind • Dispose Safely',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                  color: PillBinColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(double sw, double sh, bool isTablet) {
    return FadeTransition(
      opacity: _buttonFadeAnimation,
      child: SlideTransition(
        position: _buttonSlideAnimation,
        child: Column(
          children: [
            // Sign Up Button
            Container(
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
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/phone-field-screen',
                      arguments: {
                        'transition': TransitionType.bottomToTop,
                        'login': false,
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
                        Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: isTablet ? sw * 0.025 : sw * 0.05,
                        ),
                        SizedBox(width: sw * 0.03),
                        Text(
                          'Get Started - Sign Up',
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
            ),
            SizedBox(height: sh * 0.02),
            // Sign In Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                border: Border.all(
                  color: PillBinColors.primary,
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/phone-field-screen',
                      arguments: {
                        'transition': TransitionType.bottomToTop,
                        'login': true,
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
                        Icon(
                          Icons.login,
                          color: PillBinColors.primary,
                          size: isTablet ? sw * 0.025 : sw * 0.05,
                        ),
                        SizedBox(width: sw * 0.03),
                        Text(
                          'Already a Member? Sign In',
                          style: PillBinMedium.style(
                            fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                            color: PillBinColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(double sw, double sh, bool isTablet) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
            decoration: BoxDecoration(
              color: PillBinColors.greyLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.eco,
                  size: isTablet ? sw * 0.025 : sw * 0.04,
                  color: PillBinColors.primary,
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Text(
                    'Join thousands of users making a difference in medicine management and environmental protection',
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sh * 0.02),
          Text(
            'Safe • Secure • Sustainable',
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.018 : sw * 0.028,
              color: PillBinColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToAuth(bool isLogin) {
    Navigator.pushNamed(
      context,
      '/phone-auth',
      arguments: {
        'isLogin': isLogin,
      },
    );
  }
}
