import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/donation/data/repository/donation_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DonationQrScreen extends StatefulWidget {
  final String requestId;
  final String centerName;

  const DonationQrScreen({
    Key? key,
    required this.requestId,
    required this.centerName,
  }) : super(key: key);

  @override
  State<DonationQrScreen> createState() => _DonationQrScreenState();
}

class _DonationQrScreenState extends State<DonationQrScreen> {
  String? _token;
  String? _error;
  bool _loading = true;
  Timer? _refreshTimer;

  //* The token lives 5 minutes server-side. Refreshing a minute early means it
  //* never expires while the donor is queueing, but a screenshot still dies.
  static const Duration _refreshEvery = Duration(minutes: 4);

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(_refreshEvery, (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);

    final provider = context.read<DonationProvider>();
    final token = await provider.fetchHandoffToken(widget.requestId);

    if (!mounted) return;
    setState(() {
      _token = token;
      _error = token == null
          ? (provider.lastError ?? 'Could not create the code')
          : null;
      _loading = false;
    });
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
        title: Text('Handover Code',
            style: PillBinBold.style(
                fontSize: sw * 0.046, color: PillBinColors.textPrimary)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.06),
          child: Column(
            children: [
              SizedBox(height: sh * 0.02),
              Text('Show this to ${widget.centerName}',
                  textAlign: TextAlign.center,
                  style: PillBinMedium.style(
                      fontSize: sw * 0.042, color: PillBinColors.textDark)),
              SizedBox(height: sh * 0.008),
              Text('They scan it to complete your donation',
                  textAlign: TextAlign.center,
                  style: PillBinRegular.style(
                      fontSize: sw * 0.033,
                      color: PillBinColors.textSecondary)),
              SizedBox(height: sh * 0.04),
              Expanded(child: Center(child: _buildCode(sw, sh))),
              _footer(sw, sh),
              SizedBox(height: sh * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCode(double sw, double sh) {
    if (_loading) {
      return CircularProgressIndicator(
          strokeWidth: 2, color: PillBinColors.primary);
    }

    if (_token == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded,
              size: sw * 0.14, color: PillBinColors.error),
          SizedBox(height: sh * 0.02),
          Text(_error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: PillBinMedium.style(
                  fontSize: sw * 0.036, color: PillBinColors.textSecondary)),
          SizedBox(height: sh * 0.02),
          OutlinedButton(
            onPressed: _load,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: PillBinColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Try again',
                style: PillBinMedium.style(
                    fontSize: sw * 0.034, color: PillBinColors.primary)),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(sw * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PillBinColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: QrImageView(
        data: _token!,
        version: QrVersions.auto,
        size: sw * 0.6,
        backgroundColor: Colors.white,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Colors.black,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _footer(double sw, double sh) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.014),
      decoration: BoxDecoration(
        color: PillBinColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_clock_rounded,
              size: sw * 0.045, color: PillBinColors.primary),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Text(
              'This code refreshes automatically and only works once. '
              'Keep the screen open until the center scans it.',
              style: PillBinRegular.style(
                  fontSize: sw * 0.03, color: PillBinColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
