import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class Campaign {
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String status;
  final DateTime joinedDate;
  final int medicinesCollected;
  final int participantsCount;

  Campaign({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.status,
    required this.joinedDate,
    required this.medicinesCollected,
    required this.participantsCount,
  });

  Color get statusColor {
    switch (status) {
      case 'Ongoing':
        return PillBinColors.success;
      case 'Upcoming':
        return PillBinColors.warning;
      case 'Completed':
        return PillBinColors.primary;
      default:
        return PillBinColors.textSecondary;
    }
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get timeStatus {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (status == 'Completed') {
      return 'Completed on $formattedDate';
    } else if (status == 'Ongoing') {
      return 'Active campaign';
    } else if (difference < 0) {
      return 'Started ${difference.abs()} days ago';
    } else if (difference == 0) {
      return 'Starting today';
    } else if (difference == 1) {
      return 'Starting tomorrow';
    } else {
      return 'Starts in $difference days';
    }
  }
}

class CampaignListItem extends StatefulWidget {
  final Campaign campaign;
  final double sw;
  final double sh;
  final VoidCallback onTap;

  const CampaignListItem({
    Key? key,
    required this.campaign,
    required this.sw,
    required this.sh,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CampaignListItem> createState() => _CampaignListItemState();
}

class _CampaignListItemState extends State<CampaignListItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.sw > 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
      margin: EdgeInsets.only(bottom: widget.sh * 0.02),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          boxShadow: [
            // Main shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            // Secondary shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          child: Container(
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Subtle gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Status accent border
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: widget.campaign.statusColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                // Main content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    onTap: widget.onTap,
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) => setState(() => _isPressed = false),
                    onTapCancel: () => setState(() => _isPressed = false),
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? widget.sw * 0.03 : widget.sw * 0.045),
                      child: Row(
                        children: [
                          // Icon container with enhanced design
                          Container(
                            padding: EdgeInsets.all(isTablet ? widget.sw * 0.025 : widget.sw * 0.035),
                            decoration: BoxDecoration(
                              color: widget.campaign.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                              border: Border.all(
                                color: widget.campaign.statusColor.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.campaign.statusColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.campaign,
                              color: widget.campaign.statusColor,
                              size: isTablet ? widget.sw * 0.03 : widget.sw * 0.055,
                            ),
                          ),
                          SizedBox(width: widget.sw * 0.04),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title and status row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.campaign.title,
                                        style: PillBinMedium.style(
                                          fontSize: isTablet ? widget.sw * 0.025 : widget.sw * 0.042,
                                          color: PillBinColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isTablet ? widget.sw * 0.02 : widget.sw * 0.025,
                                        vertical: isTablet ? widget.sh * 0.005 : widget.sh * 0.007,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            widget.campaign.statusColor.withOpacity(0.2),
                                            widget.campaign.statusColor.withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                                        border: Border.all(
                                          color: widget.campaign.statusColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        widget.campaign.status,
                                        style: PillBinMedium.style(
                                          fontSize: isTablet ? widget.sw * 0.018 : widget.sw * 0.026,
                                          color: widget.campaign.statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: widget.sh * 0.008),
                                // Description
                                Text(
                                  widget.campaign.description,
                                  style: PillBinRegular.style(
                                    fontSize: isTablet ? widget.sw * 0.02 : widget.sw * 0.036,
                                    color: PillBinColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: widget.sh * 0.008),
                                // Location row with enhanced design
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? widget.sw * 0.015 : widget.sw * 0.02,
                                    vertical: isTablet ? widget.sh * 0.003 : widget.sh * 0.005,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PillBinColors.greyLight.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: isTablet ? widget.sw * 0.018 : widget.sw * 0.032,
                                        color: PillBinColors.textLight,
                                      ),
                                      SizedBox(width: widget.sw * 0.01),
                                      Flexible(
                                        child: Text(
                                          widget.campaign.location,
                                          style: PillBinRegular.style(
                                            fontSize: isTablet ? widget.sw * 0.018 : widget.sw * 0.03,
                                            color: PillBinColors.textLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: widget.sh * 0.008),
                                // Time status with enhanced styling
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? widget.sw * 0.015 : widget.sw * 0.02,
                                    vertical: isTablet ? widget.sh * 0.003 : widget.sh * 0.005,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.campaign.statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.campaign.timeStatus,
                                    style: PillBinMedium.style(
                                      fontSize: isTablet ? widget.sw * 0.018 : widget.sw * 0.03,
                                      color: widget.campaign.statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: widget.sw * 0.02),
                          // Enhanced arrow with container
                          Container(
                            padding: EdgeInsets.all(isTablet ? widget.sw * 0.012 : widget.sw * 0.02),
                            decoration: BoxDecoration(
                              color: PillBinColors.greyLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: isTablet ? widget.sw * 0.02 : widget.sw * 0.035,
                              color: PillBinColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}