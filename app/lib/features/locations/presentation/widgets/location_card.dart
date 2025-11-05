// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/locations/data/repository/medical_center_provider.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/network/models/medical_center_model.dart';
import 'package:pillbin/network/models/user_model.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class LocationCard extends StatefulWidget {
  final double sw;
  final double sh;
  final MedicalCenter medicalCenter;
  bool isSaved;

  LocationCard({
    Key? key,
    required this.sw,
    required this.sh,
    required this.medicalCenter,
    required this.isSaved,
  }) : super(key: key);

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  late bool isSaved = false;

  @override
  void initState() {
    super.initState();
    isSaved = widget.isSaved;
  }

  //* Get the current day name
  String _getCurrentDay() {
    final days = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday'
    ];
    return days[DateTime.now().weekday % 7];
  }

  //* Check if currently open
  bool _isCurrentlyOpen() {
    if (widget.medicalCenter.operatingHours == null) return false;

    final currentDay = _getCurrentDay();
    final hours = widget.medicalCenter.operatingHours![currentDay];

    if (hours == null) return false;

    final now = TimeOfDay.now();
    final openTime = _parseTime(hours.open);
    final closeTime = _parseTime(hours.close);

    if (openTime == null || closeTime == null) return false;

    final nowMinutes = now.hour * 60 + now.minute;
    final openMinutes = openTime.hour * 60 + openTime.minute;
    final closeMinutes = closeTime.hour * 60 + closeTime.minute;

    return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
  }

  //* Parse time string (e.g., "09:00" or "9:00 AM")
  TimeOfDay? _parseTime(String timeStr) {
    try {
      if (timeStr.contains(':') &&
          !timeStr.toUpperCase().contains('AM') &&
          !timeStr.toUpperCase().contains('PM')) {
        final parts = timeStr.split(':');
        return TimeOfDay(
            hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }

      //* Handle 12-hour format (e.g., "9:00 AM")
      final timeUpper = timeStr.toUpperCase();
      final isAM = timeUpper.contains('AM');
      final isPM = timeUpper.contains('PM');

      if (isAM || isPM) {
        final cleanTime = timeStr.replaceAll(RegExp(r'[APMapm\s]'), '');
        final parts = cleanTime.split(':');
        int hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        if (isPM && hour != 12) hour += 12;
        if (isAM && hour == 12) hour = 0;

        return TimeOfDay(hour: hour, minute: minute);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  //* Format time for display
  String _formatTime(String timeStr) {
    final time = _parseTime(timeStr);
    if (time == null) return timeStr;

    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute $period';
  }

  //* Get today's hours
  String _getTodayHours() {
    if (widget.medicalCenter.operatingHours == null)
      return 'Hours not available';

    final currentDay = _getCurrentDay();
    final hours = widget.medicalCenter.operatingHours![currentDay];

    if (hours == null) return 'Closed today';

    return '${_formatTime(hours.open)} - ${_formatTime(hours.close)}';
  }

  double _getDistance(double lat, double long) {
    UserProvider provider = context.read<UserProvider>();
    UserModel user = provider.user!;

    double lat1 = user.location!.coordinates!.latitude!;
    double long1 = user.location!.coordinates!.longitude!;

    //* Distance in meters
    double distanceInMeters = Geolocator.distanceBetween(
      lat1,
      long1,
      lat,
      long,
    );

    return distanceInMeters / 1000;
  }

  //* Get icon based on facility type
  IconData _getFacilityIcon() {
    switch (widget.medicalCenter.facilityType) {
      case FacilityType.hospital:
        return Icons.local_hospital;
      case FacilityType.clinic:
        return Icons.medical_services;
      case FacilityType.pharmacy:
        return Icons.local_pharmacy;
      case FacilityType.healthCenter:
        return Icons.health_and_safety;
      default:
        return Icons.local_hospital;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.sw > 600;

    return Container(
      margin: EdgeInsets.only(bottom: widget.sh * 0.015),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(
          color: PillBinColors.greyLight.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/location-card-display',
              arguments: {
                'transition': TransitionType.fade,
                'center': widget.medicalCenter,
                'duration': 300,
                'sw': widget.sw,
                'sh': widget.sh
              },
            );
          },
          child: Padding(
            padding:
                EdgeInsets.all(isTablet ? widget.sw * 0.025 : widget.sw * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isTablet),
                SizedBox(height: widget.sh * 0.012),
                _buildLocationInfo(isTablet),
                if (widget.medicalCenter.operatingHours != null) ...[
                  SizedBox(height: widget.sh * 0.008),
                  _buildHoursInfo(isTablet),
                ],
                SizedBox(height: widget.sh * 0.018),
                _buildActionButtons(isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Row(
      children: [
        Container(
          padding:
              EdgeInsets.all(isTablet ? widget.sw * 0.015 : widget.sw * 0.025),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PillBinColors.primary.withOpacity(0.1),
                PillBinColors.primaryLight.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getFacilityIcon(),
            color: PillBinColors.primary,
            size: isTablet ? widget.sw * 0.025 : widget.sw * 0.04,
          ),
        ),
        SizedBox(width: widget.sw * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.medicalCenter.name,
                      style: PillBinBold.style(
                        fontSize:
                            isTablet ? widget.sw * 0.028 : widget.sw * 0.042,
                        color: PillBinColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.medicalCenter.rating > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.sw * 0.02,
                        vertical: widget.sh * 0.003,
                      ),
                      decoration: BoxDecoration(
                        color: PillBinColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: PillBinColors.warning,
                            size:
                                isTablet ? widget.sw * 0.018 : widget.sw * 0.03,
                          ),
                          SizedBox(width: widget.sw * 0.008),
                          Text(
                            widget.medicalCenter.rating.toStringAsFixed(1),
                            style: PillBinMedium.style(
                              fontSize: isTablet
                                  ? widget.sw * 0.018
                                  : widget.sw * 0.028,
                              color: PillBinColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: widget.sh * 0.005),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.sw * 0.025,
                      vertical: widget.sh * 0.004,
                    ),
                    decoration: BoxDecoration(
                      color: PillBinColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: PillBinColors.success.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: PillBinColors.success,
                          size: isTablet ? widget.sw * 0.018 : widget.sw * 0.03,
                        ),
                        SizedBox(width: widget.sw * 0.008),
                        Text(
                          '${_getDistance(widget.medicalCenter.coordinates.last, widget.medicalCenter.coordinates.first).toStringAsFixed(1)} km',
                          style: PillBinMedium.style(
                            fontSize:
                                isTablet ? widget.sw * 0.02 : widget.sw * 0.032,
                            color: PillBinColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (isSaved) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            final double sw = MediaQuery.of(context).size.width;
                            final bool isTablet = sw > 600;

                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(isTablet ? 16 : 12),
                              ),
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: PillBinColors.primary,
                                    size: isTablet ? sw * 0.03 : sw * 0.05,
                                  ),
                                  SizedBox(width: sw * 0.02),
                                  Text(
                                    'Remove Saved Center?',
                                    style: PillBinMedium.style(
                                      fontSize:
                                          isTablet ? sw * 0.025 : sw * 0.045,
                                      color: PillBinColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                'This will remove the selected medical center from your saved list. Do you want to continue?',
                                style: PillBinRegular.style(
                                  fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                                  color: PillBinColors.textSecondary,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: PillBinMedium.style(
                                      fontSize:
                                          isTablet ? sw * 0.02 : sw * 0.035,
                                      color: PillBinColors.textSecondary,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final provider =
                                        context.read<UserProvider>();

                                    String response =
                                        await provider.removeSavedMedicalCenter(
                                            context: context,
                                            medicalCenterId:
                                                widget.medicalCenter.id);

                                    Navigator.pop(context);

                                    if (response == 'success') {
                                      setState(() {
                                        isSaved = !isSaved;
                                      });
                                    }

                                    return;
                                  },
                                  child: Text(
                                    'Delete',
                                    style: PillBinMedium.style(
                                      fontSize:
                                          isTablet ? sw * 0.02 : sw * 0.035,
                                      color: PillBinColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(widget.sw * 0.015),
                      decoration: BoxDecoration(
                        color: isSaved
                            ? PillBinColors.warning.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isSaved ? Icons.star : Icons.star_border,
                        color: isSaved
                            ? PillBinColors.warning
                            : PillBinColors.grey,
                        size: isTablet ? widget.sw * 0.025 : widget.sw * 0.045,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? widget.sw * 0.02 : widget.sw * 0.03),
      decoration: BoxDecoration(
        color: PillBinColors.greyLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: PillBinColors.textSecondary,
                size: isTablet ? widget.sw * 0.02 : widget.sw * 0.035,
              ),
              SizedBox(width: widget.sw * 0.025),
              Expanded(
                child: Text(
                  widget.medicalCenter.address,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? widget.sw * 0.022 : widget.sw * 0.036,
                    color: PillBinColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.sh * 0.008),
          Row(
            children: [
              Icon(
                Icons.phone_outlined,
                color: PillBinColors.textSecondary,
                size: isTablet ? widget.sw * 0.02 : widget.sw * 0.035,
              ),
              SizedBox(width: widget.sw * 0.025),
              Text(
                widget.medicalCenter.phoneNumber,
                style: PillBinMedium.style(
                  fontSize: isTablet ? widget.sw * 0.022 : widget.sw * 0.036,
                  color: PillBinColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoursInfo(bool isTablet) {
    final isOpen = _isCurrentlyOpen();
    final hours = _getTodayHours();

    return Row(
      children: [
        Icon(
          Icons.access_time,
          color: isOpen ? PillBinColors.success : PillBinColors.error,
          size: isTablet ? widget.sw * 0.02 : widget.sw * 0.035,
        ),
        SizedBox(width: widget.sw * 0.02),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.sw * 0.02,
            vertical: widget.sh * 0.003,
          ),
          decoration: BoxDecoration(
            color: isOpen
                ? PillBinColors.success.withOpacity(0.1)
                : PillBinColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            isOpen ? 'Open' : 'Closed',
            style: PillBinMedium.style(
              fontSize: isTablet ? widget.sw * 0.018 : widget.sw * 0.028,
              color: isOpen ? PillBinColors.success : PillBinColors.error,
            ),
          ),
        ),
        SizedBox(width: widget.sw * 0.02),
        Expanded(
          child: Text(
            hours,
            style: PillBinRegular.style(
              fontSize: isTablet ? widget.sw * 0.02 : widget.sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PillBinColors.primary,
                  PillBinColors.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  // final String rawNumber = widget.medicalCenter.phoneNumber;
                  // final String cleanedNumber =
                  //     rawNumber.replaceAll(RegExp(r'[^\d+]'), '');

                  // try {
                  //   await launchUrl(
                  //     Uri.parse('tel:$cleanedNumber'),
                  //     mode: LaunchMode.externalApplication,
                  //   );
                  // } catch (e) {
                  //   print(e.toString());
                  // }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: widget.sh * 0.012,
                    horizontal: widget.sw * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: isTablet ? widget.sw * 0.02 : widget.sw * 0.035,
                      ),
                      SizedBox(width: widget.sw * 0.015),
                      Text(
                        'Call',
                        style: PillBinMedium.style(
                          fontSize:
                              isTablet ? widget.sw * 0.022 : widget.sw * 0.036,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: widget.sw * 0.025),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PillBinColors.primary,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // final Uri mapsUri = Uri.parse(
                  //   "https://www.google.com/maps/search/?api=1&query=${widget.medicalCenter.coordinates[1]},${widget.medicalCenter.coordinates[0]}"
                  // );

                  // try {
                  //   await launchUrl(mapsUri,
                  //       mode: LaunchMode.externalApplication);
                  // } catch (e) {
                  //   print(e.toString());
                  // }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: widget.sh * 0.012,
                    horizontal: widget.sw * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions,
                        color: PillBinColors.primary,
                        size: isTablet ? widget.sw * 0.02 : widget.sw * 0.035,
                      ),
                      SizedBox(width: widget.sw * 0.015),
                      Text(
                        'Directions',
                        style: PillBinMedium.style(
                          fontSize:
                              isTablet ? widget.sw * 0.022 : widget.sw * 0.036,
                          color: PillBinColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
