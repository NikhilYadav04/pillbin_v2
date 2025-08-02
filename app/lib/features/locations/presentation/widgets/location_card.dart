import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class LocationCard extends StatefulWidget {
  final String name;
  final String distance;
  final String address;
  final String phone;
  final bool isFavorite;
  final double sw;
  final double sh;
  final String? hours;
  final bool isOpen;
  final double? rating;

  const LocationCard({
    Key? key,
    required this.name,
    required this.distance,
    required this.address,
    required this.phone,
    required this.isFavorite,
    required this.sw,
    required this.sh,
    this.hours,
    this.isOpen = true,
    this.rating,
  }) : super(key: key);

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorite;
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
            // Handle card tap - show details
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
                if (widget.hours != null) ...[
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
            Icons.local_hospital,
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
                      widget.name,
                      style: PillBinBold.style(
                        fontSize:
                            isTablet ? widget.sw * 0.028 : widget.sw * 0.042,
                        color: PillBinColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.rating != null)
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
                            widget.rating!.toStringAsFixed(1),
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
                          widget.distance,
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
                      setState(() {
                        _isFavorited = !_isFavorited;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(widget.sw * 0.015),
                      decoration: BoxDecoration(
                        color: _isFavorited
                            ? PillBinColors.warning.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isFavorited ? Icons.star : Icons.star_border,
                        color: _isFavorited
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
                  widget.address,
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
                widget.phone,
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
    return Row(
      children: [
        Icon(
          Icons.access_time,
          color: widget.isOpen ? PillBinColors.success : PillBinColors.error,
          size: isTablet ? widget.sw * 0.02 : widget.sw * 0.035,
        ),
        SizedBox(width: widget.sw * 0.02),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.sw * 0.02,
            vertical: widget.sh * 0.003,
          ),
          decoration: BoxDecoration(
            color: widget.isOpen
                ? PillBinColors.success.withOpacity(0.1)
                : PillBinColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.isOpen ? 'Open' : 'Closed',
            style: PillBinMedium.style(
              fontSize: isTablet ? widget.sw * 0.018 : widget.sw * 0.028,
              color:
                  widget.isOpen ? PillBinColors.success : PillBinColors.error,
            ),
          ),
        ),
        SizedBox(width: widget.sw * 0.02),
        Text(
          widget.hours!,
          style: PillBinRegular.style(
            fontSize: isTablet ? widget.sw * 0.02 : widget.sw * 0.032,
            color: PillBinColors.textSecondary,
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
                onTap: () {
                  // Handle call
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
                  // Handle directions
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: widget.sh * 0.012,
                    horizontal: widget.sw * 0.02,
                  ),
                  child: isTablet
                      ? FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions,
                                color: PillBinColors.primary,
                                size: isTablet
                                    ? widget.sw * 0.02
                                    : widget.sw * 0.035,
                              ),
                              SizedBox(width: widget.sw * 0.015),
                              Text(
                                'Directions',
                                style: PillBinMedium.style(
                                  fontSize: isTablet
                                      ? widget.sw * 0.022
                                      : widget.sw * 0.036,
                                  color: PillBinColors.primary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions,
                              color: PillBinColors.primary,
                              size: isTablet
                                  ? widget.sw * 0.02
                                  : widget.sw * 0.035,
                            ),
                            SizedBox(width: widget.sw * 0.015),
                            Text(
                              'Directions',
                              style: PillBinMedium.style(
                                fontSize: isTablet
                                    ? widget.sw * 0.022
                                    : widget.sw * 0.036,
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
