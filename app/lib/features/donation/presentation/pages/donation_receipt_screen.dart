import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/network/config/api_config.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptMedicine {
  final String name;
  final String category;
  final String quantity;
  final String condition;

  const ReceiptMedicine({
    required this.name,
    required this.category,
    required this.quantity,
    required this.condition,
  });
}

class DonationReceiptData {
  final String requestId;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final List<ReceiptMedicine> medicines;
  final String donorName;
  final String? donorEmail;
  final String? donorPhone;
  final String centerName;
  final String? centerAddress;
  final String? centerPhone;

  const DonationReceiptData({
    required this.requestId,
    required this.createdAt,
    required this.completedAt,
    required this.medicines,
    required this.donorName,
    required this.centerName,
    this.donorEmail,
    this.donorPhone,
    this.centerAddress,
    this.centerPhone,
  });

  //* Mirrors buildReceiptNumber on the server so both show the same string
  //* without either side storing it
  String get receiptNumber {
    final year = (createdAt ?? DateTime.now()).year;
    final tail = requestId.length >= 8
        ? requestId.substring(requestId.length - 8).toUpperCase()
        : requestId.toUpperCase();
    return 'PB-$year-$tail';
  }

  int get totalUnits => medicines.fold(0, (sum, m) {
        final parsed = int.tryParse(m.quantity.trim());
        return sum + (parsed == null || parsed < 1 ? 1 : parsed);
      });

  String get verifyUrl =>
      '${ApiConfig.baseUrl}/api/donations/verify/$requestId';

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static DateTime? _completedFrom(List? statusHistory) {
    if (statusHistory == null) return null;
    for (final entry in statusHistory.reversed) {
      if (entry is Map && entry['status'] == 'completed') {
        return _parseDate(entry['at']);
      }
    }
    return null;
  }

  //* Donor side hands over the raw request map straight from the API
  factory DonationReceiptData.fromRequestMap(
    Map<String, dynamic> request, {
    required String donorName,
    String? donorEmail,
    String? donorPhone,
  }) {
    final center = request['medicalCenterId'];
    final centerMap = center is Map ? center : const {};

    return DonationReceiptData(
      requestId: request['_id']?.toString() ?? '',
      createdAt: _parseDate(request['createdAt']),
      completedAt: _completedFrom(request['statusHistory'] as List?) ??
          _parseDate(request['updatedAt']),
      medicines: ((request['medicines'] as List?) ?? [])
          .whereType<Map>()
          .map((m) => ReceiptMedicine(
                name: m['name']?.toString() ?? '-',
                category: m['category']?.toString() ?? '-',
                quantity: m['quantity']?.toString() ?? '1',
                condition: m['condition']?.toString() ?? 'unknown',
              ))
          .toList(),
      donorName: donorName,
      donorEmail: donorEmail,
      donorPhone: donorPhone,
      centerName: centerMap['name']?.toString() ?? 'Medical Center',
      centerAddress: centerMap['address']?.toString(),
      centerPhone: centerMap['phoneNumber']?.toString(),
    );
  }
}

class DonationReceiptScreen extends StatefulWidget {
  final DonationReceiptData data;

  const DonationReceiptScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<DonationReceiptScreen> createState() => _DonationReceiptScreenState();
}

class _DonationReceiptScreenState extends State<DonationReceiptScreen> {
  final GlobalKey _captureKey = GlobalKey();
  bool _sharing = false;

