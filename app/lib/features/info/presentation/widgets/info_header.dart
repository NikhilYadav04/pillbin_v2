import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class PillBinHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final double sw;
  final double sh;
  final bool isTablet;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const PillBinHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sw,
    required this.sh,
    required this.isTablet,
    this.trailing,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
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
          if (isTablet && scaffoldKey != null) ...[
            GestureDetector(
              onTap: () {
                scaffoldKey!.currentState?.openDrawer();
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

          // Info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PillBinBold.style(
                    fontSize: isTablet ? sw * 0.04 : sw * 0.07,
                    color: PillBinColors.textWhite,
                  ),
                ),
                SizedBox(height: sh * 0.01),
                Text(
                  subtitle,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                    color: PillBinColors.textWhite.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Trailing icon
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
