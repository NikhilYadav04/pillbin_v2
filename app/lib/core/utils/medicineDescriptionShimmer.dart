import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

//* 👉 Single shimmer card
Widget medicineCardShimmer({
  required double sw,
  required double sh,
  required Color baseColor,
  Color highlightColor = Colors.white,
}) {
  final bool isTablet = sw > 600;

  Widget _shimmerBox(double width, double height, {double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  return Shimmer.fromColors(
    baseColor: baseColor,
    highlightColor: highlightColor,
    child: Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row (text + action button)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left text placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(sw * 0.4, sh * 0.025),
                    SizedBox(height: sh * 0.01),
                    _shimmerBox(sw * 0.25, sh * 0.02),
                    SizedBox(height: sh * 0.01),
                    _shimmerBox(sw * 0.2, sh * 0.02),
                    SizedBox(height: sh * 0.01),
                    _shimmerBox(sw * 0.3, sh * 0.02),
                  ],
                ),
              ),
              SizedBox(width: sw * 0.02),
              // Right button placeholder
              _shimmerBox(sw * 0.18, sh * 0.04, radius: 8),
            ],
          ),
        ],
      ),
    ),
  );
}

//* 👉 Widget to show TWO shimmer cards in a column
Widget medicineShimmerList({
  required double sw,
  required double sh,
  required Color baseColor,
  double gap = 16,
}) {
  return Column(
    children: [
      medicineCardShimmer(sw: sw, sh: sh, baseColor: baseColor),
      SizedBox(height: gap),
      medicineCardShimmer(sw: sw, sh: sh, baseColor: baseColor),
    ],
  );
}
