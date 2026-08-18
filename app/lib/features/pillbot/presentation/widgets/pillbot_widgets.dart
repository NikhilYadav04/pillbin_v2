import 'package:flutter/material.dart';
import 'package:pillbin/features/pillbot/presentation/widgets/sugeestion_chips.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/pillbot/data/model/message_model.dart';

// ─── Responsive helpers ───────────────────────────────────────────────────────
extension ResponsiveCtx on BuildContext {
  double get sw => MediaQuery.of(this).size.width;
  double get sh => MediaQuery.of(this).size.height;
  bool get isTablet => MediaQuery.of(this).size.width >= 600;
}

// ─── Suggestion Model ─────────────────────────────────────────────────────────
class SuggestionItem {
  final String label;
  final String description;
  final IconData icon;
  const SuggestionItem(
      {required this.label, required this.description, required this.icon});
}

const List<SuggestionItem> kSuggestions = [
  SuggestionItem(
    label: 'Show my active medicines list',
    description: '',
    icon: Icons.medication_outlined,
  ),
  SuggestionItem(
    label: 'Find nearby medical centers around 30 km',
    description: '',
    icon: Icons.local_hospital_outlined,
  ),
  SuggestionItem(
    label: 'Side Effects of Paracetamol',
    description: '',
    icon: Icons.warning_amber_rounded,
  ),
  SuggestionItem(
    label: 'Check my sugar level from my reports',
    description: '',
    icon: Icons.document_scanner_outlined,
  ),
  SuggestionItem(
    label: 'Show me medicine analytics',
    description: '',
    icon: Icons.analytics_outlined,
  ),
  SuggestionItem(
    label: 'Is Arogya Medical Center available?',
    description: '',
    icon: Icons.local_pharmacy_outlined,
  ),
];

const List<SuggestionItem> kVendorSuggestions = [
  SuggestionItem(
    label: 'Show my pending donation requests',
    description: '',
    icon: Icons.pending_actions_outlined,
  ),
  SuggestionItem(
    label: 'How is my center performing?',
    description: '',
    icon: Icons.insights_outlined,
  ),
  SuggestionItem(
    label: 'What medicines were donated to my center?',
    description: '',
    icon: Icons.inventory_2_outlined,
  ),
  SuggestionItem(
    label: 'Show my center rating and reviews',
    description: '',
    icon: Icons.star_outline_rounded,
  ),
  SuggestionItem(
    label: 'Any new notifications for me?',
    description: '',
    icon: Icons.notifications_none_rounded,
  ),
  SuggestionItem(
    label: 'How should expired medicines be disposed?',
    description: '',
    icon: Icons.recycling_outlined,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED ATOMS
// ─────────────────────────────────────────────────────────────────────────────

/// Bot avatar — gradient pill icon.
class BotAvatar extends StatelessWidget {
  final double size;
  const BotAvatar({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PillBinColors.primaryDark, PillBinColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.medication_rounded,
          color: PillBinColors.textWhite, size: size * 0.5),
    );
  }
}

/// User avatar — initial letter.
class UserAvatar extends StatelessWidget {
  final String initial;
  final double size;
  const UserAvatar({Key? key, required this.initial, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: PillBinColors.background,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: PillBinColors.greyLight),
      ),
      child: Center(
        child: Text(
          initial.toUpperCase(),
          style: PillBinMedium.style(
              fontSize: size * 0.38, color: PillBinColors.primary),
        ),
      ),
    );
  }
}

class AttachmentChip extends StatelessWidget {
  final String filename;
  final VoidCallback? onRemove; // null = inside a sent bubble (no remove)
  const AttachmentChip({Key? key, required this.filename, this.onRemove})
      : super(key: key);

