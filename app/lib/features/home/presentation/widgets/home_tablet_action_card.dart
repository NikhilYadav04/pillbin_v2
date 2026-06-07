import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class TabletActionButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isPrimary;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback onTap;
  final double sw;
  final double sh;

  const TabletActionButton({
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
  State<TabletActionButton> createState() => _TabletActionButtonState();
}

class _TabletActionButtonState extends State<TabletActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: widget.sh * 0.018,
                horizontal: widget.sw * 0.015,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: widget.sw * 0.06,
                    height: widget.sw * 0.06,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: textColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: textColor,
                        size: widget.sw * 0.03,
                      ),
                    ),
                  ),
                  SizedBox(height: widget.sh * 0.008),
                  Text(
                    widget.text,
                    style: PillBinMedium.style(
                      fontSize: widget.sw * 0.02,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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