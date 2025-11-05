import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/health_ai/data/repository/health_ai_provider.dart';
import 'package:path/path.dart' as path;

Widget buildHealthAIHeader(BuildContext context, double sw, double sh,
    String user_id, HealthAiProvider provider) {
  final bool isTablet = sw > 600;

  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: PillBinColors.primary,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(isTablet ? 32 : 24),
        bottomRight: Radius.circular(isTablet ? 32 : 24),
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? sw * 0.04 : sw * 0.05,
          vertical: sh * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Back button
                Flexible(
                  child: Text(
                    'Health Report Analysis',
                    style: PillBinBold.style(
                      fontSize: isTablet ? sw * 0.04 : sw * 0.065,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.025),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? sw * 0.02 : sw * 0.025,
                    vertical: sh * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange[300]!,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'EXPERIMENTAL',
                    style: PillBinBold.style(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.026,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.008),
            // Subtitle
            Text(
              'AI-powered analysis of your health reports',
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.036,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: sh * 0.01),
          ],
        ),
      ),
    ),
  );
}

Widget buildUploadedFileBar(double sw, double sh, bool isTablet,
    HealthAiProvider provider, BuildContext context, String user_id) {
  return Container(
    margin: EdgeInsets.symmetric(
      horizontal: isTablet ? sw * 0.025 : sw * 0.04,
      vertical: sh * 0.01,
    ),
    padding: EdgeInsets.all(sw * 0.03),
    decoration: BoxDecoration(
      color: PillBinColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: PillBinColors.primary.withOpacity(0.3),
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(sw * 0.02),
          decoration: BoxDecoration(
            color: PillBinColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.description,
            color: PillBinColors.primary,
            size: isTablet ? sw * 0.022 : sw * 0.04,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                path.basename(provider.file!.path),
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                  color: PillBinColors.textPrimary,
                ),
              ),
              Text(
                'Analyzed successfully',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.016 : sw * 0.026,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: PillBinColors.textSecondary,
            size: isTablet ? sw * 0.02 : sw * 0.035,
          ),
          onPressed: () {
            _showExitWarningDialog(context, sw, sh, user_id, provider);
          },
        ),
      ],
    ),
  );
}

void _showExitWarningDialog(BuildContext context, double sw, double sh,
    String user_id, HealthAiProvider provider) {
  final bool isTablet = sw > 600;
  print("User id is ${user_id}");

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: isTablet ? sw * 0.4 : sw * 0.85,
          padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: isTablet ? sw * 0.05 : sw * 0.12,
                  color: Colors.red.shade600,
                ),
              ),
              SizedBox(height: sh * 0.02),
              // Title
              Text(
                'Remove PDF?',
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.028 : sw * 0.05,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: sh * 0.015),
              // Message
              Text(
                'If you remove the PDF, all of your chat and conversation will end and PDF-related information will be gone.',
                textAlign: TextAlign.center,
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: sh * 0.025),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? sh * 0.015 : sh * 0.012,
                        ),
                        backgroundColor: PillBinColors.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: PillBinBold.style(
                          fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                          color: PillBinColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if (user_id.trim() != "") {
                          provider.deleteFAISSIndex(userId: user_id);
                        }
                        provider.deleteFile();
                        Navigator.of(context).pop(); // Go back from main screen
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? sh * 0.015 : sh * 0.012,
                        ),
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Remove',
                        style: PillBinBold.style(
                          fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
