import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/auth/presentation/widgets/complete_profile_widgets.dart';

class UserRegistrationForm extends StatefulWidget {
  const UserRegistrationForm({Key? key}) : super(key: key);

  @override
  State<UserRegistrationForm> createState() => _UserRegistrationFormState();
}

class _UserRegistrationFormState extends State<UserRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentMedicinesController = TextEditingController();
  final _diseasesController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentMedicinesController.dispose();
    _diseasesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? sw * 0.1 : sw * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: sh * 0.00),
                        buildCompleteProfileHeader(sw, sh, isTablet, context),
                        SizedBox(height: sh * 0.02),
                        buildWelcomeCompleteProfileCard(sw, sh, isTablet),
                        SizedBox(height: sh * 0.03),
                        _buildForm(sw, sh, isTablet),
                        SizedBox(height: sh * 0.03),
                        buildCompleteProfileQuickTips(sw, sh, isTablet),
                         SizedBox(height: sh * 0.03),
                        buildCompleteProfileSubmitButton(sw, sh, isTablet,_isLoading,context,_handleSubmit),
                        SizedBox(height: sh * 0.02),
                        buildCompleteProfileCancelButton(sw, sh, isTablet,context),
                        SizedBox(height: sh * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(double sw, double sh, bool isTablet) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            'Full Name',
            'Enter your full name',
            _nameController,
            sw,
            sh,
            isTablet,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(height: sh * 0.02),
          _buildTextField(
            'Email Address',
            'Enter your email (Optional)',
            _emailController,
            sw,
            sh,
            isTablet,
            isRequired: false,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
          ),
          SizedBox(height: sh * 0.02),
          _buildTextField(
            'Current Medicines',
            'List any medicines you\'re currently taking (Optional)',
            _currentMedicinesController,
            sw,
            sh,
            isTablet,
            maxLines: 3,
            isRequired: false,
          ),
          SizedBox(height: sh * 0.02),
          _buildTextField(
            'Medical Conditions',
            'Any ongoing diseases or conditions (Optional)',
            _diseasesController,
            sw,
            sh,
            isTablet,
            maxLines: 3,
            isRequired: false,
          ),
          SizedBox(height: sh * 0.02),
          _buildTextField(
            'Location',
            'Enter your city/area (Optional)',
            _locationController,
            sw,
            sh,
            isTablet,
            isRequired: false,
            suffixIcon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint,
      TextEditingController controller, double sw, double sh, bool isTablet,
      {int maxLines = 1,
      bool isRequired = false,
      TextInputType? keyboardType,
      IconData? suffixIcon,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.textPrimary,
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: sw * 0.01),
              Text(
                '*',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                  color: PillBinColors.error,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: sh * 0.008),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.022 : sw * 0.035,
              color: PillBinColors.textLight,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    color: PillBinColors.textSecondary,
                    size: isTablet ? sw * 0.025 : sw * 0.04,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              borderSide: BorderSide(color: PillBinColors.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              borderSide: BorderSide(color: PillBinColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
            filled: true,
            fillColor: PillBinColors.surface,
          ),
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.022 : sw * 0.035,
            color: PillBinColors.textDark,
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {}
}
