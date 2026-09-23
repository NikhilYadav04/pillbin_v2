import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class ModerationBadge extends StatelessWidget {
  final String status;
  final double sw;
  final bool solid;

  const ModerationBadge({
    Key? key,
    required this.status,
    required this.sw,
    this.solid = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (status != 'pending' && status != 'rejected') {
      return const SizedBox.shrink();
    }

    final bool removed = status == 'rejected';
    final Color color = removed ? PillBinColors.error : PillBinColors.warning;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.02, vertical: sw * 0.008),
      decoration: BoxDecoration(
        color: solid ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            removed ? Icons.block_rounded : Icons.hourglass_top_rounded,
            size: sw * 0.03,
            color: solid ? Colors.white : color,
          ),
          SizedBox(width: sw * 0.01),
          Text(
            removed ? 'Removed' : 'Under review',
            style: PillBinMedium.style(
              fontSize: sw * 0.026,
              color: solid ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}
