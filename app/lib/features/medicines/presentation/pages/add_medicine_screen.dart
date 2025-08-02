import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/medicines/presentation/widgets/add_medicine_widgets.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({Key? key}) : super(key: key);

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _expiryDate = DateTime.now().add(const Duration(days: 365));

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _medicineNameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
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
                buildAddMedsTitle(sw, sh, isTablet,context),
                SizedBox(height: sh * 0.04),
                buildScanOption(sw, sh, isTablet,_scanMedicine),
                SizedBox(height: sh * 0.04),
                _buildForm(sw, sh, isTablet),
                SizedBox(height: sh * 0.04),
                buildQuickTips(sw, sh, isTablet),
                SizedBox(height: sh * 0.04),
                buildAddMedicinesActionButtons(sw, sh, isTablet),
                SizedBox(height: sh * 0.02),
              ],
            ),
          ),
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
        TextFormField(
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

  Widget _buildDatePicker(String label, DateTime date,
      Function(DateTime) onChanged, double sw, double sh, bool isTablet,
      {bool isRequired = false}) {
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
        Container(
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
                firstDate: DateTime.now(),
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

  void _scanMedicine() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Scan Medicine',
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
  }
}
