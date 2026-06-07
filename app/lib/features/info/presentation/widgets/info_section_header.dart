import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onActionTap;
  final String? actionText;
  final double sw;
  final double sh;
  final bool isTablet;

  const SectionHeader({
    super.key,
    required this.title,
    required this.sw,
    required this.sh,
    required this.isTablet,
    this.icon,
    this.onActionTap,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? sw * 0.03 : sw * 0.05,
        sh * 0.03,
        isTablet ? sw * 0.03 : sw * 0.05,
        sh * 0.015,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: PillBinColors.primary,
              size: isTablet ? sw * 0.025 : sw * 0.05,
            ),
            SizedBox(width: sw * 0.02),
          ],
          Text(
            title,
            style: PillBinMedium.style(
              color: PillBinColors.textDark,
              fontSize: isTablet ? sw * 0.025 : sw * 0.045,
            ),
          ),
          const Spacer(),
          if (onActionTap != null && actionText != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                actionText!,
                style: PillBinMedium.style(
                  color: PillBinColors.primary,
                  fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
