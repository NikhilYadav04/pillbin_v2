import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final double sw;
  final double sh;

  const SettingsItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.01),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? sh * 0.015 : sh * 0.012,
              horizontal: isTablet ? sw * 0.025 : sw * 0.04,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: PillBinColors.textSecondary,
                  size: isTablet ? sw * 0.025 : sw * 0.04,
                ),
                SizedBox(width: sw * 0.03),
                Text(
                  title,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                    color: PillBinColors.textPrimary,
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
