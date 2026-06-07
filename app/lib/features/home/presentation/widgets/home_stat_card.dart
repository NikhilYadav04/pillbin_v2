import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class StatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final int delay;
  final double sw;
  final double sh;
  final void Function() onTap;

  const StatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    this.delay = 0,
    required this.sw,
    required this.sh,
    required this.onTap,
  }) : super(key: key);

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.sw > 600;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
              onTap: widget.onTap,
              child: Padding(
                padding: EdgeInsets.all(
                    isTablet ? widget.sw * 0.025 : widget.sw * 0.05),
                child: isTablet
                    ? _buildTabletCardContent()
                    : _buildMobileCardContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCardContent() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(widget.sw * 0.03),
          decoration: BoxDecoration(
            color: widget.iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: widget.sw * 0.06,
          ),
        ),
        SizedBox(width: widget.sw * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: PillBinRegular.style(
                  fontSize: widget.sw * 0.035,
                  color: PillBinColors.textSecondary,
                ),
              ),
              SizedBox(height: widget.sh * 0.005),
              Text(
                widget.value,
                style: PillBinBold.style(
                  fontSize: widget.sw * 0.07,
                  color: PillBinColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(widget.sw * 0.02),
          decoration: BoxDecoration(
            color: widget.iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: widget.sw * 0.04,
          ),
        ),
        SizedBox(height: widget.sh * 0.02),
        Text(
          widget.title,
          style: PillBinRegular.style(
            fontSize: widget.sw * 0.025,
            color: PillBinColors.textSecondary,
          ),
        ),
        SizedBox(height: widget.sh * 0.01),
        Text(
          widget.value,
          style: PillBinBold.style(
            fontSize: widget.sw * 0.045,
            color: PillBinColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
