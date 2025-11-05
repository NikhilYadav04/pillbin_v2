import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/auth/presentation/widgets/complete_profile_widgets.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:provider/provider.dart';

class UserRegistrationForm extends StatefulWidget {
  final String phone;
  UserRegistrationForm({Key? key, required this.phone}) : super(key: key);

  @override
  State<UserRegistrationForm> createState() => _UserRegistrationFormState();
}

class _UserRegistrationFormState extends State<UserRegistrationForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _diseasesController = TextEditingController();
final _locationController = TextEditingController();
  bool _isLoading = false;

  bool _isLocationLoading = false;

  //* Medicine list - each medicine is a map with name, dosage, frequency
  List<Map<String, dynamic>> _medicines = [];
  final int _maxMedicines = 10;

  double _latitude = 0.0;
  double _longitude = 0.0;

  //* Animation controllers for minimal effects
  late AnimationController _submitAnimationController;
  late Animation<double> _submitScaleAnimation;
  late Animation<double> _submitOpacityAnimation;

  @override
  void initState() {
    super.initState();

    //* Initialize minimal animation controller
    _submitAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _submitScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.99,
    ).animate(CurvedAnimation(
      parent: _submitAnimationController,
      curve: Curves.easeInOut,
    ));

    _submitOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _submitAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _diseasesController.dispose();
    _locationController.dispose();
    _submitAnimationController.dispose();

    // Dispose medicine controllers
    for (var medicine in _medicines) {
      medicine['nameController']?.dispose();
      medicine['dosageController']?.dispose();
      medicine['frequencyController']?.dispose();
    }

    super.dispose();
  }

  void _addMedicine() {
    if (_medicines.length < _maxMedicines) {
      setState(() {
        _medicines.add({
          'nameController': TextEditingController(),
          'dosageController': TextEditingController(),
          'frequencyController': TextEditingController(),
        });
      });
    }
  }

  void _removeMedicine(int index) {
    setState(() {
      // Dispose controllers before removing
      _medicines[index]['nameController']?.dispose();
      _medicines[index]['dosageController']?.dispose();
      _medicines[index]['frequencyController']?.dispose();

      _medicines.removeAt(index);
    });
  }

  //* Get position co-ordinates
  void getCoordinates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.map,
          title: 'Location services are disabled.');

      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.map,
            title: 'Location permissions are denied');
      }

      return;
    }

    if (permission == LocationPermission.deniedForever) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.map,
          title:
              'Location permissions are permanently denied, we cannot request permissions.');
      return;
    }

    setState(() {
      _isLocationLoading = true;
    });

    Position location = await Geolocator.getCurrentPosition();

    setState(() {
      _latitude = location.latitude;
      _longitude = location.longitude;
    });

    setState(() {
      _isLocationLoading = false;
    });
  }

  //* provider
  UserProvider _userProvider = UserProvider();

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
                        _buildAnimatedSubmitButton(sw, sh, isTablet),
                        SizedBox(height: sh * 0.02),
                        buildCompleteProfileCancelButton(
                            sw, sh, isTablet, context),
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
            'Phone Number',
            'Enter your phone number',
            _emailController,
            sw,
            sh,
            isTablet,
            isRequired: true,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                return 'Please enter a valid 10-digit phone number';
              }
              return null;
            },
          ),
          SizedBox(height: sh * 0.02),
          _buildMedicinesSection(sw, sh, isTablet),
          SizedBox(height: sh * 0.02),
          _buildTextField(
            'Medical Conditions',
            'Any ongoing diseases or conditions (Optional) ( E.g Heart Disease, Diabetes, Blood Pressure)',
            _diseasesController,
            sw,
            sh,
            isTablet,
            maxLines: 3,
            isRequired: false,
          ),
          SizedBox(height: sh * 0.02),
          _buildTextField('Location', 'Enter your city/area',
              _locationController, sw, sh, isTablet,
              isRequired: true,
              suffixIcon: Icons.location_on_outlined, validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your location';
            }
            return null;
          }),
          SizedBox(height: sh * 0.015),
          _buildCoordinatesBox(sw, sh, isTablet),
        ],
      ),
    );
  }

  Widget _buildCoordinatesBox(double sw, double sh, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        border: Border.all(
          color: PillBinColors.greyLight,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.my_location,
                size: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.primary,
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Coordinates',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                  color: PillBinColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.01),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude',
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                        color: PillBinColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: sh * 0.003),
                    Text(
                      _latitude == 0.0
                          ? 'Not available'
                          : _latitude.toStringAsFixed(6),
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                        color: _latitude == 0.0
                            ? PillBinColors.textLight
                            : PillBinColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sw * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Longitude',
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                        color: PillBinColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: sh * 0.003),
                    Text(
                      _longitude == 0.0
                          ? 'Not available'
                          : _longitude.toStringAsFixed(6),
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                        color: _longitude == 0.0
                            ? PillBinColors.textLight
                            : PillBinColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_latitude == 0.0 && _longitude == 0.0) ...[
            SizedBox(height: sh * 0.01),
            GestureDetector(
              onTap: getCoordinates,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.03,
                  vertical: sh * 0.008,
                ),
                decoration: BoxDecoration(
                  color: PillBinColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                  border: Border.all(
                    color: PillBinColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      size: isTablet ? sw * 0.018 : sw * 0.03,
                      color: PillBinColors.primary,
                    ),
                    SizedBox(width: sw * 0.015),
                    Text(
                      'Get Current Location',
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                        color: PillBinColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicinesSection(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Medicines (O)',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.textPrimary,
              ),
            ),
            if (_medicines.length < _maxMedicines)
              TextButton.icon(
                onPressed: _addMedicine,
                icon: Icon(
                  Icons.add,
                  size: isTablet ? sw * 0.02 : sw * 0.035,
                  color: PillBinColors.primary,
                ),
                label: Text(
                  'Add Medicine',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                    color: PillBinColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.02,
                    vertical: sh * 0.005,
                  ),
                ),
              ),
          ],
        ),
        if (_medicines.isNotEmpty) ...[
          SizedBox(height: sh * 0.01),
          Text(
            '${_medicines.length}/$_maxMedicines medicines added',
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
          ),
        ],
        SizedBox(height: sh * 0.015),
        ..._medicines.asMap().entries.map((entry) {
          int index = entry.key;
          return _buildMedicineCard(index, sw, sh, isTablet);
        }).toList(),
        if (_medicines.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              border: Border.all(
                color: PillBinColors.greyLight,
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: isTablet ? sw * 0.04 : sw * 0.08,
                  color: PillBinColors.textLight,
                ),
                SizedBox(height: sh * 0.01),
                Text(
                  'No medicines added yet',
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                    color: PillBinColors.textLight,
                  ),
                ),
                SizedBox(height: sh * 0.005),
                Text(
                  'Tap "Add Medicine" to include your current medications',
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                    color: PillBinColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMedicineCard(int index, double sw, double sh, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.02),
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        border: Border.all(color: PillBinColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: PillBinColors.textLight.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Medicine ${index + 1}',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                  color: PillBinColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => _removeMedicine(index),
                icon: Icon(
                  Icons.close,
                  size: isTablet ? sw * 0.02 : sw * 0.035,
                  color: PillBinColors.error,
                ),
                constraints: BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: sh * 0.015),
          _buildMedicineTextField(
            'Medicine Name',
            'Enter medicine name',
            _medicines[index]['nameController'],
            sw,
            sh,
            isTablet,
          ),
          SizedBox(height: sh * 0.015),
          Row(
            children: [
              Expanded(
                child: _buildMedicineTextField(
                  'Dosage',
                  'e.g., 500mg',
                  _medicines[index]['dosageController'],
                  sw,
                  sh,
                  isTablet,
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: _buildMedicineTextField(
                  'Frequency',
                  'e.g., Twice daily',
                  _medicines[index]['frequencyController'],
                  sw,
                  sh,
                  isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineTextField(String label, String hint,
      TextEditingController controller, double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.02 : sw * 0.032,
            color: PillBinColors.textSecondary,
          ),
        ),
        SizedBox(height: sh * 0.005),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.018 : sw * 0.03,
              color: PillBinColors.textLight,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
              borderSide: BorderSide(color: PillBinColors.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
              borderSide: BorderSide(color: PillBinColors.primary, width: 1.5),
            ),
            contentPadding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
            filled: true,
            fillColor: Colors.white,
          ),
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.018 : sw * 0.03,
            color: PillBinColors.textDark,
          ),
        ),
      ],
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
      animation: _submitAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isLoading ? _submitScaleAnimation.value : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: _isLoading
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
                  color: PillBinColors.primary.withOpacity(
                    _isLoading ? 0.3 : 0.4,
                  ),
                  blurRadius: _isLoading ? 8 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                onTap: _isLoading ? null : _handleSubmit,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? sh * 0.025 : sh * 0.02,
                    horizontal: isTablet ? sw * 0.03 : sw * 0.05,
                  ),
                  child: AnimatedOpacity(
                    opacity: _isLoading ? _submitOpacityAnimation.value : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading) ...[
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
                            Icons.person_add,
                            color: Colors.white,
                            size: isTablet ? sw * 0.025 : sw * 0.05,
                          ),
                        SizedBox(width: sw * 0.03),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _isLoading
                                ? 'Creating Profile...'
                                : 'Complete Profile',
                            key: ValueKey(_isLoading),
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

  List<Map<String, dynamic>> _prepareMedicinesData() {
    return _medicines.map((medicine) {
      return {
        'name': medicine['nameController'].text.trim(),
        'dosage': medicine['dosageController'].text.trim(),
        'frequency': medicine['frequencyController'].text.trim(),
      };
    }).where((medicine) {
      // Only include medicines where at least the name is provided
      return medicine['name']!.isNotEmpty;
    }).toList();
  }

  void _handleSubmit() async {
    //* Validate form
    if (!_formKey.currentState!.validate()) {
      //* Show validation errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: PillBinColors.error,
        ),
      );
      return;
    }

    //* Check if required field is filled
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Full name is required'),
          backgroundColor: PillBinColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    //* Start minimal animation
    _submitAnimationController.forward();

    try {
      //* Prepare medicines data
      List<Map<String, dynamic>> medicinesData = _prepareMedicinesData();

      List<Map<String, dynamic>> medicalConditions = [];

      List<String> medicalConditionsList =
          _diseasesController.text.trim().split(",");

      for (int i = 0; i < medicalConditionsList.length; i++) {
        medicalConditions
            .add({"condition": medicalConditionsList[i], "severity": ""});
      }

      //* Call API with updated parameters
      String response = await _userProvider.completeProfile(
          context: context,
          fullName: _nameController.text.trim(),
          phone: _emailController.text.trim(),
          currentMedicines: medicinesData,
          medicalConditions: medicalConditions,
          locationName: _locationController.text.trim(),
          latitude: _latitude,
          longitude: _longitude);

      // *Stop animation
      _submitAnimationController.reverse();

      setState(() {
        _isLoading = false;
      });

      if (response == 'success') {
        //* Navigate to next screen after a short delay
        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/bottom-bar-screen',
          (Route<dynamic> route) => false,
          arguments: {
            'transition': TransitionType.bottomToTop,
            'duration': 300,
          },
        );

        NotificationProvider _notificationProvider =
            context.read<NotificationProvider>();
        _notificationProvider.addNotification(
          context: context,
          title: "Profile Completed",
          description:
              "🎉 Welcome to the PillBin app! Your profile is now complete and you can access all features like medicine tracking, dosage reminders, and expiry alerts.",
          status: "important",
        );

        return;
      }
    } catch (e) {
      // Handle error
      _submitAnimationController.reverse();

      setState(() {
        _isLoading = false;
      });
    }
  }
}
