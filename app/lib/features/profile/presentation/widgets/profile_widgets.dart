import 'package:flutter/material.dart';
import 'package:pillbin/config/notifications/notification_config.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/chatbot/data/repository/chatbot_provider.dart';
import 'package:pillbin/features/health_ai/data/repository/health_ai_provider.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/locations/data/repository/medical_center_provider.dart';
import 'package:pillbin/features/medicines/data/repository/medicine_provider.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/features/profile/presentation/widgets/profile_achievements_card.dart';
import 'package:pillbin/features/profile/presentation/widgets/profile_campaign_card.dart';
import 'package:pillbin/features/profile/presentation/widgets/profile_settings_card.dart';
import 'package:pillbin/features/profile/presentation/widgets/profile_stats_card.dart';
import 'package:pillbin/network/models/user_model.dart';
import 'package:pillbin/network/utils/http_client.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildProfileAppBar(double sw, double sh, BuildContext context,
    GlobalKey<ScaffoldState> key, void Function() onTap) {
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
      children: [
        // Drawer icon (only for tablets)
        if (isTablet) ...[
          GestureDetector(
            onTap: () {
              print("drawer tapped");
              key.currentState?.openDrawer();
            },
            child: Container(
              padding: EdgeInsets.all(isTablet ? sw * 0.015 : sw * 0.02),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.menu,
                color: Colors.white,
                size: isTablet ? sw * 0.03 : sw * 0.05,
              ),
            ),
          ),
          SizedBox(width: sw * 0.04),
        ],

        // Profile info section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.04 : sw * 0.07,
                  color: PillBinColors.textWhite,
                ),
              ),
              SizedBox(height: sh * 0.01),
              Text(
                'Manage your account and achievements',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                  color: PillBinColors.textWhite.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),

        //* Refresh icon on the right
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.015 : sw * 0.02),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.refresh,
              color: Colors.white,
              size: isTablet ? sw * 0.03 : sw * 0.05,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildProfileHeader(
  double sw,
  double sh,
  bool isTablet,
  BuildContext context,
  UserModel? user,
) {
  bool userIsNotCompletedProfile = user?.profileCompleted == false;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
    margin: EdgeInsets.symmetric(horizontal: isTablet ? sw * 0.005 : sw * 0.04),
    decoration: BoxDecoration(
      color: PillBinColors.surface,
      borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
      border: userIsNotCompletedProfile
          ? Border.all(
              color: Colors.red,
              width: 2.0,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: isTablet ? sw * 0.12 : sw * 0.2,
          height: isTablet ? sw * 0.12 : sw * 0.2,
          decoration: BoxDecoration(
            color: PillBinColors.primary.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(isTablet ? sw * 0.06 : sw * 0.1),
          ),
          child: Center(
            child: Text(
              user?.fullName == "" ? "X" : user?.fullName?.split("")[0] ?? "X",
              style: PillBinBold.style(
                fontSize: isTablet ? sw * 0.04 : sw * 0.06,
                color: PillBinColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: sw * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user?.fullName == ""
                        ? "John Doe"
                        : user?.fullName ?? "Mr. K",
                    style: PillBinBold.style(
                      fontSize: isTablet ? sw * 0.03 : sw * 0.05,
                      color: PillBinColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: sw * 0.02),
                  GestureDetector(
                    onTap: () => {
                      Navigator.pushNamed(
                        context,
                        '/edit-profile-screen',
                        arguments: {
                          'fullName': user?.fullName ?? "",
                          'phone': user?.phoneNumber ?? "",
                          'locationName': user?.location?.name ?? "",
                          'latitude':
                              user?.location?.coordinates?.latitude ?? 0.0,
                          'longitude':
                              user?.location?.coordinates?.longitude ?? 0.0,
                          'currentMedicines': user?.currentMedicines
                                  .map((e) => e.toJson())
                                  .toList() ??
                              [],
                          'medicalConditions': user?.medicalConditions
                                  .map((e) => e.toJson())
                                  .toList() ??
                              [],
                          'transition': TransitionType.rightToLeft,
                          'duration': 300,
                        },
                      )
                    },
                    child: Icon(
                      Icons.edit,
                      size: isTablet ? sw * 0.025 : sw * 0.04,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.005),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: isTablet ? sw * 0.02 : sw * 0.035,
                    color: PillBinColors.textSecondary,
                  ),
                  SizedBox(width: sw * 0.01),
                  Text(
                    user?.email ?? "xyz@mail.com",
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.005),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: isTablet ? sw * 0.02 : sw * 0.035,
                    color: PillBinColors.textSecondary,
                  ),
                  SizedBox(width: sw * 0.01),
                  Text(
                    user?.location?.name ?? "London, England",
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Optional: Add a warning message when profile is incomplete
              if (userIsNotCompletedProfile) ...[
                SizedBox(height: sh * 0.01),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.02,
                    vertical: sh * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning,
                        size: isTablet ? sw * 0.02 : sw * 0.03,
                        color: Colors.red,
                      ),
                      SizedBox(width: sw * 0.01),
                      Text(
                        "Complete your profile",
                        style: PillBinRegular.style(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildProfileStatsCards(double sw, double sh, bool isTablet,
    BuildContext context, String medicinesTrackedCount) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
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
            child: ProfileStatCard(
              count: '${medicinesTrackedCount}',
              label: 'Medicines Tracked',
              color: PillBinColors.primary,
              sw: sw,
              sh: sh,
            ),
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: ProfileStatCard(
            count: '0',
            label: 'Safely Disposed',
            color: PillBinColors.success,
            sw: sw,
            sh: sh,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: ProfileStatCard(
            count: '0',
            label: 'Campaigns Joined',
            color: PillBinColors.info,
            sw: sw,
            sh: sh,
          ),
        ),
      ],
    ),
  );
}

Widget buildProfileAchievements(double sw, double sh, bool isTablet,
    BuildContext context, UserModel? user) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: PillBinColors.primary,
              size: isTablet ? sw * 0.03 : sw * 0.05,
            ),
            SizedBox(width: sw * 0.02),
            Text(
              'Achievements',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.03 : sw * 0.05,
                color: PillBinColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.02),
        AchievementCard(
          icon: Icons.track_changes,
          title: 'First Timer',
          description: 'Tracked 1st medicine',
          isCompleted: user?.badges.firstTimer.achieved ?? false,
          sw: sw,
          sh: sh,
        ),
        SizedBox(height: sh * 0.012),
        AchievementCard(
          icon: Icons.eco,
          title: 'Eco Helper',
          description: 'Tracked 5 medicines',
          isCompleted: user?.badges.ecoHelper.achieved ?? false,
          sw: sw,
          sh: sh,
        ),
        SizedBox(height: sh * 0.012),
        AchievementCard(
          icon: Icons.military_tech,
          title: 'Green Champion',
          description: 'Tracked 20 medicines',
          isCompleted: user?.badges.greenChampion.achieved ?? false,
          sw: sw,
          sh: sh,
        ),
      ],
    ),
  );
}

