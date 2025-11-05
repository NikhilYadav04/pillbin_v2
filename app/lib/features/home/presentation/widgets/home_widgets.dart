import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/homeShimmer.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/home/presentation/widgets/home_action_button.dart';
import 'package:pillbin/features/home/presentation/widgets/home_stat_card.dart';
import 'package:pillbin/features/home/presentation/widgets/home_tablet_action_card.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/network/models/notification_model.dart';
import 'package:pillbin/network/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
  return Consumer<UserProvider>(
    builder: (context, provider, _) {
      UserModel? user = provider.user;
      return provider.isFetching
          ? homeStatsShimmer(sw: sw, sh: sh)
          : Column(
              children: [
                StatCard(
                  icon: Icons.medication,
                  title: 'Total Medicines Tracked',
                  value: '${user?.stats.totalMedicinesTracked ?? 0}',
                  iconColor: PillBinColors.primary,
                  delay: 100,
                  sw: sw,
                  sh: sh,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/medicine-history-screen',
                      arguments: {
                        'transition': TransitionType.bottomToTop,
                        'duration': 300,
                      },
                    );
                  },
                ),
                SizedBox(height: sh * 0.02),
                StatCard(
                  icon: Icons.schedule,
                  title: 'Expiring Soon',
                  value: '${user?.stats.expiringSoonCount ?? 0}',
                  iconColor: PillBinColors.warning,
                  delay: 200,
                  sw: sw,
                  sh: sh,
                  onTap: () {},
                ),
                SizedBox(height: sh * 0.02),
                StatCard(
                  icon: Icons.check_circle,
                  title: 'Medicines Disposed',
                  value: '0',
                  iconColor: PillBinColors.success,
                  delay: 300,
                  sw: sw,
                  sh: sh,
                  onTap: () {},
                ),
              ],
            );
    },
  );
}

Widget buildTabletStatsGrid(double sw, double sh) {
  return Consumer<UserProvider>(builder: (context, provider, _) {
    UserModel? user = provider.user;
    return provider.isFetching
        ? homeStatsShimmer(sw: sw, sh: sh)
        : Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.medication,
                  title: 'Total Medicines Tracked',
                  value: '${user?.stats.totalMedicinesTracked ?? 0}',
                  iconColor: PillBinColors.primary,
                  delay: 100,
                  sw: sw,
                  sh: sh,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/medicine-history-screen',
                      arguments: {
                        'transition': TransitionType.bottomToTop,
                        'duration': 300,
                      },
                    );
                  },
                ),
              ),
              SizedBox(width: sw * 0.02),
              Expanded(
                child: StatCard(
                  icon: Icons.schedule,
                  title: 'Expiring Soon',
                  value: '${user?.stats.expiringSoonCount ?? 0}',
                  iconColor: PillBinColors.warning,
                  delay: 200,
                  sw: sw,
                  sh: sh,
                  onTap: () {},
                ),
              ),
              SizedBox(width: sw * 0.02),
              Expanded(
                child: StatCard(
                  icon: Icons.check_circle,
                  title: 'Medicines Disposed',
                  value: '0',
                  iconColor: PillBinColors.success,
                  delay: 300,
                  sw: sw,
                  sh: sh,
                  onTap: () {},
                ),
              ),
            ],
          );
  });
}

Widget buildMobileActions(
  double sw,
  double sh,
  void Function() onTap1,
  void Function() onTap2,
  void Function() onTap3,
  void Function() onTap4,
  void Function() onTap5,
  void Function() onTap6,
  void Function() onTap7,
) {
  return Column(
    children: [
      ActionButton(
        icon: Icons.add_circle,
        text: 'Add Medicine',
        isPrimary: true,
        onTap: onTap1,
        sw: sw,
        sh: sh,
      ),
      SizedBox(height: sh * 0.015),
      ActionButton(
        icon: Icons.inventory_2,
        text: 'My Inventory',
        isOutlined: true,
        onTap: onTap4,
        sw: sw,
        sh: sh,
      ),
      SizedBox(height: sh * 0.015),
      ActionButton(
        icon: Icons.history,
        text: 'Medicines History',
        isOutlined: true,
        onTap: onTap5,
        sw: sw,
        sh: sh,
      ),
      // SizedBox(height: sh * 0.015),
      // ActionButton(
      //   icon: Icons.event,
      //   text: 'View Campaigns',
      //   isOutlined: true,
      //   onTap: onTap3,
      //   sw: sw,
      //   sh: sh,
      // ),
      SizedBox(height: sh * 0.015),
      ActionButton(
        icon: Icons.local_hospital,
        text: 'View Disposal Centers',
        isOutlined: true,
        onTap: onTap6,
        sw: sw,
        sh: sh,
      ),
      // SizedBox(height: sh * 0.015),
      // ActionButton(
      //   icon: Icons.bookmark,
      //   text: 'Saved Disposal Centers',
      //   isOutlined: true,
      //   onTap: onTap7,
      //   sw: sw,
      //   sh: sh,
      // ),
      SizedBox(height: sh * 0.015),
      ActionButton(
        icon: Icons.support_agent,
        text: 'Chat Assistant',
        isOutlined: true,
        onTap: onTap2,
        sw: sw,
        sh: sh,
      ),
    ],
  );
}