  //* The receipt paints at a fixed width so the shared image is identical on
  //* every device, then scales down to fit whatever screen is previewing it
  static const double _canvasWidth = 720;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    return '$day ${_months[local.month - 1]} ${local.year}';
  }

  Future<Uint8List?> _capture() async {
    final boundary = _captureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 2.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);

    try {
      final bytes = await _capture();
      if (bytes == null) throw Exception('Could not render the receipt');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.data.receiptNumber}.png');
      await file.writeAsBytes(bytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          subject: 'PillBin donation receipt ${widget.data.receiptNumber}',
          text: 'Donation receipt ${widget.data.receiptNumber} - '
              '${widget.data.medicines.length} '
              '${widget.data.medicines.length == 1 ? 'medicine' : 'medicines'} '
              'donated to ${widget.data.centerName} via PillBin.',
        ),
      );
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title: 'Could not share the receipt',
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: sw * 0.05, color: PillBinColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Donation Receipt',
            style: PillBinBold.style(
                fontSize: sw * 0.046, color: PillBinColors.textPrimary)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04, vertical: sh * 0.015),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: RepaintBoundary(
                      key: _captureKey,
                      child: SizedBox(
                        width: _canvasWidth,
                        child: _receipt(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  sw * 0.05, sh * 0.008, sw * 0.05, sh * 0.02),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sharing ? null : _share,
                  icon: _sharing
                      ? SizedBox(
                          width: sw * 0.045,
                          height: sw * 0.045,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white)),
                        )
                      : Icon(Icons.ios_share_rounded, size: sw * 0.05),
                  label: Text(_sharing ? 'Preparing…' : 'Share Receipt',
                      style: PillBinMedium.style(
                          fontSize: sw * 0.038, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PillBinColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        PillBinColors.primary.withValues(alpha: 0.6),
                    disabledForegroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: sh * 0.017),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //* Everything below paints on the fixed 720px canvas, so sizes are absolute
  //* rather than screen-relative
  Widget _receipt() {
    final data = widget.data;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 28, 40, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _parties(),
                const SizedBox(height: 26),
                _table(),
                const SizedBox(height: 22),
                _summary(),
                const SizedBox(height: 26),
                _verification(),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    '${data.receiptNumber}  ·  Generated by PillBin',
                    style: PillBinRegular.style(
                        fontSize: 11, color: const Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final data = widget.data;

    return Container(
      width: double.infinity,
      color: PillBinColors.primary,
      padding: const EdgeInsets.fromLTRB(40, 30, 40, 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PillBin',
                    style:
                        PillBinBold.style(fontSize: 30, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Safe medicine disposal and donation',
                    style: PillBinRegular.style(
                        fontSize: 13, color: const Color(0xFFDBEAFE))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('DONATION RECEIPT',
                  style: PillBinBold.style(fontSize: 17, color: Colors.white)),
              const SizedBox(height: 8),
              Text(data.receiptNumber,
                  style: PillBinRegular.style(
                      fontSize: 13, color: const Color(0xFFDBEAFE))),
              const SizedBox(height: 3),
              Text('Issued ${_formatDate(DateTime.now())}',
                  style: PillBinRegular.style(
                      fontSize: 13, color: const Color(0xFFDBEAFE))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _parties() {
    final data = widget.data;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _party('Donated by', data.donorName,
              [data.donorEmail, data.donorPhone]),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: _party('Received by', data.centerName, [
            data.centerAddress,
            data.centerPhone,
            'Collected on ${_formatDate(data.completedAt)}',
          ]),
        ),
      ],
    );
  }

  Widget _party(String label, String title, List<String?> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: PillBinBold.style(fontSize: 11, color: PillBinColors.textSecondary)
                .copyWith(letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text(title,
            style:
                PillBinBold.style(fontSize: 16, color: PillBinColors.textDark)),
        ...lines.whereType<String>().where((l) => l.trim().isNotEmpty).map(
              (line) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(line,
                    style: PillBinRegular.style(
                        fontSize: 13, color: PillBinColors.textSecondary)),
              ),
            ),
      ],
    );
  }

  Widget _table() {
    final medicines = widget.data.medicines;

    return Column(
      children: [
        Container(
          color: const Color(0xFFF1F5F9),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              _cell('MEDICINE', 40, header: true),
              _cell('CATEGORY', 22, header: true),
              _cell('QTY', 13, header: true),
              _cell('CONDITION', 25, header: true),
            ],
          ),
        ),
        ...medicines.asMap().entries.map((entry) {
          final medicine = entry.value;
          return Container(
            decoration: BoxDecoration(
              color: entry.key.isOdd ? const Color(0xFFFAFAFA) : Colors.white,
              border: const Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.8)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _cell(medicine.name, 40, strong: true),
                _cell(medicine.category, 22),
                _cell(medicine.quantity, 13),
                _cell(medicine.condition, 25),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _cell(String value, int flex,
      {bool header = false, bool strong = false}) {
    final style = header
        ? PillBinBold.style(fontSize: 11, color: PillBinColors.textSecondary)
            .copyWith(letterSpacing: 0.6)
        : strong
            ? PillBinBold.style(fontSize: 13, color: PillBinColors.textDark)
            : PillBinRegular.style(
                fontSize: 13, color: PillBinColors.textSecondary);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(value.isEmpty ? '-' : value, style: style),
      ),
    );
  }

  Widget _summary() {
    final data = widget.data;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _stat('${data.medicines.length}', 'Items donated'),
          const SizedBox(width: 28),
          _stat('${data.totalUnits}', 'Total units'),
          const SizedBox(width: 28),
          Expanded(
            child: Text(
              'Records a donation of unused medicines for safe redistribution '
              'or disposal. Carries no monetary value.',
              style: PillBinRegular.style(
                  fontSize: 11, color: PillBinColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style:
                PillBinBold.style(fontSize: 22, color: PillBinColors.primary)),
        const SizedBox(height: 3),
        Text(label.toUpperCase(),
            style: PillBinRegular.style(
                    fontSize: 10, color: PillBinColors.textSecondary)
                .copyWith(letterSpacing: 0.6)),
      ],
    );
  }

  Widget _verification() {
    final data = widget.data;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QrImageView(
          data: data.verifyUrl,
          version: QrVersions.auto,
          size: 108,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Color(0xFF0F172A),
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text('Verify this receipt',
                  style: PillBinBold.style(
                      fontSize: 14, color: PillBinColors.textDark)),
              const SizedBox(height: 6),
              Text(
                'Scan the code to confirm this donation against PillBin '
                'records.',
                style: PillBinRegular.style(
                    fontSize: 12, color: PillBinColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(data.verifyUrl,
                  style: PillBinRegular.style(
                      fontSize: 11, color: PillBinColors.primary)),
            ],
          ),
        ),
      ],
    );
  }
}
