import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/dateFormatter.dart';
import 'package:pillbin/network/models/medicine_model.dart';

class MedicineListItem extends StatefulWidget {
  final Medicine medicine;
  final double sw;
  final double sh;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MedicineListItem({
    Key? key,
    required this.medicine,
    required this.sw,
    required this.sh,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<MedicineListItem> createState() => _MedicineListItemState();
}

class _MedicineListItemState extends State<MedicineListItem> {
  bool _isPressed = false;

  Color _getStatusColor() {
    switch (widget.medicine.status.toString()) {
      case 'MedicineStatus.active':
        return PillBinColors.success;
      case 'MedicineStatus.expired':
        return PillBinColors.error;
      default:
        return PillBinColors.warning;
    }
  }

  String _getStatusText() {
    if (widget.medicine.status.toString() == 'MedicineStatus.expired') {
      return 'Expired ${Dateformatter.customDateDifference(DateTime.now(), widget.medicine.expiryDate)} ago';
    }
    return 'Expires in ${Dateformatter.customDateDifference(DateTime.now(), widget.medicine.expiryDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.sw > 600;
    final statusColor = _getStatusColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
      margin: EdgeInsets.only(bottom: widget.sh * 0.02),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          child: Container(
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              border: Border.all(
                color: statusColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        statusColor.withOpacity(0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Status indicator bar
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          statusColor,
                          statusColor.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon container
                              Container(
                                padding: EdgeInsets.all(isTablet
                                    ? widget.sw * 0.025
                                    : widget.sw * 0.035),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      statusColor.withOpacity(0.15),
                                      statusColor.withOpacity(0.08),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 16 : 12),
                                  border: Border.all(
                                    color: statusColor.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withOpacity(0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.medication_rounded,
                                  color: statusColor,
                                  size: isTablet
                                      ? widget.sw * 0.032
                                      : widget.sw * 0.06,
                                ),
                              ),
                              SizedBox(width: widget.sw * 0.04),

                              // Medicine info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.medicine.name,
                                      style: PillBinMedium.style(
                                        fontSize: isTablet
                                            ? widget.sw * 0.026
                                            : widget.sw * 0.044,
                                        color: PillBinColors.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: widget.sh * 0.006),

                                    // Dosage with icon
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.medical_information_outlined,
                                          size: isTablet
                                              ? widget.sw * 0.018
                                              : widget.sw * 0.032,
                                          color: PillBinColors.textSecondary,
                                        ),
                                        SizedBox(width: widget.sw * 0.015),
                                        Expanded(
                                          child: Text(
                                            (widget.medicine.dosage == null ||
                                                    widget.medicine.dosage!
                                                        .isEmpty)
                                                ? "Dosage not specified"
                                                : widget.medicine.dosage!,
                                            style: PillBinRegular.style(
                                              fontSize: isTablet
                                                  ? widget.sw * 0.019
                                                  : widget.sw * 0.034,
                                              color:
                                                  PillBinColors.textSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: widget.sh * 0.018),

                          // Status badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet
                                  ? widget.sw * 0.02
                                  : widget.sw * 0.025,
                              vertical: isTablet
                                  ? widget.sh * 0.006
                                  : widget.sh * 0.008,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor.withOpacity(0.15),
                                  statusColor.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: isTablet
                                      ? widget.sw * 0.018
                                      : widget.sw * 0.032,
                                  color: statusColor,
                                ),
                                SizedBox(width: widget.sw * 0.015),
                                Text(
                                  _getStatusText(),
                                  style: PillBinMedium.style(
                                    fontSize: isTablet
                                        ? widget.sw * 0.019
                                        : widget.sw * 0.032,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: widget.sh * 0.018),

                          // Divider
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  PillBinColors.greyLight.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: widget.sh * 0.018),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: widget.onEdit,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet
                                          ? widget.sh * 0.013
                                          : widget.sh * 0.014,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          PillBinColors.primary
                                              .withOpacity(0.12),
                                          PillBinColors.primary
                                              .withOpacity(0.06),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: PillBinColors.primary
                                            .withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.edit_rounded,
                                          size: isTablet
                                              ? widget.sw * 0.022
                                              : widget.sw * 0.042,
                                          color: PillBinColors.primary,
                                        ),
                                        SizedBox(width: widget.sw * 0.02),
                                        Text(
                                          'Edit',
                                          style: PillBinMedium.style(
                                            fontSize: isTablet
                                                ? widget.sw * 0.02
                                                : widget.sw * 0.036,
                                            color: PillBinColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: widget.sw * 0.03),
                              Expanded(
                                child: InkWell(
                                  onTap: widget.onDelete,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet
                                          ? widget.sh * 0.013
                                          : widget.sh * 0.014,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          PillBinColors.error.withOpacity(0.12),
                                          PillBinColors.error.withOpacity(0.06),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: PillBinColors.error
                                            .withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.delete_rounded,
                                          size: isTablet
                                              ? widget.sw * 0.022
                                              : widget.sw * 0.042,
                                          color: PillBinColors.error,
                                        ),
                                        SizedBox(width: widget.sw * 0.02),
                                        Text(
                                          'Delete',
                                          style: PillBinMedium.style(
                                            fontSize: isTablet
                                                ? widget.sw * 0.02
                                                : widget.sw * 0.036,
                                            color: PillBinColors.error,
                                          ),
                                        ),
                                      ],
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
