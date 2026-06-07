import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/features/vendor/data/repository/vendor_provider.dart';
import 'package:pillbin/network/utils/http_client.dart';
import 'package:provider/provider.dart';

class VendorOnboardingScreen extends StatefulWidget {
  final int startAtStep;
  const VendorOnboardingScreen({Key? key, this.startAtStep = 0}) : super(key: key);

  @override
  State<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen>
    with TickerProviderStateMixin {
  // 0 = personal details, 1 = choose mode, 2 = register new, 3 = verify docs
  int _step = 0;

  final _personalNameCtrl = TextEditingController();
  final _personalFormKey = GlobalKey<FormState>();
  bool _isSavingName = false;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  String _facilityType = 'pharmacy';
  bool _isLoading = false;
  bool _isLocationLoading = false;
  final List<File> _verificationDocs = [];
  double? _latitude;
  double? _longitude;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _step = widget.startAtStep;
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
    _personalNameCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePersonalDetails() async {
    if (!_personalFormKey.currentState!.validate()) return;
    setState(() => _isSavingName = true);
    final success = await context
        .read<UserProvider>()
        .updateFullName(_personalNameCtrl.text.trim());
    setState(() => _isSavingName = false);
    if (success && mounted) setState(() => _step = 1);
  }

  Future<void> _getCoordinates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.map,
          title: 'Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CustomSnackBar.show(
            context: context,
            icon: Icons.map,
            title: 'Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.map,
          title: 'Location permissions are permanently denied.');
      return;
    }

    setState(() => _isLocationLoading = true);
    final position = await Geolocator.getCurrentPosition();

    // Reverse geocode to get address
    try {
      final placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      if (placemarks.isNotEmpty && _addressCtrl.text.trim().isEmpty) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
        if (parts.isNotEmpty) _addressCtrl.text = parts;
      }
    } catch (_) {}

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _isLocationLoading = false;
    });
  }

  Future<void> _pickVerificationDoc() async {
    final picker = ImagePicker();
    final xfile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (xfile != null && mounted) {
      setState(() => _verificationDocs.add(File(xfile.path)));
    }
  }

  Future<void> _submitVerificationDocs() async {
    setState(() => _isLoading = true);
    final vp = context.read<VendorProvider>();
    final success = await vp.uploadVerificationDocs(_verificationDocs);
    setState(() => _isLoading = false);
    if (!mounted) return;
    if (success) {
      _navigateToVendorHome();
    } else {
      CustomSnackBar.show(
        context: context,
        icon: Icons.error_outline,
        title: vp.lastError ?? 'Failed to submit documents',
      );
    }
  }

  void _navigateToVendorHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/vendor-bottom-bar-screen',
      (route) => false,
      arguments: {'transition': TransitionType.rightToLeft, 'duration': 300},
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.location_on,
          title: 'Please fetch your current location first.');
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'phoneNumber': _phoneCtrl.text.trim(),
      'facilityType': _facilityType,
      if (_emailCtrl.text.trim().isNotEmpty) 'contactEmail': _emailCtrl.text.trim(),
      if (_websiteCtrl.text.trim().isNotEmpty) 'website': _websiteCtrl.text.trim(),
      'location': {'latitude': _latitude, 'longitude': _longitude},
    };

    final success =
        await context.read<VendorProvider>().registerCenter(data);

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Save vendorCenterId from provider
      final centerId = context.read<VendorProvider>().center?.id;
      await HttpClient().saveVendorCenterId(centerId);
      setState(() => _step = 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.background,
        elevation: 0,
        title: Text(
          _step == 0
              ? 'Welcome'
              : _step == 3
                  ? 'Get Verified'
                  : 'Set Up Your Center',
          style: PillBinBold.style(
              fontSize: sw * 0.05, color: PillBinColors.textPrimary),
        ),
        leading: _step == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                color: PillBinColors.textPrimary,
                onPressed: () => setState(() => _step = 0),
              )
            : _step == 2
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: PillBinColors.textPrimary,
                    onPressed: () => setState(() => _step = 1),
                  )
                : null,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _step == 0
              ? _buildPersonalStep(sw, sh)
              : _step == 1
                  ? _buildChooseStep(sw, sh)
                  : _step == 2
                      ? _buildRegisterForm(sw, sh)
                      : _buildVerificationStep(sw, sh),
        ),
      ),
    );
  }

  Widget _buildPersonalStep(double sw, double sh) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(sw * 0.06),
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PillBinColors.primary.withValues(alpha: 0.1),
                    PillBinColors.primaryLight.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: PillBinColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(sw * 0.03),
                    decoration: BoxDecoration(
                      color: PillBinColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person_outline,
                        size: sw * 0.05, color: PillBinColors.primary),
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tell us about yourself',
                            style: PillBinMedium.style(
                                fontSize: sw * 0.04, color: PillBinColors.primary)),
                        Text('This appears on your vendor profile',
                            style: PillBinRegular.style(
                                fontSize: sw * 0.032,
                                color: PillBinColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sh * 0.04),
            Row(
              children: [
                Text('Your Full Name',
                    style: PillBinMedium.style(
                        fontSize: sw * 0.04, color: PillBinColors.textPrimary)),
                SizedBox(width: sw * 0.01),
                Text('*',
                    style: PillBinMedium.style(
                        fontSize: sw * 0.04, color: PillBinColors.error)),
              ],
            ),
            SizedBox(height: sh * 0.008),
            TextFormField(
              controller: _personalNameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'e.g. Dr. Ramesh Kumar',
                hintStyle: PillBinRegular.style(
                    fontSize: sw * 0.035, color: PillBinColors.textLight),
                prefixIcon: Icon(Icons.person_outline,
                    color: PillBinColors.textSecondary),
                filled: true,
                fillColor: PillBinColors.surface,
                contentPadding: EdgeInsets.all(sw * 0.04),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: PillBinColors.greyLight)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: PillBinColors.greyLight)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: PillBinColors.primary, width: 2)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: PillBinColors.error, width: 1)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: PillBinColors.error, width: 2)),
              ),
              style: PillBinRegular.style(
                  fontSize: sw * 0.035, color: PillBinColors.textDark),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            SizedBox(height: sh * 0.05),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [PillBinColors.primary, PillBinColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: PillBinColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isSavingName ? null : _savePersonalDetails,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isSavingName)
                          SizedBox(
                            width: sw * 0.05,
                            height: sw * 0.05,
                            child: const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2),
                          )
                        else
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: sw * 0.05),
                        SizedBox(width: sw * 0.03),
                        Text(
                          _isSavingName ? 'Saving...' : 'Continue',
                          style: PillBinMedium.style(
                              fontSize: sw * 0.045, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChooseStep(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.all(sw * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, Vendor!',
            style: PillBinBold.style(
                fontSize: sw * 0.07, color: PillBinColors.textPrimary),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'Get your medical center listed so users can find and donate medicines to you.',
            style: PillBinRegular.style(
                fontSize: sw * 0.038, color: PillBinColors.textSecondary),
          ),
          SizedBox(height: sh * 0.05),
          _buildChoiceCard(
            sw: sw,
            sh: sh,
            icon: Icons.add_business_outlined,
            title: 'Register New Center',
            subtitle: 'Add your center to PillBin for the first time',
            onTap: () => setState(() => _step = 2),
          ),
          SizedBox(height: sh * 0.02),
          _buildChoiceCard(
            sw: sw,
            sh: sh,
            icon: Icons.search_outlined,
            title: 'Claim Existing Center',
            subtitle: 'Your center is already listed — take ownership',
            onTap: () {
              Navigator.pushNamed(context, '/vendor-claim-center-screen',
                  arguments: {
                    'transition': TransitionType.rightToLeft,
                    'duration': 300,
                  });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required double sw,
    required double sh,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(sw * 0.05),
        decoration: BoxDecoration(
          color: PillBinColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PillBinColors.greyLight),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(sw * 0.03),
              decoration: BoxDecoration(
                color: PillBinColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: PillBinColors.primary, size: sw * 0.07),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: PillBinMedium.style(
                          fontSize: sw * 0.042,
                          color: PillBinColors.textPrimary)),
                  SizedBox(height: sh * 0.005),
                  Text(subtitle,
                      style: PillBinRegular.style(
                          fontSize: sw * 0.032,
                          color: PillBinColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: sw * 0.04, color: PillBinColors.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(double sw, double sh) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(sw * 0.06),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PillBinColors.primary.withValues(alpha: 0.1),
                    PillBinColors.primaryLight.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PillBinColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(sw * 0.03),
                    decoration: BoxDecoration(
                      color: PillBinColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add_business_outlined,
                        size: sw * 0.05, color: PillBinColors.primary),
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Register Your Center',
                            style: PillBinMedium.style(
                                fontSize: sw * 0.04, color: PillBinColors.primary)),
                        Text('Fill in your center details to get listed',
                            style: PillBinRegular.style(
                                fontSize: sw * 0.032, color: PillBinColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sh * 0.02),
            // Quick tips
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                color: PillBinColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PillBinColors.info.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: sw * 0.04, color: PillBinColors.primary),
                      SizedBox(width: sw * 0.02),
                      Text('Quick Tips',
                          style: PillBinMedium.style(
                              fontSize: sw * 0.038, color: PillBinColors.primary)),
                    ],
                  ),
                  SizedBox(height: sh * 0.012),
                  _buildTip(sw, sh, 'Use your center\'s official registered name'),
                  _buildTip(sw, sh, 'Fetch live location for accurate map placement'),
                  _buildTip(sw, sh, 'Phone number will be shown to donors'),
                  _buildTip(sw, sh, 'You can update details anytime from your dashboard'),
                ],
              ),
            ),
            SizedBox(height: sh * 0.025),
            Text('Center Details',
                style: PillBinBold.style(
                    fontSize: sw * 0.055, color: PillBinColors.textPrimary)),
            SizedBox(height: sh * 0.025),
            _buildField(
              controller: _nameCtrl,
              label: 'Center Name',
              hint: 'e.g. City Health Pharmacy',
              icon: Icons.business_outlined,
              isRequired: true,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            SizedBox(height: sh * 0.02),
            _buildField(
              controller: _addressCtrl,
              label: 'Address',
              hint: 'Full address of the center',
              icon: Icons.location_on_outlined,
              isRequired: true,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Address is required' : null,
            ),
            SizedBox(height: sh * 0.02),
            _buildField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: 'Contact number',
              icon: Icons.phone_outlined,
              isRequired: true,
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Phone is required' : null,
            ),
            SizedBox(height: sh * 0.02),
            _buildField(
              controller: _emailCtrl,
              label: 'Contact Email (optional)',
              hint: 'center@example.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: sh * 0.02),
            _buildField(
              controller: _websiteCtrl,
              label: 'Website (optional)',
              hint: 'https://yourcenter.com',
              icon: Icons.language_outlined,
            ),
            SizedBox(height: sh * 0.02),
            Text('Facility Type',
                style: PillBinMedium.style(
                    fontSize: sw * 0.038, color: PillBinColors.textPrimary)),
            SizedBox(height: sh * 0.01),
            Container(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
              decoration: BoxDecoration(
                color: PillBinColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PillBinColors.greyLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _facilityType,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'pharmacy', child: Text('Pharmacy', style: PillBinRegular.style(fontSize: sw * 0.038, color: PillBinColors.textDark))),
                    DropdownMenuItem(value: 'hospital', child: Text('Hospital', style: PillBinRegular.style(fontSize: sw * 0.038, color: PillBinColors.textDark))),
                    DropdownMenuItem(value: 'clinic', child: Text('Clinic', style: PillBinRegular.style(fontSize: sw * 0.038, color: PillBinColors.textDark))),
                    DropdownMenuItem(value: 'health_center', child: Text('Health Center', style: PillBinRegular.style(fontSize: sw * 0.038, color: PillBinColors.textDark))),
                  ],
                  onChanged: (v) => setState(() => _facilityType = v!),
                ),
              ),
            ),
            SizedBox(height: sh * 0.02),
            Text('Location',
                style: PillBinMedium.style(
                    fontSize: sw * 0.038, color: PillBinColors.textPrimary)),
            SizedBox(height: sh * 0.01),
            Container(
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                color: PillBinColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _latitude != null
                      ? PillBinColors.primary
                      : PillBinColors.greyLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      color: _latitude != null
                          ? PillBinColors.primary
                          : PillBinColors.textSecondary,
                      size: sw * 0.055),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: Text(
                      _latitude != null
                          ? 'Lat: ${_latitude!.toStringAsFixed(5)},  Lng: ${_longitude!.toStringAsFixed(5)}'
                          : 'No location fetched yet',
                      style: PillBinRegular.style(
                          fontSize: sw * 0.035,
                          color: _latitude != null
                              ? PillBinColors.textPrimary
                              : PillBinColors.textLight),
                    ),
                  ),
                  _isLocationLoading
                      ? SizedBox(
                          width: sw * 0.05,
                          height: sw * 0.05,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: PillBinColors.primary),
                        )
                      : TextButton(
                          onPressed: _getCoordinates,
                          child: Text(
                            _latitude != null ? 'Refresh' : 'Use Current',
                            style: PillBinMedium.style(
                                fontSize: sw * 0.033,
                                color: PillBinColors.primary),
                          ),
                        ),
                ],
              ),
            ),
            SizedBox(height: sh * 0.04),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [PillBinColors.primary, PillBinColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: PillBinColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isLoading ? null : _submitRegistration,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          SizedBox(
                            width: sw * 0.05,
                            height: sw * 0.05,
                            child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2),
                          )
                        else
                          Icon(Icons.check_circle_outline,
                              color: Colors.white, size: sw * 0.05),
                        SizedBox(width: sw * 0.03),
                        Text(
                          _isLoading ? 'Registering...' : 'Register Center',
                          style: PillBinMedium.style(
                              fontSize: sw * 0.045, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: sh * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(double sw, double sh, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: sw * 0.012,
            height: sw * 0.012,
            margin: EdgeInsets.only(top: sh * 0.008, right: sw * 0.02),
            decoration: BoxDecoration(
              color: PillBinColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(text,
                style: PillBinRegular.style(
                    fontSize: sw * 0.032, color: PillBinColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: PillBinMedium.style(
                    fontSize: sw * 0.04, color: PillBinColors.textPrimary)),
            if (isRequired) ...[
              SizedBox(width: sw * 0.01),
              Text('*',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.04, color: PillBinColors.error)),
            ],
          ],
        ),
        SizedBox(height: sh * 0.008),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: PillBinRegular.style(
                fontSize: sw * 0.035, color: PillBinColors.textLight),
            prefixIcon: Icon(icon, color: PillBinColors.textSecondary),
            filled: true,
            fillColor: PillBinColors.surface,
            contentPadding: EdgeInsets.all(sw * 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PillBinColors.greyLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PillBinColors.greyLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PillBinColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PillBinColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PillBinColors.error, width: 2),
            ),
          ),
          style: PillBinRegular.style(
              fontSize: sw * 0.035, color: PillBinColors.textDark),
        ),
      ],
    );
  }

  Widget _buildVerificationStep(double sw, double sh) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(sw * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              color: PillBinColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: PillBinColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(sw * 0.025),
                  decoration: BoxDecoration(
                    color: PillBinColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.verified_outlined,
                      color: PillBinColors.primary, size: sw * 0.05),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Verify Your Center',
                          style: PillBinBold.style(
                              fontSize: sw * 0.038,
                              color: PillBinColors.textPrimary)),
                      SizedBox(height: sh * 0.005),
                      Text(
                          'Upload your center\'s registration certificate or license. '
                          'Our team will review and verify your center within 24-48 hours.',
                          style: PillBinRegular.style(
                              fontSize: sw * 0.032,
                              color: PillBinColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sh * 0.025),
          Text('Upload Documents',
              style: PillBinBold.style(
                  fontSize: sw * 0.042, color: PillBinColors.textPrimary)),
          SizedBox(height: sh * 0.008),
          Text('Accepted: registration certificate, operating license, any govt-issued document (max 5)',
              style: PillBinRegular.style(
                  fontSize: sw * 0.03, color: PillBinColors.textSecondary)),
          SizedBox(height: sh * 0.018),
          // Doc slots grid
          Wrap(
            spacing: sw * 0.03,
            runSpacing: sw * 0.03,
            children: [
              ..._verificationDocs.asMap().entries.map((e) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          e.value,
                          width: sw * 0.26,
                          height: sw * 0.26,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _verificationDocs.removeAt(e.key)),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                size: 13, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )),
              if (_verificationDocs.length < 5)
                GestureDetector(
                  onTap: _pickVerificationDoc,
                  child: Container(
                    width: sw * 0.26,
                    height: sw * 0.26,
                    decoration: BoxDecoration(
                      color: PillBinColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: PillBinColors.greyLight, width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: PillBinColors.primary, size: sw * 0.07),
                        SizedBox(height: 4),
                        Text('Add',
                            style: PillBinRegular.style(
                                fontSize: sw * 0.028,
                                color: PillBinColors.primary)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: sh * 0.035),
          // Submit button
          if (_verificationDocs.isNotEmpty)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [PillBinColors.primary, PillBinColors.primaryLight]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: PillBinColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _isLoading ? null : _submitVerificationDocs,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                  strokeWidth: 2))
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.upload_outlined,
                                    color: Colors.white, size: 18),
                                SizedBox(width: sw * 0.02),
                                Text('Submit for Verification',
                                    style: PillBinMedium.style(
                                        fontSize: sw * 0.042,
                                        color: Colors.white)),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(height: sh * 0.015),
          // Skip button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: PillBinColors.greyLight),
                ),
              ),
              onPressed: _navigateToVendorHome,
              child: Text('Skip for now',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.04,
                      color: PillBinColors.textSecondary)),
            ),
          ),
          SizedBox(height: sh * 0.015),
          _buildTip(sw, sh, 'You can also submit documents from your dashboard later'),
          _buildTip(sw, sh, 'Verified centers appear with a badge and rank higher in search'),
        ],
      ),
    );
  }
}
