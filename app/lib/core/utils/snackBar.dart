import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    bool isTablet = sw > 600;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: isTablet ? 24 : 20,
            ),
            SizedBox(width: sw * 0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: PillBinColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 15 : 12),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.02,
        ),
        duration: duration,
      ),
    );
  }
}
