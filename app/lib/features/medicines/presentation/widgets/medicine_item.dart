import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class Medicine {
  final String name;
  final String quantity;
  final DateTime expiryDate;
  final String status;
  final String notes;
  final DateTime addedDate;

  Medicine({
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.status,
    required this.notes,
    required this.addedDate,
  });

  Color get statusColor {
    switch (status) {
      case 'Active':
        return PillBinColors.success;
      case 'Expiring Soon':
        return PillBinColors.warning;
      case 'Expired':
        return PillBinColors.error;
      default:
        return PillBinColors.textSecondary;
    }
  }

  String get daysUntilExpiry {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;

    if (difference < 0) {
      return 'Expired ${difference.abs()} days ago';
    } else if (difference == 0) {
      return 'Expires today';
    } else if (difference == 1) {
      return 'Expires tomorrow';
    } else {
      return 'Expires in $difference days';
    }
  }
}

class MedicineListItem extends StatefulWidget {
  final Medicine medicine;
  final double sw;
  final double sh;
  final VoidCallback onTap;

  const MedicineListItem({
    Key? key,
    required this.medicine,
    required this.sw,
    required this.sh,
    required this.onTap,
  }) : super(key: key);

  @override
  State<MedicineListItem> createState() => _MedicineListItemState();
}

class _MedicineListItemState extends State<MedicineListItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.sw > 600;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
      margin: EdgeInsets.only(bottom: widget.sh * 0.02),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          boxShadow: [
            // Main shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            // Secondary shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          child: Container(
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Subtle gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Status accent border
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: widget.medicine.statusColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                // Main content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                    onTap: widget.onTap,
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) => setState(() => _isPressed = false),
                    onTapCancel: () => setState(() => _isPressed = false),
                    child: Padding(
                      padding: EdgeInsets.all(
                          isTablet ? widget.sw * 0.03 : widget.sw * 0.045),
                      child: Row(
                        children: [
                          // Icon container with enhanced design
                          Container(
                            padding: EdgeInsets.all(isTablet
                                ? widget.sw * 0.025
                                : widget.sw * 0.035),
                            decoration: BoxDecoration(
                              color:
                                  widget.medicine.statusColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(isTablet ? 16 : 12),
                              border: Border.all(
                                color: widget.medicine.statusColor
                                    .withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.medicine.statusColor
                                      .withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.medication,
                              color: widget.medicine.statusColor,
                              size: isTablet
                                  ? widget.sw * 0.03
                                  : widget.sw * 0.055,
                            ),
                          ),
                          SizedBox(width: widget.sw * 0.04),
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.medicine.name,
                                  style: PillBinMedium.style(
                                    fontSize: isTablet
                                        ? widget.sw * 0.025
                                        : widget.sw * 0.042,
                                    color: PillBinColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: widget.sh * 0.008),
                                Text(
                                  widget.medicine.quantity,
                                  style: PillBinRegular.style(
                                    fontSize: isTablet
                                        ? widget.sw * 0.02
                                        : widget.sw * 0.036,
                                    color: PillBinColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: widget.sh * 0.006),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet
                                        ? widget.sw * 0.015
                                        : widget.sw * 0.02,
                                    vertical: isTablet
                                        ? widget.sh * 0.003
                                        : widget.sh * 0.005,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.medicine.statusColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.medicine.daysUntilExpiry,
                                    style: PillBinMedium.style(
                                      fontSize: isTablet
                                          ? widget.sw * 0.018
                                          : widget.sw * 0.03,
                                      color: widget.medicine.statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: widget.sw * 0.02),
                          // Enhanced arrow with container
                          Container(
                            padding: EdgeInsets.all(isTablet
                                ? widget.sw * 0.012
                                : widget.sw * 0.02),
                            decoration: BoxDecoration(
                              color: PillBinColors.greyLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: isTablet
                                  ? widget.sw * 0.02
                                  : widget.sw * 0.035,
                              color: PillBinColors.textLight,
                            ),
                          ),
                        ],
                      ),
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
