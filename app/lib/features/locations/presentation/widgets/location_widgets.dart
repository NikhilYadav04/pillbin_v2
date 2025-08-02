import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/home/presentation/widgets/home_action_button.dart';
import 'package:pillbin/features/locations/presentation/widgets/location_card.dart';

Widget buildLocationHeader(double sw, double sh, bool isTablet) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: PillBinColors.primary,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(isTablet ? 32 : 24),
        bottomRight: Radius.circular(isTablet ? 32 : 24),
      ),
    ),
    padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Disposal Locations',
                    style: PillBinBold.style(
                      fontSize: isTablet ? sw * 0.035 : sw * 0.06,
                      color: PillBinColors.textWhite,
                    ),
                  ),
                  SizedBox(height: sh * 0.005),
                  Text(
                    'Find safe disposal points near you',
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                      color: PillBinColors.textWhite.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget buildCurrentLocationButton(double sw, double sh, bool isTablet) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: ActionButton(
      icon: Icons.my_location,
      text: 'Use Current Location',
      isPrimary: true,
      onTap: () {},
      sw: sw,
      sh: sh,
    ),
  );
}

Widget buildMapContainer(double sw, double sh, bool isTablet) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    height: isTablet ? sh * 0.5 : sh * 0.35,
    decoration: BoxDecoration(
      color: PillBinColors.greyLight,
      borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
      border: Border.all(color: PillBinColors.greyLight),
    ),
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PillBinColors.greyLight,
                PillBinColors.greyLight.withOpacity(0.8),
              ],
            ),
          ),
        ),
        // Map dots - adjusted for tablet
        Positioned(
          top: isTablet ? sh * 0.1 : sh * 0.08,
          left: isTablet ? sw * 0.12 : sw * 0.15,
          child: _buildMapDot(PillBinColors.primary, sw, isTablet),
        ),
        Positioned(
          top: isTablet ? sh * 0.18 : sh * 0.15,
          right: isTablet ? sw * 0.15 : sw * 0.2,
          child: _buildMapDot(PillBinColors.primary, sw, isTablet),
        ),
        Positioned(
          bottom: isTablet ? sh * 0.15 : sh * 0.12,
          left: isTablet ? sw * 0.2 : sw * 0.25,
          child: _buildMapDot(PillBinColors.primary, sw, isTablet),
        ),
        if (isTablet) ...[
          Positioned(
            top: sh * 0.25,
            left: sw * 0.08,
            child: _buildMapDot(PillBinColors.warning, sw, isTablet),
          ),
          Positioned(
            bottom: sh * 0.08,
            right: sw * 0.1,
            child: _buildMapDot(PillBinColors.success, sw, isTablet),
          ),
        ],
        // Center content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
                decoration: BoxDecoration(
                  color: PillBinColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.location_on,
                  color: PillBinColors.primary,
                  size: isTablet ? sw * 0.05 : sw * 0.1,
                ),
              ),
              SizedBox(height: sh * 0.02),
              Text(
                'Interactive Map',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                  color: PillBinColors.textPrimary,
                ),
              ),
              SizedBox(height: sh * 0.005),
              Text(
                'Tap locations for details',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.018 : sw * 0.035,
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

Widget _buildMapDot(Color color, double sw, bool isTablet) {
  return Container(
    width: isTablet ? sw * 0.025 : sw * 0.04,
    height: isTablet ? sw * 0.025 : sw * 0.04,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    ),
  );
}

Widget buildNearbyLocations(double sw, double sh, bool isTablet) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Locations',
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.03 : sw * 0.05,
            color: PillBinColors.textPrimary,
          ),
        ),
        SizedBox(height: sh * 0.02),
        LocationCard(
          name: 'Apollo Pharmacy',
          distance: '0.5 km',
          address: 'Shop No. 12, Linking Road, Bandra West, Mumbai',
          phone: '+91 22 2650 7890',
          isFavorite: false,
          sw: sw,
          sh: sh,
        ),
        SizedBox(height: sh * 0.015),
        LocationCard(
          name: 'Lilavati Hospital',
          distance: '1.2 km',
          address: 'A-791, Bandra Reclamation, Bandra West, Mumbai',
          phone: '+91 22 2675 1000',
          isFavorite: true,
          sw: sw,
          sh: sh,
        ),
        SizedBox(height: sh * 0.015),
        LocationCard(
          name: 'Hinduja Hospital',
          distance: '2.1 km',
          address: 'Veer Savarkar Marg, Mahim, Mumbai',
          phone: '+91 22 2445 2222',
          isFavorite: false,
          sw: sw,
          sh: sh,
        ),
      ],
    ),
  );
}

Widget buildImportantNote(double sw, double sh, bool isTablet) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
    decoration: BoxDecoration(
      color: PillBinColors.info.withOpacity(0.1),
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      border: Border.all(color: PillBinColors.info.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: PillBinColors.info,
              size: isTablet ? sw * 0.025 : sw * 0.05,
            ),
            SizedBox(width: sw * 0.02),
            Text(
              'Important Note',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.04,
                color: PillBinColors.info,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.01),
        Text(
          'Always call ahead to confirm disposal programs are available. Some locations may have specific hours for medicine collection.',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.018 : sw * 0.035,
            color: PillBinColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
