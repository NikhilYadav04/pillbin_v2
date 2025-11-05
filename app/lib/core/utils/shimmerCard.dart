import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCards {
  //* profile header shimmer
  static Widget buildProfileHeaderShimmer(double sw, double sh, bool isTablet) {
    return Shimmer.fromColors(
      baseColor: Color.fromARGB(255, 118, 190, 242), // Very light blue tint
      highlightColor: const Color(0xFFF8FDFF), // Almost white with blue hint
      period:
          const Duration(milliseconds: 1200), // Slower, more subtle animation
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
        margin:
            EdgeInsets.symmetric(horizontal: isTablet ? sw * 0.005 : sw * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 24 : 16),
          border: Border.all(color: const Color(0xFFE1F5FE), width: 1),
        ),
        child: Row(
          children: [
            // Avatar placeholder with gradient-like effect
            Container(
              width: isTablet ? sw * 0.12 : sw * 0.2,
              height: isTablet ? sw * 0.12 : sw * 0.2,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: sw * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name placeholder - slightly rounded corners
                  Container(
                    height: isTablet ? sw * 0.03 : sw * 0.05,
                    width:
                        sw * 0.35, // Slightly shorter for more realistic look
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: sh * 0.012),
                  // Phone placeholder
                  Container(
                    height: isTablet ? sw * 0.022 : sw * 0.035,
                    width: sw * 0.28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(height: sh * 0.008),
                  // Location placeholder
                  Container(
                    height: isTablet ? sw * 0.022 : sw * 0.035,
                    width: sw * 0.42, // Varied width for natural look
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
            // Optional: Add a small shimmer element for edit icon placeholder
            Container(
              width: isTablet ? sw * 0.08 : sw * 0.06,
              height: isTablet ? sw * 0.08 : sw * 0.06,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //* profile stats 3 cards
  static Widget buildProfileStatsShimmer(double sw, double sh, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCardShimmer(sw, sh, isTablet),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: _buildStatCardShimmer(sw, sh, isTablet),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: _buildStatCardShimmer(sw, sh, isTablet),
          ),
        ],
      ),
    );
  }
}

Widget _buildStatCardShimmer(double sw, double sh, bool isTablet) {
  return Shimmer.fromColors(
    baseColor: Color.fromARGB(255, 118, 190, 242), // Very light blue tint
    highlightColor: const Color(0xFFF8FDFF), // Almost white with blue hint
    period: const Duration(milliseconds: 1200),
    child: Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: const Color(0xFFE1F5FE), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Count number placeholder
          Container(
            height: isTablet ? sw * 0.045 : sw * 0.08,
            width: sw * 0.08,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(height: sh * 0.01),
          // Label text placeholder (first line)
          Container(
            height: isTablet ? sw * 0.022 : sw * 0.035,
            width: sw * 0.18,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(height: sh * 0.005),
          // Label text placeholder (second line)
          Container(
            height: isTablet ? sw * 0.022 : sw * 0.035,
            width: sw * 0.15,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    ),
  );
}
