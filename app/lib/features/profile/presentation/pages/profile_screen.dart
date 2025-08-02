import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/profile/presentation/widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


    return Scaffold(
      key: _scaffoldKey,
      drawer: isTablet
          ? Drawer(
            width: sw*0.5,
              backgroundColor: PillBinColors.surface,
              child: Column(
                children: [
                  // Drawer Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(sw * 0.03),
                    decoration: BoxDecoration(
                      color: PillBinColors.primary,
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: sw * 0.04,
                          ),
                          SizedBox(height: sh * 0.015),
                          Text(
                            'Settings & More',
                            style: PillBinBold.style(
                              fontSize: sw * 0.035,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Manage your preferences',
                            style: PillBinRegular.style(
                              fontSize: sw * 0.025,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Scrollable Settings Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(sw * 0.025),
                      child: buildProfileSettings(sw, sh, isTablet),
                    ),
                  ),
                ],
              ),
            )
          : null,
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: isTablet
              ? _buildTabletLayout(sw, sh,_scaffoldKey)
              : _buildMobileLayout(sw, sh,_scaffoldKey),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(double sw, double sh,GlobalKey<ScaffoldState> key) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildProfileAppBar(sw, sh, context,key),
          SizedBox(height: sh * 0.025),
          buildProfileHeader(sw, sh, false),
          SizedBox(height: sh * 0.025),
          buildProfileStatsCards(sw, sh, false),
          SizedBox(height: sh * 0.03),
          buildProfileAchievements(sw, sh, false),
          SizedBox(height: sh * 0.03),
          // buildProfileCampaigns(sw, sh, false),
          // SizedBox(height: sh * 0.03),
          buildProfileSurveySection(sw, sh, false),
          SizedBox(height: sh * 0.03),
          buildProfileSettings(sw, sh, false),
          SizedBox(height: sh * 0.02),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(double sw, double sh,GlobalKey<ScaffoldState> key) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
      child: Column(
        children: [
          // Fixed header section (non-scrollable)
          buildProfileAppBar(sw, sh, context,key),
          SizedBox(height: sh * 0.025),
          buildProfileHeader(sw, sh, true),
          SizedBox(height: sh * 0.025),

          // Scrollable content section with independent columns
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Stats, Achievements, Survey (Independent scroll)
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        buildProfileStatsCards(sw, sh, true),
                        SizedBox(height: sh * 0.03),
                        buildProfileAchievements(sw, sh, true),
                        SizedBox(height: sh * 0.03),
                        buildProfileSurveySection(sw, sh, true),
                        SizedBox(height: sh * 0.02), // Bottom padding
                      ],
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.03),

                // Right column - Campaigns, Settings (Independent scroll)
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        buildProfileCampaigns(sw, sh, true),
                        SizedBox(height: sh * 0.03),
                        // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
