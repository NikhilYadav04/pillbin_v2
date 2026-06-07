// ─────────────────────────────────────────────────────────────────────────────
//  UPDATED: bigger chips, 2+2 per page layout
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/pillbot/presentation/widgets/pillbot_widgets.dart';

class SuggestionChip extends StatefulWidget {
  final SuggestionItem item;
  final VoidCallback onTap;
  const SuggestionChip({Key? key, required this.item, required this.onTap})
      : super(key: key);

  @override
  State<SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<SuggestionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    final isTablet = context.isTablet;

    // ✅ Bigger sizes
    final iconSize = sw * (isTablet ? 0.032 : 0.045);
    final iconBoxSize = sw * (isTablet ? 0.056 : 0.072);
    final labelSize = sw * (isTablet ? 0.019 : 0.032);
    final hPad = sw * (isTablet ? 0.028 : 0.038);
    final vPad = sw * (isTablet ? 0.022 : 0.032);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: _pressed
                ? PillBinColors.primary.withOpacity(0.06)
                : PillBinColors.surface,
            borderRadius: BorderRadius.circular(sw * 0.05),
            border: Border.all(
              color: _pressed
                  ? PillBinColors.primary.withOpacity(0.35)
                  : PillBinColors.greyLight,
              width: 1.2,
            ),
            boxShadow: _pressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.055),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: PillBinColors.primary.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PillBinColors.primary.withOpacity(0.13),
                        PillBinColors.primary.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(iconBoxSize * 0.32),
                  ),
                  child: Icon(
                    widget.item.icon,
                    size: iconSize,
                    color: PillBinColors.primary,
                  ),
                ),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                flex: 3,
                child: Text(
                  widget.item.label,
                  style: PillBinBold.style(
                    fontSize: labelSize,
                    color: PillBinColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STAGGER WRAPPER (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class AnimatedSuggestionChip extends StatefulWidget {
  final SuggestionItem item;
  final Duration delay;
  final VoidCallback onTap;
  const AnimatedSuggestionChip({
    Key? key,
    required this.item,
    required this.delay,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedSuggestionChip> createState() => _AnimatedSuggestionChipState();
}

class _AnimatedSuggestionChipState extends State<AnimatedSuggestionChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SuggestionChip(item: widget.item, onTap: widget.onTap),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SWIPABLE GRID: 2 top + 2 bottom per page
// ─────────────────────────────────────────────────────────────────────────────

class SuggestionChipsGrid extends StatelessWidget {
  final List<SuggestionItem> items;
  final void Function(SuggestionItem) onTap;

  const SuggestionChipsGrid({
    Key? key,
    required this.items,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;

    // Split into 2 rows
    final row1 = items.sublist(0, (items.length / 2).ceil());
    final row2 = items.sublist((items.length / 2).ceil());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChipRow(items: row1, onTap: onTap, sw: sw),
        SizedBox(height: sw * 0.025),
        _ChipRow(items: row2, onTap: onTap, sw: sw),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CHIP ROW — wraps chips with equal spacing
// ─────────────────────────────────────────────────────────────────────────────

class _ChipRow extends StatelessWidget {
  final List<SuggestionItem> items;
  final void Function(SuggestionItem) onTap;
  final double sw;

  const _ChipRow({
    required this.items,
    required this.onTap,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: items.map((item) {
          return GestureDetector(
            onTap: () => onTap(item),
            child: Container(
              margin: EdgeInsets.only(right: sw * 0.025),
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.045,
                vertical: sw * 0.03,
              ),
              decoration: BoxDecoration(
                color: PillBinColors.surface,
                borderRadius: BorderRadius.circular(sw * 0.06),
                border: Border.all(
                  color: PillBinColors.primary.withOpacity(0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: PillBinColors.primary.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                item.label,
                style: PillBinMedium.style(
                  fontSize: sw * 0.033,
                  color: PillBinColors.textDark,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
