// ─── Helpers ────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w';
  if (diff.inDays > 0) return '${diff.inDays}d';
  if (diff.inHours > 0) return '${diff.inHours}h';
  if (diff.inMinutes > 0) return '${diff.inMinutes}m';
  return 'now';
}

String initials(String email, String name) {
  if (name.isNotEmpty) return name[0].toUpperCase();
  return email.split('@')[0][0].toUpperCase();
}

String displayName(String email, String name) {
  if (name.isNotEmpty) return name;
  return email.split('@')[0];
}

//* ─── Shared Sheet Scaffold ──────────────────────────────────────────────────

/// Internal wrapper that provides the draggable sheet chrome
class BottomSheetScaffold extends StatelessWidget {
  final String title;
  final String countLabel;
  final Widget body;
  final Widget? footer;

  const BottomSheetScaffold({
    required this.title,
    required this.countLabel,
    required this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;

    return Container(
      height: sh * 0.75,
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Drag Handle ──
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PillBinColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──
          Padding(
            padding: EdgeInsets.fromLTRB(sw * 0.05, 12, sw * 0.04, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: PillBinBold.style(
                      fontSize: sw * 0.045,
                      color: PillBinColors.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PillBinColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PillBinColors.primary.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    countLabel,
                    style: PillBinMedium.style(
                      fontSize: sw * 0.03,
                      color: PillBinColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: PillBinColors.greyLight.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: sw * 0.045,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Divider(
            height: 1,
            thickness: 1,
            color: PillBinColors.greyLight.withOpacity(0.5),
          ),

          // ── Body ──
          Expanded(child: body),

          // ── Footer (optional) ──
          if (footer != null) footer!,
        ],
      ),
    );
  }
}