  IconData _icon() {
    final ext = filename.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext))
      return Icons.image_rounded;
    if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['doc', 'docx'].contains(ext)) return Icons.description_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color _iconColor() {
    final ext = filename.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext))
      return const Color(0xFF10B981); // green for images
    if (ext == 'pdf') return const Color(0xFFEF4444); // red for pdf
    return PillBinColors.info;
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    final iconSize = sw * 0.05;
    final iconBoxSize = sw * 0.09;
    final nameSize = sw * 0.03;
    final extSize = sw * 0.026;
    final ext = filename.split('.').last.toUpperCase();
    final nameOnly = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: sw * 0.028, vertical: sw * 0.018),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(color: _iconColor().withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: _iconColor().withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File type icon box
          Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: _iconColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(iconBoxSize * 0.25),
            ),
            child: Icon(_icon(), size: iconSize, color: _iconColor()),
          ),
          SizedBox(width: sw * 0.022),
          // Name + ext
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: sw * 0.32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nameOnly,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: PillBinMedium.style(
                      fontSize: nameSize, color: PillBinColors.textDark),
                ),
                SizedBox(height: sw * 0.004),
                Text(
                  ext,
                  style: PillBinRegular.style(
                      fontSize: extSize, color: _iconColor()),
                ),
              ],
            ),
          ),
          // Remove button (only in input preview, not in sent bubble)
          if (onRemove != null) ...[
            SizedBox(width: sw * 0.018),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: sw * 0.055,
                height: sw * 0.055,
                decoration: BoxDecoration(
                  color: PillBinColors.greyLight,
                  borderRadius: BorderRadius.circular(sw * 0.055),
                ),
                child: Icon(Icons.close_rounded,
                    size: sw * 0.032, color: PillBinColors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHIMMER LOADER
// ─────────────────────────────────────────────────────────────────────────────
class ShimmerMessageLoader extends StatelessWidget {
  const ShimmerMessageLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.03),
      child: Shimmer.fromColors(
        baseColor: PillBinColors.greyLight,
        highlightColor: PillBinColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerRow(sw: sw, isUser: false, widthFactor: 0.65),
            SizedBox(height: sw * 0.04),
            _ShimmerRow(sw: sw, isUser: true, widthFactor: 0.50),
            SizedBox(height: sw * 0.04),
            _ShimmerRow(sw: sw, isUser: false, widthFactor: 0.75),
            SizedBox(height: sw * 0.04),
            _ShimmerRow(sw: sw, isUser: true, widthFactor: 0.55),
            SizedBox(height: sw * 0.04),
            _ShimmerRow(sw: sw, isUser: false, widthFactor: 0.68),
            SizedBox(height: sw * 0.04),
            _ShimmerRow(sw: sw, isUser: true, widthFactor: 0.75),
          ],
        ),
      ),
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  final double sw;
  final bool isUser;
  final double widthFactor;
  const _ShimmerRow(
      {required this.sw, required this.isUser, required this.widthFactor});

  @override
  Widget build(BuildContext context) {
    final avatarSize = sw * 0.09;
    final radius = sw * 0.04;
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser) ...[
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(avatarSize * 0.28)),
          ),
          SizedBox(width: sw * 0.02),
        ],
        Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              width: sw * widthFactor,
              height: sw * 0.13,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  topRight: Radius.circular(radius),
                  bottomLeft: Radius.circular(isUser ? radius : 4),
                  bottomRight: Radius.circular(isUser ? 4 : radius),
                ),
              ),
            ),
            SizedBox(height: sw * 0.012),
            Container(
              width: sw * 0.14,
              height: sw * 0.025,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(sw * 0.01)),
            ),
          ],
        ),
        if (isUser) ...[
          SizedBox(width: sw * 0.02),
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(avatarSize * 0.28)),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TYPING INDICATOR
// ─────────────────────────────────────────────────────────────────────────────

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    final avatarSize = sw * 0.09;

    return Container(
      margin: EdgeInsets.only(bottom: sw * 0.03),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          BotAvatar(size: avatarSize),
          SizedBox(width: sw * 0.02),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04, vertical: sw * 0.03),
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                    color: PillBinColors.primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        PillBinColors.primaryDark,
                        PillBinColors.primaryLight,
                        PillBinColors.primaryDark,
                      ],
                      stops: [
                        (_anim.value - 0.3).clamp(0.0, 1.0),
                        _anim.value.clamp(0.0, 1.0),
                        (_anim.value + 0.3).clamp(0.0, 1.0),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'Thinking...',
                      style: PillBinMedium.style(
                        fontSize: sw * 0.038,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.02),
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    return Row(
                      children: List.generate(3, (i) {
                        final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
                        final bounce = (offset < 0.5 ? offset : 1 - offset) * 2;
                        return Transform.translate(
                          offset: Offset(0, -sw * 0.015 * bounce),
                          child: Container(
                            margin: EdgeInsets.only(left: sw * 0.01),
                            width: sw * 0.015,
                            height: sw * 0.015,
                            decoration: BoxDecoration(
                              color: PillBinColors.primary
                                  .withOpacity(0.4 + 0.6 * bounce),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class EmptyStateView extends StatefulWidget {
  final void Function(String) onSuggestionTap;
  final bool isVendor;
  const EmptyStateView(
      {Key? key, required this.onSuggestionTap, this.isVendor = false})
      : super(key: key);

  @override
  State<EmptyStateView> createState() => _EmptyStateViewState();
}

class _EmptyStateViewState extends State<EmptyStateView>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    final sh = context.sh;
    final isTablet = context.isTablet;
    final heroSize = sw * (isTablet ? 0.14 : 0.2);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(horizontal: sw * 0.06, vertical: sh * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: sh * 0.02),

              // Hero icon
              Container(
                width: heroSize,
                height: heroSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      PillBinColors.primaryDark,
                      PillBinColors.primaryLight
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(heroSize * 0.28),
                  boxShadow: [
                    BoxShadow(
                      color: PillBinColors.primary.withOpacity(0.28),
                      blurRadius: heroSize * 0.5,
                      offset: Offset(0, heroSize * 0.18),
                    ),
                  ],
                ),
                child: Icon(
                    widget.isVendor
                        ? Icons.local_hospital_rounded
                        : Icons.medication_rounded,
                    color: PillBinColors.textWhite,
                    size: heroSize * 0.5),
              ),

              SizedBox(height: sh * 0.025),

              Text(
                widget.isVendor ? 'PillBot for Centers 🏥' : 'Hi! I\'m PillBot 👋',
                textAlign: TextAlign.center,
                style: PillBinBold.style(
                  fontSize: sw * (isTablet ? 0.034 : 0.054),
                  color: PillBinColors.textDark,
                ),
              ),

              SizedBox(height: sh * 0.01),

              // 1–2 line subtitle
              Text(
                widget.isVendor
                    ? 'Your assistant for donation requests,\ncenter performance & notifications.'
                    : 'Your AI health companion for medicines,\nsymptoms & general health queries.',
                textAlign: TextAlign.center,
                style: PillBinRegular.style(
                  fontSize: sw * (isTablet ? 0.021 : 0.035),
                  color: PillBinColors.textSecondary,
                ),
              ),

              SizedBox(height: sh * 0.035),

              // Section label
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'TRY ASKING ABOUT',
                  style: PillBinMedium.style(
                    fontSize: sw * (isTablet ? 0.017 : 0.027),
                    color: PillBinColors.textLight,
                  ),
                ),
              ),

              SizedBox(height: sw * 0.03),

              // Horizontal floating chip row
              SuggestionChipsGrid(
                items: widget.isVendor ? kVendorSuggestions : kSuggestions,
                onTap: (item) => widget.onSuggestionTap(item.label),
              ),

              SizedBox(height: sh * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────────────────────────────────────
class PillBotHeader extends StatelessWidget {
  final bool isTyping;
  final int messageCount;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onClearHistory;
  final VoidCallback onClearMemory;

  const PillBotHeader({
    Key? key,
    required this.isTyping,
    required this.messageCount,
    required this.onBack,
    required this.onRefresh,
    required this.onClearHistory,
    required this.onClearMemory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    final isTablet = context.isTablet;
    final hPad = sw * (isTablet ? 0.04 : 0.04);
    final vPad = sw * (isTablet ? 0.03 : 0.038);
    final iconSize = sw * (isTablet ? 0.022 : 0.046);
    final avatarSize = sw * (isTablet ? 0.07 : 0.105);
    final titleSize = sw * (isTablet ? 0.028 : 0.046);
    final subSize = sw * (isTablet ? 0.018 : 0.03);
    final dotSize = sw * (isTablet ? 0.016 : 0.02);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PillBinColors.primaryDark,
            PillBinColors.primary,
            PillBinColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
      child: Row(
        children: [
          BotAvatar(size: avatarSize),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('PillBot',
                    style: PillBinBold.style(
                        fontSize: titleSize, color: PillBinColors.textWhite)),
                SizedBox(height: sw * 0.005),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: dotSize,
                      height: dotSize,
                      decoration: BoxDecoration(
                        color: isTyping
                            ? PillBinColors.warning
                            : PillBinColors.success,
                        borderRadius: BorderRadius.circular(dotSize),
                      ),
                    ),
                    SizedBox(width: sw * 0.015),
                    Text(
                      isTyping ? 'Typing...' : 'Online · Health AI',
                      style: PillBinRegular.style(
                        fontSize: subSize,
                        color: PillBinColors.textWhite.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Clear Memory',
            child: _HBtn(
                icon: Icons.memory_rounded,
                size: iconSize,
                onTap: onClearMemory,
                tooltip: 'Clear Memory'),
          ),
          SizedBox(width: sw * 0.02),
          Tooltip(
            message: 'Clear History',
            child: _HBtn(
                icon: Icons.delete_outline_rounded,
                size: iconSize,
                onTap: onClearHistory,
                tooltip: 'Clear History'),
          ),
          SizedBox(width: sw * 0.02),
          Tooltip(
            message: 'Refresh',
            child: _HBtn(
                icon: Icons.refresh_rounded,
                size: iconSize,
                onTap: onRefresh,
                tooltip: 'Refresh'),
          ),
        ],
      ),
    );
  }
}

class _HBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final String tooltip;
  const _HBtn(
      {required this.icon,
      required this.size,
      required this.onTap,
      required this.tooltip});

  @override
  Widget build(BuildContext context) {
    final btnSize = size * 2.2;
    final sw = context.sw;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: btnSize,
        height: btnSize,
        decoration: BoxDecoration(
          color: PillBinColors.textWhite.withOpacity(0.18),
          borderRadius: BorderRadius.circular(sw * 0.022),
        ),
        child: Icon(icon, color: PillBinColors.textWhite, size: size),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MESSAGE INPUT BAR
// ─────────────────────────────────────────────────────────────────────────────
class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final List<String> pendingFiles;
  final VoidCallback onSend;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  // New
  final bool locationSuggestionVisible;
  final bool locationEnabled;
  final ValueChanged<bool> onLocationToggle;

  const MessageInputBar({
    Key? key,
    required this.controller,
    required this.isTyping,
    required this.pendingFiles,
    required this.onSend,
    required this.onPickFile,
    required this.onRemoveFile,
    this.locationSuggestionVisible = false,
    this.locationEnabled = false,
    required this.onLocationToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    final isTablet = context.isTablet;
    final hPad = sw * (isTablet ? 0.04 : 0.035);
    final vPad = sw * (isTablet ? 0.03 : 0.03);
    final btnSize = sw * (isTablet ? 0.09 : 0.115);
    final iconSize = sw * (isTablet ? 0.034 : 0.046);
    final fieldRadius = sw * 0.04;
    final hintSize = sw * (isTablet ? 0.02 : 0.034);
    final textSize = sw * (isTablet ? 0.022 : 0.037);

    return Container(
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        boxShadow: [
          BoxShadow(
            color: PillBinColors.primary.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          hPad,
          (pendingFiles.isNotEmpty || locationSuggestionVisible)
              ? sw * 0.02
              : vPad,
          hPad,
          vPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Location suggestion banner ──────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: locationSuggestionVisible
                ? _LocationBanner(
                    sw: sw,
                    enabled: locationEnabled,
                    onToggle: onLocationToggle,
                  )
                : const SizedBox.shrink(),
          ),

          // ── File preview ────────────────────────────────────────────
          if (pendingFiles.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: sw * 0.025),
              child: AttachmentChip(
                filename: pendingFiles.first,
                onRemove: onRemoveFile,
              ),
            ),

          // ── Input row ───────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: isTyping ? null : onPickFile,
                child: Container(
                  width: btnSize,
                  height: btnSize,
                  margin: EdgeInsets.only(right: sw * 0.02),
                  decoration: BoxDecoration(
                    color: PillBinColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    border: Border.all(color: PillBinColors.greyLight),
                  ),
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: isTyping
                        ? PillBinColors.inactive
                        : PillBinColors.primary,
                    size: iconSize,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: PillBinColors.background,
                    borderRadius: BorderRadius.circular(fieldRadius),
                    border: Border.all(color: PillBinColors.greyLight),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: 4,
                    minLines: 1,
                    enabled: !isTyping,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    style: PillBinRegular.style(
                        fontSize: textSize, color: PillBinColors.textDark),
                    decoration: InputDecoration(
                      hintText: isTyping
                          ? 'PillBot is responding...'
                          : 'Ask me anything...',
                      hintStyle: PillBinRegular.style(
                          fontSize: hintSize, color: PillBinColors.textLight),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: sw * 0.035, vertical: sw * 0.028),
                    ),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.02),
              GestureDetector(
                onTap: isTyping ? null : onSend,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: btnSize,
                  height: btnSize,
                  decoration: BoxDecoration(
                    gradient: isTyping
                        ? null
                        : const LinearGradient(
                            colors: [
                              PillBinColors.primaryDark,
                              PillBinColors.primary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: isTyping ? PillBinColors.greyLight : null,
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    boxShadow: isTyping
                        ? []
                        : [
                            BoxShadow(
                              color: PillBinColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: isTyping
                        ? PillBinColors.inactive
                        : PillBinColors.textWhite,
                    size: iconSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Location banner widget ─────────────────────────────────────────────────

class _LocationBanner extends StatelessWidget {
  final double sw;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _LocationBanner({
    required this.sw,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(bottom: sw * 0.022),
      padding:
          EdgeInsets.symmetric(horizontal: sw * 0.035, vertical: sw * 0.022),
      decoration: BoxDecoration(
        color: enabled
            ? PillBinColors.primary.withOpacity(0.08)
            : PillBinColors.background,
        borderRadius: BorderRadius.circular(sw * 0.03),
        border: Border.all(
          color: enabled
              ? PillBinColors.primary.withOpacity(0.4)
              : PillBinColors.greyLight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: sw * 0.042,
            color: enabled ? PillBinColors.primary : PillBinColors.textLight,
          ),
          SizedBox(width: sw * 0.022),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Include my location',
                  style: PillBinMedium.style(
                    fontSize: sw * 0.033,
                    color: enabled
                        ? PillBinColors.primary
                        : PillBinColors.textDark,
                  ),
                ),
                Text(
                  'Adds your profile location to this query',
                  style: PillBinRegular.style(
                    fontSize: sw * 0.027,
                    color: PillBinColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: enabled,
              onChanged: onToggle,
              activeColor: PillBinColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class PaginationLoader extends StatelessWidget {
  const PaginationLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * 0.04),
      child: Center(
        child: SizedBox(
          width: sw * 0.055,
          height: sw * 0.055,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: PillBinColors.primary,
          ),
        ),
      ),
    );
  }
}

class _FadeInOnce extends StatefulWidget {
  final String id;
  final bool enabled;
  final Widget child;

  const _FadeInOnce({
    required this.id,
    required this.enabled,
    required this.child,
  });

  @override
  State<_FadeInOnce> createState() => _FadeInOnceState();
}

class _FadeInOnceState extends State<_FadeInOnce> {
  static final Set<String> _played = <String>{};
  late final bool _play;

  @override
  void initState() {
    super.initState();
    _play = widget.enabled && widget.id.isNotEmpty && !_played.contains(widget.id);
    if (_play) {
      if (_played.length > 400) _played.clear();
      _played.add(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_play) return widget.child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      child: widget.child,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String userInitial;
  final bool animateIn;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.userInitial,
    this.animateIn = false,
  }) : super(key: key);

  bool get _isUser => message.role == MessageRole.user;
  bool get _isError =>
      message.message.trimLeft().toLowerCase().startsWith('error');
  bool get _hasTable =>
      message.isTable == true &&
      message.tableColumns != null &&
      message.tableRows != null;

  bool get _isLowConfidence =>
      !_isUser && (message.confidence != null && message.confidence! < 0.6);

  String _time(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    final isTablet = context.isTablet;
    final avatarSize = sw * (isTablet ? 0.07 : 0.09);
    final hPad = sw * (isTablet ? 0.03 : 0.035);
    final vPad = sw * (isTablet ? 0.025 : 0.028);
    final radius = sw * (isTablet ? 0.03 : 0.04);
    final maxWidth = sw * (isTablet ? 0.65 : 0.72);
    final textSize = sw * (isTablet ? 0.022 : 0.037);
    final timeSize = sw * (isTablet ? 0.018 : 0.028);

    final Border? bubbleBorder = _isUser
        ? Border.all(color: PillBinColors.textWhite, width: 1)
        : _isError
            ? Border.all(color: PillBinColors.error, width: 1)
            : _isLowConfidence
                ? Border.all(color: PillBinColors.warning, width: 1)
                : Border.all(color: PillBinColors.primary, width: 1);

    final Color bubbleBg = _isUser
        ? Colors.transparent
        : _isError
            ? PillBinColors.error.withOpacity(0.06)
            : _isLowConfidence
                ? PillBinColors.warning.withOpacity(0.05)
                : PillBinColors.surface;

    final Color textColor = _isUser
        ? PillBinColors.textWhite
        : _isError
            ? PillBinColors.error
            : PillBinColors.textDark;

    return _FadeInOnce(
      id: message.id,
      enabled: animateIn,
      child: Tooltip(
      message: _isLowConfidence
          ? 'PillBot is not fully confident in this response. Please verify with a healthcare professional.'
          : '',
      triggerMode: _isLowConfidence
          ? TooltipTriggerMode.longPress
          : TooltipTriggerMode.manual,
      preferBelow: false,
      decoration: BoxDecoration(
        color: PillBinColors.warning.withOpacity(0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: PillBinRegular.style(
        fontSize: sw * 0.028,
        color: Colors.white,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: sw * 0.035),
        child: Row(
          mainAxisAlignment:
              _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!_isUser) ...[
              BotAvatar(size: avatarSize),
              SizedBox(width: sw * 0.02),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    decoration: BoxDecoration(
                      gradient: _isUser
                          ? const LinearGradient(
                              colors: [
                                PillBinColors.primaryDark,
                                PillBinColors.primary
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: bubbleBg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(radius),
                        topRight: Radius.circular(radius),
                        bottomLeft: Radius.circular(_isUser ? radius : 4),
                        bottomRight: Radius.circular(_isUser ? 4 : radius),
                      ),
                      border: bubbleBorder,
                      boxShadow: [
                        BoxShadow(
                          color: _isUser
                              ? PillBinColors.primary
                              : _isError
                                  ? PillBinColors.error.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _hasTable && !_isUser
                        ? _TableBubbleContent(
                            leadingText: message.message,
                            columns: message.tableColumns!,
                            rows: message.tableRows!,
                            textSize: textSize,
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: hPad, vertical: vPad),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_isError && !_isUser)
                                  Padding(
                                    padding:
                                        EdgeInsets.only(bottom: sw * 0.012),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.error_outline_rounded,
                                            size: sw * 0.038,
                                            color: PillBinColors.error),
                                        SizedBox(width: sw * 0.014),
                                        Text('Error',
                                            style: PillBinBold.style(
                                                fontSize: sw * 0.032,
                                                color: PillBinColors.error)),
                                      ],
                                    ),
                                  ),
                                _isUser
                                    ? Text(
                                        message.message,
                                        style: PillBinRegular.style(
                                            fontSize: textSize,
                                            color: textColor),
                                      )
                                    : SelectableText(
                                        message.message,
                                        style: PillBinRegular.style(
                                            fontSize: textSize,
                                            color: textColor),
                                      ),
                              ],
                            ),
                          ),
                  ),
                  SizedBox(height: sw * 0.01),
                  Text(
                    _time(message.timestamp),
                    style: PillBinLight.style(
                        fontSize: timeSize, color: PillBinColors.textLight),
                  ),
                ],
              ),
            ),
            if (_isUser) ...[
              SizedBox(width: sw * 0.02),
              UserAvatar(initial: userInitial, size: avatarSize),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  4. TABLE BUBBLE CONTENT  (markdown pipe-table → DataTable)
// ─────────────────────────────────────────────────────────────────────────────

class _TableBubbleContent extends StatelessWidget {
  final String leadingText;
  final List<String> columns;
  final List<List<String>> rows;
  final double textSize;

  const _TableBubbleContent({
    required this.leadingText,
    required this.columns,
    required this.rows,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    final sw = context.sw;
    return Padding(
      padding: EdgeInsets.all(sw * 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leadingText.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: sw * 0.02),
              child: Text(leadingText,
                  style: PillBinRegular.style(
                      fontSize: textSize, color: PillBinColors.textDark)),
            ),
          Container(
            decoration: BoxDecoration(
              color: PillBinColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PillBinColors.primary.withOpacity(0.2)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                    PillBinColors.primary.withOpacity(0.09)),
                dataRowMinHeight: sw * 0.09,
                dataRowMaxHeight: sw * 0.13,
                border: TableBorder(
                  horizontalInside:
                      BorderSide(color: PillBinColors.greyLight, width: 0.8),
                ),
                headingTextStyle: PillBinBold.style(
                    fontSize: sw * 0.031, color: PillBinColors.primary),
                dataTextStyle: PillBinRegular.style(
                    fontSize: sw * 0.03, color: PillBinColors.textDark),
                columns:
                    columns.map((c) => DataColumn(label: Text(c))).toList(),
                rows: rows
                    .map((row) => DataRow(
                          cells: List.generate(
                            columns.length,
                            (i) => DataCell(Text(i < row.length ? row[i] : '')),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── markdown table parser ─────────────────────────────────────────────────

List<Map<String, dynamic>> _split(String text) {
  final lines = text.split('\n');
  final result = <Map<String, dynamic>>[];
  final textBuf = <String>[];
  final tableBuf = <String>[];
  bool inTable = false;

  for (final line in lines) {
    if (line.trim().startsWith('|')) {
      if (!inTable) {
        if (textBuf.isNotEmpty) {
          result.add({'type': 'text', 'content': textBuf.join('\n')});
          textBuf.clear();
        }
        inTable = true;
      }
      tableBuf.add(line);
    } else {
      if (inTable) {
        result.add({'type': 'table', 'rows': _parseRows(tableBuf)});
        tableBuf.clear();
        inTable = false;
      }
      textBuf.add(line);
    }
  }

  if (inTable && tableBuf.isNotEmpty) {
    result.add({'type': 'table', 'rows': _parseRows(tableBuf)});
  }
  if (textBuf.isNotEmpty) {
    result.add({'type': 'text', 'content': textBuf.join('\n')});
  }
  return result;
}

List<List<String>> _parseRows(List<String> lines) {
  final rows = <List<String>>[];
  for (final line in lines) {
    // skip separator: |---|---|
    if (RegExp(r'^\|[\s\-\|:]+\|$').hasMatch(line.trim())) continue;
    final cells = line
        .split('|')
        .where((c) => c.isNotEmpty)
        .map((c) => c.trim())
        .toList();
    if (cells.isNotEmpty) rows.add(cells);
  }
  return rows;
}
