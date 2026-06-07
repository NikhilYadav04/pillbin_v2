import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/vendor/data/models/vendor_models.dart';
import 'package:pillbin/features/vendor/data/repository/vendor_provider.dart';
import 'package:provider/provider.dart';

class VendorInventoryScreen extends StatefulWidget {
  const VendorInventoryScreen({Key? key}) : super(key: key);

  @override
  State<VendorInventoryScreen> createState() => _VendorInventoryScreenState();
}

class _VendorInventoryScreenState extends State<VendorInventoryScreen>
    with TickerProviderStateMixin {
  late List<InventoryItem> _inventory;
  bool _isDirty = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    final raw = context.read<VendorProvider>().inventory;
    _inventory = List<InventoryItem>.from(raw);
  }

  void _addCategory() {
    setState(() {
      _inventory.add(InventoryItem(
        category: '',
        specificNames: [],
        acceptanceStatus: 'accepting',
      ));
      _isDirty = true;
    });
  }

  void _removeCategory(int index) {
    setState(() {
      _inventory.removeAt(index);
      _isDirty = true;
    });
  }

  Future<void> _save() async {
    final valid = _inventory
        .where((c) => c.category.trim().isNotEmpty)
        .toList();
    final provider = context.read<VendorProvider>();
    final success = await provider.updateInventory(valid);
    if (!mounted) return;
    if (success) {
      setState(() => _isDirty = false);
      CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle_outline,
          title: 'Inventory updated successfully');
    } else {
      CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: provider.lastError ?? 'Failed to update inventory');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        automaticallyImplyLeading: false,
        title: Text('Manage Inventory',
            style: PillBinBold.style(
                fontSize: sw * 0.048, color: PillBinColors.textPrimary)),
        actions: [
          if (_isDirty)
            Padding(
              padding: EdgeInsets.only(right: sw * 0.03),
              child: GestureDetector(
                onTap: _save,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04, vertical: sh * 0.008),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PillBinColors.primary,
                        PillBinColors.primaryLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: PillBinColors.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text('Save',
                      style: PillBinMedium.style(
                          fontSize: sw * 0.035, color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header info card
            Padding(
              padding: EdgeInsets.fromLTRB(
                  sw * 0.05, sh * 0.01, sw * 0.05, 0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(sw * 0.04),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PillBinColors.primary.withValues(alpha: 0.1),
                      PillBinColors.primaryLight.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: PillBinColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(sw * 0.025),
                      decoration: BoxDecoration(
                        color: PillBinColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.inventory_2_outlined,
                          size: sw * 0.05, color: PillBinColors.primary),
                    ),
                    SizedBox(width: sw * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Medicine Categories',
                              style: PillBinMedium.style(
                                  fontSize: sw * 0.038,
                                  color: PillBinColors.textPrimary)),
                          SizedBox(height: sh * 0.003),
                          Text(
                              'List what your center accepts so donors can match',
                              style: PillBinRegular.style(
                                  fontSize: sw * 0.03,
                                  color: PillBinColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: sh * 0.015),
            Expanded(
              child: _inventory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(sw * 0.06),
                            decoration: BoxDecoration(
                              color:
                                  PillBinColors.primary.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.inventory_2_outlined,
                                size: sw * 0.12,
                                color: PillBinColors.primary
                                    .withValues(alpha: 0.6)),
                          ),
                          SizedBox(height: sh * 0.02),
                          Text('No categories yet',
                              style: PillBinMedium.style(
                                  fontSize: sw * 0.042,
                                  color: PillBinColors.textPrimary)),
                          SizedBox(height: sh * 0.008),
                          Text('Tap "Add Category" to get started',
                              style: PillBinRegular.style(
                                  fontSize: sw * 0.033,
                                  color: PillBinColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                      itemCount: _inventory.length,
                      separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
                      itemBuilder: (context, i) =>
                          _buildCategoryCard(i, sw, sh),
                    ),
            ),
            // Add Category button
            Padding(
              padding: EdgeInsets.fromLTRB(
                  sw * 0.05, sh * 0.015, sw * 0.05, sh * 0.025),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      PillBinColors.primary,
                      PillBinColors.primaryLight,
                    ],
                  ),
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
                    onTap: _addCategory,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline,
                              color: Colors.white, size: sw * 0.05),
                          SizedBox(width: sw * 0.025),
                          Text('Add Category',
                              style: PillBinMedium.style(
                                  fontSize: sw * 0.04, color: Colors.white)),
                        ],
                      ),
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

  Widget _buildCategoryCard(int i, double sw, double sh) {
    final item = _inventory[i];
    final status = item.acceptanceStatus;
    final specificNames = List<String>.from(item.specificNames);

    InputDecoration _fieldDeco(String hint, {int maxLines = 1}) =>
        InputDecoration(
          hintText: hint,
          hintStyle: PillBinRegular.style(
              fontSize: sw * 0.035, color: PillBinColors.textLight),
          filled: true,
          fillColor: PillBinColors.background,
          contentPadding:
              EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.015),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: PillBinColors.greyLight)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: PillBinColors.greyLight)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: PillBinColors.primary, width: 2)),
        );

    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PillBinColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header row: index badge + "Category X" + delete
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(sw * 0.02),
                decoration: BoxDecoration(
                  color: PillBinColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.medication_outlined,
                    size: sw * 0.045, color: PillBinColors.primary),
              ),
              SizedBox(width: sw * 0.025),
              Expanded(
                child: Text('Category ${i + 1}',
                    style: PillBinMedium.style(
                        fontSize: sw * 0.038,
                        color: PillBinColors.textPrimary)),
              ),
              GestureDetector(
                onTap: () => _removeCategory(i),
                child: Container(
                  padding: EdgeInsets.all(sw * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete_outline,
                      color: Colors.red, size: sw * 0.045),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.015),

          // Category name field
          Row(
            children: [
              Text('Category Name',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.037, color: PillBinColors.textPrimary)),
              SizedBox(width: sw * 0.01),
              Text('*',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.037, color: PillBinColors.error)),
            ],
          ),
          SizedBox(height: sh * 0.008),
          TextFormField(
            initialValue: item.category,
            decoration: _fieldDeco('e.g. Antibiotics, Vitamins'),
            style: PillBinRegular.style(
                fontSize: sw * 0.035, color: PillBinColors.textDark),
            textCapitalization: TextCapitalization.words,
            onChanged: (v) {
              item.category = v;
              setState(() => _isDirty = true);
            },
          ),
          SizedBox(height: sh * 0.015),

          // Status
          Text('Acceptance Status',
              style: PillBinMedium.style(
                  fontSize: sw * 0.037, color: PillBinColors.textPrimary)),
          SizedBox(height: sh * 0.008),
          Row(
            children: [
              _statusChip('accepting', status, Colors.green, i, sw, sh),
              SizedBox(width: sw * 0.02),
              _statusChip('full', status, Colors.orange, i, sw, sh),
              SizedBox(width: sw * 0.02),
              _statusChip('not_accepting', status, Colors.red, i, sw, sh),
            ],
          ),
          SizedBox(height: sh * 0.015),

          // Specific medicines
          Text('Specific Medicines',
              style: PillBinMedium.style(
                  fontSize: sw * 0.037, color: PillBinColors.textPrimary)),
          SizedBox(height: sh * 0.003),
          Text('Optional — helps donors know exactly what to bring',
              style: PillBinRegular.style(
                  fontSize: sw * 0.028, color: PillBinColors.textSecondary)),
          SizedBox(height: sh * 0.008),
          Wrap(
            spacing: sw * 0.02,
            runSpacing: sh * 0.007,
            children: [
              ...specificNames.map((name) => Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.03, vertical: sh * 0.006),
                    decoration: BoxDecoration(
                      color: PillBinColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: PillBinColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(name,
                            style: PillBinRegular.style(
                                fontSize: sw * 0.03,
                                color: PillBinColors.primary)),
                        SizedBox(width: sw * 0.015),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              specificNames.remove(name);
                              item.specificNames = specificNames;
                              _isDirty = true;
                            });
                          },
                          child: Icon(Icons.close,
                              size: sw * 0.035, color: PillBinColors.primary),
                        ),
                      ],
                    ),
                  )),
              GestureDetector(
                onTap: () => _showAddNameDialog(i, specificNames),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03, vertical: sh * 0.006),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: PillBinColors.primary.withValues(alpha: 0.5),
                        width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add,
                          size: sw * 0.035, color: PillBinColors.primary),
                      SizedBox(width: sw * 0.01),
                      Text('Add',
                          style: PillBinMedium.style(
                              fontSize: sw * 0.03,
                              color: PillBinColors.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.015),

          // Notes
          Text('Notes',
              style: PillBinMedium.style(
                  fontSize: sw * 0.037, color: PillBinColors.textPrimary)),
          SizedBox(height: sh * 0.003),
          Text('Optional — e.g. sealed only, no liquids',
              style: PillBinRegular.style(
                  fontSize: sw * 0.028, color: PillBinColors.textSecondary)),
          SizedBox(height: sh * 0.008),
          TextFormField(
            initialValue: item.notes,
            maxLines: 2,
            decoration: _fieldDeco('e.g. Sealed packaging only'),
            style: PillBinRegular.style(
                fontSize: sw * 0.035, color: PillBinColors.textDark),
            onChanged: (v) {
              item.notes = v;
              setState(() => _isDirty = true);
            },
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
      String value, String current, Color color, int index, double sw, double sh) {
    final selected = current == value;
    const labels = {
      'accepting': 'Accepting',
      'full': 'Full',
      'not_accepting': 'Not Accepting',
    };
    return GestureDetector(
      onTap: () {
        setState(() {
          _inventory[index].acceptanceStatus = value;
          _isDirty = true;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.028, vertical: sh * 0.008),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : PillBinColors.greyLight, width: 1.5),
        ),
        child: Text(
          labels[value] ?? value,
          style: PillBinMedium.style(
            fontSize: sw * 0.03,
            color: selected ? color : PillBinColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showAddNameDialog(int index, List<String> current) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: PillBinColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(sw * 0.025),
                    decoration: BoxDecoration(
                      color: PillBinColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.medication_outlined,
                        size: sw * 0.05, color: PillBinColors.primary),
                  ),
                  SizedBox(width: sw * 0.03),
                  Text('Add Medicine Name',
                      style: PillBinBold.style(
                          fontSize: sw * 0.042,
                          color: PillBinColors.textPrimary)),
                ],
              ),
              SizedBox(height: sh * 0.02),
              Text('Medicine Name',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.038, color: PillBinColors.textPrimary)),
              SizedBox(height: sh * 0.008),
              TextField(
                controller: ctrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. Paracetamol 500mg',
                  hintStyle: PillBinRegular.style(
                      fontSize: sw * 0.035, color: PillBinColors.textLight),
                  filled: true,
                  fillColor: PillBinColors.background,
                  contentPadding: EdgeInsets.all(sw * 0.04),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: PillBinColors.greyLight)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: PillBinColors.greyLight)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          BorderSide(color: PillBinColors.primary, width: 2)),
                ),
                style: PillBinRegular.style(
                    fontSize: sw * 0.035, color: PillBinColors.textDark),
              ),
              SizedBox(height: sh * 0.025),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sh * 0.015),
                        decoration: BoxDecoration(
                          color: PillBinColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: PillBinColors.greyLight),
                        ),
                        child: Center(
                          child: Text('Cancel',
                              style: PillBinMedium.style(
                                  fontSize: sw * 0.037,
                                  color: PillBinColors.textSecondary)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final name = ctrl.text.trim();
                        if (name.isNotEmpty) {
                          setState(() {
                            current.add(name);
                            _inventory[index].specificNames = current;
                            _isDirty = true;
                          });
                        }
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: sh * 0.015),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              PillBinColors.primary,
                              PillBinColors.primaryLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: PillBinColors.primary
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text('Add',
                              style: PillBinMedium.style(
                                  fontSize: sw * 0.037, color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
