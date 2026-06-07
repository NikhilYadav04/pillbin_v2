import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/blog/data/repository/blog_provider.dart';
import 'package:pillbin/features/blog/presentation/widgets/add_blog_widgets.dart';
import 'package:pillbin/features/blog/presentation/widgets/ai_image_generator_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:provider/provider.dart';

class AddBlogPostScreen extends StatefulWidget {
  const AddBlogPostScreen({Key? key}) : super(key: key);

  @override
  State<AddBlogPostScreen> createState() => _AddBlogPostScreenState();
}

class _AddBlogPostScreenState extends State<AddBlogPostScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _selectedRole = 'normal';
  final List<String> _roles = [
    'normal',
    'doctor',
    'expert',
    'educator',
    'student'
  ];

  List<File> _selectedImages = [];

  // Toggle for using profile data
  bool _useProfilePhone = false;
  bool _useProfileEmail = false;
  bool _useProfileName = false;

  bool _isSubmitting = false;

  // Animation controllers for buttons
  late AnimationController _saveAnimationController;
  late AnimationController _aiAnimationController;
  late Animation<double> _saveScaleAnimation;
  late Animation<double> _saveOpacityAnimation;
  late Animation<double> _aiPulseAnimation;

  final _formKey = GlobalKey<FormState>();

  // User profile data (fetched from user provider)
  String? _userProfilePhone;
  String? _userProfileEmail;
  String? _userProfileName;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _aiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _saveScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.easeInOut,
    ));

    _saveOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.easeInOut,
    ));

    _aiPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _aiAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Start AI button pulse animation
    _aiAnimationController.repeat(reverse: true);

    // Load user profile data on init
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _userProfilePhone = userProvider.user?.phoneNumber;
    _userProfileEmail = userProvider.user?.email;

    // // Mock data for now
    // _userProfilePhone = "+1234567890";
    // _userProfileEmail = "user@example.com";
  }

  /// Fetch phone from user profile when toggle is enabled
  void _fetchProfilePhone() {
    if (_useProfilePhone) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _userProfilePhone = userProvider.user?.phoneNumber;

      if (_userProfilePhone == null || _userProfilePhone!.isEmpty) {
        setState(() {
          _useProfilePhone = false;
        });
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "Phone not found",
          subtitle: "Please add phone number to your profile or enter manually",
        );
      } else {
        CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle,
          title: "Phone loaded",
          subtitle: "Using $_userProfilePhone",
        );
      }
    }
  }

  //* Fetch email from user profile when toggle is enabled
  void _fetchProfileEmail() {
    if (_useProfileEmail) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _userProfileEmail = userProvider.user?.email;

      if (_userProfileEmail == null || _userProfileEmail!.isEmpty) {
        setState(() {
          _useProfileEmail = false;
        });
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "Email not found",
          subtitle: "Please add email to your profile or enter manually",
        );
      } else {
        CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle,
          title: "Email loaded",
          subtitle: "Using $_userProfileEmail",
        );
      }
    }
  }

  void _fetchProfileName() {
    if (_useProfileName) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _userProfileName = userProvider.user?.fullName;

      if (_userProfileName == null || _userProfileName!.isEmpty) {
        setState(() {
          _useProfileName = false;
        });
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "Name not found",
          subtitle: "Please add name to your profile or enter manually",
        );
      } else {
        CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle,
          title: "Name loaded",
          subtitle: "Using $_userProfileEmail",
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _saveAnimationController.dispose();
    _aiAnimationController.dispose();
    _contentController.dispose();
    _experienceController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    if (_selectedImages.length >= 2) {
      CustomSnackBar.show(
        context: context,
        icon: Icons.error_outline,
        title: "Maximum 2 images allowed",
      );
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      // CRITICAL: Add this delay to prevent crash
      await Future.delayed(const Duration(milliseconds: 300));

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: PillBinColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        setState(() {
          _selectedImages.add(File(croppedFile.path));
        });
        CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle,
          title: "Image added successfully",
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "Failed to add image",
          subtitle: e.toString(),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    CustomSnackBar.show(
      context: context,
      icon: Icons.delete,
      title: "Image removed",
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.add_a_photo,
                color: PillBinColors.primary,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Add Image',
                style: PillBinMedium.style(
                  fontSize: 20,
                  color: PillBinColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: PillBinColors.primary),
                title: Text(
                  'Take Photo',
                  style: PillBinRegular.style(
                    fontSize: 16,
                    color: PillBinColors.textDark,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndCropImage(ImageSource.camera);
                },
              ),
              Divider(),
              ListTile(
                leading:
                    Icon(Icons.photo_library, color: PillBinColors.primary),
                title: Text(
                  'Choose from Gallery',
                  style: PillBinRegular.style(
                    fontSize: 16,
                    color: PillBinColors.textDark,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndCropImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: PillBinMedium.style(
                  fontSize: 16,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAIImageGeneratorDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AIImageGeneratorDialog(),
    );

    if (result != null && result.isNotEmpty && _selectedImages.length < 2) {
      // Convert base64 to File and add to _selectedImages
      try {
        final imageBytes = base64Decode(result);
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${tempDir.path}/ai_generated_$timestamp.png');
        await file.writeAsBytes(imageBytes);

        if (mounted) {
          setState(() {
            _selectedImages.add(file);
          });
          CustomSnackBar.show(
            context: context,
            icon: Icons.auto_awesome,
            title: "AI image added to your post!",
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error_outline,
            title: "Failed to add AI image",
            subtitle: e.toString(),
          );
        }
      }
    }
  }

  Future<void> _submitBlogPost() async {
    if (!_formKey.currentState!.validate()) {
      CustomSnackBar.show(
        context: context,
        icon: Icons.error_outline,
        title: "Please fix the errors above",
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      CustomSnackBar.show(
        context: context,
        icon: Icons.error_outline,
        title: "Please enter blog content",
      );
      return;
    }

    // Get phone number (from profile or manual entry)
    String phoneNumber;
    if (_useProfilePhone) {
      if (_userProfilePhone == null || _userProfilePhone!.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "Profile phone number not found",
          subtitle: "Please enter manually",
        );
        return;
      }
      phoneNumber = _userProfilePhone!;
    } else {
      if (_phoneController.text.trim().isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "Please enter your phone number",
        );
        return;
      }
      phoneNumber = _phoneController.text.trim();
    }

    // Get email (from profile or manual entry)
    String email;
    if (_useProfileEmail) {
      if (_userProfileEmail == null || _userProfileEmail!.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "Profile email not found",
          subtitle: "Please enter manually",
        );
        return;
      }
      email = _userProfileEmail!;
    } else {
      if (_emailController.text.trim().isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "Please enter your email",
        );
        return;
      }
      email = _emailController.text.trim();
    }

    String name;
    if (_useProfileName) {
      if (_userProfileName == null || _userProfileName!.isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "Profile name not found",
          subtitle: "Please enter manually",
        );
        return;
      }
      name = _userProfileName!;
    } else {
      if (_nameController.text.trim().isEmpty) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: "Please enter your name",
        );
        return;
      }
      name = _nameController.text.trim();
    }

    setState(() {
      _isSubmitting = true;
    });

    _saveAnimationController.forward();

    try {
      final blogProvider = Provider.of<BlogProvider>(context, listen: false);

      String result;

      // Check if there are images
      if (_selectedImages.isEmpty) {
        // Create blog without images
        result = await blogProvider.createBlog(
            context: context,
            content: _contentController.text.trim(),
            role: _selectedRole,
            experience: _experienceController.text.trim(),
            phone: phoneNumber,
            email: email,
            name: name);
      } else {
        // Create blog with images
        result = await blogProvider.createBlogWithImages(
            context: context,
            content: _contentController.text.trim(),
            role: _selectedRole,
            experience: _experienceController.text.trim(),
            phone: phoneNumber,
            email: email,
            images: _selectedImages,
            name: name);
      }

      _saveAnimationController.reverse();

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (result == 'success') {
          // Navigate back to previous screen
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          // Show error if result is not success
          CustomSnackBar.show(
            context: context,
            icon: Icons.error_outline,
            title: "Failed to publish",
            subtitle: "Please try again",
          );
        }
      }
    } catch (e) {
      _saveAnimationController.reverse();

      setState(() {
        _isSubmitting = false;
      });

      Logger().e(e.toString());

      if (mounted) {
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
                  _buildMediaSection(sw, sh, isTablet),
                  SizedBox(height: sh * 0.04),
                  _buildRoleSection(sw, sh, isTablet),
                  SizedBox(height: sh * 0.02),
                  _buildTextField(
                    'Blog Content',
                    'Share your medical knowledge and experience...',
                    _contentController,
                    sw,
                    sh,
                    isTablet,
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
                    'Experience',
                    'Brief description of your experience (optional)',
                    _experienceController,
                    sw,
                    sh,
                    isTablet,
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
                  _buildNameField(sw, sh, isTablet),
                  SizedBox(height: sh * 0.02),
                  _buildPhoneField(sw, sh, isTablet),
                  SizedBox(height: sh * 0.02),
                  _buildEmailField(sw, sh, isTablet),
                  SizedBox(height: sh * 0.02),
                  buildQuickTips(sw, sh, isTablet),
                  SizedBox(height: sh * 0.04),
                  _buildAnimatedSubmitButton(sw, sh, isTablet),
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
                'Create Blog Post',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.032 : sw * 0.055,
                  color: PillBinColors.textPrimary,
                ),
              ),
              SizedBox(height: sh * 0.005),
              Text(
                'Share your knowledge with the community',
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

  Widget _buildMediaSection(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Media',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.textPrimary,
              ),
            ),
            SizedBox(width: sw * 0.02),
            Text(
              '(Up to 2 images)',
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                color: PillBinColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.015),
        if (_selectedImages.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: sw * 0.03,
              mainAxisSpacing: sh * 0.015,
              childAspectRatio: 1,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    child: Image.file(
                      _selectedImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: isTablet ? 12 : 8,
                    right: isTablet ? 12 : 8,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 6 : 4),
                        decoration: BoxDecoration(
                          color: PillBinColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: isTablet ? sw * 0.018 : sw * 0.035,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: sh * 0.02),
        ],
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildAddMediaButton(sw, sh, isTablet),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              flex: 2,
              child: _buildAIButton(sw, sh, isTablet),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddMediaButton(double sw, double sh, bool isTablet) {
    final isDisabled = _selectedImages.length >= 2;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDisabled
            ? PillBinColors.surface.withOpacity(0.5)
            : PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        border: Border.all(
          color: isDisabled
              ? PillBinColors.greyLight.withOpacity(0.5)
              : PillBinColors.greyLight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          onTap: isDisabled ? null : _showImageSourceDialog,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? sh * 0.018 : sh * 0.015,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  color: isDisabled
                      ? PillBinColors.textSecondary.withOpacity(0.5)
                      : PillBinColors.primary,
                  size: isTablet ? sw * 0.022 : sw * 0.045,
                ),
                SizedBox(width: sw * 0.02),
                Text(
                  'Add Media',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                    color: isDisabled
                        ? PillBinColors.textSecondary.withOpacity(0.5)
                        : PillBinColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIButton(double sw, double sh, bool isTablet) {
    return AnimatedBuilder(
      animation: _aiAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _aiPulseAnimation.value,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PillBinColors.primary,
                  PillBinColors.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              boxShadow: [
                BoxShadow(
                  color: PillBinColors.primary.withOpacity(0.3),
                  blurRadius: isTablet ? 10 : 8,
                  offset: Offset(0, isTablet ? 5 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                onTap: _showAIImageGeneratorDialog,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? sh * 0.018 : sh * 0.015,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: isTablet ? sw * 0.022 : sw * 0.045,
                      ),
                      SizedBox(width: sw * 0.015),
                      Text(
                        'AI Gen',
                        style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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

  Widget _buildNameField(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Enter Your Name',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.textPrimary,
              ),
            ),
            if (!_useProfileName) ...[
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

        /// Checkbox Row
        Row(
          children: [
            Transform.scale(
              scale: isTablet ? 0.9 : 1.0,
              child: Checkbox(
                value: _useProfileName,
                onChanged: (value) {
                  setState(() {
                    _useProfileName = value ?? false;
                  });
                  _fetchProfileName(); // Fetch name when enabled
                },
                activeColor: PillBinColors.primary,
              ),
            ),
            Expanded(
              child: Text(
                'Use name from my profile',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ),
          ],
        ),

        /// If NOT using profile name → Show TextField
        if (!_useProfileName) ...[
          SizedBox(height: sh * 0.008),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              validator: (value) {
                if (!_useProfileName && (value == null || value.isEmpty)) {
                  return 'Please enter your name';
                }
                if (value != null && value.length > 50) {
                  return 'Name must be less than 50 characters';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter your full name',
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
                  borderSide:
                      BorderSide(color: PillBinColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  borderSide: BorderSide(color: PillBinColors.error, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  borderSide: BorderSide(color: PillBinColors.error, width: 2),
                ),
                contentPadding:
                    EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
                filled: true,
                fillColor: PillBinColors.surface,
              ),
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                color: PillBinColors.textDark,
              ),
            ),
          ),
        ]

        /// If using profile name → Show Container
        else
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
            decoration: BoxDecoration(
              color: PillBinColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              border: Border.all(
                color: PillBinColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: PillBinColors.primary,
                  size: isTablet ? sw * 0.02 : sw * 0.04,
                ),
                SizedBox(width: sw * 0.02),
                Expanded(
                  child: Text(
                    _userProfileName != null
                        ? 'Using: $_userProfileName'
                        : 'Using profile name',
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                      color: PillBinColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneField(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Phone Number',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.textPrimary,
              ),
            ),
            if (!_useProfilePhone) ...[
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
        Row(
          children: [
            Transform.scale(
              scale: isTablet ? 0.9 : 1.0,
              child: Checkbox(
                value: _useProfilePhone,
                onChanged: (value) {
                  setState(() {
                    _useProfilePhone = value ?? false;
                  });
                  _fetchProfilePhone(); // Fetch phone when toggle is enabled
                },
                activeColor: PillBinColors.primary,
              ),
            ),
            Expanded(
              child: Text(
                'Use phone number from my profile',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        if (!_useProfilePhone) ...[
          SizedBox(height: sh * 0.008),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (!_useProfilePhone && (value == null || value.isEmpty)) {
                  return 'Please enter your phone number';
                }
                if (value != null && value.length > 20) {
                  return 'Phone number must be less than 20 characters';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter your phone number',
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
                  borderSide:
                      BorderSide(color: PillBinColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  borderSide: BorderSide(color: PillBinColors.error, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  borderSide: BorderSide(color: PillBinColors.error, width: 2),
                ),
                contentPadding:
                    EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
                filled: true,
                fillColor: PillBinColors.surface,
              ),
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                color: PillBinColors.textDark,
              ),
            ),
          ),
        ] else
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
            decoration: BoxDecoration(
              color: PillBinColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              border: Border.all(
                color: PillBinColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: PillBinColors.primary,
                  size: isTablet ? sw * 0.02 : sw * 0.04,
                ),
                SizedBox(width: sw * 0.02),
                Expanded(
                  child: Text(
                    _userProfilePhone != null
                        ? 'Using: $_userProfilePhone'
                        : 'Using profile phone number',
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                      color: PillBinColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmailField(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Email Address',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.textPrimary,
              ),
            ),
            if (!_useProfileEmail) ...[
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
        Row(
          children: [
            Transform.scale(
              scale: isTablet ? 0.9 : 1.0,
              child: Checkbox(
                value: _useProfileEmail,
                onChanged: (value) {
                  setState(() {
                    _useProfileEmail = value ?? false;
                  });
                  _fetchProfileEmail(); // Fetch email when toggle is enabled
                },
                activeColor: PillBinColors.primary,
              ),
            ),
            Expanded(
              child: Text(
                'Use email from my profile',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        if (!_useProfileEmail) ...[
          SizedBox(height: sh * 0.008),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (!_useProfileEmail && (value == null || value.isEmpty)) {
                  return 'Please enter your email';
                }
                if (value != null &&
                    !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                if (value != null && value.length > 100) {
                  return 'Email must be less than 100 characters';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter your email address',
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
                  borderSide:
                      BorderSide(color: PillBinColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  borderSide: BorderSide(color: PillBinColors.error, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  borderSide: BorderSide(color: PillBinColors.error, width: 2),
                ),
                contentPadding:
                    EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
                filled: true,
                fillColor: PillBinColors.surface,
              ),
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                color: PillBinColors.textDark,
              ),
            ),
          ),
        ] else
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
            decoration: BoxDecoration(
              color: PillBinColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              border: Border.all(
                color: PillBinColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: PillBinColors.primary,
                  size: isTablet ? sw * 0.02 : sw * 0.04,
                ),
                SizedBox(width: sw * 0.02),
                Expanded(
                  child: Text(
                    _userProfileEmail != null
                        ? 'Using: $_userProfileEmail'
                        : 'Using profile email',
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                      color: PillBinColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    double sw,
    double sh,
    bool isTablet, {
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: TextFormField(
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
        ),
      ],
    );
  }

  Widget _buildAnimatedSubmitButton(double sw, double sh, bool isTablet) {
    return AnimatedBuilder(
      animation: _saveAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSubmitting ? _saveScaleAnimation.value : 1.0,
          child: Container(
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
                  color: PillBinColors.primary
                      .withOpacity(_isSubmitting ? 0.3 : 0.4),
                  blurRadius: _isSubmitting
                      ? (isTablet ? 10 : 8)
                      : (isTablet ? 14 : 12),
                  offset: Offset(0, isTablet ? 5 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                onTap: _isSubmitting ? null : _submitBlogPost,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? sh * 0.025 : sh * 0.02,
                    horizontal: isTablet ? sw * 0.03 : sw * 0.05,
                  ),
                  child: AnimatedOpacity(
                    opacity: _isSubmitting ? _saveOpacityAnimation.value : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSubmitting) ...[
                          SizedBox(
                            width: isTablet ? sw * 0.025 : sw * 0.04,
                            height: isTablet ? sw * 0.025 : sw * 0.04,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          ),
                        ] else
                          Icon(
                            Icons.send,
                            color: Colors.white,
                            size: isTablet ? sw * 0.025 : sw * 0.05,
                          ),
                        SizedBox(width: sw * 0.03),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _isSubmitting ? 'Publishing...' : 'Publish Post',
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
            ),
          ),
        );
      },
    );
  }
}
