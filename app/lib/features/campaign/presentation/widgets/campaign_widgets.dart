import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

Widget buildCampaignHeader(double sw, double sh, bool isTablet,BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(isTablet ? sw * 0.01 : sw * 0.06),
    child: Column(
      crossAxisAlignment:
          isTablet ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isTablet ? MainAxisAlignment.center :MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(
                Icons.arrow_back_ios,
                size: isTablet ? sw * 0.03 : sw * 0.06,
                color: PillBinColors.textPrimary,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'My Campaigns',
              style: PillBinBold.style(
                fontSize: isTablet ? sw * 0.04 : sw * 0.07,
                color: PillBinColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.01),
        Text(
          'Join disposal events and community initiatives',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
