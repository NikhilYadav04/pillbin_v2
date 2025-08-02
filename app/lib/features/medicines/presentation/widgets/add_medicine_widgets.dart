import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

Widget buildAddMedsTitle(double sw, double sh, bool isTablet,BuildContext context) {
  return Column(
    crossAxisAlignment: isTablet ? CrossAxisAlignment.center : CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: isTablet ? MainAxisAlignment.center : MainAxisAlignment.start,
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
            'Add New Medicine',
            style: PillBinBold.style(
              fontSize: isTablet ? sw * 0.04 : sw * 0.07,
              color: PillBinColors.textPrimary,
            ),
          ),
        ],
      ),
      SizedBox(height: sh * 0.01),
      Text(
        'Track your medicines for safe disposal',
        style: PillBinRegular.style(
          fontSize: isTablet ? sw * 0.025 : sw * 0.04,
          color: PillBinColors.textSecondary,
        ),
      ),
    ],
  );
}

Widget buildQuickTips(double sw, double sh, bool isTablet) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
    decoration: BoxDecoration(
      color: PillBinColors.info.withOpacity(0.1),
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      border: Border.all(color: PillBinColors.info.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Tips',
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.info,
          ),
        ),
        SizedBox(height: sh * 0.01),
        _buildTipItem(
            'Check expiry date carefully before entering', sw, sh, isTablet),
        _buildTipItem('Include quantity for better tracking', sw, sh, isTablet),
        _buildTipItem(
            'Add notes for special storage instructions', sw, sh, isTablet),
        _buildTipItem(
            'You\'ll get notifications before expiry', sw, sh, isTablet),
      ],
    ),
  );
}

Widget _buildTipItem(String text, double sw, double sh, bool isTablet) {
  return Padding(
    padding: EdgeInsets.only(bottom: sh * 0.005),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isTablet ? sw * 0.008 : sw * 0.015,
          height: isTablet ? sw * 0.008 : sw * 0.015,
          margin: EdgeInsets.only(top: sh * 0.008, right: sw * 0.02),
          decoration: BoxDecoration(
            color: PillBinColors.info,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.035,
              color: PillBinColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildAddMedicinesActionButtons(double sw, double sh, bool isTablet) {
  return Column(
    children: [
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: PillBinColors.primary,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: PillBinColors.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? sh * 0.02 : sh * 0.015,
                horizontal: isTablet ? sw * 0.03 : sw * 0.05,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    color: PillBinColors.textWhite,
                    size: isTablet ? sw * 0.025 : sw * 0.05,
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'Add Medicine',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                      color: PillBinColors.textWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: sh * 0.015),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          border: Border.all(color: PillBinColors.textSecondary),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? sh * 0.02 : sh * 0.015,
                horizontal: isTablet ? sw * 0.03 : sw * 0.05,
              ),
              child: Text(
                'Cancel',
                textAlign: TextAlign.center,
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget buildScanOption(
    double sw, double sh, bool isTablet, void Function() onTap) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
    decoration: BoxDecoration(
      color: PillBinColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      border: Border.all(color: PillBinColors.primary.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: PillBinColors.primary,
              size: isTablet ? sw * 0.03 : sw * 0.06,
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Medicine',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                      color: PillBinColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Auto-fill information by scanning',
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.015),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: PillBinColors.primary,
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? sh * 0.015 : sh * 0.012,
                  horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      color: PillBinColors.textWhite,
                      size: isTablet ? sw * 0.025 : sw * 0.04,
                    ),
                    SizedBox(width: sw * 0.02),
                    Text(
                      'Scan Medicine',
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                        color: PillBinColors.textWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: sh * 0.01),
        Text(
          'OR',
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.02 : sw * 0.035,
            color: PillBinColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
