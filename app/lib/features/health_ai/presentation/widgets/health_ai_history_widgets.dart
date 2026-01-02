import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/health_ai/data/model/rag_model.dart';
import 'package:intl/intl.dart';
import 'package:pillbin/features/health_ai/data/repository/rag_provider.dart';
import 'package:provider/provider.dart';

//* document card
Widget buildDocumentCard(HealthRagModel doc, double sw, double sh,
    bool isTablet, BuildContext context) {
  return _DocumentCardStateful(
    doc: doc,
    sw: sw,
    sh: sh,
    isTablet: isTablet,
  );
}

class _DocumentCardStateful extends StatefulWidget {
  final HealthRagModel doc;
  final double sw;
  final double sh;
  final bool isTablet;

  const _DocumentCardStateful({
    required this.doc,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  State<_DocumentCardStateful> createState() => _DocumentCardStatefulState();
}

class _DocumentCardStatefulState extends State<_DocumentCardStateful> {
  bool _isExpanded = false;
  final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: widget.sh * 0.015),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(widget.sw * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(widget.sw * 0.025),
                          decoration: BoxDecoration(
                            color: PillBinColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.description,
                            color: PillBinColors.primary,
                            size: widget.isTablet
                                ? widget.sw * 0.025
                                : widget.sw * 0.045,
                          ),
                        ),
                        SizedBox(width: widget.sw * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.doc.pdfName,
                                style: PillBinBold.style(
                                  fontSize: widget.isTablet
                                      ? widget.sw * 0.022
                                      : widget.sw * 0.038,
                                  color: PillBinColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: widget.sh * 0.003),
                              Text(
                                dateFormat.format(widget.doc.uploadedAt),
                                style: PillBinRegular.style(
                                  fontSize: widget.isTablet
                                      ? widget.sw * 0.018
                                      : widget.sw * 0.028,
                                  color: PillBinColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: widget.isTablet
                                ? widget.sw * 0.025
                                : widget.sw * 0.045,
                          ),
                          onPressed: () => _showDeleteDialog(widget.doc,
                              widget.sw, widget.sh, widget.isTablet, context),
                        ),
                      ],
                    ),
                    if (widget.doc.pdfDescription != null &&
                        widget.doc.pdfDescription!.isNotEmpty) ...[
                      SizedBox(height: widget.sh * 0.015),
                      Text(
                        widget.doc.pdfDescription!,
                        style: PillBinRegular.style(
                          fontSize: widget.isTablet
                              ? widget.sw * 0.02
                              : widget.sw * 0.032,
                          color: PillBinColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: widget.sh * 0.015),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.chat_bubble_outline,
                          label: '${widget.doc.queries.length} queries',
                          sw: widget.sw,
                          sh: widget.sh,
                          isTablet: widget.isTablet,
                        ),
                        SizedBox(width: widget.sw * 0.02),
                        _buildInfoChip(
                          icon: Icons.access_time,
                          label: _getTimeAgo(widget.doc.uploadedAt),
                          sw: widget.sw,
                          sh: widget.sh,
                          isTablet: widget.isTablet,
                        ),
                        Spacer(),
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: PillBinColors.textSecondary,
                          size: widget.isTablet
                              ? widget.sw * 0.025
                              : widget.sw * 0.05,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //* Expandable Queries Section
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildQueriesSection(),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueriesSection() {
    if (widget.doc.queries.isEmpty) {
      return Container(
        padding: EdgeInsets.all(widget.sw * 0.04),
        decoration: BoxDecoration(
          color: PillBinColors.background,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Center(
          child: Text(
            'No queries yet',
            style: PillBinRegular.style(
              fontSize: widget.isTablet ? widget.sw * 0.02 : widget.sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: PillBinColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: PillBinColors.greyLight.withOpacity(0.3),
          ),
          Padding(
            padding: EdgeInsets.all(widget.sw * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: widget.isTablet
                          ? widget.sw * 0.022
                          : widget.sw * 0.04,
                      color: PillBinColors.primary,
                    ),
                    SizedBox(width: widget.sw * 0.02),
                    Text(
                      'Query History',
                      style: PillBinBold.style(
                        fontSize: widget.isTablet
                            ? widget.sw * 0.022
                            : widget.sw * 0.036,
                        color: PillBinColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.sh * 0.015),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.doc.queries.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: widget.sh * 0.01),
                  itemBuilder: (context, index) {
                    final query = widget.doc.queries[index];
                    return _buildQueryItem(query, index);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryItem(QueryRagModel query, int index) {
    final queryDateFormat = DateFormat('MMM dd, hh:mm a');

    return Container(
      padding: EdgeInsets.all(widget.sw * 0.03),
      decoration: BoxDecoration(
        color: query.byUser
            ? PillBinColors.primary.withOpacity(0.05)
            : PillBinColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: query.byUser
              ? PillBinColors.primary.withOpacity(0.2)
              : PillBinColors.greyLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.sw * 0.02,
                  vertical: widget.sh * 0.003,
                ),
                decoration: BoxDecoration(
                  color: query.byUser
                      ? PillBinColors.primary
                      : PillBinColors.textSecondary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  query.byUser ? 'USER' : 'AI',
                  style: PillBinBold.style(
                    fontSize:
                        widget.isTablet ? widget.sw * 0.016 : widget.sw * 0.024,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: widget.sw * 0.02),
              Text(
                queryDateFormat.format(query.createdAt),
                style: PillBinRegular.style(
                  fontSize:
                      widget.isTablet ? widget.sw * 0.016 : widget.sw * 0.026,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.sh * 0.008),
          Text(
            query.content,
            style: PillBinRegular.style(
              fontSize: widget.isTablet ? widget.sw * 0.018 : widget.sw * 0.03,
              color: PillBinColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

//* chip
Widget _buildInfoChip({
  required IconData icon,
  required String label,
  required double sw,
  required double sh,
  required bool isTablet,
}) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: sw * 0.025,
      vertical: sh * 0.005,
    ),
    decoration: BoxDecoration(
      color: PillBinColors.background,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isTablet ? sw * 0.018 : sw * 0.03,
          color: PillBinColors.textSecondary,
        ),
        SizedBox(width: sw * 0.01),
        Text(
          label,
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.018 : sw * 0.028,
            color: PillBinColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

//* time helper
String _getTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()}mo ago';
  } else if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}

//* Delete Dialog
void _showDeleteDialog(HealthRagModel doc, double sw, double sh, bool isTablet,
    BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: PillBinColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Delete Document',
        style: PillBinBold.style(
          fontSize: isTablet ? sw * 0.025 : sw * 0.045,
          color: PillBinColors.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${doc.pdfName}"?',
        style: PillBinRegular.style(
          fontSize: isTablet ? sw * 0.02 : sw * 0.036,
          color: PillBinColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.036,
              color: PillBinColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            final provider = context.read<RagProvider>();
            provider.deleteRagDocument(doc.id, context);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Delete',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.036,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}
