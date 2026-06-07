// Shimmer version of StatCard
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MedicineStatCardShimmer extends StatelessWidget {
  final double sw;
  final double sh;

  const MedicineStatCardShimmer({
    Key? key,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Shimmer.fromColors(
      baseColor: Color.fromARGB(255, 118, 190, 242),
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: isTablet ? sw * 0.15 : null,
        padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.06),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isTablet ? sw * 0.08 : sw * 0.12,
              height: isTablet ? sw * 0.04 : sw * 0.06,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: sh * 0.005),
            Container(
              width: isTablet ? sw * 0.06 : sw * 0.1,
              height: isTablet ? sw * 0.015 : sw * 0.025,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget showing 3 shimmer cards in a row with spacing
class MedicineStatCardShimmerRow extends StatelessWidget {
  final double sw;
  final double sh;

  const MedicineStatCardShimmerRow({
    Key? key,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) {
        return MedicineStatCardShimmer(sw: sw, sh: sh);
      }),
    );
  }
}
