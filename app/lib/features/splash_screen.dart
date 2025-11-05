import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/network/utils/http_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _backgroundAnimation;

  //* http client
  final HttpClient _httpClient = HttpClient();

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Text animations
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Background gradient animation
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    // Start background animation immediately
    _backgroundController.forward();

    // Start logo animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Navigate to landing page after all animations
    bool isAuth = await _httpClient.isAuthenticated();

    await Future.delayed(const Duration(milliseconds: 3000));

    if (isAuth) {
      Navigator.pushReplacementNamed(
        context,
        '/bottom-bar-screen',
        arguments: {
          'transition': TransitionType.bottomToTop,
          'duration': 300,
        },
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/landing-screen',
        arguments: {
          'transition': TransitionType.bottomToTop,
          'duration': 300,
        },
      );
    }
  }

  void _navigateToLanding() {
    Navigator.of(context).pushReplacementNamed('/landing');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                      PillBinColors.background,
                      PillBinColors.primaryLight.withOpacity(0.1),
                      _backgroundAnimation.value)!,
                  Color.lerp(
                      PillBinColors.background,
                      PillBinColors.primary.withOpacity(0.05),
                      _backgroundAnimation.value)!,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _logoOpacityAnimation,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Container(
                            width: isTablet ? sw * 0.25 : sw * 0.35,
                            height: isTablet ? sw * 0.25 : sw * 0.35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  isTablet ? sw * 0.06 : sw * 0.08),
                              boxShadow: [
                                BoxShadow(
                                  color: PillBinColors.primary.withOpacity(
                                      0.3 * _logoOpacityAnimation.value),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                      0.1 * _logoOpacityAnimation.value),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Logo image
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        isTablet ? sw * 0.06 : sw * 0.08),
                                    child: Image.asset(
                                      'assets/images/logo.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // Shimmer effect
                                Positioned.fill(
                                  child: AnimatedBuilder(
                                    animation: _logoController,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              isTablet ? sw * 0.06 : sw * 0.08),
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
                                              Colors.white.withOpacity(0.4),
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
                  ),

                  SizedBox(height: sh * 0.04),

                  // Animated App Name
                  FadeTransition(
                    opacity: _textOpacityAnimation,
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'PillBin',
                            style: PillBinBold.style(
                              fontSize: isTablet ? sw * 0.06 : sw * 0.1,
                              color: PillBinColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: sh * 0.01),
                          Text(
                            'Dispose Them Properly',
                            style: PillBinMedium.style(
                              fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                              color: PillBinColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: sh * 0.08),

                  // Loading indicator
                  FadeTransition(
                    opacity: _textOpacityAnimation,
                    child: SizedBox(
                      width: isTablet ? sw * 0.08 : sw * 0.12,
                      height: isTablet ? sw * 0.08 : sw * 0.12,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          PillBinColors.primary.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
