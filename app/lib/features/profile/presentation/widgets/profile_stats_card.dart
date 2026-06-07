import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class ProfileStatCard extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final double sw;
  final double sh;

  const ProfileStatCard({
    Key? key,
    required this.count,
    required this.label,
    required this.color,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: PillBinBold.style(
              fontSize: isTablet ? sw * 0.04 : sw * 0.06,
              color: color,
            ),
          ),
          SizedBox(height: sh * 0.005),
          Text(
            label,
            textAlign: TextAlign.center,
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.018 : sw * 0.03,
              color: PillBinColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
