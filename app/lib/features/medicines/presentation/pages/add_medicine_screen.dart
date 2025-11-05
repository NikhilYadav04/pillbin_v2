import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/medicines/data/repository/medicine_provider.dart';
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
                onTap: _isScanning ? null : _scanMedicine,
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
                firstDate: DateTime(2000), // User can select any date from 2000
                lastDate: DateTime(2030), // Up to 2030
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

  void _scanMedicine() async {
    setState(() {
      _isScanning = true;
    });

    // Start scanning animation
    _scanAnimationController.repeat(reverse: true);

    try {
      // Simulate scanning process
      await Future.delayed(const Duration(seconds: 2));

      // Stop animation
      _scanAnimationController.stop();
      _scanAnimationController.reset();

      setState(() {
        _isScanning = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Scan Complete',
            style: PillBinMedium.style(
              fontSize: 18,
              color: PillBinColors.textPrimary,
            ),
          ),
          content: Text(
            'Camera scanner will be implemented here to automatically fill medicine information.',
            style: PillBinRegular.style(
              fontSize: 14,
              color: PillBinColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: PillBinMedium.style(
                  fontSize: 14,
                  color: PillBinColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      _scanAnimationController.stop();
      _scanAnimationController.reset();

      setState(() {
        _isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanning failed. Please try again.'),
          backgroundColor: PillBinColors.error,
        ),
      );
    }
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

    // Validate dates - ADD THIS CHECK
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
      NotificationProvider _notificationProvider = context.read<NotificationProvider>();

      DateTime safeExpiryDate = createSafeDateTime(_expiryDate);
      DateTime safePurchaseDate = createSafeDateTime(_purchaseDate);

      String response = await _provider.addMedicine(
        context: context,
        name: _medicineNameController.text.trim(),
        expiryDate: safeExpiryDate.toIso8601String(),
        notes: _notesController.text.trim(),
        dosage: _quantityController.text.trim(),
        manufacturer: _manufacturerController.text.trim(),
        batchNumber: _batchNumberController.text.trim(),
        type: _selectedMedicineType ?? 'Other',
        purchaseDate: safePurchaseDate.toIso8601String(),
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
