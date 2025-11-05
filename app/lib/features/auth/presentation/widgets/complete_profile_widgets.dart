import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

Widget buildCompleteProfileHeader(
    double sw, double sh, bool isTablet, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: sh * 0.02),
      Row(
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
            'Complete Your Profile',
            style: PillBinBold.style(
              fontSize: isTablet ? sw * 0.045 : sw * 0.06,
              color: PillBinColors.primary,
            ),
          ),
        ],
      ),
      SizedBox(height: sh * 0.01),
      Text(
        'Help us personalize your medicine tracking experience',
        style: PillBinRegular.style(
          fontSize: isTablet ? sw * 0.025 : sw * 0.036,
          color: PillBinColors.textSecondary,
        ),
      ),
    ],
  );
}

Widget buildWelcomeCompleteProfileCard(double sw, double sh, bool isTablet) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          PillBinColors.primary.withOpacity(0.1),
          PillBinColors.primaryLight.withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      border: Border.all(
        color: PillBinColors.primary.withOpacity(0.2),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
          decoration: BoxDecoration(
            color: PillBinColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.person_add,
            size: isTablet ? sw * 0.03 : sw * 0.05,
            color: PillBinColors.primary,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Your Profile',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                  color: PillBinColors.primary,
                ),
              ),
              Text(
                'Fill in your details to get started',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildCompleteProfileQuickTips(double sw, double sh, bool isTablet) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
    decoration: BoxDecoration(
      color: PillBinColors.primaryLight.withOpacity(0.1),
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      border: Border.all(
        color: PillBinColors.primaryLight.withOpacity(0.3),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: isTablet ? sw * 0.025 : sw * 0.04,
              color: PillBinColors.primary,
            ),
            SizedBox(width: sw * 0.02),
            Text(
              'Quick Tips',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.015),
        _buildTipItem('Provide accurate information for better recommendations',
            sw, isTablet),
        _buildTipItem('Email helps with account recovery and notifications', sw,
            isTablet),
        _buildTipItem(
            'Medicine list helps track potential interactions', sw, isTablet),
        _buildTipItem(
            'Location helps find nearby disposal centers', sw, isTablet),
      ],
    ),
  );
}

Widget _buildTipItem(String text, double sw, bool isTablet) {
  return Padding(
    padding: EdgeInsets.only(bottom: sw * 0.01),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isTablet ? sw * 0.008 : sw * 0.012,
          height: isTablet ? sw * 0.008 : sw * 0.012,
          margin: EdgeInsets.only(top: sw * 0.015),
          decoration: BoxDecoration(
            color: PillBinColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: sw * 0.02),
        Expanded(
          child: Text(
            text,
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildCompleteProfileSubmitButton(double sw, double sh, bool isTablet,
    bool _isLoading, BuildContext context, void Function() onTap) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          PillBinColors.primary,
          PillBinColors.primaryLight,
        ],
      ),
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      boxShadow: [
        BoxShadow(
          color: PillBinColors.primary.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        onTap: _isLoading ? null : onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? sh * 0.025 : sh * 0.02,
            horizontal: isTablet ? sw * 0.03 : sw * 0.05,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                SizedBox(
                  width: isTablet ? sw * 0.025 : sw * 0.04,
                  height: isTablet ? sw * 0.025 : sw * 0.04,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: isTablet ? sw * 0.025 : sw * 0.05,
                ),
              SizedBox(width: sw * 0.03),
              Text(
                _isLoading ? 'Creating Profile...' : 'Complete Registration',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildCompleteProfileCancelButton(
    double sw, double sh, bool isTablet, BuildContext context) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      border: Border.all(color: PillBinColors.greyLight),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        onTap: () => {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/bottom-bar-screen',
            (Route<dynamic> route) => false,
            arguments: {
              'transition': TransitionType.bottomToTop,
              'duration': 300,
            },
          )
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? sh * 0.02 : sh * 0.015,
            horizontal: isTablet ? sw * 0.03 : sw * 0.05,
          ),
          child: Text(
            'Skip for Now',
            textAlign: TextAlign.center,
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.025 : sw * 0.04,
              color: PillBinColors.textSecondary,
            ),
          ),
        ),
      ),
    ),
  );
}
