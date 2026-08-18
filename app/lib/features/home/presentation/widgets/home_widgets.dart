import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/homeShimmer.dart';
import 'package:pillbin/core/widgets/notification_bell.dart';
import 'package:pillbin/features/home/presentation/widgets/home_action_button.dart';
import 'package:pillbin/features/home/presentation/widgets/home_stat_card.dart';
import 'package:pillbin/features/home/presentation/widgets/home_tablet_action_card.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/network/models/user_model.dart';
import 'package:provider/provider.dart';

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
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
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
        ),
        const NotificationBell(),
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
                      '/inventory-screen',
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
                      '/inventory-screen',
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
  void Function() onTap3,
  void Function() onTap4,
  void Function() onTap5,
  void Function() onTap6,
  void Function() onTap7,
  void Function() onTap8,
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
        icon: Icons.volunteer_activism,
        text: 'My Donations',
        isOutlined: true,
        onTap: onTap8,
        sw: sw,
        sh: sh,
      ),
      SizedBox(height: sh * 0.015),
      ActionButton(
        icon: Icons.local_hospital,
        text: 'View Disposal Centers',
        isOutlined: true,
        onTap: onTap6,
        sw: sw,
        sh: sh,
      ),
      SizedBox(height: sh * 0.015),
      // ActionButton(
      //   icon: Icons.bookmark,
      //   text: 'Saved Disposal Centers',
      //   isOutlined: true,
      //   onTap: onTap7,
      //   sw: sw,
      //   sh: sh,
      // ),
      ActionButton(
        icon: Icons.location_on,
        text: 'Search Disposal Centers',
        isOutlined: true,
        onTap: onTap7,
        sw: sw,
        sh: sh,
      ),
      SizedBox(height: sh * 0.015),
    ],
  );
}

Widget buildTabletActions(
  double sw,
  double sh,
  void Function() onTap1,
  void Function() onTap3,
  void Function() onTap4,
  void Function() onTap5,
  void Function() onTap6,
  void Function() onTap7,
  void Function() onTap8,
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
          Expanded(
            child: TabletActionButton(
              icon: Icons.volunteer_activism,
              text: 'My Donations',
              isOutlined: true,
              onTap: onTap8,
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
              icon: Icons.local_hospital,
              text: 'View Disposal Centers',
              isOutlined: true,
              onTap: onTap6,
              sw: sw,
              sh: sh,
            ),
          ),
        ],
      ),
      SizedBox(height: sh * 0.02),
      Row(
        children: [
          // Expanded(
          //   child: TabletActionButton(
          //     icon: Icons.local_hospital,
          //     text: 'View Disposal Centers',
          //     isOutlined: true,
          //     onTap: onTap6,
          //     sw: sw,
          //     sh: sh,
          //   ),
          // ),
          //SizedBox(width: sw * 0.02),
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
              icon: Icons.location_on,
              text: 'Search Disposal Centers',
              isOutlined: true,
              onTap: onTap7,
              sw: sw,
              sh: sh,
            ),
          ),
        ],
      ),
    ],
  );
}
