import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/medicines/data/repository/medicine_provider.dart';
import 'package:pillbin/features/medicines/presentation/widgets/add_medicine_widgets.dart';
import 'package:provider/provider.dart';

class EditMedicineScreen extends StatefulWidget {
  final String medicineId;
  final String medicineName;
  final String? medicineType;
  final DateTime expiryDate;
  final DateTime purchaseDate;
  final String? quantity;
  final String? manufacturer;
  final String? batchNumber;
  final String? notes;

  const EditMedicineScreen({
    Key? key,
    required this.medicineId,
    required this.medicineName,
    this.medicineType,
    required this.expiryDate,
    required this.purchaseDate,
    this.quantity,
    this.manufacturer,
    this.batchNumber,
    this.notes,
  }) : super(key: key);

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Animation controllers for buttons
  late AnimationController _saveAnimationController;
  late Animation<double> _saveScaleAnimation;
  late Animation<double> _saveOpacityAnimation;

  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _batchNumberController = TextEditingController();

  late DateTime _expiryDate;
  late DateTime _purchaseDate;
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

  @override
  void initState() {
    super.initState();

    // Initialize with existing values
    _medicineNameController.text = widget.medicineName;
    _quantityController.text = widget.quantity ?? '';
    _notesController.text = widget.notes ?? '';
    _manufacturerController.text = widget.manufacturer ?? '';
    _batchNumberController.text = widget.batchNumber ?? '';
    _expiryDate = widget.expiryDate;
    _purchaseDate = widget.purchaseDate;
    _selectedMedicineType = widget.medicineType;

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _saveAnimationController.dispose();
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
      appBar: AppBar(
        backgroundColor: PillBinColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: PillBinColors.textPrimary,
            size: isTablet ? sw * 0.025 : sw * 0.05,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Medicine',
          style: PillBinBold.style(
            fontSize: isTablet ? sw * 0.03 : sw * 0.05,
            color: PillBinColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? sw * 0.05 : sw * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEditNotice(sw, sh, isTablet),
                SizedBox(height: sh * 0.03),
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

  Widget _buildEditNotice(double sw, double sh, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PillBinColors.primary.withOpacity(0.1),
            PillBinColors.primaryLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: PillBinColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.05),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? sw * 0.015 : sw * 0.02),
              decoration: BoxDecoration(
                color: PillBinColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.edit_note,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.025 : sw * 0.04,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editing Medicine',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                      color: PillBinColors.primary,
                    ),
                  ),
                  SizedBox(height: sh * 0.005),
                  Text(
                    'Update the information below to modify this medicine',
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
                onTap: _isSaving ? null : _handleUpdateMedicine,
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
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: isTablet ? sw * 0.025 : sw * 0.05,
                          ),
                        SizedBox(width: sw * 0.03),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _isSaving
                                ? 'Updating Medicine...'
                                : 'Update Medicine',
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

  void _handleUpdateMedicine() async {
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

    // *Validate dates
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

      String response = await _provider.updateMedicine(
        context: context,
        medicineId: widget.medicineId,
        name: _medicineNameController.text.trim(),
        expiryDate: safeExpiryDate.toIso8601String(),
        notes: _notesController.text.trim(),
        dosage: _quantityController.text.trim(),
        manufacturer: _manufacturerController.text.trim(),
        batchNumber: _batchNumberController.text.trim(),
        type: _selectedMedicineType ?? 'Other',
        purchaseDate: safePurchaseDate.toIso8601String(),
      );

      _notificationProvider.addNotification(
        context: context,
        title: "${_medicineNameController.text.trim()} updated",
        description:
            "The details for ${_medicineNameController.text.trim()} have been updated. All reminders will reflect the new information.",
        status: 'normal',
      );

      //* Stop animation
      _saveAnimationController.reverse();

      setState(() {
        _isSaving = false;
      });

      if (response == 'success') {
        // Show success message

        //* Go back to previous screen
        Navigator.of(context).pop(true);
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
