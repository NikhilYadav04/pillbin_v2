import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

const Map<String, String> kStatusLabels = {
  'pending': 'Submitted',
  'approved': 'Approved',
  'rejected': 'Rejected',
  'completed': 'Completed',
  'cancelled': 'Cancelled',
};

const Map<String, IconData> kStatusIcons = {
  'pending': Icons.schedule_outlined,
  'approved': Icons.check_circle_outline,
  'rejected': Icons.highlight_off_outlined,
  'completed': Icons.done_all_outlined,
  'cancelled': Icons.block_outlined,
};

Color statusColorFor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'approved':
      return Colors.green;
    case 'completed':
      return PillBinColors.primary;
    case 'rejected':
      return Colors.red;
    default:
      return PillBinColors.textSecondary;
  }
}

class StatusTimeline extends StatefulWidget {
  final List<dynamic>? history;
  final String currentStatus;
  final String? createdAt;

  const StatusTimeline({
    Key? key,
    required this.history,
    required this.currentStatus,
    this.createdAt,
  }) : super(key: key);

  @override
  State<StatusTimeline> createState() => _StatusTimelineState();
}

class _StatusTimelineState extends State<StatusTimeline> {
  bool _expanded = false;

  /// Requests created before statusHistory existed have none — show the
  /// current state alone rather than an empty timeline.
  List<Map<String, dynamic>> get _entries {
    final raw = widget.history;
    if (raw == null || raw.isEmpty) {
      return [
        {'status': widget.currentStatus, 'at': widget.createdAt},
      ];
    }
    return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  String _format(String? iso) {
    if (iso == null) return '';
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return '';
    final d = parsed.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour < 12 ? 'AM' : 'PM';
    return '${months[d.month - 1]} ${d.day}, $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final entries = _entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: sh * 0.008),
            child: Row(
              children: [
                Icon(Icons.timeline_outlined,
                    size: sw * 0.038, color: PillBinColors.textSecondary),
                SizedBox(width: sw * 0.02),
                Text(
                  _expanded
                      ? 'Hide timeline'
                      : 'View timeline (${entries.length})',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.031,
                      color: PillBinColors.textSecondary),
                ),
                SizedBox(width: sw * 0.01),
                Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: sw * 0.045,
                    color: PillBinColors.textSecondary),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: EdgeInsets.only(top: sh * 0.004, bottom: sh * 0.004),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(entries.length, (i) {
                final entry = entries[i];
                final status = entry['status'] as String? ?? '';
                final note = entry['note'] as String?;
                final isLast = i == entries.length - 1;
                final color = statusColorFor(status);

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: sw * 0.055,
                            height: sw * 0.055,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: color.withValues(alpha: 0.5)),
                            ),
                            child: Icon(
                                kStatusIcons[status] ?? Icons.circle_outlined,
                                size: sw * 0.03,
                                color: color),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 1.5,
                                margin: EdgeInsets.symmetric(
                                    vertical: sh * 0.004),
                                color: PillBinColors.greyLight,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: sw * 0.03),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: isLast ? 0 : sh * 0.016),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      kStatusLabels[status] ?? status,
                                      style: PillBinMedium.style(
                                          fontSize: sw * 0.033,
                                          color: PillBinColors.textPrimary),
                                    ),
                                  ),
                                  Text(
                                    _format(entry['at'] as String?),
                                    style: PillBinRegular.style(
                                        fontSize: sw * 0.028,
                                        color: PillBinColors.textLight),
                                  ),
                                ],
                              ),
                              if (note != null && note.trim().isNotEmpty) ...[
                                SizedBox(height: sh * 0.004),
                                Text(
                                  '"$note"',
                                  style: PillBinRegular.style(
                                      fontSize: sw * 0.03, color: color),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
