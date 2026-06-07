import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

Widget buildOTPHeader(double sw, double sh, bool isTablet,BuildContext context) {
  return Row(
    children: [
      GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child:  Icon(
            Icons.arrow_back_ios,
            size: isTablet ? sw * 0.03 : sw * 0.07,
            color: PillBinColors.textPrimary,
          ),
      ),
      SizedBox(width: 5,),
      Text(
        'Verify Phone',
        style: PillBinBold.style(
          fontSize: isTablet ? sw * 0.035 : sw * 0.055,
          color: PillBinColors.textPrimary,
        ),
      ),
    ],
  );
}

Widget buildOTPLogo(double sw, double sh, bool isTablet) {
  return Center(
    child: Container(
      width: isTablet ? sw * 0.2 : sw * 0.28,
      height: isTablet ? sw * 0.2 : sw * 0.28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PillBinColors.primary,
            PillBinColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.05 : sw * 0.07),
        boxShadow: [
          BoxShadow(
            color: PillBinColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sms_outlined,
            size: isTablet ? sw * 0.06 : sw * 0.1,
            color: Colors.white,
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'OTP',
            style: PillBinBold.style(
              fontSize: isTablet ? sw * 0.025 : sw * 0.04,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildOTPInstructions(double sw, double sh,String email, bool isTablet) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: sh * 0.01),
      RichText(
        text: TextSpan(
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textSecondary,
          ),
          children: [
            const TextSpan(
                text: 'We\'ve sent a 6-digit verification code to\n'),
            TextSpan(
              text: "${email}",
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.primary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
