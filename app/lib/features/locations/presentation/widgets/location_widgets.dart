import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/home/presentation/widgets/home_action_button.dart';
import 'package:pillbin/features/locations/data/repository/medical_center_provider.dart';
import 'package:pillbin/features/locations/presentation/widgets/location_card.dart';
import 'package:provider/provider.dart';

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

Widget buildCurrentLocationButton(
    double sw, double sh, bool isTablet, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: ActionButton(
      icon: Icons.my_location,
      text: 'Use Current Location',
      isPrimary: true,
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            final double sw = MediaQuery.of(context).size.width;
            final bool isTablet = sw > 600;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: PillBinColors.primary,
                    size: isTablet ? sw * 0.03 : sw * 0.05,
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'Select Location',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                      color: PillBinColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Would you like to use your current location or fetch a different one?',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                  color: PillBinColors.textSecondary,
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          final provider =
                              context.read<MedicalCenterProvider>();
                          provider.setLocation(false, context);

                          Navigator.pop(context, "current");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PillBinColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? sw * 0.03 : sw * 0.04,
                            vertical: isTablet ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: FittedBox(
                          child: Text(
                            'Current Location',
                            style: PillBinMedium.style(
                              fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: sw * 0.02,
                    ),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          final provider =
                              context.read<MedicalCenterProvider>();
                          provider.setLocation(true, context);

                          Navigator.pop(context, "fetch");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PillBinColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? sw * 0.03 : sw * 0.04,
                            vertical: isTablet ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: FittedBox(
                          child: Text(
                            'Fetch Location',
                            style: PillBinMedium.style(
                              fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
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

Widget buildNearbyLocations(
    double sw, double sh, bool isTablet, MedicalCenterProvider provider) {
  if (provider.fetchedCenters.isEmpty) {
    //* show empty state first
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size:  isTablet ? sw * 0.1 : sw * 0.15,
            color: PillBinColors.greyLight,
          ),
          SizedBox(height: sh * 0.02),
          Text(
            'No centers found',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.03 : sw * 0.04,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'Try adjusting your distance',
            style: PillBinRegular.style(
              fontSize:  isTablet ? sw * 0.025 : sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  //* otherwise render list
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            
            Logger().d(provider.hasMoreFetch);
            Logger().d(provider.fetchedCenters);
          },
          child: Text(
            'Nearby Locations',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.03 : sw * 0.05,
              color: PillBinColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: sh * 0.02),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              provider.fetchedCenters.length + (provider.hasMoreFetch ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == provider.fetchedCenters.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final center = provider.fetchedCenters[index];

            return LocationCard(
              sh: sh,
              sw: sw,
              medicalCenter: center,
              isSaved: false,
            );
          },
        ),
      ],
    ),
  );
}

Widget buildLocationInfo(
  double sw,
  double sh,
  bool isTablet,
  double? latitude,
  double? longitude,
  String? placeName,
) {
  //* Only show if latitude and longitude are not null
  if (latitude == null ||
      longitude == null ||
      latitude == 0.0 ||
      longitude == 0.0) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: sw * (isTablet ? 0.05 : 0.04),
      vertical: sh * 0.01,
    ),
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.04,
        vertical: sh * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with location icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 8 : 6),
                decoration: BoxDecoration(
                  color: PillBinColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  size: isTablet ? 20 : 18,
                  color: PillBinColors.primary,
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.012),

          //* Divider
          Divider(
            color: Colors.grey[200],
            thickness: 1,
            height: 1,
          ),

          SizedBox(height: sh * 0.012),

          //* Place name (if available)
          if (placeName != null && placeName.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.place,
                  size: isTablet ? 18 : 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: sw * 0.02),
                Expanded(
                  child: Text(
                    placeName,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.01),
          ],

          // * Coordinates container
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.03,
              vertical: sh * 0.012,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Latitude
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.02,
                        vertical: sh * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: PillBinColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LAT',
                        style: TextStyle(
                          fontSize: isTablet ? 11 : 10,
                          fontWeight: FontWeight.bold,
                          color: PillBinColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Text(
                        latitude.toStringAsFixed(6),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          fontFamily: 'monospace',
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sh * 0.008),

                // Longitude
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.02,
                        vertical: sh * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: PillBinColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LNG',
                        style: TextStyle(
                          fontSize: isTablet ? 11 : 10,
                          fontWeight: FontWeight.bold,
                          color: PillBinColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Text(
                        longitude.toStringAsFixed(6),
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          fontFamily: 'monospace',
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
