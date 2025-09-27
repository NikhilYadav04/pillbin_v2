import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';

class InventoryListShimmer extends StatefulWidget {
  final Color? shimmerColor;
  final int itemCount;

  const InventoryListShimmer({
    Key? key,
    this.shimmerColor,
    this.itemCount = 6,
  }) : super(key: key);

  @override
  State<InventoryListShimmer> createState() => _InventoryListShimmerState();
}

class _InventoryListShimmerState extends State<InventoryListShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return ListView.builder(
      padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: sh * 0.02),
          child: _buildMedicineCardShimmer(sw, sh, isTablet),
        );
      },
    );
  }

  Widget _buildMedicineCardShimmer(double sw, double sh, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: PillBinColors.greyLight.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with medicine name and status
          Row(
            children: [
              Expanded(
                child: _buildShimmerBox(
                  width: sw * 0.5,
                  height: isTablet ? sw * 0.03 : sw * 0.045,
                ),
              ),
              SizedBox(width: sw * 0.03),
              _buildShimmerBox(
                width: sw * 0.2,
                height: isTablet ? sw * 0.025 : sw * 0.035,
                borderRadius: 8,
              ),
            ],
          ),

          SizedBox(height: sh * 0.015),

          // Medicine details rows
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'Quantity',
                  sw * 0.25,
                  sw,
                  sh,
                  isTablet,
                ),
              ),
              SizedBox(width: sw * 0.04),
              Expanded(
                child: _buildInfoRow(
                  'Expiry',
                  sw * 0.3,
                  sw,
                  sh,
                  isTablet,
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.01),

          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  'Added',
                  sw * 0.28,
                  sw,
                  sh,
                  isTablet,
                ),
              ),
              SizedBox(width: sw * 0.04),
              Expanded(
                child: _buildInfoRow(
                  'Status',
                  sw * 0.32,
                  sw,
                  sh,
                  isTablet,
                ),
              ),
            ],
          ),

          SizedBox(height: sh * 0.015),

          // Notes section
          _buildShimmerBox(
            width: sw * 0.7,
            height: isTablet ? sw * 0.02 : sw * 0.032,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, double valueWidth, double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmerBox(
          width: sw * 0.15,
          height: isTablet ? sw * 0.018 : sw * 0.028,
        ),
        SizedBox(height: sh * 0.005),
        _buildShimmerBox(
          width: valueWidth,
          height: isTablet ? sw * 0.02 : sw * 0.032,
        ),
      ],
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 6,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: [
                widget.shimmerColor?.withOpacity(0.1) ??
                    PillBinColors.greyLight.withOpacity(0.2),
                widget.shimmerColor?.withOpacity(0.3) ??
                    PillBinColors.greyLight.withOpacity(0.4),
                widget.shimmerColor?.withOpacity(0.1) ??
                    PillBinColors.greyLight.withOpacity(0.2),
              ],
            ),
          ),
        );
      },
    );
  }
}
