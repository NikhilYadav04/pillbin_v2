import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class CampaignCard extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final double sw;
  final double sh;

  const CampaignCard({
    Key? key,
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                    color: PillBinColors.textPrimary,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Text(
                  date,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                    color: PillBinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: isTablet ? sw * 0.015 : sw * 0.025,
            height: isTablet ? sw * 0.015 : sw * 0.025,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
