import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/home/presentation/widgets/home_screen_carousel.dart';
import 'package:pillbin/features/home/presentation/widgets/home_widgets.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationProvider _notificationProvider =
          context.read<NotificationProvider>();
      _notificationProvider.fetchNotifications(context: context);
    });
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

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: isTablet
              ? _buildTabletLayout(sw, sh)
              : _buildMobileLayout(sw, sh),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(double sw, double sh) {
    return RefreshIndicator(
      color: PillBinColors.primary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        UserProvider _userProvider = context.read<UserProvider>();
        _userProvider.refresh();

        NotificationProvider _notificationProvider =
            context.read<NotificationProvider>();
        _notificationProvider.refresh();

        return;
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHomeHeader(sw, sh),
            SizedBox(height: sh * 0.03),
            _buildStatsCards(sw, sh),
            SizedBox(height: sh * 0.04),
            _buildQuickActions(sw, sh),
            SizedBox(height: sh * 0.04),
            InfoCarouselWidget(sw: sw, sh: sh),
            SizedBox(height: sh * 0.04),
            buildRecentActivity(sw, sh, context),
            SizedBox(height: sh * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(double sw, double sh) {
    return RefreshIndicator(
      color: PillBinColors.primary,
      backgroundColor: Colors.white,
      onRefresh: () async {
        UserProvider _userProvider = context.read<UserProvider>();
        _userProvider.refresh();

        NotificationProvider _notificationProvider =
            context.read<NotificationProvider>();
        _notificationProvider.refresh();

        return;
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHomeHeader(sw, sh),
              SizedBox(height: sh * 0.03),
              _buildStatsCards(sw, sh),
              SizedBox(height: sh * 0.03),
              _buildQuickActions(sw, sh),
              SizedBox(height: sh * 0.03),
              InfoCarouselWidget(sw: sw, sh: sh),
              SizedBox(height: sh * 0.04),
              buildRecentActivity(sw, sh, context),
              SizedBox(height: sh * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(double sw, double sh) {
    final bool isTablet = sw > 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
      child: isTablet
          ? buildTabletStatsGrid(sw, sh)
          : buildMobileStatsColumn(sw, sh),
    );
  }

  Widget _buildQuickActions(double sw, double sh) {
    final bool isTablet = sw > 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.035 : sw * 0.05,
              color: PillBinColors.textPrimary,
            ),
          ),
          SizedBox(height: sh * 0.02),
          isTablet
              ? buildTabletActions(sw, sh, () {
                  Navigator.pushNamed(
                    context,
                    '/add-medicine-screen',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/chatbot-screen',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/campaign-screen',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/inventory-screen',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/medicine-history-screen',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/medical-center-display-detail',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/medical-center-display-saved',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                })
              : buildMobileActions(sw, sh, () {
                  Navigator.pushNamed(
                    context,
                    '/add-medicine-screen',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/chatbot-screen',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/campaign-screen',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/inventory-screen',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/medicine-history-screen',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/medical-center-display-detail',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }, () {
                  Navigator.pushNamed(
                    context,
                    '/medical-center-display-saved',
                    arguments: {
                      'transition': TransitionType.bottomToTop,
                      'duration': 300,
                    },
                  );
                }),
        ],
      ),
    );
  }
}
