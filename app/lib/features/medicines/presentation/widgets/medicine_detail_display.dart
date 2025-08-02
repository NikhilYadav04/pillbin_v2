import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_item.dart';

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
                          color: medicine.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          medicine.status,
                          style: PillBinMedium.style(
                            fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                            color: medicine.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.03),
                  _buildDetailRow(
                      'Quantity', medicine.quantity, sw, sh, isTablet),
                  _buildDetailRow(
                      'Expiry Date',
                      '${medicine.expiryDate.day}/${medicine.expiryDate.month}/${medicine.expiryDate.year}',
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Status', medicine.daysUntilExpiry, sw, sh, isTablet),
                  _buildDetailRow(
                      'Added Date',
                      '${medicine.addedDate.day}/${medicine.addedDate.month}/${medicine.addedDate.year}',
                      sw,
                      sh,
                      isTablet),
                  if (medicine.notes.isNotEmpty)
                    _buildDetailRow('Notes', medicine.notes, sw, sh, isTablet),
                  const Spacer(),
                  if (medicine.status == 'Expired')
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