Widget buildProfileCampaigns(double sw, double sh, bool isTablet) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: PillBinColors.primary,
              size: isTablet ? sw * 0.03 : sw * 0.05,
            ),
            SizedBox(width: sw * 0.02),
            Text(
              'My Campaigns',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.03 : sw * 0.05,
                color: PillBinColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.02),
        CampaignCard(
          title: 'Bandra Medicine Drive',
          date: 'July 28, 2024',
          status: 'Completed',
          statusColor: PillBinColors.primary,
          sw: sw,
          sh: sh,
        ),
        SizedBox(height: sh * 0.012),
        CampaignCard(
          title: 'Apollo Take-Back Program',
          date: 'Ongoing',
          status: 'Active',
          statusColor: PillBinColors.success,
          sw: sw,
          sh: sh,
        ),
        SizedBox(height: sh * 0.012),
        CampaignCard(
          title: 'Hospital Disposal Event',
          date: 'June 15, 2024',
          status: 'Completed',
          statusColor: PillBinColors.primary,
          sw: sw,
          sh: sh,
        ),
      ],
    ),
  );
}

Widget buildProfileSurveySection(double sw, double sh, bool isTablet) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PillBinColors.success.withOpacity(0.1),
            PillBinColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        border: Border.all(color: PillBinColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.03 : sw * 0.05,
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Help Us Improve',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.03 : sw * 0.045,
                  color: PillBinColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'Share your experience with medicine disposal to help us serve you better.',
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.035,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.015),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: PillBinColors.primary,
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
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
                onTap: () async {
                  final Uri url = Uri.parse(
                    'https://docs.google.com/forms/d/e/1FAIpQLSdm5baK6hgQHAAW6Y9Mm5vymBo-jZXRx4XXCKee5vmFpJTx8w/viewform',
                  );

                  if (!await launchUrl(url,
                      mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                },
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? sh * 0.015 : sh * 0.012,
                    horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review,
                        color: PillBinColors.textWhite,
                        size: isTablet ? sw * 0.025 : sw * 0.04,
                      ),
                      SizedBox(width: sw * 0.02),
                      Text(
                        'Fill Survey Form',
                        style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                          color: PillBinColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildProfileSettings(
    double sw, double sh, bool isTablet, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.settings,
              color: PillBinColors.primary,
              size: isTablet ? sw * 0.03 : sw * 0.05,
            ),
            SizedBox(width: sw * 0.02),
            Text(
              'Settings',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.03 : sw * 0.05,
                color: PillBinColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.02),
        // SettingsItem(
        //   title: 'Notification Preferences',
        //   icon: Icons.notifications_outlined,
        //   onTap: () {},
        //   sw: sw,
        //   sh: sh,
        // ),
        SettingsItem(
          title: 'Privacy Settings',
          icon: Icons.privacy_tip_outlined,
          onTap: () {},
          sw: sw,
          sh: sh,
        ),
        SettingsItem(
          title: 'Language & Region',
          icon: Icons.language_outlined,
          onTap: () {},
          sw: sw,
          sh: sh,
        ),
        SettingsItem(
          title: 'Help & Support',
          icon: Icons.help_outline,
          onTap: () {},
          sw: sw,
          sh: sh,
        ),
        SettingsItem(
          title: 'About PillBin',
          icon: Icons.info_outline,
          onTap: () {},
          sw: sw,
          sh: sh,
        ),
        SettingsItem(
          title: 'Logout',
          icon: Icons.logout,
          onTap: () {
            _showLogoutWarningDialog(context, sw, sh);
          },
          sw: sw,
          sh: sh,
        ),
      ],
    ),
  );
}

