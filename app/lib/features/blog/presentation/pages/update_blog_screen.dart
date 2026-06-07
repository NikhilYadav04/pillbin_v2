import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/blog/data/repository/blog_provider.dart';
import 'package:pillbin/features/blog/presentation/widgets/add_blog_widgets.dart';
import 'package:pillbin/network/models/blog_model.dart';
import 'package:provider/provider.dart';

class UpdateBlogPostScreen extends StatefulWidget {
  final BlogModel blog;

  const UpdateBlogPostScreen({Key? key, required this.blog}) : super(key: key);

  @override
  State<UpdateBlogPostScreen> createState() => _UpdateBlogPostScreenState();
}

class _UpdateBlogPostScreenState extends State<UpdateBlogPostScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late TextEditingController _contentController;
  late TextEditingController _experienceController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  String _selectedRole = 'normal';
  final List<String> _roles = [
    'normal',
    'doctor',
    'expert',
    'educator',
    'student'
  ];

  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Pre-fill fields from existing blog data
    _contentController = TextEditingController(text: widget.blog.content);
    _experienceController =
        TextEditingController(text: widget.blog.experience ?? '');
    _phoneController = TextEditingController(text: widget.blog.phone ?? '');
    _emailController = TextEditingController(text: widget.blog.email ?? '');
    _selectedRole = widget.blog.role;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contentController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      CustomSnackBar.show(
        context: context,
        icon: Icons.error_outline,
        title: "Please fix the errors above",
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final blogProvider = Provider.of<BlogProvider>(context, listen: false);

      final result = await blogProvider.updateBlog(
        context: context,
        blogId: widget.blog.id,
        content: _contentController.text.trim(),
        role: _selectedRole,
        experience: _experienceController.text.trim().isEmpty
            ? null
            : _experienceController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (result == 'success') {
          Navigator.pop(context, true);
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      Logger().e(e.toString());
      if (mounted) {
        setState(() => _isSubmitting = false);
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "An error occurred",
          subtitle: "Please try again",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? sw * 0.05 : sw * 0.04),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(sw, sh, isTablet),
                  SizedBox(height: sh * 0.04),
                  _buildRoleSection(sw, sh, isTablet),
                  SizedBox(height: sh * 0.02),
                  _buildTextField(
                    label: 'Blog Content',
                    hint: 'Share your medical knowledge and experience...',
                    controller: _contentController,
                    sw: sw,
                    sh: sh,
                    isTablet: isTablet,
                    maxLines: 8,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter blog content';
                      }
                      if (value.length > 10000) {
                        return 'Content must be less than 10,000 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: sh * 0.02),
                  _buildTextField(
                    label: 'Experience',
                    hint: 'Brief description of your experience (optional)',
                    controller: _experienceController,
                    sw: sw,
                    sh: sh,
                    isTablet: isTablet,
                    maxLines: 3,
                    isRequired: false,
                    validator: (value) {
                      if (value != null && value.length > 500) {
                        return 'Experience must be less than 500 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: sh * 0.02),
                  _buildTextField(
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    controller: _phoneController,
                    sw: sw,
                    sh: sh,
                    isTablet: isTablet,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.length > 20) {
                        return 'Phone number must be less than 20 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: sh * 0.02),
                  _buildTextField(
                    label: 'Email Address',
                    hint: 'Enter your email address',
                    controller: _emailController,
                    sw: sw,
                    sh: sh,
                    isTablet: isTablet,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      if (value != null && value.length > 100) {
                        return 'Email must be less than 100 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: sh * 0.04),
                  _buildSubmitButton(sw, sh, isTablet),
                  SizedBox(height: sh * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(double sw, double sh, bool isTablet) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.015 : sw * 0.02),
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PillBinColors.greyLight),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: isTablet ? sw * 0.02 : sw * 0.04,
              color: PillBinColors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Blog Post',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.032 : sw * 0.055,
                  color: PillBinColors.textPrimary,
                ),
              ),
              SizedBox(height: sh * 0.005),
              Text(
                'Update your post details',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSection(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Your Role',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.textPrimary,
              ),
            ),
            SizedBox(width: sw * 0.01),
            Text(
              '*',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.008),
        BlogRoleDropdown(
          selectedRole: _selectedRole,
          roles: _roles,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedRole = newValue;
              });
            }
          },
          isTablet: isTablet,
          sw: sw,
          sh: sh,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required double sw,
    required double sh,
    required bool isTablet,
    int maxLines = 1,
    bool isRequired = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
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
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.022 : sw * 0.035,
            color: PillBinColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(double sw, double sh, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: _isSubmitting
              ? [
                  PillBinColors.primary.withOpacity(0.8),
                  PillBinColors.primaryLight.withOpacity(0.8),
                ]
              : [
                  PillBinColors.primary,
                  PillBinColors.primaryLight,
                ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: PillBinColors.primary.withOpacity(_isSubmitting ? 0.3 : 0.4),
            blurRadius: isTablet ? 14 : 12,
            offset: Offset(0, isTablet ? 5 : 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          onTap: _isSubmitting ? null : _submitUpdate,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? sh * 0.025 : sh * 0.02,
              horizontal: isTablet ? sw * 0.03 : sw * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting)
                  SizedBox(
                    width: isTablet ? sw * 0.025 : sw * 0.04,
                    height: isTablet ? sw * 0.025 : sw * 0.04,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    Icons.save,
                    color: Colors.white,
                    size: isTablet ? sw * 0.025 : sw * 0.05,
                  ),
                SizedBox(width: sw * 0.03),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _isSubmitting ? 'Saving...' : 'Save Changes',
                    key: ValueKey(_isSubmitting),
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                      color: Colors.white,
                    ),
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
