import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class ActionButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isPrimary;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback onTap;
  final double sw;
  final double sh;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.text,
    this.isPrimary = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    required this.onTap,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.sw > 600;
    Color bgColor = widget.isPrimary
        ? PillBinColors.primary
        : widget.backgroundColor ?? PillBinColors.surface;

    Color textColor = widget.isPrimary
        ? PillBinColors.textWhite
        : widget.textColor ?? PillBinColors.textPrimary;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.isOutlined ? Colors.transparent : bgColor,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          border: widget.isOutlined
              ? Border.all(color: PillBinColors.primary, width: 1.5)
              : null,
          boxShadow: widget.isPrimary
              ? [
                  BoxShadow(
                    color: PillBinColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? widget.sh * 0.025 : widget.sh * 0.02,
                horizontal: isTablet ? widget.sw * 0.03 : widget.sw * 0.05,
              ),
              child: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: textColor,
                    size: isTablet ? widget.sw * 0.03 : widget.sw * 0.05,
                  ),
                  SizedBox(width: widget.sw * 0.03),
                  Text(
                    widget.text,
                    style: PillBinMedium.style(
                      fontSize: isTablet ? widget.sw * 0.025 : widget.sw * 0.04,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