void _showLogoutWarningDialog(BuildContext context, double sw, double sh) {
  final bool isTablet = sw > 600;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: isTablet ? sw * 0.4 : sw * 0.85,
          padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: isTablet ? sw * 0.05 : sw * 0.12,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: sh * 0.02),

              // Title
              Text(
                'Logout?',
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.028 : sw * 0.05,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: sh * 0.015),

              // Message
              Text(
                "Are you sure you want to log out? You’ll need to sign in again to access your data, and any scheduled notifications will be cancelled.",
                textAlign: TextAlign.center,
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: sh * 0.025),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? sh * 0.015 : sh * 0.012,
                        ),
                        backgroundColor: PillBinColors.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: PillBinBold.style(
                          fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                          color: PillBinColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final HttpClient _httpClient = HttpClient();
                        Map<String, String> map =
                            await _httpClient.getUserData();

                        await context.read<UserProvider>().reset();
                        await context.read<MedicineProvider>().reset();
                        await context.read<MedicalCenterProvider>().reset();
                        await context.read<ChatbotProvider>().reset();
                        await context.read<NotificationProvider>().reset();
                        await context.read<HealthAiProvider>().reset();

                        NotificationConfig().cancelAllNotifications();

                        HealthAiProvider provider =
                            context.read<HealthAiProvider>();

                        provider.deleteFAISSIndex(
                          userId:
                              "${map["name"]}_${map["phone"]?.substring(0, 4)}",
                        );

                        provider.deleteFile();
                        await _httpClient.logout();

                        Navigator.pushReplacementNamed(
                          context,
                          '/landing-screen',
                          arguments: {
                            'transition': TransitionType.topToBottom,
                            'duration': 300,
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? sh * 0.015 : sh * 0.012,
                        ),
                        backgroundColor: Colors.orange.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: PillBinBold.style(
                          fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
