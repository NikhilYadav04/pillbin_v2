import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class MyPostsCard extends StatelessWidget {
  final double sw;
  final double sh;
  final VoidCallback? onTap;

  const MyPostsCard({
    Key? key,
    required this.sw,
    required this.sh,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.035),
        decoration: BoxDecoration(
          color: PillBinColors.surface,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
              decoration: BoxDecoration(
                color: PillBinColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.article_outlined,
                size: isTablet ? sw * 0.04 : sw * 0.07,
                color: PillBinColors.primary,
              ),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              'My Posts',
              textAlign: TextAlign.center,
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                color: PillBinColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
