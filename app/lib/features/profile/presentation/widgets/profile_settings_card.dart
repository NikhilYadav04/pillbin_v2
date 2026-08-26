import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final double sw;
  final double sh;
  final Color? iconColor;
  final Color? titleColor;
  final bool showChevron;

  const SettingsItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.sw,
    required this.sh,
    this.iconColor,
    this.titleColor,
    this.showChevron = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? sh * 0.015 : sh * 0.014,
            horizontal: isTablet ? sw * 0.025 : sw * 0.04,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? PillBinColors.textSecondary,
                size: isTablet ? sw * 0.025 : sw * 0.045,
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Text(
                  title,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                    color: titleColor ?? PillBinColors.textPrimary,
                  ),
                ),
              ),
              if (showChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  color: PillBinColors.textLight,
                  size: isTablet ? sw * 0.028 : sw * 0.05,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
