import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final double sw;
  final double sh;
  final bool isTablet;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? sw * 0.06 : sw * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? sw * 0.035 : sw * 0.06),
              decoration: BoxDecoration(
                color: PillBinColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: isTablet ? sw * 0.08 : sw * 0.16,
                color: PillBinColors.primary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: sh * 0.03),
            Text(
              title,
              style: PillBinMedium.style(
                color: PillBinColors.textDark,
                fontSize: isTablet ? sw * 0.028 : sw * 0.05,
              ),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              message,
              textAlign: TextAlign.center,
              style: PillBinRegular.style(
                color: PillBinColors.textSecondary,
                fontSize: isTablet ? sw * 0.02 : sw * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
