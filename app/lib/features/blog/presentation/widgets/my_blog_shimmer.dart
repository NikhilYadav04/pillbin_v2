import 'package:flutter/material.dart';

class BlogShimmerGrid extends StatefulWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const BlogShimmerGrid({
    Key? key,
    required this.sw,
    required this.sh,
    required this.isTablet,
  }) : super(key: key);

  @override
  State<BlogShimmerGrid> createState() => _BlogShimmerGridState();
}

class _BlogShimmerGridState extends State<BlogShimmerGrid>
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
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
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
    final double radius = widget.isTablet ? 16.0 : 12.0;
    final double spacing = widget.sw * 0.02;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? widget.sw * 0.05 : widget.sw * 0.04,
            vertical: widget.sh * 0.01,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 0.75,
          ),
          itemCount: 9,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.0, 0.5, 1.0],
                colors: const [
                  Color(0xFFE8E8E8),
                  Color(0xFFF5F5F5),
                  Color(0xFFE8E8E8),
                ],
                transform: _SlidingGradientTransform(
                  slidePercent: _animation.value,
                ),
              ),
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
