import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:shimmer/shimmer.dart';

class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.05 : sw * 0.04,
        vertical: sh * 0.02,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return NotificationShimmerCard(
          sw: sw,
          sh: sh,
          isTablet: isTablet,
        );
      },
    );
  }
}

class NotificationShimmerCard extends StatelessWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const NotificationShimmerCard({
    Key? key,
    required this.sw,
    required this.sh,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: PillBinColors.greyLight.withOpacity(0.5)),
      ),
      child: Shimmer.fromColors(
        baseColor: PillBinColors.greyLight.withOpacity(0.3),
        highlightColor: PillBinColors.greyLight.withOpacity(0.1),
        child: Row(
          children: [
            // Icon circle shimmer
            Container(
              width: isTablet ? sw * 0.05 : sw * 0.08,
              height: isTablet ? sw * 0.05 : sw * 0.08,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: sw * 0.03),

            // Content shimmer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title shimmer
                  Container(
                    width: sw * 0.5,
                    height: isTablet ? sw * 0.02 : sw * 0.035,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: sh * 0.008),
                  // Description shimmer
                  Container(
                    width: sw * 0.4,
                    height: isTablet ? sw * 0.018 : sw * 0.03,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: sh * 0.008),
                  // Time shimmer
                  Container(
                    width: sw * 0.2,
                    height: isTablet ? sw * 0.015 : sw * 0.025,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            // Status dot and close button shimmer
            Row(
              children: [
                Container(
                  width: isTablet ? sw * 0.015 : sw * 0.02,
                  height: isTablet ? sw * 0.015 : sw * 0.02,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: sw * 0.02),
                Container(
                  width: isTablet ? sw * 0.025 : sw * 0.04,
                  height: isTablet ? sw * 0.025 : sw * 0.04,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}