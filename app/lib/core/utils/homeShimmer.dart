import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget homeStatsShimmer({
  required double sw,
  required double sh,
}) {
  final bool isTablet = sw > 600;

  final List<Widget> shimmerCards = List.generate(
    3,
    (_) => _buildStatCardShimmer(sw, sh, isTablet),
  );

  return Padding(
    padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.01),
    child: isTablet
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: shimmerCards,
          )
        : Column(
            children: shimmerCards
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          entry.key != shimmerCards.length - 1 ? sh * 0.025 : 0,
                    ),
                    child: entry.value,
                  ),
                )
                .toList(),
          ),
  );
}

Widget _buildStatCardShimmer(double sw, double sh, bool isTablet) {
  return Container(
    width: isTablet ? sw * 0.25 : double.infinity,
    padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.02),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
    ),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Count number placeholder
          Container(
            height: isTablet ? sw * 0.045 : sw * 0.08,
            width: sw * 0.08,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(height: sh * 0.01),
          // Label text placeholder (first line)
          Container(
            height: isTablet ? sw * 0.022 : sw * 0.035,
            width: sw * 0.18,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(height: sh * 0.005),
          // Label text placeholder (second line)
          Container(
            height: isTablet ? sw * 0.022 : sw * 0.035,
            width: sw * 0.15,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    ),
  );
}
