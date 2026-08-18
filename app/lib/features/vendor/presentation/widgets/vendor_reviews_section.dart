import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class VendorReviewsSection extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final List<Map<String, dynamic>> reviews;
  final Map<int, int> breakdown;
  final bool isLoading;

  const VendorReviewsSection({
    Key? key,
    required this.rating,
    required this.totalReviews,
    required this.reviews,
    this.breakdown = const {},
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PillBinColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, size: sw * 0.05, color: Colors.amber),
              SizedBox(width: sw * 0.025),
              Text('Ratings & Reviews',
                  style: PillBinBold.style(
                      fontSize: sw * 0.042,
                      color: PillBinColors.textPrimary)),
            ],
          ),
          SizedBox(height: sh * 0.02),
          if (totalReviews == 0)
            _empty(sw, sh)
          else ...[
            _summary(sw, sh),
            SizedBox(height: sh * 0.02),
            if (isLoading && reviews.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: sh * 0.02),
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: PillBinColors.primary),
                ),
              )
            else
              ...reviews.take(2).map((r) => _reviewTile(sw, sh, r)),
            if (totalReviews > 0) ...[
              SizedBox(height: sh * 0.015),
              _viewAll(context, sw, sh,
                  'View all $totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
                  '/vendor-reviews-screen'),
            ],
          ],
        ],
      ),
    );
  }

  Widget _viewAll(BuildContext context, double sw, double sh, String label,
      String route) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: sh * 0.014),
          side: BorderSide(
              color: PillBinColors.primary.withValues(alpha: 0.4)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: PillBinMedium.style(
                    fontSize: sw * 0.033, color: PillBinColors.primary)),
            SizedBox(width: sw * 0.015),
            Icon(Icons.arrow_forward_rounded,
                size: sw * 0.04, color: PillBinColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _empty(double sw, double sh) => Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.025),
        child: Column(
          children: [
            Icon(Icons.star_outline_rounded,
                size: sw * 0.1, color: PillBinColors.greyLight),
            SizedBox(height: sh * 0.01),
            Text('No reviews yet',
                style: PillBinMedium.style(
                    fontSize: sw * 0.036,
                    color: PillBinColors.textSecondary)),
            SizedBox(height: sh * 0.004),
            Text('Donors can rate you once a donation is completed',
                textAlign: TextAlign.center,
                style: PillBinRegular.style(
                    fontSize: sw * 0.03, color: PillBinColors.textLight)),
          ],
        ),
      );

  Widget _summary(double sw, double sh) {
    final counts = List<int>.generate(5, (i) => breakdown[i + 1] ?? 0);
    final maxCount = counts.fold<int>(0, (m, c) => c > m ? c : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(rating.toStringAsFixed(1),
                style: PillBinBold.style(
                    fontSize: sw * 0.11, color: PillBinColors.textPrimary)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final filled = rating >= i + 1;
                final half = !filled && rating > i;
                return Icon(
                  half
                      ? Icons.star_half_rounded
                      : filled
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                  size: sw * 0.033,
                  color: filled || half
                      ? Colors.amber
                      : PillBinColors.greyLight,
                );
              }),
            ),
            SizedBox(height: sh * 0.004),
            Text('$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
                style: PillBinRegular.style(
                    fontSize: sw * 0.028,
                    color: PillBinColors.textSecondary)),
          ],
        ),
        SizedBox(width: sw * 0.05),
        Expanded(
          child: Column(
            children: List.generate(5, (i) {
              final star = 5 - i;
              final count = counts[star - 1];
              return Padding(
                padding: EdgeInsets.only(bottom: sh * 0.006),
                child: Row(
                  children: [
                    Text('$star',
                        style: PillBinRegular.style(
                            fontSize: sw * 0.028,
                            color: PillBinColors.textSecondary)),
                    SizedBox(width: sw * 0.015),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: maxCount == 0 ? 0 : count / maxCount,
                          minHeight: sh * 0.008,
                          backgroundColor: PillBinColors.greyLight
                              .withValues(alpha: 0.5),
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.amber),
                        ),
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    SizedBox(
                      width: sw * 0.05,
                      child: Text('$count',
                          textAlign: TextAlign.end,
                          style: PillBinRegular.style(
                              fontSize: sw * 0.028,
                              color: PillBinColors.textLight)),
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

  Widget _reviewTile(double sw, double sh, Map<String, dynamic> review) {
    final value = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = (review['comment'] as String? ?? '').trim();
    final user = review['userId'];
    final name = user is Map
        ? (user['fullName'] as String? ?? 'Donor')
        : 'Donor';
    final when = _formatDate(review['createdAt'] as String?);

    return Container(
      margin: EdgeInsets.only(top: sh * 0.012),
      padding: EdgeInsets.all(sw * 0.035),
      decoration: BoxDecoration(
        color: PillBinColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PillBinColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < value
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: sw * 0.035,
                  color: i < value ? Colors.amber : PillBinColors.greyLight,
                ),
              ),
              SizedBox(width: sw * 0.02),
              Expanded(
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PillBinMedium.style(
                        fontSize: sw * 0.032,
                        color: PillBinColors.textPrimary)),
              ),
              if (when != null)
                Text(when,
                    style: PillBinRegular.style(
                        fontSize: sw * 0.027,
                        color: PillBinColors.textLight)),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: sh * 0.008),
            Text(comment,
                style: PillBinRegular.style(
                    fontSize: sw * 0.031,
                    color: PillBinColors.textSecondary)),
          ],
        ],
      ),
    );
  }

  String? _formatDate(String? iso) {
    if (iso == null) return null;
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return null;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = parsed.toLocal();
    return '${months[d.month - 1]} ${d.day}';
  }
}
