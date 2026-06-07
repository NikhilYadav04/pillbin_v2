import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pillbin/config/theme/appColors.dart';

class LocationCardShimmer extends StatelessWidget {
  final double sw;
  final double sh;

  const LocationCardShimmer({
    Key? key,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(
          color: PillBinColors.greyLight.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderShimmer(isTablet),
              SizedBox(height: sh * 0.012),
              _buildLocationInfoShimmer(isTablet),
              SizedBox(height: sh * 0.008),
              _buildHoursShimmer(isTablet),
              SizedBox(height: sh * 0.018),
              _buildActionButtonsShimmer(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderShimmer(bool isTablet) {
    return Row(
      children: [
        Container(
          width: isTablet ? sw * 0.06 : sw * 0.09,
          height: isTablet ? sw * 0.06 : sw * 0.09,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: isTablet ? sw * 0.025 : sw * 0.038,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.02),
                  Container(
                    width: sw * 0.15,
                    height: isTablet ? sw * 0.025 : sw * 0.035,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.008),
              Row(
                children: [
                  Container(
                    width: sw * 0.25,
                    height: isTablet ? sw * 0.025 : sw * 0.035,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: isTablet ? sw * 0.04 : sw * 0.065,
                    height: isTablet ? sw * 0.04 : sw * 0.065,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildLocationInfoShimmer(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
      decoration: BoxDecoration(
        color: PillBinColors.greyLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? sw * 0.02 : sw * 0.035,
                height: isTablet ? sw * 0.02 : sw * 0.035,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: sw * 0.025),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: isTablet ? sw * 0.02 : sw * 0.032,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: sh * 0.005),
                    Container(
                      width: sw * 0.5,
                      height: isTablet ? sw * 0.02 : sw * 0.032,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.008),
          Row(
            children: [
              Container(
                width: isTablet ? sw * 0.02 : sw * 0.035,
                height: isTablet ? sw * 0.02 : sw * 0.035,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: sw * 0.025),
              Container(
                width: sw * 0.3,
                height: isTablet ? sw * 0.02 : sw * 0.032,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoursShimmer(bool isTablet) {
    return Row(
      children: [
        Container(
          width: isTablet ? sw * 0.02 : sw * 0.035,
          height: isTablet ? sw * 0.02 : sw * 0.035,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: sw * 0.02),
        Container(
          width: sw * 0.15,
          height: isTablet ? sw * 0.022 : sw * 0.032,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(width: sw * 0.02),
        Container(
          width: sw * 0.25,
          height: isTablet ? sw * 0.02 : sw * 0.028,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsShimmer(bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: sh * 0.05,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        SizedBox(width: sw * 0.025),
        Expanded(
          child: Container(
            height: sh * 0.05,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
