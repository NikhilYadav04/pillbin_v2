import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/donation/data/repository/donation_provider.dart';
import 'package:provider/provider.dart';

class CenterReviewsScreen extends StatefulWidget {
  final String centerId;
  final String centerName;

  const CenterReviewsScreen({
    Key? key,
    required this.centerId,
    required this.centerName,
  }) : super(key: key);

  @override
  State<CenterReviewsScreen> createState() => _CenterReviewsScreenState();
}

class _CenterReviewsScreenState extends State<CenterReviewsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _starFilter = 0;

  int? get _rating => _starFilter == 0 ? null : _starFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<DonationProvider>();
        if (provider.hasMoreReviews(widget.centerId, rating: _rating) &&
            !provider.isLoadingReviews) {
          _load();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) {
    return context
        .read<DonationProvider>()
        .loadCenterReviews(widget.centerId, rating: _rating, reset: reset);
  }

  void _selectStar(int star) {
    if (star == _starFilter) return;
    setState(() => _starFilter = star);
    _load(reset: true);
  }

  Future<void> _confirmDelete(String reviewId) async {
    final sw = MediaQuery.of(context).size.width;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete your review',
            style: PillBinBold.style(
                fontSize: sw * 0.045, color: PillBinColors.textDark)),
        content: Text(
            'This removes your rating from ${widget.centerName}. '
            'You can review this donation again afterwards.',
            style: PillBinRegular.style(
                fontSize: sw * 0.035, color: PillBinColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: PillBinMedium.style(
                    fontSize: sw * 0.038,
                    color: PillBinColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: PillBinBold.style(
                    fontSize: sw * 0.038, color: PillBinColors.error)),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final provider = context.read<DonationProvider>();
    final success = await provider.deleteReview(reviewId);
    if (!mounted) return;

    CustomSnackBar.show(
      context: context,
      icon: success ? Icons.check_circle_outline : Icons.error_outline,
      title: success
          ? 'Review deleted'
          : provider.lastError ?? 'Could not delete review',
    );

    if (success) _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final provider = context.watch<DonationProvider>();

    final reviews = provider.reviewsFor(widget.centerId, rating: _rating);
    final summary = provider.reviewSummary(widget.centerId);
    final rating = (summary?['rating'] as num?)?.toDouble() ?? 0;
    final total = (summary?['totalReviews'] as num?)?.toInt() ?? 0;
    final breakdown = _breakdownOf(summary);

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: sw * 0.05, color: PillBinColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Reviews',
            style: PillBinBold.style(
                fontSize: sw * 0.046, color: PillBinColors.textPrimary)),
      ),
      body: RefreshIndicator(
        color: PillBinColors.primary,
        onRefresh: () => _load(reset: true),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.centerName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PillBinMedium.style(
                            fontSize: sw * 0.036,
                            color: PillBinColors.textSecondary)),
                    SizedBox(height: sh * 0.015),
                    _summaryCard(sw, sh, rating, total, breakdown),
                    SizedBox(height: sh * 0.02),
                    _filterRow(sw, sh, breakdown, total),
                    SizedBox(height: sh * 0.015),
                  ],
                ),
              ),
              if (reviews.isEmpty && !provider.isLoadingReviews)
                SliverToBoxAdapter(child: _empty(sw, sh))
              else
                SliverList.builder(
                  itemCount: reviews.length,
                  itemBuilder: (_, i) => _reviewCard(sw, sh, reviews[i]),
                ),
              if (provider.isLoadingReviews)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: sh * 0.025),
                    child: Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: PillBinColors.primary),
                    ),
                  ),
                ),
              if (!provider.hasMoreReviews(widget.centerId, rating: _rating) &&
                  reviews.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: sh * 0.02),
                    child: Center(
                      child: Text('That\'s all ${reviews.length} reviews',
                          style: PillBinRegular.style(
                              fontSize: sw * 0.03,
                              color: PillBinColors.textLight)),
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: sh * 0.04)),
            ],
          ),
        ),
      ),
    );
  }

  Map<int, int> _breakdownOf(Map<String, dynamic>? summary) {
    final raw = summary?['ratingBreakdown'];
    if (raw is! Map) return const {};
    return raw.map((k, v) =>
        MapEntry(int.tryParse(k.toString()) ?? 0, (v as num?)?.toInt() ?? 0));
  }

  Widget _summaryCard(double sw, double sh, double rating, int total,
      Map<int, int> breakdown) {
    final maxCount = breakdown.values.fold<int>(0, (m, c) => c > m ? c : m);

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
      child: Row(
        children: [
          Column(
            children: [
              Text(rating.toStringAsFixed(1),
                  style: PillBinBold.style(
                      fontSize: sw * 0.12, color: PillBinColors.textPrimary)),
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
                    size: sw * 0.035,
                    color:
                        filled || half ? Colors.amber : PillBinColors.greyLight,
                  );
                }),
              ),
              SizedBox(height: sh * 0.005),
              Text('$total ${total == 1 ? 'review' : 'reviews'}',
                  style: PillBinRegular.style(
                      fontSize: sw * 0.029,
                      color: PillBinColors.textSecondary)),
            ],
          ),
          SizedBox(width: sw * 0.05),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = breakdown[star] ?? 0;
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
                            backgroundColor:
                                PillBinColors.greyLight.withValues(alpha: 0.5),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.amber),
                          ),
                        ),
                      ),
                      SizedBox(width: sw * 0.02),
                      SizedBox(
                        width: sw * 0.06,
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
      ),
    );
  }

  Widget _filterRow(
      double sw, double sh, Map<int, int> breakdown, int total) {
    const options = [0, 5, 4, 3, 2, 1];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: options.map((star) {
          final selected = _starFilter == star;
          final label = star == 0 ? 'All' : '$star ★';
          final count = star == 0 ? total : (breakdown[star] ?? 0);

          return Padding(
            padding: EdgeInsets.only(right: sw * 0.025),
            child: GestureDetector(
              onTap: () => _selectStar(star),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04, vertical: sh * 0.009),
                decoration: BoxDecoration(
                  color:
                      selected ? PillBinColors.primary : PillBinColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : PillBinColors.greyLight,
                    width: 1.5,
                  ),
                ),
                child: Text('$label ($count)',
                    style: PillBinMedium.style(
                      fontSize: sw * 0.03,
                      color: selected
                          ? Colors.white
                          : PillBinColors.textSecondary,
                    )),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _empty(double sw, double sh) => Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.08),
        child: Column(
          children: [
            Icon(Icons.star_outline_rounded,
                size: sw * 0.14, color: PillBinColors.greyLight),
            SizedBox(height: sh * 0.015),
            Text(
                _starFilter == 0
                    ? 'No reviews yet'
                    : 'No $_starFilter-star reviews',
                style: PillBinMedium.style(
                    fontSize: sw * 0.038,
                    color: PillBinColors.textSecondary)),
          ],
        ),
      );

  Widget _reviewCard(double sw, double sh, Map<String, dynamic> review) {
    final value = (review['rating'] as num?)?.toInt() ?? 0;
    final comment = (review['comment'] as String? ?? '').trim();
    final user = review['userId'];
    final name =
        user is Map ? (user['fullName'] as String? ?? 'Donor') : 'Donor';
    final when = _formatDate(review['createdAt'] as String?);
    final isMine = review['isMine'] == true;

    return Container(
      key: ValueKey(review['_id']),
      margin: EdgeInsets.only(bottom: sh * 0.012),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMine
              ? PillBinColors.primary.withValues(alpha: 0.35)
              : PillBinColors.greyLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: sw * 0.09,
                height: sw * 0.09,
                decoration: BoxDecoration(
                  color: PillBinColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'D',
                    style: PillBinMedium.style(
                        fontSize: sw * 0.038, color: PillBinColors.primary),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(isMine ? 'You' : name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: PillBinMedium.style(
                                  fontSize: sw * 0.035,
                                  color: PillBinColors.textDark)),
                        ),
                        if (isMine) ...[
                          SizedBox(width: sw * 0.02),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.02,
                                vertical: sh * 0.002),
                            decoration: BoxDecoration(
                              color: PillBinColors.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Your review',
                                style: PillBinMedium.style(
                                    fontSize: sw * 0.025,
                                    color: PillBinColors.primary)),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: sh * 0.003),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < value
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: sw * 0.033,
                          color: i < value
                              ? Colors.amber
                              : PillBinColors.greyLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isMine)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(Icons.delete_outline_rounded,
                      size: sw * 0.048, color: PillBinColors.error),
                  onPressed: () =>
                      _confirmDelete(review['_id'].toString()),
                )
              else if (when != null)
                Text(when,
                    style: PillBinRegular.style(
                        fontSize: sw * 0.027,
                        color: PillBinColors.textLight)),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: sh * 0.012),
            Text(comment,
                style: PillBinRegular.style(
                    fontSize: sw * 0.032,
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
