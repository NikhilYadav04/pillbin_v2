import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

Widget buildInventoryHeader(double sw, double sh, bool isTablet,BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
    child: Column(
      crossAxisAlignment: isTablet ? CrossAxisAlignment.center  : CrossAxisAlignment.start,
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
              'Medicine Inventory',
              style: PillBinBold.style(
                fontSize: isTablet ? sw * 0.04 : sw * 0.07,
                color: PillBinColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.01),
        Text(
          'Track expiry dates and manage your medicines',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

Widget buildInventoryTabBar(
    double sw,
    double sh,
    bool isTablet,
    TabController tabController,
    int activeCount,
    int expiringCount,
    int expiredCount) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: isTablet ? sw * 0.05 : sw * 0.04),
    decoration: BoxDecoration(
      color: PillBinColors.surface,
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TabBar(
      controller: tabController,
      indicator: BoxDecoration(
        color: PillBinColors.primary,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding:
          EdgeInsets.symmetric(vertical: isTablet ? sh * 0.01 : sh * 0.004),
      labelColor: PillBinColors.textWhite,
      unselectedLabelColor: PillBinColors.textSecondary,
      labelStyle: PillBinMedium.style(
        fontSize: isTablet ? sw * 0.02 : sw * 0.032,
      ),
      unselectedLabelStyle: PillBinRegular.style(
        fontSize: isTablet ? sw * 0.02 : sw * 0.032,
      ),
      tabs: [
        Tab(
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: sw * 0.04,
                ),
                SizedBox(width: sw * 0.015),
                Text('Active (${activeCount})'),
              ],
            ),
          ),
        ),
        Tab(
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  size: sw * 0.04,
                ),
                SizedBox(width: sw * 0.015),
                Text('Expiring (${expiringCount})'),
              ],
            ),
          ),
        ),
        Tab(
          child: FittedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cancel_outlined,
                  size: sw * 0.04,
                ),
                SizedBox(width: sw * 0.015),
                Text('Expired (${expiredCount})'),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
