import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

Widget buildHealthAIHeader(BuildContext context, double sw, double sh) {
  final bool isTablet = sw > 600;

  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: PillBinColors.primary,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(isTablet ? 32 : 24),
        bottomRight: Radius.circular(isTablet ? 32 : 24),
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? sw * 0.04 : sw * 0.05,
          vertical: sh * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Health Report Analysis',
                    style: PillBinBold.style(
                      fontSize: isTablet ? sw * 0.04 : sw * 0.065,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.025),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? sw * 0.02 : sw * 0.025,
                    vertical: sh * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'EXPERIMENTAL',
                    style: PillBinBold.style(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.026,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.008),
            // Subtitle
            Text(
              'AI-powered analysis of your health reports',
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.036,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: sh * 0.01),
          ],
        ),
      ),
    ),
  );
}
