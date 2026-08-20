import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/vendor/data/repository/vendor_provider.dart';
import 'package:provider/provider.dart';

class VendorScanScreen extends StatefulWidget {
  const VendorScanScreen({Key? key}) : super(key: key);

  @override
  State<VendorScanScreen> createState() => _VendorScanScreenState();
}

class _VendorScanScreenState extends State<VendorScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  //* The camera fires continuously — without this one code is submitted many
  //* times before the first response lands
  bool _handling = false;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;

    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) return;

    setState(() {
      _handling = true;
      _message = null;
    });
    await _controller.stop();

    final provider = context.read<VendorProvider>();
    final error = await provider.scanHandoff(raw);

    if (!mounted) return;

    if (error == null) {
      CustomSnackBar.show(
        context: context,
        icon: Icons.check_circle_outline,
        title: 'Donation completed',
      );
      Navigator.pop(context, true);
      return;
    }

    setState(() => _message = error);
  }

  Future<void> _resume() async {
    setState(() {
      _message = null;
      _handling = false;
    });
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Scan Donor Code',
            style:
                PillBinBold.style(fontSize: sw * 0.046, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _cameraError(sw, sh, error),
          ),
          _reticle(sw),
          Positioned(
            left: 0,
            right: 0,
            bottom: sh * 0.06,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
              child: _status(sw, sh),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reticle(double sw) {
    return Center(
      child: Container(
        width: sw * 0.68,
        height: sw * 0.68,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white70, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _status(double sw, double sh) {
    if (_message != null) {
      return Container(
        padding: EdgeInsets.all(sw * 0.045),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: sw * 0.08, color: PillBinColors.error),
            SizedBox(height: sh * 0.01),
            Text(_message!,
                textAlign: TextAlign.center,
                style: PillBinMedium.style(
                    fontSize: sw * 0.035, color: PillBinColors.textDark)),
            SizedBox(height: sh * 0.015),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PillBinColors.primary,
                  padding: EdgeInsets.symmetric(vertical: sh * 0.014),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Scan again',
                    style: PillBinMedium.style(
                        fontSize: sw * 0.035, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sh * 0.016),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_handling) ...[
            SizedBox(
              width: sw * 0.04,
              height: sw * 0.04,
              child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white)),
            ),
            SizedBox(width: sw * 0.03),
          ],
          Flexible(
            child: Text(
              _handling
                  ? 'Completing donation…'
                  : 'Point at the donor\'s QR code',
              textAlign: TextAlign.center,
              style: PillBinMedium.style(
                  fontSize: sw * 0.035, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraError(double sw, double sh, MobileScannerException error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_photography_rounded,
                size: sw * 0.16, color: Colors.white54),
            SizedBox(height: sh * 0.02),
            Text('Camera unavailable',
                style: PillBinMedium.style(
                    fontSize: sw * 0.042, color: Colors.white)),
            SizedBox(height: sh * 0.01),
            Text(
              'Allow camera access for PillBin in your device settings, '
              'then reopen this screen.',
              textAlign: TextAlign.center,
              style: PillBinRegular.style(
                  fontSize: sw * 0.032, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
