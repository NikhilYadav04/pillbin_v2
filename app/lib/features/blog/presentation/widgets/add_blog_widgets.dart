import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class BlogRoleDropdown extends StatelessWidget {
  final String selectedRole;
  final List<String> roles;
  final ValueChanged<String?> onChanged;
  final bool isTablet;
  final double sw;
  final double sh;

  const BlogRoleDropdown({
    Key? key,
    required this.selectedRole,
    required this.roles,
    required this.onChanged,
    required this.isTablet,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'doctor':
        return Icons.medical_services;
      case 'expert':
        return Icons.psychology;
      case 'educator':
        return Icons.school;
      case 'student':
        return Icons.person;
      default:
        return Icons.account_circle;
    }
  }

  String _formatRoleName(String role) {
    return role[0].toUpperCase() + role.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: InputDecoration(
          hintText: 'Select your role',
          hintStyle: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.022 : sw * 0.035,
            color: PillBinColors.textLight,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            borderSide: BorderSide(color: PillBinColors.greyLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            borderSide: BorderSide(color: PillBinColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            borderSide: BorderSide(color: PillBinColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            borderSide: BorderSide(color: PillBinColors.error, width: 2),
          ),
          contentPadding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
          filled: true,
          fillColor: PillBinColors.surface,
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: PillBinColors.textSecondary,
          size: isTablet ? sw * 0.03 : sw * 0.06,
        ),
        style: PillBinRegular.style(
          fontSize: isTablet ? sw * 0.022 : sw * 0.035,
          color: PillBinColors.textDark,
        ),
        items: roles.map((String role) {
          return DropdownMenuItem<String>(
            value: role,
            child: Row(
              children: [
                Icon(
                  _getRoleIcon(role),
                  color: PillBinColors.primary,
                  size: isTablet ? sw * 0.02 : sw * 0.04,
                ),
                SizedBox(width: sw * 0.025),
                Text(
                  _formatRoleName(role),
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                    color: PillBinColors.textDark,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// Helper widget for building tips
Widget buildQuickTips(double sw, double sh, bool isTablet) {
  return Container(
    padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          PillBinColors.primary.withOpacity(0.08),
          PillBinColors.primaryLight.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
      border: Border.all(
        color: PillBinColors.primary.withOpacity(0.2),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: PillBinColors.primary,
              size: isTablet ? sw * 0.025 : sw * 0.045,
            ),
            SizedBox(width: sw * 0.02),
            Text(
              'Quick Tips',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                color: PillBinColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.012),
        _buildTip('✓ Share accurate medical information', sw, isTablet),
        _buildTip('✓ Be clear and concise in your writing', sw, isTablet),
        _buildTip('✓ Include relevant images when possible', sw, isTablet),
      ],
    ),
  );
}

Widget _buildTip(String text, double sw, bool isTablet) {
  return Padding(
    padding: EdgeInsets.only(top: 6),
    child: Text(
      text,
      style: PillBinRegular.style(
        fontSize: isTablet ? sw * 0.018 : sw * 0.032,
        color: PillBinColors.textSecondary,
      ),
    ),
  );
}
