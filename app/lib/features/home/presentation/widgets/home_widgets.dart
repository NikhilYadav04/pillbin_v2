import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/home/presentation/widgets/home_action_button.dart';
import 'package:pillbin/features/home/presentation/widgets/home_stat_card.dart';
import 'package:pillbin/features/home/presentation/widgets/home_tablet_action_card.dart';

Widget buildHomeHeader(double sw, double sh) {
  final bool isTablet = sw > 600;

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
        Text(
          'Welcome to PillBin',
          style: PillBinBold.style(
            fontSize: isTablet ? sw * 0.04 : sw * 0.07,
            color: PillBinColors.textWhite,
          ),
        ),
        SizedBox(height: sh * 0.01),
        Text(
          'Manage your medicines safely and responsibly',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textWhite.withOpacity(0.9),
          ),
        ),
      ],
    ),
  );
}

Widget buildMobileStatsColumn(double sw, double sh) {
  return Column(
    children: [
      StatCard(
        icon: Icons.medication,
        title: 'Total Medicines Tracked',
        value: '12',
        iconColor: PillBinColors.primary,
        delay: 100,
        sw: sw,
        sh: sh,
      ),
      SizedBox(height: sh * 0.02),
      StatCard(
        icon: Icons.schedule,
        title: 'Expiring Soon',
        value: '3',
        iconColor: PillBinColors.warning,
        delay: 200,
        sw: sw,
        sh: sh,
      ),
      SizedBox(height: sh * 0.02),
      StatCard(
        icon: Icons.check_circle,
        title: 'Medicines Disposed',
        value: '8',
        iconColor: PillBinColors.success,
        delay: 300,
        sw: sw,
        sh: sh,
      ),
    ],
  );
}

Widget buildTabletStatsGrid(double sw, double sh) {
  return Row(
    children: [
      Expanded(
        child: StatCard(
          icon: Icons.medication,
          title: 'Total Medicines Tracked',
          value: '12',
          iconColor: PillBinColors.primary,
          delay: 100,
          sw: sw,
          sh: sh,
        ),
      ),
      SizedBox(width: sw * 0.02),
      Expanded(
        child: StatCard(
          icon: Icons.schedule,
          title: 'Expiring Soon',
          value: '3',
          iconColor: PillBinColors.warning,
          delay: 200,
          sw: sw,
          sh: sh,
        ),
      ),
      SizedBox(width: sw * 0.02),
      Expanded(
        child: StatCard(
          icon: Icons.check_circle,
          title: 'Medicines Disposed',
          value: '8',
          iconColor: PillBinColors.success,
          delay: 300,
          sw: sw,
          sh: sh,
        ),
      ),
    ],
  );
}

Widget buildMobileActions(double sw, double sh, void Function() onTap1,
    void Function() onTap2, void Function() onTap3, void Function() onTap4) {
  return Column(
    children: [
      ActionButton(
        icon: Icons.add,
        text: 'Add Medicine',
        isPrimary: true,
        onTap: onTap1,
        sw: sw,
        sh: sh,
      ),
      SizedBox(height: sh * 0.015),
      ActionButton(
        icon: Icons.support_agent,
        text: 'Chat Assistant',
        isOutlined: true,
        onTap: onTap2,
        sw: sw,
        sh: sh,
      ),
      SizedBox(height: sh * 0.015),
      ActionButton(
        icon: Icons.calendar_today,
        text: 'View Campaigns',
        isOutlined: true,
        onTap: onTap3,
        sw: sw,
        sh: sh,
      ),
      SizedBox(height: sh * 0.015),
      ActionButton(
        icon: Icons.inventory,
        text: 'My Inventory',
        isOutlined: true,
        onTap: onTap4,
        sw: sw,
        sh: sh,
      ),
    ],
  );
}

Widget buildTabletActions(double sw, double sh, void Function() onTap1,
    void Function() onTap2, void Function() onTap3, void Function() onTap4) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: TabletActionButton(
              icon: Icons.add,
              text: 'Add Medicine',
              isPrimary: true,
              onTap: onTap1,
              sw: sw,
              sh: sh,
            ),
          ),
          SizedBox(width: sw * 0.02),
          Expanded(
            child: TabletActionButton(
              icon: Icons.support_agent,
              text: 'Chat Assistant',
              isOutlined: true,
              onTap: onTap2,
              sw: sw,
              sh: sh,
            ),
          ),
        ],
      ),
      SizedBox(height: sh * 0.02),
      Row(
        children: [
          Expanded(
            child: TabletActionButton(
              icon: Icons.calendar_today,
              text: 'View Campaigns',
              isOutlined: true,
              onTap: onTap3,
              sw: sw,
              sh: sh,
            ),
          ),
          SizedBox(width: sw * 0.02),
          Expanded(
            child: TabletActionButton(
              icon: Icons.inventory,
              text: 'My Inventory',
              isOutlined: true,
              onTap: onTap4,
              sw: sw,
              sh: sh,
            ),
          ),
        ],
      ),
    ],
  );
}

class ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color statusColor;
  final double sw;
  final double sh;

  const ActivityItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.statusColor,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: PillBinColors.greyLight.withOpacity(0.5)),
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
                  subtitle,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                    color: PillBinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: isTablet ? sw * 0.015 : sw * 0.02,
            height: isTablet ? sw * 0.015 : sw * 0.02,
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

Widget buildRecentActivity(double sw, double sh) {
  final bool isTablet = sw > 600;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.035 : sw * 0.05,
            color: PillBinColors.textPrimary,
          ),
        ),
        SizedBox(height: sh * 0.02),
        ActivityItem(
          title: 'Paracetamol added',
          subtitle: '2 hours ago',
          statusColor: PillBinColors.success,
          sw: sw,
          sh: sh,
        ),
        ActivityItem(
          title: 'Crocin expires soon',
          subtitle: '1 day ago',
          statusColor: PillBinColors.warning,
          sw: sw,
          sh: sh,
        ),
        ActivityItem(
          title: 'Dolo disposed safely',
          subtitle: '3 days ago',
          statusColor: PillBinColors.primary,
          sw: sw,
          sh: sh,
        ),
      ],
    ),
  );
}
