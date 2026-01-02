import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class SaveReportDialog extends StatefulWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const SaveReportDialog({
    Key? key,
    required this.sw,
    required this.sh,
    required this.isTablet,
  }) : super(key: key);

  @override
  State<SaveReportDialog> createState() => _SaveReportDialogState();
}

class _SaveReportDialogState extends State<SaveReportDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: PillBinColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Save Your Report and Queries',
        style: PillBinBold.style(
          fontSize: widget.isTablet ? widget.sw * 0.025 : widget.sw * 0.045,
          color: PillBinColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter PDF Description',
            style: PillBinMedium.style(
              fontSize: widget.isTablet ? widget.sw * 0.02 : widget.sw * 0.036,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: widget.sh * 0.015),
          Container(
            decoration: BoxDecoration(
              color: PillBinColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PillBinColors.greyLight.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 4,
              style: PillBinRegular.style(
                fontSize:
                    widget.isTablet ? widget.sw * 0.02 : widget.sw * 0.036,
                color: PillBinColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter a description for this PDF...',
                hintStyle: PillBinRegular.style(
                  fontSize:
                      widget.isTablet ? widget.sw * 0.02 : widget.sw * 0.036,
                  color: PillBinColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(widget.sw * 0.03),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          child: Text(
            'Cancel',
            style: PillBinMedium.style(
              fontSize: widget.isTablet ? widget.sw * 0.02 : widget.sw * 0.036,
              color: PillBinColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final description = _controller.text.trim();
            Navigator.pop(context, description);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: PillBinColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Save',
            style: PillBinMedium.style(
              fontSize: widget.isTablet ? widget.sw * 0.02 : widget.sw * 0.036,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
