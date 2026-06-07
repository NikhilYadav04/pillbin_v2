import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/cards/full_image_preview.dart';
import 'package:pillbin/core/utils/dateFormatter.dart';
import 'package:pillbin/network/models/medicine_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool _shouldShowRebuyLinks() {
    return (widget.medicine.status.toString() == 'MedicineStatus.expired' ||
            widget.medicine.status.toString() ==
                'MedicineStatus.expiringSoon') &&
        widget.medicine.productLinks != null &&
        (widget.medicine.productLinks!.tata1mg != null ||
            widget.medicine.productLinks!.pharmeasy != null ||
            widget.medicine.productLinks!.netmeds != null);
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

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.sw > 600;
    final statusColor = _getStatusColor();
    final bool showRebuyLinks = _shouldShowRebuyLinks();

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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.medicine.image?.url != null) ...[
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 16 : 12),
                                  child: Container(
                                    width: isTablet
                                        ? widget.sw * 0.12
                                        : widget.sw * 0.18,
                                    height: isTablet
                                        ? widget.sw * 0.12
                                        : widget.sw * 0.18,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          isTablet ? 16 : 12),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        FullScreenImagePreview.show(
                                          context,
                                          widget.medicine.image!.url!,
                                          heroTag:
                                              'medicine-${widget.medicine.id}',
                                        );
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: widget.medicine.image!.url!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: statusColor.withOpacity(0.08),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                statusColor.withOpacity(0.15),
                                                statusColor.withOpacity(0.08),
                                              ],
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.medication_rounded,
                                            color: statusColor.withOpacity(0.5),
                                            size: isTablet
                                                ? widget.sw * 0.05
                                                : widget.sw * 0.08,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: widget.sw * 0.035),
                              ] else ...[
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
                                    borderRadius: BorderRadius.circular(
                                        isTablet ? 16 : 12),
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
                              ],
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
                          if (showRebuyLinks) ...[
                            SizedBox(height: widget.sh * 0.018),
                            Container(
                              padding: EdgeInsets.all(isTablet
                                  ? widget.sw * 0.02
                                  : widget.sw * 0.03),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    PillBinColors.primary.withOpacity(0.08),
                                    PillBinColors.primaryLight
                                        .withOpacity(0.04),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: PillBinColors.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        color: PillBinColors.primary,
                                        size: isTablet
                                            ? widget.sw * 0.02
                                            : widget.sw * 0.038,
                                      ),
                                      SizedBox(width: widget.sw * 0.015),
                                      Text(
                                        'Rebuy Medicine',
                                        style: PillBinMedium.style(
                                          fontSize: isTablet
                                              ? widget.sw * 0.02
                                              : widget.sw * 0.035,
                                          color: PillBinColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: widget.sh * 0.01),
                                  Wrap(
                                    spacing: widget.sw * 0.015,
                                    runSpacing: widget.sh * 0.008,
                                    children: [
                                      if (widget
                                              .medicine.productLinks?.tata1mg !=
                                          null)
                                        _buildCompactStoreButton(
                                          '1mg',
                                          widget
                                              .medicine.productLinks!.tata1mg!,
                                          Colors.orange,
                                          isTablet,
                                        ),
                                      if (widget.medicine.productLinks
                                              ?.pharmeasy !=
                                          null)
                                        _buildCompactStoreButton(
                                          'PharmEasy',
                                          widget.medicine.productLinks!
                                              .pharmeasy!,
                                          Colors.teal,
                                          isTablet,
                                        ),
                                      if (widget
                                              .medicine.productLinks?.netmeds !=
                                          null)
                                        _buildCompactStoreButton(
                                          'Netmeds',
                                          widget
                                              .medicine.productLinks!.netmeds!,
                                          Colors.blue,
                                          isTablet,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: widget.sh * 0.018),
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

  Widget _buildCompactStoreButton(
    String storeName,
    String url,
    Color color,
    bool isTablet,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? widget.sw * 0.015 : widget.sw * 0.02,
            vertical: isTablet ? widget.sh * 0.006 : widget.sh * 0.008,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_new,
                size: isTablet ? widget.sw * 0.015 : widget.sw * 0.028,
                color: color,
              ),
              SizedBox(width: widget.sw * 0.01),
              Text(
                storeName,
                style: PillBinMedium.style(
                  fontSize: isTablet ? widget.sw * 0.016 : widget.sw * 0.028,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
