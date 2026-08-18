import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/pillbot/presentation/pages/pillbot_screen.dart';
import 'package:pillbin/features/profile/presentation/pages/profile_screen.dart';
import 'package:pillbin/features/vendor/data/repository/vendor_provider.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_dashboard_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_requests_screen.dart';
import 'package:provider/provider.dart';

class VendorBottomBarScreen extends StatefulWidget {
  const VendorBottomBarScreen({Key? key}) : super(key: key);

  @override
  State<VendorBottomBarScreen> createState() => _VendorBottomBarScreenState();
}

class _VendorBottomBarScreenState extends State<VendorBottomBarScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    VendorDashboardScreen(),
    VendorRequestsScreen(),
    PillBotScreen(isVendor: true),
    ProfileScreen(isVendor: true),
  ];

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final pendingCount = context.watch<VendorProvider>().pendingCount;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: PillBinColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: sh * 0.01,
              horizontal: sw * 0.02,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_outlined, 'Dashboard', sw, sh, 0),
                _navItem(1, Icons.list_alt_outlined, 'Requests', sw, sh, pendingCount),
                _navItem(2, Icons.smart_toy_outlined, 'PillBot', sw, sh, 0),
                _navItem(3, Icons.person_outline, 'Profile', sw, sh, 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int index, IconData icon, String label, double sw, double sh, int badge) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _selectTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
            vertical: sh * 0.008, horizontal: sw * 0.04),
        decoration: BoxDecoration(
          color: selected
              ? PillBinColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon,
                    size: sw * 0.06,
                    color: selected
                        ? PillBinColors.primary
                        : PillBinColors.textSecondary),
                if (badge > 0)
                  Positioned(
                    top: -sh * 0.005,
                    right: -sw * 0.02,
                    child: Container(
                      padding: EdgeInsets.all(sw * 0.008),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                          minWidth: sw * 0.045, minHeight: sw * 0.045),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        style: PillBinBold.style(
                            fontSize: sw * 0.022, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: sh * 0.003),
            Text(label,
                style: PillBinMedium.style(
                  fontSize: sw * 0.025,
                  color: selected
                      ? PillBinColors.primary
                      : PillBinColors.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}
