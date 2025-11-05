import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:url_launcher/url_launcher.dart';

class KnowMoreCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Map<String, String?>> links;
  final double sw;
  final double sh;
  final bool isTablet;

  const KnowMoreCategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.links,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.03 : sw * 0.05,
        vertical: sh * 0.015,
      ),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.025 : sw * 0.05),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.05),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.1),
                  iconColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isTablet ? sw * 0.025 : sw * 0.05),
                topRight: Radius.circular(isTablet ? sw * 0.025 : sw * 0.05),
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(
                        isTablet ? sw * 0.015 : sw * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isTablet ? sw * 0.032 : sw * 0.06,
                  ),
                ),
                SizedBox(width: sw * 0.035),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: PillBinMedium.style(
                          color: PillBinColors.textDark,
                          fontSize: isTablet ? sw * 0.024 : sw * 0.042,
                        ),
                      ),
                      SizedBox(height: sh * 0.004),
                      Text(
                        subtitle,
                        style: PillBinRegular.style(
                          color: PillBinColors.textSecondary,
                          fontSize: isTablet ? sw * 0.019 : sw * 0.034,
                        ),
                      ),
                    ],
                  ),
                ),

                // Count Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? sw * 0.015 : sw * 0.025,
                    vertical: isTablet ? sh * 0.006 : sh * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: BorderRadius.circular(
                        isTablet ? sw * 0.015 : sw * 0.025),
                  ),
                  child: Text(
                    '${links.length}',
                    style: PillBinMedium.style(
                      color: Colors.white,
                      fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Links Section
          Padding(
            padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
            child: Column(
              children: List.generate(links.length, (index) {
                final link = links[index];
                final linkText = link['text'] ?? '';
                final linkUrl = link['url'] ?? '';

                return Container(
                  margin: EdgeInsets.only(
                    bottom: index < links.length - 1 ? sh * 0.012 : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _launchURL(linkUrl),
                      borderRadius: BorderRadius.circular(
                          isTablet ? sw * 0.015 : sw * 0.03),
                      splashColor: iconColor.withOpacity(0.1),
                      highlightColor: iconColor.withOpacity(0.05),
                      child: Container(
                        padding:
                            EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
                        decoration: BoxDecoration(
                          color: PillBinColors.background,
                          borderRadius: BorderRadius.circular(
                              isTablet ? sw * 0.015 : sw * 0.03),
                          border: Border.all(
                            color: iconColor.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Link icon
                            Container(
                              padding: EdgeInsets.all(
                                  isTablet ? sw * 0.012 : sw * 0.02),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(
                                    isTablet ? sw * 0.01 : sw * 0.018),
                              ),
                              child: Icon(
                                Icons.open_in_new_rounded,
                                color: iconColor,
                                size: isTablet ? sw * 0.022 : sw * 0.04,
                              ),
                            ),
                            SizedBox(width: sw * 0.035),

                            // Link text
                            Expanded(
                              child: Text(
                                linkText,
                                style: PillBinRegular.style(
                                  color: PillBinColors.textDark,
                                  fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            SizedBox(width: sw * 0.02),

                            // Arrow icon
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: iconColor.withOpacity(0.6),
                              size: isTablet ? sw * 0.02 : sw * 0.035,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