Widget buildTabletActions(
  double sw,
  double sh,
  void Function() onTap1,
  void Function() onTap2,
  void Function() onTap3,
  void Function() onTap4,
  void Function() onTap5,
  void Function() onTap6,
  void Function() onTap7,
) {
  return Column(
    children: [
      Row(
        children: [
          Expanded(
            child: TabletActionButton(
              icon: Icons.add_circle,
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
              icon: Icons.inventory_2,
              text: 'My Inventory',
              isOutlined: true,
              onTap: onTap4,
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
              icon: Icons.history,
              text: 'Medicines History',
              isOutlined: true,
              onTap: onTap5,
              sw: sw,
              sh: sh,
            ),
          ),
          SizedBox(width: sw * 0.02),
          // Expanded(
          //   child: TabletActionButton(
          //     icon: Icons.event,
          //     text: 'View Campaigns',
          //     isOutlined: true,
          //     onTap: onTap3,
          //     sw: sw,
          //     sh: sh,
          //   ),
          // ),
        ],
      ),
      SizedBox(height: sh * 0.02),
      Row(
        children: [
          Expanded(
            child: TabletActionButton(
              icon: Icons.local_hospital,
              text: 'View Disposal Centers',
              isOutlined: true,
              onTap: onTap6,
              sw: sw,
              sh: sh,
            ),
          ),
          SizedBox(width: sw * 0.02),
          // Expanded(
          //   child: TabletActionButton(
          //     icon: Icons.bookmark,
          //     text: 'Saved Disposal Centers',
          //     isOutlined: true,
          //     onTap: onTap7,
          //     sw: sw,
          //     sh: sh,
          //   ),
          // ),
        ],
      ),
      SizedBox(height: sh * 0.02),
      Row(
        children: [
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
    ],
  );
}

class ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final DateTime timestamp;
  final Color statusColor;
  final double sw;
  final double sh;

  const ActivityItem({
    Key? key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.statusColor,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: sh * 0.006),
                Text(
                  description,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                    color: PillBinColors.textSecondary,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: sh * 0.008),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: isTablet ? sw * 0.018 : sw * 0.032,
                      color: PillBinColors.textLight,
                    ),
                    SizedBox(width: sw * 0.01),
                    Text(
                      _getTimeAgo(timestamp),
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                        color: PillBinColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.03),
          Container(
            width: isTablet ? sw * 0.015 : sw * 0.02,
            height: isTablet ? sw * 0.015 : sw * 0.02,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildRecentActivity(double sw, double sh, BuildContext context) {
  final bool isTablet = sw > 600;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        List<NotificationModel> notifications = provider.notifications;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.035 : sw * 0.05,
                    color: PillBinColors.textPrimary,
                  ),
                ),
                if (notifications.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/notification-screen',
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          'View All',
                          style: PillBinMedium.style(
                            fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                            color: PillBinColors.primary,
                          ),
                        ),
                        SizedBox(width: sw * 0.01),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: isTablet ? sw * 0.018 : sw * 0.03,
                          color: PillBinColors.primary,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: sh * 0.02),

            //* Empty state
            if (notifications.isEmpty)
              Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.15),
                decoration: BoxDecoration(
                  color: PillBinColors.surface,
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  border: Border.all(
                    color: PillBinColors.greyLight.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: isTablet ? sw * 0.08 : sw * 0.15,
                      color: PillBinColors.textSecondary.withOpacity(0.5),
                    ),
                    SizedBox(height: sh * 0.015),
                    Text(
                      'No Recent Activity',
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                        color: PillBinColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: sh * 0.008),
                    Text(
                      'Your notifications will appear here',
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                        color: PillBinColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )

            //* Display notifications (up to 3)
            else
              ...List.generate(
                notifications.length > 3 ? 3 : notifications.length,
                (index) {
                  final notification = notifications[index];

                  //* Determine status color based on notification type or priority
                  Color statusColor = PillBinColors.primary;
                  if (notification.status.toString().contains('alert') |
                      notification.status.toString().contains('urgent')) {
                    statusColor = PillBinColors.error;
                  } else if (notification.status
                      .toString()
                      .contains('important')) {
                    statusColor = PillBinColors.primary;
                  } else if (notification.status
                      .toString()
                      .contains('normal')) {
                    statusColor = PillBinColors.success;
                  }

                  return ActivityItem(
                    title: notification.title.trim(),
                    description: notification.description.trim(),
                    timestamp: notification.createdAt,
                    statusColor: statusColor,
                    sw: sw,
                    sh: sh,
                  );
                },
              ),
          ],
        );
      },
    ),
  );
}
