import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final List<InlineSpan> content;
  final IconData? icon;
  final Color? iconColor;
  final double sw;
  final double sh;
  final String image;
  final bool isTablet;
  final bool isSurvey;

  const InfoCard({
    super.key,
    required this.title,
    required this.content,
    required this.sw,
    required this.sh,
    required this.isTablet,
    this.icon,
    this.iconColor,
    this.isSurvey = false,
    required this.image,
  });

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
            color: (iconColor ?? PillBinColors.primary).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Header Section
          Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.05),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (iconColor ?? PillBinColors.primary).withOpacity(0.1),
                  (iconColor ?? PillBinColors.primary).withOpacity(0.05),
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
                if (icon != null) ...[
                  // Icon
                  Container(
                    padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
                    decoration: BoxDecoration(
                      color: iconColor ?? PillBinColors.primary,
                      borderRadius: BorderRadius.circular(
                          isTablet ? sw * 0.015 : sw * 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: (iconColor ?? PillBinColors.primary)
                              .withOpacity(0.3),
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
                ],

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: PillBinMedium.style(
                      color: PillBinColors.textDark,
                      fontSize: isTablet ? sw * 0.024 : sw * 0.042,
                    ),
                  ),
                ),
              ],
            ),
          ),

          //* Content Section
          Padding(
            padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.05),
            child: isSurvey
                ? _buildSurveyContent(context)
                : _buildRegularContent(context, image),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularContent(BuildContext context, String image) {
    return image == ""
        ? RichText(
            text: TextSpan(
              style: PillBinRegular.style(
                color: PillBinColors.textDark,
                fontSize: isTablet ? sw * 0.02 : sw * 0.035,
              ),
              children: content,
            ),
          )
        : Column(
            children: [
              Image.asset( image),
              SizedBox(height: sh*0.027,),
              RichText(
                text: TextSpan(
                  style: PillBinRegular.style(
                    color: PillBinColors.textDark,
                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                  ),
                  children: content,
                ),
              )
            ],
          );
  }

  Widget _buildSurveyContent(BuildContext context) {
    // Parse survey responses from content
    final text = content.map((span) {
      if (span is TextSpan && span.text != null) {
        return span.text!;
      }
      return '';
    }).join();

    // Split by double newlines to get individual responses
    final responses =
        text.split('\n\n').where((r) => r.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Survey responses grid/list
        ...List.generate(responses.length, (index) {
          final response = responses[index].trim();
          // Remove quotes if present
          final cleanResponse = response
              .replaceAll('"', '')
              .replaceAll('"', '')
              .replaceAll('"', '');

          return Container(
            margin: EdgeInsets.only(
              bottom: index < responses.length - 1 ? sh * 0.02 : 0,
            ),
            padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.045),
            decoration: BoxDecoration(
              color: PillBinColors.background,
              borderRadius:
                  BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.035),
              border: Border.all(
                color: (iconColor ?? PillBinColors.primary).withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote icon and response text
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large quote icon
                    Icon(
                      Icons.format_quote_rounded,
                      color:
                          (iconColor ?? PillBinColors.primary).withOpacity(0.3),
                      size: isTablet ? sw * 0.045 : sw * 0.08,
                    ),
                    SizedBox(width: sw * 0.02),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: sh * 0.005),
                        child: Text(
                          cleanResponse,
                          style: PillBinRegular.style(
                            color: PillBinColors.textDark,
                            fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
