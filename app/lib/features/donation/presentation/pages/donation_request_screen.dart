import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/donation/data/repository/donation_provider.dart';
import 'package:provider/provider.dart';

class DonationRequestScreen extends StatefulWidget {
  final String centerId;
  final String centerName;

  const DonationRequestScreen({
    Key? key,
    required this.centerId,
    required this.centerName,
  }) : super(key: key);

  @override
  State<DonationRequestScreen> createState() => _DonationRequestScreenState();
}

class _DonationRequestScreenState extends State<DonationRequestScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _noteCtrl = TextEditingController();
  String _contactPreference = 'either';
  DateTime? _scheduledDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Dynamic list of medicines the user wants to donate
  final List<Map<String, dynamic>> _medicines = [];

  // Medicine photos (max 2)
  final List<File> _medicinePhotos = [];

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
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DonationProvider>().loadCenterInventory(widget.centerId);
    });
    _addMedicine(); // start with one row
  }

  @override
  void dispose() {
    _animationController.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _addMedicine() {
    setState(() {
      _medicines.add({
        'name': '',
        'category': '',
        'quantity': '',
        'condition': 'unknown',
      });
    });
  }

  void _removeMedicine(int i) {
    if (_medicines.length == 1) return;
    setState(() => _medicines.removeAt(i));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: source, imageQuality: 80);
    if (xfile == null) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: xfile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: PillBinColors.primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Photo'),
      ],
    );
    if (cropped != null) {
      setState(() => _medicinePhotos.add(File(cropped.path)));
    }
  }

  void _showPhotoSourceSheet() {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      backgroundColor: PillBinColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.02, sw * 0.06, sh * 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: sw * 0.1,
                height: 4,
                decoration: BoxDecoration(
                    color: PillBinColors.greyLight,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            SizedBox(height: sh * 0.02),
            Text('Add Photo',
                style: PillBinBold.style(
                    fontSize: sw * 0.045, color: PillBinColors.textPrimary)),
            SizedBox(height: sh * 0.02),
            ListTile(
              leading: Icon(Icons.camera_alt, color: PillBinColors.primary),
              title: Text('Camera',
                  style: PillBinRegular.style(
                      fontSize: sw * 0.038, color: PillBinColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: PillBinColors.primary),
              title: Text('Gallery',
                  style: PillBinRegular.style(
                      fontSize: sw * 0.038, color: PillBinColors.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final validMeds = _medicines
        .where((m) => (m['name'] as String).trim().isNotEmpty)
        .toList();

    if (validMeds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine')),
      );
      return;
    }

    final data = {
      'medicalCenterId': widget.centerId,
      'medicines': validMeds,
      'contactPreference': _contactPreference,
      if (_noteCtrl.text.trim().isNotEmpty) 'userNote': _noteCtrl.text.trim(),
      if (_scheduledDate != null)
        'scheduledDate': _scheduledDate!.toIso8601String(),
    };

    final provider = context.read<DonationProvider>();
    final success = await provider.submitRequest(data, photos: _medicinePhotos);

    if (!mounted) return;
    if (success) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle_outline,
          title: 'Donation request submitted!');
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/my-donations-screen',
        (route) => route.settings.name == '/bottom-bar-screen',
        arguments: {'transition': TransitionType.rightToLeft, 'duration': 300},
      );
    } else {
      CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: provider.lastError ?? 'Failed to submit request');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final provider = context.watch<DonationProvider>();
    final inventory =
        provider.centerInventory?['inventory'] as List? ?? [];

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.background,
        elevation: 0,
        title: Text('Donate Medicines',
            style: PillBinBold.style(
                fontSize: sw * 0.048, color: PillBinColors.textPrimary)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Center info — gradient welcome card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(sw * 0.04),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PillBinColors.primary.withValues(alpha: 0.12),
                      PillBinColors.primaryLight.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: PillBinColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(sw * 0.03),
                      decoration: BoxDecoration(
                        color: PillBinColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.local_hospital_outlined,
                          color: PillBinColors.primary, size: sw * 0.06),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Donating to',
                              style: PillBinRegular.style(
                                  fontSize: sw * 0.03,
                                  color: PillBinColors.textSecondary)),
                          SizedBox(height: sh * 0.003),
                          Text(widget.centerName,
                              style: PillBinBold.style(
                                  fontSize: sw * 0.042,
                                  color: PillBinColors.primary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
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
                        Text('Tips for Donation',
                            style: PillBinMedium.style(
                                fontSize: sw * 0.036, color: PillBinColors.primary)),
                      ],
                    ),
                    SizedBox(height: sh * 0.01),
                    _buildTip(sw, sh, 'Only donate medicines that are within expiry'),
                    _buildTip(sw, sh, 'Sealed or unopened medicines are preferred'),
                    _buildTip(sw, sh, 'The center will contact you before pick-up'),
                  ],
                ),
              ),

              // Accepted categories hint
              if (inventory.isNotEmpty) ...[
                SizedBox(height: sh * 0.02),
                Text('Accepted Categories',
                    style: PillBinBold.style(
                        fontSize: sw * 0.04,
                        color: PillBinColors.textPrimary)),
                SizedBox(height: sh * 0.01),
                Wrap(
                  spacing: sw * 0.02,
                  runSpacing: sh * 0.006,
                  children: inventory.map<Widget>((inv) {
                    final status = inv['acceptanceStatus'] as String? ?? 'accepting';
                    final color = status == 'accepting'
                        ? Colors.green
                        : status == 'full'
                            ? Colors.orange
                            : Colors.red;
                    return Chip(
                      label: Text(
                          '${inv['category']} · $status',
                          style: PillBinRegular.style(fontSize: sw * 0.028)),
                      backgroundColor: color.withValues(alpha: 0.1),
                      side: BorderSide(color: color.withValues(alpha: 0.4)),
                    );
                  }).toList(),
                ),
              ],

              SizedBox(height: sh * 0.025),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Medicines to Donate',
                      style: PillBinBold.style(
                          fontSize: sw * 0.042,
                          color: PillBinColors.textPrimary)),
                  GestureDetector(
                    onTap: _addMedicine,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: sw * 0.03, vertical: sh * 0.007),
                      decoration: BoxDecoration(
                        color: PillBinColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: PillBinColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add,
                              size: sw * 0.04, color: PillBinColors.primary),
                          SizedBox(width: sw * 0.01),
                          Text('Add',
                              style: PillBinMedium.style(
                                  fontSize: sw * 0.033,
                                  color: PillBinColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.01),

              ..._medicines.asMap().entries.map((e) =>
                  _buildMedicineRow(e.key, sw, sh)),

              SizedBox(height: sh * 0.025),
              Text('Contact Preference',
                  style: PillBinBold.style(
                      fontSize: sw * 0.042,
                      color: PillBinColors.textPrimary)),
              SizedBox(height: sh * 0.01),
              Row(
                children: [
                  _contactChip('call', 'Call First', sw),
                  SizedBox(width: sw * 0.02),
                  _contactChip('visit', 'Direct Visit', sw),
                  SizedBox(width: sw * 0.02),
                  _contactChip('either', 'Either', sw),
                ],
              ),

              SizedBox(height: sh * 0.02),
              Text('Preferred Drop-off Date (optional)',
                  style: PillBinBold.style(
                      fontSize: sw * 0.038,
                      color: PillBinColors.textPrimary)),
              SizedBox(height: sh * 0.01),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04, vertical: sh * 0.016),
                  decoration: BoxDecoration(
                    color: PillBinColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PillBinColors.greyLight),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          color: PillBinColors.textSecondary, size: sw * 0.05),
                      SizedBox(width: sw * 0.03),
                      Text(
                        _scheduledDate != null
                            ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                            : 'Select a date',
                        style: PillBinRegular.style(
                            fontSize: sw * 0.038,
                            color: _scheduledDate != null
                                ? PillBinColors.textPrimary
                                : PillBinColors.textLight),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: sh * 0.02),
              Text('Note to Center (optional)',
                  style: PillBinBold.style(
                      fontSize: sw * 0.038,
                      color: PillBinColors.textPrimary)),
              SizedBox(height: sh * 0.01),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any additional information...',
                  filled: true,
                  fillColor: PillBinColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: PillBinColors.greyLight)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: PillBinColors.greyLight)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: PillBinColors.primary, width: 2)),
                ),
              ),

              SizedBox(height: sh * 0.025),
              // Medicine photos section
              Row(
                children: [
                  Text('Medicine Photos',
                      style: PillBinBold.style(
                          fontSize: sw * 0.042,
                          color: PillBinColors.textPrimary)),
                  SizedBox(width: sw * 0.02),
                  Text('(max 2, optional)',
                      style: PillBinRegular.style(
                          fontSize: sw * 0.03,
                          color: PillBinColors.textSecondary)),
                ],
              ),
              SizedBox(height: sh * 0.01),
              Row(
                children: [
                  ..._medicinePhotos.asMap().entries.map((e) => Padding(
                        padding: EdgeInsets.only(right: sw * 0.03),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                e.value,
                                width: sw * 0.25,
                                height: sw * 0.25,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _medicinePhotos.removeAt(e.key)),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (_medicinePhotos.length < 2)
                    GestureDetector(
                      onTap: _showPhotoSourceSheet,
                      child: Container(
                        width: sw * 0.25,
                        height: sw * 0.25,
                        decoration: BoxDecoration(
                          color: PillBinColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  PillBinColors.primary.withValues(alpha: 0.4),
                              width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: sw * 0.07,
                                color: PillBinColors.primary
                                    .withValues(alpha: 0.7)),
                            SizedBox(height: sh * 0.005),
                            Text('Add Photo',
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
                    onTap: provider.isSubmitting ? null : _submit,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (provider.isSubmitting)
                            SizedBox(
                              width: sw * 0.05,
                              height: sw * 0.05,
                              child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2),
                            )
                          else
                            Icon(Icons.volunteer_activism,
                                color: Colors.white, size: sw * 0.05),
                          SizedBox(width: sw * 0.03),
                          Text(
                            provider.isSubmitting ? 'Submitting...' : 'Submit Donation Request',
                            style: PillBinMedium.style(
                                fontSize: sw * 0.042, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: sh * 0.03),
            ],
          ),
        ),
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
            decoration: const BoxDecoration(
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

  Widget _buildMedicineRow(int i, double sw, double sh) {
    final med = _medicines[i];
    const _borderRadius = 10.0;
    InputDecoration _fieldDecoration(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: PillBinRegular.style(
              fontSize: sw * 0.032, color: PillBinColors.textLight),
          filled: true,
          fillColor: PillBinColors.background,
          contentPadding:
              EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sh * 0.015),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: BorderSide(color: PillBinColors.greyLight)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: BorderSide(color: PillBinColors.greyLight)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: BorderSide(color: PillBinColors.primary, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: BorderSide(color: PillBinColors.error, width: 1)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: BorderSide(color: PillBinColors.error, width: 2)),
        );

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.015),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PillBinColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Name row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Medicine Name',
                            style: PillBinMedium.style(
                                fontSize: sw * 0.035,
                                color: PillBinColors.textPrimary)),
                        SizedBox(width: sw * 0.01),
                        Text('*',
                            style: PillBinMedium.style(
                                fontSize: sw * 0.035,
                                color: PillBinColors.error)),
                      ],
                    ),
                    SizedBox(height: sh * 0.006),
                    TextFormField(
                      initialValue: med['name'] as String,
                      decoration: _fieldDecoration('e.g. Paracetamol'),
                      style: PillBinRegular.style(
                          fontSize: sw * 0.035, color: PillBinColors.textDark),
                      validator: i == 0
                          ? (v) => v == null || v.isEmpty ? 'Required' : null
                          : null,
                      onChanged: (v) => med['name'] = v,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: sh * 0.026),
                child: IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color:
                          _medicines.length > 1 ? Colors.red : Colors.grey),
                  onPressed: () => _removeMedicine(i),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.012),
          // Quantity + Condition row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity',
                        style: PillBinMedium.style(
                            fontSize: sw * 0.035,
                            color: PillBinColors.textPrimary)),
                    SizedBox(height: sh * 0.006),
                    TextFormField(
                      initialValue: med['quantity'] as String,
                      decoration: _fieldDecoration('e.g. 10 strips'),
                      style: PillBinRegular.style(
                          fontSize: sw * 0.035, color: PillBinColors.textDark),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => med['quantity'] = v,
                    ),
                  ],
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Condition',
                        style: PillBinMedium.style(
                            fontSize: sw * 0.035,
                            color: PillBinColors.textPrimary)),
                    SizedBox(height: sh * 0.006),
                    DropdownButtonFormField<String>(
                      initialValue: med['condition'] as String,
                      decoration: _fieldDecoration(''),
                      items: [
                        DropdownMenuItem(
                            value: 'sealed',
                            child: Text('Sealed',
                                style: PillBinRegular.style(
                                    fontSize: sw * 0.033,
                                    color: PillBinColors.textDark))),
                        DropdownMenuItem(
                            value: 'opened',
                            child: Text('Opened',
                                style: PillBinRegular.style(
                                    fontSize: sw * 0.033,
                                    color: PillBinColors.textDark))),
                        DropdownMenuItem(
                            value: 'unknown',
                            child: Text('Unknown',
                                style: PillBinRegular.style(
                                    fontSize: sw * 0.033,
                                    color: PillBinColors.textDark))),
                      ],
                      onChanged: (v) => setState(() => med['condition'] = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactChip(String value, String label, double sw) {
    final sh = MediaQuery.of(context).size.height;
    final selected = _contactPreference == value;
    return GestureDetector(
      onTap: () => setState(() => _contactPreference = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.035, vertical: sh * 0.01),
        decoration: BoxDecoration(
          color: selected
              ? PillBinColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? PillBinColors.primary : PillBinColors.greyLight,
              width: 1.5),
        ),
        child: Text(label,
            style: PillBinMedium.style(
              fontSize: sw * 0.03,
              color: selected ? PillBinColors.primary : PillBinColors.textSecondary,
            )),
      ),
    );
  }
}
