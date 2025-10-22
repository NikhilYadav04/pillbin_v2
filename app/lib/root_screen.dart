import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/health_ai/presentation/pages/health_ai_screen.dart';
import 'package:pillbin/features/home/presentation/pages/home_screen.dart';
import 'package:pillbin/features/locations/presentation/pages/location_screen.dart';
import 'package:pillbin/features/medicines/presentation/pages/medicines_screen.dart';
import 'package:pillbin/features/profile/presentation/pages/profile_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({Key? key}) : super(key: key);

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const InventoryScreen(),
    const HealthReportChatScreen(),
    const LocationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class InfoPlaceholderScreen extends StatelessWidget {
  const InfoPlaceholderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.all(isTablet ? sw * 0.1 : sw * 0.06),
            padding: EdgeInsets.all(isTablet ? sw * 0.05 : sw * 0.08),
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: isTablet ? sw * 0.12 : sw * 0.2,
                  color: PillBinColors.primary,
                ),
                SizedBox(height: sh * 0.02),
                Text(
                  'Info Screen',
                  style: PillBinBold.style(
                    fontSize: isTablet ? sw * 0.04 : sw * 0.06,
                    color: PillBinColors.textPrimary,
                  ),
                ),
                SizedBox(height: sh * 0.01),
                Text(
                  'Coming Soon',
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                    color: PillBinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Container(
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? sh * 0.015 : sh * 0.01,
            horizontal: isTablet ? sw * 0.05 : sw * 0.02,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home', sw, sh, isTablet),
              _buildNavItem(1, Icons.medication, 'Medicines', sw, sh, isTablet),
              _buildNavItem(
                  2, Icons.smart_toy, 'Health AI', sw, sh, isTablet),
              _buildNavItem(
                  3, Icons.location_on, 'Locations', sw, sh, isTablet),
              _buildNavItem(4, Icons.person, 'Profile', sw, sh, isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, double sw,
      double sh, bool isTablet) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? sh * 0.01 : sh * 0.008,
          horizontal: isTablet ? sw * 0.025 : sw * 0.02,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? PillBinColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isTablet ? sw * 0.03 : sw * 0.06,
              color: isSelected
                  ? PillBinColors.primary
                  : PillBinColors.textSecondary,
            ),
            SizedBox(height: sh * 0.003),
            Text(
              label,
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.018 : sw * 0.025,
                color: isSelected
                    ? PillBinColors.primary
                    : PillBinColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
