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

  bool get _isExpired =>
      widget.medicine.status.toString() == 'MedicineStatus.expired';

  bool get _isActive =>
      widget.medicine.status.toString() == 'MedicineStatus.active';

  //* The one place status is expressed as colour — the rail down the left edge
  Color get _railColor {
    if (_isExpired) return PillBinColors.error;
    if (_isActive) return PillBinColors.success;
    return PillBinColors.warning;
  }

  //* An in-date medicine has nothing to announce, so it reads as muted text
  //* rather than competing with the ones that actually need attention
  Color get _statusTextColor =>
      _isActive ? PillBinColors.textSecondary : _railColor;

  String get _statusText {
    final diff = Dateformatter.customDateDifference(
        DateTime.now(), widget.medicine.expiryDate);
    return _isExpired ? 'Expired $diff ago' : 'Expires in $diff';
  }

  bool get _showRebuy {
    final links = widget.medicine.productLinks;
    return !_isActive &&
        links != null &&
        (links.tata1mg != null ||
            links.pharmeasy != null ||
            links.netmeds != null);
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      //* A dead store link should never interrupt browsing the inventory
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.sw > 600;
    final double fs = isTablet ? widget.sw * 0.55 : widget.sw;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      transform: Matrix4.identity()..scale(_isPressed ? 0.985 : 1.0),
      transformAlignment: Alignment.center,
      margin: EdgeInsets.only(bottom: widget.sh * 0.014),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PillBinColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: _railColor),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    onTapDown: (_) => setState(() => _isPressed = true),
                    onTapUp: (_) => setState(() => _isPressed = false),
                    onTapCancel: () => setState(() => _isPressed = false),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(fs, isTablet),
                          if (_showRebuy) ...[
                            const SizedBox(height: 12),
                            Divider(
                                height: 1,
                                thickness: 1,
                                color: PillBinColors.greyLight),
                            const SizedBox(height: 10),
                            _rebuyRow(fs),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(double fs, bool isTablet) {
    final dosage = widget.medicine.dosage;
    final hasDosage = dosage != null && dosage.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _thumbnail(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.medicine.name,
                style: PillBinMedium.style(
                  fontSize: fs * 0.042,
                  color: PillBinColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasDosage) ...[
                const SizedBox(height: 3),
                Text(
                  dosage,
                  style: PillBinRegular.style(
                    fontSize: fs * 0.033,
                    color: PillBinColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 7),
              Row(
                children: [
                  Icon(
                    _isExpired
                        ? Icons.error_outline_rounded
                        : Icons.schedule_rounded,
                    size: fs * 0.036,
                    color: _statusTextColor,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      _statusText,
                      style: PillBinMedium.style(
                        fontSize: fs * 0.032,
                        color: _statusTextColor,
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
        _menu(fs),
      ],
    );
  }

  Widget _thumbnail() {
    final url = widget.medicine.image?.url;
    const double size = 52;

    if (url == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _railColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.medication_rounded, color: _railColor, size: 24),
      );
    }

    return GestureDetector(
      onTap: () => FullScreenImagePreview.show(
        context,
        url,
        heroTag: 'medicine-${widget.medicine.id}',
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: size,
            height: size,
            color: PillBinColors.greyLight,
          ),
          errorWidget: (_, __, ___) => Container(
            width: size,
            height: size,
            color: _railColor.withValues(alpha: 0.08),
            child: Icon(Icons.medication_rounded, color: _railColor, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _menu(double fs) {
    if (widget.onEdit == null && widget.onDelete == null) {
      return const SizedBox(width: 8);
    }

    return SizedBox(
      width: 34,
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded,
            size: 20, color: PillBinColors.textSecondary),
        padding: EdgeInsets.zero,
        splashRadius: 18,
        position: PopupMenuPosition.under,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (value) {
          if (value == 'edit') widget.onEdit?.call();
          if (value == 'delete') widget.onDelete?.call();
        },
        itemBuilder: (_) => [
          if (widget.onEdit != null)
            PopupMenuItem(
              value: 'edit',
              height: 42,
              child: Row(
                children: [
                  Icon(Icons.edit_outlined,
                      size: 18, color: PillBinColors.textPrimary),
                  const SizedBox(width: 10),
                  Text('Edit',
                      style: PillBinRegular.style(
                          fontSize: fs * 0.034,
                          color: PillBinColors.textPrimary)),
                ],
              ),
            ),
          if (widget.onDelete != null)
            PopupMenuItem(
              value: 'delete',
              height: 42,
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 18, color: PillBinColors.error),
                  const SizedBox(width: 10),
                  Text('Delete',
                      style: PillBinRegular.style(
                          fontSize: fs * 0.034, color: PillBinColors.error)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _rebuyRow(double fs) {
    final links = widget.medicine.productLinks!;
    final stores = <MapEntry<String, String>>[
      if (links.tata1mg != null) MapEntry('1mg', links.tata1mg!),
      if (links.pharmeasy != null) MapEntry('PharmEasy', links.pharmeasy!),
      if (links.netmeds != null) MapEntry('Netmeds', links.netmeds!),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(
            'Rebuy',
            style: PillBinRegular.style(
              fontSize: fs * 0.031,
              color: PillBinColors.textLight,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            spacing: 14,
            runSpacing: 4,
            children: stores
                .map((s) => InkWell(
                      onTap: () => _launchURL(s.value),
                      child: Text(
                        s.key,
                        style: PillBinMedium.style(
                          fontSize: fs * 0.031,
                          color: PillBinColors.primary,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
