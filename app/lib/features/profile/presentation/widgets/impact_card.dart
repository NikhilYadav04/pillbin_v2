import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:share_plus/share_plus.dart';

class ImpactCardData {
  final String name;
  final int disposed;
  final int tracked;
  final int campaigns;
  final bool firstTimer;
  final bool ecoHelper;
  final bool greenChampion;

  const ImpactCardData({
    required this.name,
    required this.disposed,
    required this.tracked,
    required this.campaigns,
    required this.firstTimer,
    required this.ecoHelper,
    required this.greenChampion,
  });

  List<String> get earnedBadges => [
        if (greenChampion) 'Green Champion',
        if (ecoHelper) 'Eco Helper',
        if (firstTimer) 'First Timer',
      ];
}

class ImpactCard extends StatefulWidget {
  final ImpactCardData data;

  const ImpactCard({Key? key, required this.data}) : super(key: key);

  @override
  State<ImpactCard> createState() => ImpactCardState();
}

class ImpactCardState extends State<ImpactCard> {
  final GlobalKey _captureKey = GlobalKey();
  static const double _canvasWidth = 720;

  Future<Uint8List?> _capture() async {
    final boundary = _captureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 2.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  Future<bool> share() async {
    final bytes = await _capture();
    if (bytes == null) return false;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pillbin_impact.png');
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        subject: 'My PillBin Impact',
        text: '${widget.data.disposed} medicines safely disposed with '
            'PillBin. Join me in keeping medicines out of landfills and '
            'water supply.',
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _captureKey,
      child: SizedBox(
        width: _canvasWidth,
        child: _card(),
      ),
    );
  }

  Widget _card() {
    final data = widget.data;
    final badges = data.earnedBadges;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [PillBinColors.primary, Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(44, 40, 44, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.volunteer_activism_rounded,
                    size: 26, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Text('PillBin',
                  style: PillBinBold.style(fontSize: 24, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 34),
          Text(data.name,
              style: PillBinBold.style(fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 6),
          Text('My Impact',
              style: PillBinBold.style(fontSize: 30, color: Colors.white)),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${data.disposed}',
                  style:
                      PillBinBold.style(fontSize: 72, color: Colors.white)),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                    data.disposed == 1 ? 'medicine\ndisposed' : 'medicines\ndisposed',
                    style: PillBinMedium.style(
                        fontSize: 16, color: Colors.white.withValues(alpha: 0.9))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('kept out of landfill and water supply',
              style: PillBinRegular.style(
                  fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 32),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _stat('${data.tracked}', 'Tracked'),
              const SizedBox(width: 36),
              _stat('${data.campaigns}', 'Campaigns'),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: badges
                  .map((label) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(label,
                            style: PillBinMedium.style(
                                fontSize: 13, color: Colors.white)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 32),
          Text('Join me at pillbin.app',
              style: PillBinRegular.style(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: PillBinBold.style(fontSize: 22, color: Colors.white)),
        const SizedBox(height: 3),
        Text(label.toUpperCase(),
            style: PillBinRegular.style(
                    fontSize: 11, color: Colors.white.withValues(alpha: 0.75))
                .copyWith(letterSpacing: 0.6)),
      ],
    );
  }
}
