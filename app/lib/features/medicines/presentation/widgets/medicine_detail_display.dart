import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/cards/full_image_preview.dart';
import 'package:pillbin/core/utils/dateFormatter.dart';
import 'package:pillbin/network/models/medicine_model.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MedicineDetailsModal extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailsModal({Key? key, required this.medicine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    final bool showRebuyLinks =
        (medicine.status.toString() == 'MedicineStatus.expired' ||
                medicine.status.toString() == 'MedicineStatus.expiringSoon') &&
            medicine.productLinks != null &&
            (medicine.productLinks!.tata1mg != null ||
                medicine.productLinks!.pharmeasy != null ||
                medicine.productLinks!.netmeds != null);

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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (medicine.image?.url != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GestureDetector(
                        onTap: () {
                          FullScreenImagePreview.show(
                            context,
                            medicine.image!.url!,
                            heroTag: 'medicine-${medicine.id}',
                          );
                        },
                        child: CachedNetworkImage(
                          imageUrl: medicine.image!.url!,
                          height: sh * 0.2,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: sh * 0.2,
                            decoration: BoxDecoration(
                              color: PillBinColors.greyLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: PillBinColors.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: sh * 0.2,
                            decoration: BoxDecoration(
                              color: PillBinColors.greyLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: isTablet ? sw * 0.06 : sw * 0.1,
                                color: PillBinColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: sh * 0.02),
                  ],
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
                  if (medicine.manufacturer != null &&
                      medicine.manufacturer!.isNotEmpty)
                    _buildDetailRow('Manufacturer', medicine.manufacturer!, sw,
                        sh, isTablet),
                  if (medicine.batchNumber != null &&
                      medicine.batchNumber!.isNotEmpty)
                    _buildDetailRow('Batch Number', medicine.batchNumber!, sw,
                        sh, isTablet),
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
                              " in ${Dateformatter.customDateDifference(DateTime.now(), medicine.expiryDate)}",
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
                  SizedBox(height: sh * 0.02),
                  if (showRebuyLinks) ...[
                    _buildRebuySection(sw, sh, isTablet),
                    SizedBox(height: sh * 0.02),
                  ],
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

  Widget _buildRebuySection(double sw, double sh, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PillBinColors.primary.withOpacity(0.1),
            PillBinColors.primaryLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PillBinColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.025 : sw * 0.045,
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Rebuy Medicine',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.042,
                  color: PillBinColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.015),
          Text(
            'Purchase from trusted online pharmacies',
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.015),
          Wrap(
            spacing: sw * 0.02,
            runSpacing: sh * 0.01,
            children: [
              if (medicine.productLinks?.tata1mg != null)
                _buildStoreButton(
                  '1mg',
                  medicine.productLinks!.tata1mg!,
                  Colors.orange,
                  sw,
                  sh,
                  isTablet,
                ),
              if (medicine.productLinks?.pharmeasy != null)
                _buildStoreButton(
                  'PharmEasy',
                  medicine.productLinks!.pharmeasy!,
                  Colors.teal,
                  sw,
                  sh,
                  isTablet,
                ),
              if (medicine.productLinks?.netmeds != null)
                _buildStoreButton(
                  'Netmeds',
                  medicine.productLinks!.netmeds!,
                  Colors.blue,
                  sw,
                  sh,
                  isTablet,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreButton(
    String storeName,
    String url,
    Color color,
    double sw,
    double sh,
    bool isTablet,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? sw * 0.02 : sw * 0.03,
            vertical: isTablet ? sh * 0.008 : sh * 0.01,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_new,
                size: isTablet ? sw * 0.018 : sw * 0.035,
                color: color,
              ),
              SizedBox(width: sw * 0.015),
              Text(
                storeName,
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
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
