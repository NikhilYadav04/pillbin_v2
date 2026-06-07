import 'package:flutter/material.dart';

// ─── Shimmer animation wrapper ────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius:
                widget.shape == BoxShape.circle ? null : widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: const [
                Color(0xFFE8E8E8),
                Color(0xFFF5F5F5),
                Color(0xFFE8E8E8),
              ],
              transform:
                  _SlidingGradientTransform(slidePercent: _animation.value),
            ),
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0, 0);
  }
}

// ─── Single card shimmer ───────────────────────────────────────────────────────
class _BlogCardShimmer extends StatelessWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const _BlogCardShimmer({
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final double hPad = isTablet ? sw * 0.025 : sw * 0.035;
    final double avatarSize = isTablet ? sw * 0.055 : sw * 0.1;

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.022),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + name + subtitle + menu dot ──
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, hPad * 0.6),
            child: Row(
              children: [
                _ShimmerBox(
                  width: avatarSize,
                  height: avatarSize,
                  shape: BoxShape.circle,
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        width: sw * 0.32,
                        height: 14,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      SizedBox(height: sh * 0.007),
                      _ShimmerBox(
                        width: sw * 0.22,
                        height: 11,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
                // three-dot menu placeholder
                _ShimmerBox(
                  width: 20,
                  height: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),

          // ── Image area ──
          ClipRRect(
            child: _ShimmerBox(
              width: double.infinity,
              height: sh * 0.28,
              borderRadius: BorderRadius.zero,
            ),
          ),

          // ── Tags row ──
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, hPad * 0.8, hPad, hPad * 0.4),
            child: Row(
              children: [
                _ShimmerBox(
                  width: sw * 0.22,
                  height: 26,
                  borderRadius: BorderRadius.circular(20),
                ),
                SizedBox(width: sw * 0.03),
                _ShimmerBox(
                  width: sw * 0.3,
                  height: 26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ],
            ),
          ),

          // ── Text lines ──
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, hPad * 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  width: double.infinity,
                  height: 13,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: sh * 0.008),
                _ShimmerBox(
                  width: sw * 0.75,
                  height: 13,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: sh * 0.008),
                _ShimmerBox(
                  width: sw * 0.4,
                  height: 13,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: sh * 0.01),
                // "Read more" placeholder
                _ShimmerBox(
                  width: sw * 0.2,
                  height: 13,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Divider(height: 1, thickness: 1, color: const Color(0xFFF0F0F0)),

          // ── Action bar: like + comment + share ──
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: hPad * 0.75),
            child: Row(
              children: [
                _ShimmerBox(
                  width: sw * 0.2,
                  height: 30,
                  borderRadius: BorderRadius.circular(20),
                ),
                SizedBox(width: sw * 0.03),
                _ShimmerBox(
                  width: sw * 0.18,
                  height: 30,
                  borderRadius: BorderRadius.circular(20),
                ),
                const Spacer(),
                _ShimmerBox(
                  width: 28,
                  height: 28,
                  borderRadius: BorderRadius.circular(14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Blog Feed Shimmer Widget
/// Loading state for the feed
// ─── Public widget ─────────────────────────────────────────────────────────────
class BlogFeedShimmer extends StatelessWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const BlogFeedShimmer({
    Key? key,
    required this.sw,
    required this.sh,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.05 : sw * 0.04,
        vertical: sh * 0.012,
      ),
      itemCount: 3,
      itemBuilder: (_, index) => _BlogCardShimmer(
        sw: sw,
        sh: sh,
        isTablet: isTablet,
      ),
    );
  }
}
