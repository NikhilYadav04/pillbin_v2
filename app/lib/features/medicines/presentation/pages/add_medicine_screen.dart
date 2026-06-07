import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pillbin/config/notifications/notification_config.dart';
import 'package:pillbin/config/notifications/notification_helper.dart';
import 'package:pillbin/config/notifications/notification_model.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/medicines/data/helper/ocr_helper.dart';
import 'package:pillbin/features/medicines/data/repository/medicine_provider.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/features/medicines/presentation/widgets/add_medicine_widgets.dart';
import 'package:provider/provider.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({Key? key}) : super(key: key);

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  //* For OCR ( Image or file )
  File? file;

  //* For medicine photo upload
  File? medicinePhoto;

  // Animation controllers for buttons
  late AnimationController _saveAnimationController;
  late AnimationController _scanAnimationController;
  late Animation<double> _saveScaleAnimation;
  late Animation<double> _saveOpacityAnimation;
  late Animation<double> _scanPulseAnimation;

  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _batchNumberController = TextEditingController();

  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));
  DateTime _purchaseDate = DateTime.now();
  String? _selectedMedicineType;

  // Common medicine types
  final List<String> _medicineTypes = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Cream/Ointment',
    'Drops',
    'Inhaler',
    'Patch',
    'Powder',
    'Gel',
    'Spray',
    'Lotion',
    'Suspension',
    'Suppository',
    'Other'
  ];

  bool _isSaving = false;
  bool _isScanning = false;

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

    // Initialize button animation controllers
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scanAnimationController = AnimationController(
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

    _scanPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _scanAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _saveAnimationController.dispose();
    _scanAnimationController.dispose();
    _medicineNameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _manufacturerController.dispose();
    _batchNumberController.dispose();
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? sw * 0.05 : sw * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sh * 0.00),
                buildAddMedsTitle(sw, sh, isTablet, context),
                SizedBox(height: sh * 0.04),
                _buildAnimatedScanOption(sw, sh, isTablet),
                SizedBox(height: sh * 0.04),
                _buildMedicinePhotoSection(
                    sw, sh, isTablet), // NEW: Photo section
                SizedBox(height: sh * 0.04),
                _buildForm(sw, sh, isTablet),
                SizedBox(height: sh * 0.04),
                buildQuickTips(sw, sh, isTablet),
                SizedBox(height: sh * 0.04),
                _buildAnimatedActionButtons(sw, sh, isTablet),
                SizedBox(height: sh * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// NEW: Medicine Photo Section with Add/Edit/Remove functionality
  Widget _buildMedicinePhotoSection(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Medicine Photo',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.textPrimary,
              ),
            ),
            SizedBox(width: sw * 0.02),
            Text(
              '(Optional)',
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                color: PillBinColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: sh * 0.015),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(
              color: PillBinColors.greyLight,
              width: 1,
            ),
          ),
          child: medicinePhoto != null
              ? _buildPhotoPreview(sw, sh, isTablet)
              : _buildAddPhotoButton(sw, sh, isTablet),
        ),
      ],
    );
  }

  /// Photo preview with edit/remove options
  Widget _buildPhotoPreview(double sw, double sh, bool isTablet) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isTablet ? 16 : 12),
            topRight: Radius.circular(isTablet ? 16 : 12),
          ),
          child: Image.file(
            medicinePhoto!,
            height: sh * 0.25,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showPhotoSourceDialog,
                  icon: Icon(
                    Icons.edit,
                    size: isTablet ? sw * 0.02 : sw * 0.04,
                    color: PillBinColors.primary,
                  ),
                  label: Text(
                    'Change Photo',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                      color: PillBinColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: PillBinColors.primary),
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? sh * 0.015 : sh * 0.012,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.02),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    medicinePhoto = null;
                  });
                },
                icon: Icon(
                  Icons.delete_outline,
                  size: isTablet ? sw * 0.02 : sw * 0.04,
                  color: PillBinColors.error,
                ),
                label: Text(
                  'Remove',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                    color: PillBinColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: PillBinColors.error),
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? sh * 0.015 : sh * 0.012,
                    horizontal: isTablet ? sw * 0.02 : sw * 0.03,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Add photo button
  Widget _buildAddPhotoButton(double sw, double sh, bool isTablet) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        onTap: _showPhotoSourceDialog,
        child: Padding(
          padding: EdgeInsets.all(isTablet ? sw * 0.05 : sw * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
                decoration: BoxDecoration(
                  color: PillBinColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_photo_alternate,
                  size: isTablet ? sw * 0.04 : sw * 0.08,
                  color: PillBinColors.primary,
                ),
              ),
              SizedBox(height: sh * 0.015),
              Text(
                'Add Medicine Photo',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                  color: PillBinColors.primary,
                ),
              ),
              SizedBox(height: sh * 0.005),
              Text(
                'Tap to choose from gallery or camera',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show dialog to choose photo source
  void _showPhotoSourceDialog() {
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
                'Add Photo',
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
                  _pickAndCropMedicinePhoto(ImageSource.camera);
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
                  _pickAndCropMedicinePhoto(ImageSource.gallery);
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

  /// Pick and crop medicine photo
  Future<void> _pickAndCropMedicinePhoto(ImageSource source) async {
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
            toolbarTitle: 'Crop Medicine Photo',
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
            title: 'Crop Medicine Photo',
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
          medicinePhoto = File(croppedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo added successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add photo: ${e.toString()}'),
            backgroundColor: PillBinColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickImageAndScan() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      setState(() {
        file = File(image.path);
      });

      // Show option to scan the image
      _showScanConfirmDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture image: ${e.toString()}'),
          backgroundColor: PillBinColors.error,
        ),
      );
    }
  }

  Widget _buildAnimatedScanOption(double sw, double sh, bool isTablet) {
    return AnimatedBuilder(
      animation: _scanAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isScanning ? _scanPulseAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PillBinColors.primary.withOpacity(_isScanning ? 0.1 : 0.15),
                  PillBinColors.primaryLight
                      .withOpacity(_isScanning ? 0.05 : 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              border: Border.all(
                color:
                    PillBinColors.primary.withOpacity(_isScanning ? 0.3 : 0.2),
                width: _isScanning ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                onTap: _isScanning ? null : _pickImageAndScan,
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.05),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                                isTablet ? sw * 0.015 : sw * 0.02),
                            decoration: BoxDecoration(
                              color: PillBinColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isScanning
                                  ? SizedBox(
                                      width: isTablet ? sw * 0.025 : sw * 0.04,
                                      height: isTablet ? sw * 0.025 : sw * 0.04,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          PillBinColors.primary,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.qr_code_scanner,
                                      color: PillBinColors.primary,
                                      size: isTablet ? sw * 0.025 : sw * 0.04,
                                    ),
                            ),
                          ),
                          SizedBox(width: sw * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isScanning ? 'Scanning...' : 'Scan Medicine',
                                  style: PillBinMedium.style(
                                    fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                                    color: PillBinColors.primary,
                                  ),
                                ),
                                SizedBox(height: sh * 0.005),
                                Text(
                                  _isScanning
                                      ? 'Please wait while we scan'
                                      : 'Use camera to auto-fill information',
                                  style: PillBinRegular.style(
                                    fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                                    color: PillBinColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (file != null) ...[
                        SizedBox(height: sh * 0.015),
                        Container(
                          height: sh * 0.08,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: PillBinColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Image.file(
                                    file!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: PillBinColors.error,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      file = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  void _showScanConfirmDialog() {
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
                Icons.image_search,
                color: PillBinColors.primary,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Scan Image',
                style: PillBinMedium.style(
                  fontSize: 20,
                  color: PillBinColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Do you want to scan this image to auto-fill medicine details?',
            style: PillBinRegular.style(
              fontSize: 16,
              color: PillBinColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  file = null;
                });
              },
              child: Text(
                'Cancel',
                style: PillBinMedium.style(
                  fontSize: 16,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _scanMedicine();
              },
              child: Text(
                'Scan Now',
                style: PillBinMedium.style(
                  fontSize: 16,
                  color: PillBinColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  //* Perform OCR scanning
  void _scanMedicine() async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please capture an image first'),
          backgroundColor: PillBinColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
    });

    _scanAnimationController.repeat(reverse: true);

    try {
      Map<String, String> extractedFields =
          await MedicineOCRHelper.performOCR(file!);

      _scanAnimationController.stop();
      _scanAnimationController.reset();

      setState(() {
        _isScanning = false;
      });

      if (extractedFields.isNotEmpty) {
        _populateFormFromOCR(extractedFields);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully extracted medicine information!',
              style: PillBinRegular.style(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not extract medicine information. Please fill manually.',
              style: PillBinRegular.style(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _scanAnimationController.stop();
      _scanAnimationController.reset();

      setState(() {
        _isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Scanning failed: ${e.toString()}',
            style: PillBinRegular.style(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          backgroundColor: PillBinColors.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  //* Add this new method to populate form fields
  void _populateFormFromOCR(Map<String, String> fields) {
    setState(() {
      if (fields['name']?.isNotEmpty ?? false) {
        _medicineNameController.text = fields['name']!;
      }

      if (fields['type']?.isNotEmpty ?? false) {
        String extractedType = fields['type']!;
        if (_medicineTypes.contains(extractedType)) {
          _selectedMedicineType = extractedType;
        }
      }

      if (fields['quantity']?.isNotEmpty ?? false) {
        _quantityController.text = fields['quantity']!;
      }

      if (fields['manufacturer']?.isNotEmpty ?? false) {
        _manufacturerController.text = fields['manufacturer']!;
      }

      if (fields['batchNumber']?.isNotEmpty ?? false) {
        _batchNumberController.text = fields['batchNumber']!;
      }

      if (fields['expiryDate']?.isNotEmpty ?? false) {
        DateTime? parsedExpiry =
            MedicineOCRHelper.parseExtractedDate(fields['expiryDate']!);
        if (parsedExpiry != null) {
          _expiryDate = parsedExpiry;
        }
      }

      if (fields['purchaseDate']?.isNotEmpty ?? false) {
        DateTime? parsedPurchase =
            MedicineOCRHelper.parseExtractedDate(fields['purchaseDate']!);
        if (parsedPurchase != null) {
          _purchaseDate = parsedPurchase;
        }
      }
    });
  }

  Widget _buildForm(double sw, double sh, bool isTablet) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            'Medicine Name',
            'Enter medicine name',
            _medicineNameController,
            sw,
            sh,
            isTablet,
            isRequired: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter medicine name';
              }
              return null;
            },
          ),
          SizedBox(height: sh * 0.02),
          _buildMedicineTypeDropdown(sw, sh, isTablet),
          SizedBox(height: sh * 0.02),
          _buildDatePicker(
            'Purchase Date',
            _purchaseDate,
            (date) => setState(() => _purchaseDate = date),
            sw,
            sh,
            isTablet,
            isRequired: true,
            isPurchaseDate: true,
          ),
          SizedBox(height: sh * 0.02),
          _buildDatePicker(
            'Expiry Date',
            _expiryDate,
            (date) => setState(() => _expiryDate = date),
            sw,
            sh,
            isTablet,
            isRequired: true,
          ),
          SizedBox(height: sh * 0.02),
          _buildTextField(
            'Quantity',
            'e.g., 30 tablets (Optional)',
            _quantityController,
            sw,
            sh,
            isTablet,
            isRequired: false,
          ),
          SizedBox(height: sh * 0.02),
          _buildTextField(
            'Manufacturer',
            'Enter manufacturer name (Optional)',
            _manufacturerController,
            sw,
            sh,
            isTablet,
            maxLines: 1,
            isRequired: false,
          ),
          SizedBox(height: sh * 0.02),
          _buildTextField(
            'Batch Number',
            'Enter batch number (Optional)',
            _batchNumberController,
            sw,
            sh,
            isTablet,
            maxLines: 1,
            isRequired: false,
          ),
          SizedBox(height: sh * 0.02),
          _buildTextField(
            'Notes',
            'Any additional notes (Optional)',
            _notesController,
            sw,
            sh,
            isTablet,
            maxLines: 3,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineTypeDropdown(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medicine Type',
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textPrimary,
          ),
        ),
        SizedBox(height: sh * 0.008),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: DropdownButtonFormField<String>(
            value: _selectedMedicineType,
            decoration: InputDecoration(
              hintText: 'Select medicine type',
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
            items: _medicineTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                    color: PillBinColors.textDark,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedMedicineType = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint,
      TextEditingController controller, double sw, double sh, bool isTablet,
      {int maxLines = 1,
      bool isRequired = false,
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
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

  Widget _buildDatePicker(String label, DateTime date,
      Function(DateTime) onChanged, double sw, double sh, bool isTablet,
      {bool isRequired = false, bool isPurchaseDate = false}) {
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
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            border: Border.all(color: PillBinColors.greyLight),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
          ),
          child: GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2030),
              );
              if (picked != null && picked != date) {
                onChanged(picked);
              }
            },
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: isTablet ? sw * 0.025 : sw * 0.04,
                  color: PillBinColors.textSecondary,
                ),
                SizedBox(width: sw * 0.02),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                    color: PillBinColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedActionButtons(double sw, double sh, bool isTablet) {
    return AnimatedBuilder(
      animation: _saveAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSaving ? _saveScaleAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: _isSaving
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
                  color:
                      PillBinColors.primary.withOpacity(_isSaving ? 0.3 : 0.4),
                  blurRadius: _isSaving ? 8 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                onTap: _isSaving ? null : _handleSaveMedicine,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? sh * 0.025 : sh * 0.02,
                    horizontal: isTablet ? sw * 0.03 : sw * 0.05,
                  ),
                  child: AnimatedOpacity(
                    opacity: _isSaving ? _saveOpacityAnimation.value : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSaving) ...[
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
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: isTablet ? sw * 0.025 : sw * 0.05,
                          ),
                        SizedBox(width: sw * 0.03),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _isSaving ? 'Adding Medicine...' : 'Add Medicine',
                            key: ValueKey(_isSaving),
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

  //* validate dates
  bool _validateDates() {
    if (_expiryDate.isBefore(_purchaseDate) ||
        _expiryDate.isAtSameMomentAs(_purchaseDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expiry date must be after purchase date'),
          backgroundColor: PillBinColors.error,
        ),
      );
      return false;
    }
    return true;
  }

  DateTime createSafeDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, 12, 0, 0);
  }

  void _handleSaveMedicine() async {
    //* Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: PillBinColors.error,
        ),
      );
      return;
    }

    //* Check required fields
    if (_medicineNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medicine name is required'),
          backgroundColor: PillBinColors.error,
        ),
      );
      return;
    }

    // Validate dates
    if (!_validateDates()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    //* Start save animation
    _saveAnimationController.forward();

    try {
      //* API Call
      MedicineProvider _provider = context.read<MedicineProvider>();
      NotificationProvider _notificationProvider =
          context.read<NotificationProvider>();

      DateTime safeExpiryDate = createSafeDateTime(_expiryDate);
      DateTime safePurchaseDate = createSafeDateTime(_purchaseDate);

      // Call updated addMedicine with image parameter
      String response = await _provider.addMedicine(
        name: _medicineNameController.text.trim(),
        expiryDate: safeExpiryDate.toIso8601String(),
        notes: _notesController.text.trim(),
        dosage: _quantityController.text.trim(),
        manufacturer: _manufacturerController.text.trim(),
        batchNumber: _batchNumberController.text.trim(),
        type: _selectedMedicineType ?? 'Other',
        purchaseDate: safePurchaseDate.toIso8601String(),
        imageFile: medicinePhoto,
        userModel: context.read<UserProvider>().user,
        context: context,
      );

      //* Add Notification
      _notificationProvider.addNotification(
        context: context,
        title: "${_medicineNameController.text.trim()} added",
        description:
            "Your medicine has been added successfully and will now be tracked for dosage reminders and expiry alerts.",
        status: 'normal',
      );

      // Stop animation
      _saveAnimationController.reverse();

      setState(() {
        _isSaving = false;
      });

      if (response == 'success') {
        //* schedule notification
        final random = Random();
        final id1 = random.nextInt(10000) + random.nextInt(100);

        //* 1] Inform before 2 days of expiry
        Map<String, dynamic> expiring_soon_map =
            NotificationHelper.getExpiringSoon(
                _medicineNameController.text.trim());

        int hours1 = NotificationHelper.getDurationNotification(_expiryDate);

        NotificationConfig().scheduleReminder(
            notify: PushNotificationModel(
                id: id1.toString(),
                title: expiring_soon_map["title"],
                body: expiring_soon_map["desc"]),
            hours: hours1);

        //* 2] Inform at day of expiry
        final id2 = random.nextInt(10000) + random.nextInt(100);

        Future.delayed(Duration(milliseconds: 500));

        Map<String, dynamic> expired_map =
            NotificationHelper.getExpired(_medicineNameController.text.trim());

        int hours2 = NotificationHelper.getDurationNotification(_expiryDate);

        NotificationConfig().scheduleReminder(
            notify: PushNotificationModel(
                id: id2.toString(),
                title: expired_map["title"],
                body: expired_map["desc"]),
            hours: hours2);

        //* Clear form after success
        _medicineNameController.clear();
        _quantityController.clear();
        _notesController.clear();
        _manufacturerController.clear();
        _batchNumberController.clear();
        setState(() {
          _expiryDate = DateTime.now().add(const Duration(days: 365));
          _purchaseDate = DateTime.now();
          _selectedMedicineType = null;
          medicinePhoto = null; // Clear the photo
        });
      } else {
        return;
      }
    } catch (e) {
      // Handle error
      _saveAnimationController.reverse();

      setState(() {
        _isSaving = false;
      });
    }
  }
}
