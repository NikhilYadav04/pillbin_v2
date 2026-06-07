import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/nudge/nudge_manager.dart';
import 'package:pillbin/core/nudge/nudge_model.dart';

/// Wraps [child] and shows queued [nudges] one at a time as slide-up cards.
class NudgeOverlay extends StatefulWidget {
  final Widget child;
  final List<Nudge> nudges;

  const NudgeOverlay({
    Key? key,
    required this.child,
    required this.nudges,
  }) : super(key: key);

  @override
  State<NudgeOverlay> createState() => _NudgeOverlayState();
}

class _NudgeOverlayState extends State<NudgeOverlay>
    with SingleTickerProviderStateMixin {
  late final Queue<Nudge> _queue;
  Nudge? _current;

  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  Timer? _autoTimer;
  Timer? _nextTimer;

  // Drag-to-dismiss state
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _queue = Queue.from(widget.nudges);

    _animController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    // Start the first nudge after initial delay
    if (_queue.isNotEmpty) {
      _nextTimer = Timer(const Duration(seconds: 2), _showNext);
    }
  }

  @override
  void didUpdateWidget(NudgeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nudges arrive asynchronously after evaluation — load them when they come in
    if (oldWidget.nudges.isEmpty &&
        widget.nudges.isNotEmpty &&
        _queue.isEmpty &&
        _current == null) {
      _queue.addAll(widget.nudges);
      _nextTimer?.cancel();
      _nextTimer = Timer(const Duration(seconds: 2), _showNext);
    }
  }

  void _showNext() {
    if (!mounted || _queue.isEmpty) return;
    setState(() {
      _current = _queue.removeFirst();
      _dragOffset = 0;
    });
    _animController.forward(from: 0);
    // Auto-dismiss after 6 seconds
    _autoTimer = Timer(const Duration(seconds: 6), _dismiss);
  }

  Future<void> _dismiss() async {
    _autoTimer?.cancel();
    _nextTimer?.cancel();
    if (!mounted || _current == null) return;

    // Persist seen state for discovery-type nudges
    await NudgeManager().markDiscoverySeen(_current!.type);

    await _animController.reverse();
    if (!mounted) return;
    setState(() {
      _current = null;
      _dragOffset = 0;
    });

    // Show next nudge after a brief pause
    if (_queue.isNotEmpty) {
      _nextTimer = Timer(const Duration(seconds: 2), _showNext);
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (d.delta.dy > 0) {
      setState(() => _dragOffset += d.delta.dy);
    }
  }

  void _onDragEnd(DragEndDetails d) {
    if (_dragOffset > 60 || d.velocity.pixelsPerSecond.dy > 300) {
      _dismiss();
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _nextTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_current != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Transform.translate(
                  offset: Offset(0, _dragOffset),
                  child: GestureDetector(
                    onVerticalDragUpdate: _onDragUpdate,
                    onVerticalDragEnd: _onDragEnd,
                    child: _NudgeCard(
                      nudge: _current!,
                      onDismiss: _dismiss,
                      onAction: _onAction,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onAction(Nudge nudge) {
    _dismiss();
    if (nudge.route != null && mounted) {
      Navigator.pushNamed(
        context,
        nudge.route!,
        arguments: {
          'transition': TransitionType.bottomToTop,
          'duration': 300,
        },
      );
    }
  }
}

// ── NudgeCard ──────────────────────────────────────────────────────────────

class _NudgeCard extends StatelessWidget {
  final Nudge nudge;
  final VoidCallback onDismiss;
  final void Function(Nudge) onAction;

  const _NudgeCard({
    required this.nudge,
    required this.onDismiss,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          sw * 0.04,
          0,
          sw * 0.04,
          sh * 0.015,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              boxShadow: [
                BoxShadow(
                  color: nudge.color.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Colored left accent bar
                    Container(
                      width: sw * 0.012,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            nudge.color,
                            nudge.color.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(sw * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Drag handle
                            Center(
                              child: Container(
                                width: sw * 0.08,
                                height: 3,
                                margin: EdgeInsets.only(bottom: sh * 0.012),
                                decoration: BoxDecoration(
                                  color: PillBinColors.greyLight,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // Header row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon bubble
                                Container(
                                  padding: EdgeInsets.all(sw * 0.025),
                                  decoration: BoxDecoration(
                                    color:
                                        nudge.color.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(isTablet ? 14 : 12),
                                  ),
                                  child: Icon(
                                    nudge.icon,
                                    size: isTablet ? sw * 0.028 : sw * 0.055,
                                    color: nudge.color,
                                  ),
                                ),
                                SizedBox(width: sw * 0.03),
                                // Title + subtitle
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nudge.title,
                                        style: PillBinBold.style(
                                          fontSize:
                                              isTablet ? sw * 0.022 : sw * 0.038,
                                          color: PillBinColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: sh * 0.005),
                                      Text(
                                        nudge.subtitle,
                                        style: PillBinRegular.style(
                                          fontSize:
                                              isTablet ? sw * 0.018 : sw * 0.03,
                                          color: PillBinColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Dismiss ×
                                GestureDetector(
                                  onTap: onDismiss,
                                  child: Container(
                                    padding: EdgeInsets.all(sw * 0.01),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: isTablet ? sw * 0.022 : sw * 0.045,
                                      color: PillBinColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Action button
                            if (nudge.actionLabel != null) ...[
                              SizedBox(height: sh * 0.014),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () => onAction(nudge),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: sw * 0.04,
                                      vertical: sh * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          nudge.color,
                                          nudge.color.withValues(alpha: 0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: nudge.color
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      nudge.actionLabel!,
                                      style: PillBinMedium.style(
                                        fontSize: isTablet
                                            ? sw * 0.018
                                            : sw * 0.03,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
