import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class AchievementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isCompleted;
  final double sw;
  final double sh;

  const AchievementCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: PillBinColors.success.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        child: Container(
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            border: Border.all(
              color: isCompleted
                  ? PillBinColors.success.withOpacity(0.3)
                  : PillBinColors.grey.withOpacity(0.2),
              width: isCompleted ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Decorative background pattern for completed achievements
              if (isCompleted)
                Positioned.fill(
                  child: CustomPaint(
                    painter: AchievementDecorationPainter(),
                  ),
                ),
              // Status accent border
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? PillBinColors.success
                        : PillBinColors.grey,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              // Top decorative element for completed achievements
              if (isCompleted)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: isTablet ? sw * 0.15 : sw * 0.2,
                    height: isTablet ? sh * 0.06 : sh * 0.04,
                    decoration: BoxDecoration(
                      // gradient: LinearGradient(
                      //   begin: Alignment.topRight,
                      //   end: Alignment.bottomLeft,
                      //   colors: [
                      //     PillBinColors.success.withOpacity(0.1),
                      //     PillBinColors.success.withOpacity(0.1),
                      //   ],
                      // ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(30),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: isTablet ? sw * 0.01 : sw * 0.02,
                          right: isTablet ? sw * 0.01 : sw * 0.02,
                          child: Icon(
                            Icons.stars,
                            color: PillBinColors.success.withOpacity(0.8),
                            size: isTablet ? sw * 0.02 : sw * 0.03,
                          ),
                        ),
                        Positioned(
                          top: isTablet ? sw * 0.02 : sw * 0.035,
                          right: isTablet ? sw * 0.025 : sw * 0.04,
                          child: Icon(
                            Icons.auto_awesome,
                            color: PillBinColors.success.withOpacity(0.2),
                            size: isTablet ? sw * 0.015 : sw * 0.02,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Main content
              Padding(
                padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.045),
                child: Row(
                  children: [
                    SizedBox(width: sw * 0.02),
                    // Icon container with decorative elements
                    Container(
                      padding:
                          EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.035),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? PillBinColors.success.withOpacity(0.15)
                            : PillBinColors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                        border: Border.all(
                          color: isCompleted
                              ? PillBinColors.success.withOpacity(0.3)
                              : PillBinColors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: PillBinColors.success.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            icon,
                            color: isCompleted
                                ? PillBinColors.success
                                : PillBinColors.grey,
                            size: isTablet ? sw * 0.03 : sw * 0.05,
                          ),
                          // Decorative sparkle for completed achievements
                          if (isCompleted)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: isTablet ? sw * 0.012 : sw * 0.02,
                                height: isTablet ? sw * 0.012 : sw * 0.02,
                                decoration: BoxDecoration(
                                  color: PillBinColors.success,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: PillBinColors.success
                                          .withOpacity(0.6),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: sw * 0.04),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: PillBinMedium.style(
                                    fontSize:
                                        isTablet ? sw * 0.025 : sw * 0.042,
                                    color: isCompleted
                                        ? PillBinColors.textPrimary
                                        : PillBinColors.textSecondary,
                                  ),
                                ),
                              ),
                              // Completion badge
                              if (isCompleted)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        isTablet ? sw * 0.015 : sw * 0.02,
                                    vertical:
                                        isTablet ? sh * 0.003 : sh * 0.005,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PillBinColors.success,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: PillBinColors.success
                                            .withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: isTablet ? sw * 0.012 : sw * 0.02,
                                      ),
                                      SizedBox(width: sw * 0.005),
                                      Text(
                                        'EARNED',
                                        style: PillBinMedium.style(
                                          fontSize: isTablet
                                              ? sw * 0.012
                                              : sw * 0.018,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: sh * 0.008),
                          Text(
                            description,
                            style: PillBinRegular.style(
                              fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                              color: isCompleted
                                  ? PillBinColors.textSecondary
                                  : PillBinColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    // Status indicator with decoration
                    Container(
                      padding:
                          EdgeInsets.all(isTablet ? sw * 0.012 : sw * 0.018),
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  PillBinColors.success,
                                  PillBinColors.success.withOpacity(0.8),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  PillBinColors.grey.withOpacity(0.3),
                                  PillBinColors.grey.withOpacity(0.2),
                                ],
                              ),
                        shape: BoxShape.circle,
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: PillBinColors.success.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        isCompleted ? Icons.emoji_events : Icons.lock,
                        color: isCompleted ? Colors.white : PillBinColors.grey,
                        size: isTablet ? sw * 0.022 : sw * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AchievementDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PillBinColors.success.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw decorative dots pattern
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 6; j++) {
        final x = (size.width / 8) * i + (size.width / 16);
        final y = (size.height / 6) * j + (size.height / 12);

        if ((i + j) % 3 == 0) {
          canvas.drawCircle(
            Offset(x, y),
            1.5,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
