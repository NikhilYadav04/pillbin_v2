import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'dart:math' as math;

enum AchievementType {
  firstTimer,
  ecoHelper,
  greenChampion,
}

class UnlockedAchievementCard extends StatefulWidget {
  final AchievementType type;
  final String title;
  final String description;
  final IconData icon;

  final VoidCallback? onDismiss;

  const UnlockedAchievementCard({
    Key? key,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<UnlockedAchievementCard> createState() =>
      _UnlockedAchievementCardState();
}

class _UnlockedAchievementCardState extends State<UnlockedAchievementCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late AnimationController _shimmerController;
  late AnimationController _bounceController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _confettiAnimation = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.linear,
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );

    _scaleController.forward();
    _confettiController.forward();
    _bounceController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    _shimmerController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case AchievementType.firstTimer:
        return const Color(0xFF6FCBC6); // Soft turquoise for first timer
      case AchievementType.ecoHelper:
        return const Color(0xFF95E1D3); // Light green for eco helper
      case AchievementType.greenChampion:
        return const Color(0xFF4CAF50); // Green for champion
    }
  }

  Color _getTypeSecondaryColor() {
    switch (widget.type) {
      case AchievementType.firstTimer:
        return const Color(0xFF9FE2DD); // Lighter turquoise
      case AchievementType.ecoHelper:
        return const Color(0xFF66D9A6);
      case AchievementType.greenChampion:
        return const Color(0xFF81C784);
    }
  }

  String _getTypeLabel() {
    switch (widget.type) {
      case AchievementType.firstTimer:
        return 'FIRST TIMER';
      case AchievementType.ecoHelper:
        return 'ECO HELPER';
      case AchievementType.greenChampion:
        return 'GREEN CHAMPION';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;
    final primaryColor = _getTypeColor();
    final secondaryColor = _getTypeSecondaryColor();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: sw,
        height: sh,
        color: Colors.black.withOpacity(0.6),
        child: Stack(
          children: [
            // Confetti particles
            AnimatedBuilder(
              animation: _confettiAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(
                    animation: _confettiAnimation.value,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                  ),
                  size: Size(sw, sh),
                );
              },
            ),
            // Main card
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: isTablet ? sw * 0.5 : sw * 0.85,
                  margin: EdgeInsets.symmetric(horizontal: sw * 0.05),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Card content
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(isTablet ? 28 : 24),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 8,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(isTablet ? 28 : 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: PillBinColors.surface,
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Shimmer effect
                                AnimatedBuilder(
                                  animation: _shimmerAnimation,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: ShimmerPainter(
                                        animation: _shimmerAnimation.value,
                                        primaryColor: primaryColor,
                                      ),
                                      size: Size(
                                        isTablet
                                            ? sw * 0.5
                                            : sw * 0.85,
                                        sh * 0.4,
                                      ),
                                    );
                                  },
                                ),
                                // Gradient header
                                Container(
                                  height: isTablet
                                      ? sh * 0.15
                                      : sh * 0.12,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        primaryColor,
                                        secondaryColor,
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Decorative pattern
                                      CustomPaint(
                                        painter: HeaderPatternPainter(
                                          color: Colors.white.withOpacity(0.1),
                                        ),
                                        size: Size(
                                          isTablet
                                              ? sw * 0.5
                                              : sw * 0.85,
                                          isTablet
                                              ? sh * 0.15
                                              : sh * 0.12,
                                        ),
                                      ),
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.celebration,
                                              color: Colors.white,
                                              size: isTablet
                                                  ? sw * 0.035
                                                  : sw * 0.06,
                                            ),
                                            SizedBox(height: sh * 0.01),
                                            Text(
                                              'ACHIEVEMENT UNLOCKED!',
                                              style: PillBinMedium.style(
                                                fontSize: isTablet
                                                    ? sw * 0.018
                                                    : sw * 0.035,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Main content
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: isTablet
                                        ? sh * 0.15
                                        : sh * 0.12,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: sh * 0.03),
                                      // Animated icon container
                                      AnimatedBuilder(
                                        animation: _bounceAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: 1.0 +
                                                (_bounceAnimation.value * 0.1),
                                            child: Container(
                                              padding: EdgeInsets.all(
                                                isTablet
                                                    ? sw * 0.035
                                                    : sw * 0.05,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    primaryColor
                                                        .withOpacity(0.2),
                                                    secondaryColor
                                                        .withOpacity(0.2),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        isTablet ? 24 : 20),
                                                border: Border.all(
                                                  color: primaryColor
                                                      .withOpacity(0.4),
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: primaryColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 20,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                widget.icon,
                                                color: primaryColor,
                                                size: isTablet
                                                    ? sw * 0.06
                                                    : sw * 0.12,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(height: sh * 0.025),
                                      // Type badge
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isTablet
                                              ? sw * 0.025
                                              : sw * 0.04,
                                          vertical: isTablet
                                              ? sh * 0.008
                                              : sh * 0.01,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              primaryColor,
                                              secondaryColor
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  primaryColor.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.military_tech,
                                              color: Colors.white,
                                              size: isTablet
                                                  ? sw * 0.018
                                                  : sw * 0.028,
                                            ),
                                            SizedBox(width: sw * 0.01),
                                            Text(
                                              _getTypeLabel(),
                                              style: PillBinMedium.style(
                                                fontSize: isTablet
                                                    ? sw * 0.015
                                                    : sw * 0.025,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: sh * 0.02),
                                      // Title
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isTablet
                                              ? sw * 0.04
                                              : sw * 0.06,
                                        ),
                                        child: Text(
                                          widget.title,
                                          textAlign: TextAlign.center,
                                          style: PillBinMedium.style(
                                            fontSize: isTablet
                                                ? sw * 0.028
                                                : sw * 0.05,
                                            color: PillBinColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: sh * 0.012),
                                      // Description
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isTablet
                                              ? sw * 0.04
                                              : sw * 0.06,
                                        ),
                                        child: Text(
                                          widget.description,
                                          textAlign: TextAlign.center,
                                          style: PillBinRegular.style(
                                            fontSize: isTablet
                                                ? sw * 0.02
                                                : sw * 0.036,
                                            color: PillBinColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: sh * 0.04),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: sh * 0.03),
                      // Close button
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isTablet ? sw * 0.04 : sw * 0.08,
                            vertical: isTablet
                                ? sh * 0.015
                                : sh * 0.018,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, secondaryColor],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            'AWESOME!',
                            style: PillBinMedium.style(
                              fontSize: isTablet
                                  ? sw * 0.02
                                  : sw * 0.038,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Confetti painter for animated particles
class ConfettiPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color secondaryColor;

  ConfettiPainter({
    required this.animation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final particles = 60;

    for (int i = 0; i < particles; i++) {
      final progress = animation;
      final randomX = random.nextDouble();
      final randomY = random.nextDouble();
      final randomRotation = random.nextDouble() * math.pi * 4;
      final randomSize = 3 + random.nextDouble() * 6;
      final isCircle = random.nextBool();
      final colorChoice = random.nextInt(5);

      Color particleColor;
      switch (colorChoice) {
        case 0:
          particleColor = primaryColor;
          break;
        case 1:
          particleColor = secondaryColor;
          break;
        case 2:
          particleColor = PillBinColors.success;
          break;
        case 3:
          particleColor = const Color(0xFFFFD93D);
          break;
        default:
          particleColor = const Color(0xFFFF6B6B);
      }

      final x = size.width * randomX;
      final startY = size.height * 0.3 + (randomY * size.height * 0.1);
      final endY = size.height * 1.2;
      final y = startY + (endY - startY) * progress;

      final opacity = 1.0 - progress;
      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = particleColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(randomRotation * progress);

      if (isCircle) {
        canvas.drawCircle(Offset.zero, randomSize, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: randomSize * 1.5,
            height: randomSize * 1.5,
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

// Shimmer effect painter
class ShimmerPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;

  ShimmerPainter({
    required this.animation,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          primaryColor.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: [
          animation - 0.3,
          animation,
          animation + 0.3,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(ShimmerPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

// Header pattern painter
class HeaderPatternPainter extends CustomPainter {
  final Color color;

  HeaderPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw star pattern
    for (int i = 0; i < 15; i++) {
      final random = math.Random(i);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final starSize = 2 + random.nextDouble() * 3;

      _drawStar(canvas, Offset(x, y), starSize, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
