import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/dateFormatter.dart';
import 'package:pillbin/network/models/medicine_model.dart';
import 'package:intl/intl.dart';

class MedicineDetailsModal extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailsModal({Key? key, required this.medicine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Container(
      height: sh * 0.7,
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTablet ? 32 : 24),
          topRight: Radius.circular(isTablet ? 32 : 24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: sw * 0.12,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: sh * 0.015),
            decoration: BoxDecoration(
              color: PillBinColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          medicine.name,
                          style: PillBinBold.style(
                            fontSize: isTablet ? sw * 0.035 : sw * 0.06,
                            color: PillBinColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? sw * 0.02 : sw * 0.03,
                          vertical: isTablet ? sh * 0.005 : sh * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: medicine.status.toString() ==
                                  'MedicineStatus.active'
                              ? PillBinColors.success.withOpacity(0.1)
                              : medicine.status.toString() ==
                                      'MedicineStatus.expired'
                                  ? PillBinColors.error.withOpacity(0.1)
                                  : PillBinColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          medicine.status.toString() == 'MedicineStatus.active'
                              ? 'Active'
                              : medicine.status.toString() ==
                                      'MedicineStatus.expired'
                                  ? 'Expired'
                                  : 'Expiring Soon',
                          style: PillBinMedium.style(
                            fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                            color: medicine.status.toString() ==
                                    'MedicineStatus.active'
                                ? PillBinColors.success
                                : medicine.status.toString() ==
                                        'MedicineStatus.expired'
                                    ? PillBinColors.error
                                    : PillBinColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.03),
                  _buildDetailRow(
                      'Type',
                      (medicine.type == null || medicine.type!.isEmpty)
                          ? "Not Mentioned"
                          : medicine.type!,
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Quantity',
                      (medicine.dosage == null || medicine.dosage!.isEmpty)
                          ? "Not Mentioned"
                          : medicine.dosage!,
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Expiry Date',
                      "${DateFormat('d MMMM yyyy').format(medicine.expiryDate)}",
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Status',
                      medicine.status.toString() == 'MedicineStatus.expired'
                          ? 'Expired'
                          : 'Expires' +
                              "in ${Dateformatter.customDateDifference(DateTime.now(), medicine.expiryDate)}",
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Added Date',
                      "${DateFormat('d MMMM yyyy').format(medicine.addedDate)}",
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Purchase Date',
                      "${DateFormat('d MMMM yyyy').format(medicine.purchaseDate)}",
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Notes',
                      (medicine.notes == null || medicine.notes!.isEmpty)
                          ? "Not Mentioned"
                          : medicine.notes!,
                      sw,
                      sh,
                      isTablet),
                  const Spacer(),
                  if (medicine.status.toString() == 'MedicineStatus.expired')
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
                      decoration: BoxDecoration(
                        color: PillBinColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: PillBinColors.error.withOpacity(0.3)),
                      ),
                      child: Text(
                        'This medicine has expired. Please dispose of it safely at a designated collection point.',
                        style: PillBinRegular.style(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                          color: PillBinColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, double sw, double sh, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                color: PillBinColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                color: PillBinColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
