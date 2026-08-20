import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/shimmerCard.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/donation/data/repository/donation_provider.dart';
import 'package:pillbin/features/donation/presentation/pages/donation_receipt_screen.dart';
import 'package:pillbin/features/donation/presentation/widgets/status_timeline.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({Key? key}) : super(key: key);

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  //* No "All" tab — grouping every status into one scroll fights pagination,
  //* since a new page lands in the middle of the list instead of the end
  final List<String?> _filters = [
    'pending',
    'approved',
    'completed',
    'rejected',
    'cancelled'
  ];
  final List<String> _labels = [
    'Pending',
    'Approved',
    'Completed',
    'Rejected',
    'Cancelled'
  ];
  final List<IconData> _icons = [
    Icons.hourglass_empty_outlined,
    Icons.check_circle_outline,
    Icons.done_all_outlined,
    Icons.cancel_outlined,
    Icons.block_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<DonationProvider>();
        if (provider.hasMoreRequests(_filter) && !provider.isLoading) {
          provider.loadMoreMyRequests(status: _filter);
        }
      }
    });
  }

  String? get _filter => _filters[_selectedIndex];

  void _load() {
    context.read<DonationProvider>().ensureMyRequests(status: _filter);
  }

  Future<void> _refresh() {
    return context.read<DonationProvider>().refreshMyRequests(status: _filter);
  }

  void _selectFilter(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final provider = context.watch<DonationProvider>();

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.background,
        elevation: 0,
        title: Text('My Donations',
            style: PillBinBold.style(
                fontSize: sw * 0.048, color: PillBinColors.textPrimary)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Custom pill filter tabs
            _buildFilterRow(sw, sh),
            SizedBox(height: sh * 0.01),
            _buildSearchBar(sw, sh),
            SizedBox(height: sh * 0.01),
            // Content
            Expanded(
              //* Full-screen shimmer only on a cold tab — a load-more must not
              //* replace the list the user is scrolling
              child: provider.isLoading &&
                      provider.requestsFor(_filter).isEmpty
                  ? ShimmerCards.buildDonationRequestListShimmer(sw, sh)
                  : _buildList(provider, sw, sh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
        style: PillBinRegular.style(
            fontSize: sw * 0.035, color: PillBinColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search by medicine or center…',
          hintStyle: PillBinRegular.style(
              fontSize: sw * 0.033, color: PillBinColors.textSecondary),
          prefixIcon: Icon(Icons.search_rounded,
              size: sw * 0.05, color: PillBinColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(Icons.close_rounded,
                      size: sw * 0.045, color: PillBinColors.textSecondary),
                )
              : null,
          filled: true,
          fillColor: PillBinColors.surface,
          contentPadding:
              EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.015),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: PillBinColors.greyLight, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: PillBinColors.greyLight, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                BorderSide(color: PillBinColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(double sw, double sh) {
    return Container(
      color: PillBinColors.background,
      padding: EdgeInsets.fromLTRB(sw * 0.04, sh * 0.005, sw * 0.04, sh * 0.01),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_labels.length, (i) {
            final selected = _selectedIndex == i;
            return Padding(
              padding: EdgeInsets.only(right: sw * 0.025),
              child: GestureDetector(
                onTap: () => _selectFilter(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04, vertical: sh * 0.011),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [
                              PillBinColors.primary,
                              PillBinColors.primaryLight
                            ],
                          )
                        : null,
                    color: selected ? null : PillBinColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : PillBinColors.greyLight,
                      width: 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color:
                                  PillBinColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[i],
                        size: sw * 0.035,
                        color: selected
                            ? Colors.white
                            : PillBinColors.textSecondary,
                      ),
                      SizedBox(width: sw * 0.015),
                      Text(
                        _labels[i],
                        style: selected
                            ? PillBinMedium.style(
                                fontSize: sw * 0.032, color: Colors.white)
                            : PillBinRegular.style(
                                fontSize: sw * 0.032,
                                color: PillBinColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _applySearch(List<Map<String, dynamic>> source) {
    if (_searchQuery.isEmpty) return source;
    return source.where((r) {
      final center = r['medicalCenterId'];
      final centerName = center is Map
          ? (center['name'] as String? ?? '').toLowerCase()
          : '';
      final medicines = (r['medicines'] as List?)
              ?.map((m) => (m['name'] as String? ?? '').toLowerCase())
              .join(' ') ??
          '';
      return centerName.contains(_searchQuery) ||
          medicines.contains(_searchQuery);
    }).toList();
  }

  Widget _buildList(DonationProvider provider, double sw, double sh) {
    final filter = _filter;
    final items = _applySearch(provider.requestsFor(filter));

    if (items.isEmpty) return _buildEmpty(sw, sh);

    return RefreshIndicator(
      onRefresh: _refresh,
      color: PillBinColors.primary,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.05, vertical: sh * 0.01),
        itemCount: items.length + (provider.hasMoreRequests(filter) ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
        itemBuilder: (_, i) {
          if (i == items.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: sh * 0.02),
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: PillBinColors.primary),
              ),
            );
          }
          return _donationCard(items[i], sw, sh, provider);
        },
      ),
    );
  }

  Widget _buildEmpty(double sw, double sh) {
    return RefreshIndicator(
      color: PillBinColors.primary,
      onRefresh: _refresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: _emptyBody(sw, sh),
          ),
        ),
      ),
    );
  }

  Widget _emptyBody(double sw, double sh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.06),
            decoration: BoxDecoration(
              color: PillBinColors.primary.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.volunteer_activism_outlined,
                size: sw * 0.12,
                color: PillBinColors.primary.withValues(alpha: 0.5)),
          ),
          SizedBox(height: sh * 0.02),
          Text(
            _searchQuery.isNotEmpty ? 'No results found' : 'No donations yet',
            style: PillBinMedium.style(
                fontSize: sw * 0.042, color: PillBinColors.textPrimary),
          ),
          SizedBox(height: sh * 0.008),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'Find a nearby center and donate medicines',
            style: PillBinRegular.style(
                fontSize: sw * 0.033, color: PillBinColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _reviewSection(Map<String, dynamic> req, double sw, double sh,
      DonationProvider provider, String centerName) {
    final existing = req['myReview'] as Map?;

    if (existing != null) {
      final given = existing['rating'] as int? ?? 0;
      return Container(
        padding: EdgeInsets.all(sw * 0.03),
        decoration: BoxDecoration(
          color: PillBinColors.success.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: PillBinColors.success.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Text('You rated',
                style: PillBinRegular.style(
                    fontSize: sw * 0.031,
                    color: PillBinColors.textSecondary)),
            SizedBox(width: sw * 0.02),
            ...List.generate(
              5,
              (i) => Icon(
                i < given ? Icons.star_rounded : Icons.star_outline_rounded,
                size: sw * 0.042,
                color: i < given ? Colors.amber : PillBinColors.greyLight,
              ),
            ),
            const Spacer(),
            if (existing['_id'] != null)
              GestureDetector(
                onTap: () => _confirmDeleteReview(
                    existing['_id'].toString(), centerName, provider),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.01),
                  child: Icon(Icons.delete_outline_rounded,
                      size: sw * 0.045, color: PillBinColors.error),
                ),
              ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () =>
            _openReviewSheet(req['_id'] as String, centerName, provider),
        icon: Icon(Icons.star_outline_rounded,
            size: sw * 0.045, color: Colors.amber),
        label: Text('Rate this center',
            style: PillBinMedium.style(
                fontSize: sw * 0.033, color: PillBinColors.textPrimary)),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: sh * 0.013),
          side: BorderSide(color: Colors.amber.withValues(alpha: 0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteReview(
      String reviewId, String centerName, DonationProvider provider) async {
    final sw = MediaQuery.of(context).size.width;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete your review',
            style: PillBinBold.style(
                fontSize: sw * 0.045, color: PillBinColors.textDark)),
        content: Text(
            'This removes your rating from $centerName. '
            'You can rate this donation again afterwards.',
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

    final success = await provider.deleteReview(reviewId);
    if (!mounted) return;

    CustomSnackBar.show(
      context: context,
      icon: success ? Icons.check_circle_outline : Icons.error_outline,
      title: success
          ? 'Review deleted'
          : provider.lastError ?? 'Could not delete review',
    );
  }

  Future<void> _openReviewSheet(
      String requestId, String centerName, DonationProvider provider) async {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final commentCtrl = TextEditingController();
    int selected = 0;
    bool submitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => Container(
            padding: EdgeInsets.all(sw * 0.055),
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: sw * 0.12,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PillBinColors.greyLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: sh * 0.025),
                Text('How was your donation?',
                    style: PillBinBold.style(
                        fontSize: sw * 0.045,
                        color: PillBinColors.textPrimary)),
                SizedBox(height: sh * 0.005),
                Text(centerName,
                    style: PillBinRegular.style(
                        fontSize: sw * 0.033,
                        color: PillBinColors.textSecondary)),
                SizedBox(height: sh * 0.025),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final filled = i < selected;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selected = i + 1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: sw * 0.015),
                          child: Icon(
                            filled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: sw * 0.1,
                            color: filled
                                ? Colors.amber
                                : PillBinColors.greyLight,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: sh * 0.025),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Add a comment (optional)',
                    hintStyle: PillBinRegular.style(
                        fontSize: sw * 0.033,
                        color: PillBinColors.textLight),
                    filled: true,
                    fillColor: PillBinColors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: PillBinColors.greyLight)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: PillBinColors.greyLight)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: PillBinColors.primary, width: 2)),
                  ),
                  style: PillBinRegular.style(
                      fontSize: sw * 0.034, color: PillBinColors.textDark),
                ),
                SizedBox(height: sh * 0.01),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selected == 0 || submitting
                        ? null
                        : () async {
                            setSheetState(() => submitting = true);
                            final ok = await provider.submitReview(requestId,
                                rating: selected,
                                comment: commentCtrl.text.trim());
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            if (!mounted) return;
                            if (ok) {
                              CustomSnackBar.show(
                                  context: context,
                                  icon: Icons.star_rounded,
                                  title: 'Thanks for your feedback!');
                            } else {
                              CustomSnackBar.show(
                                  context: context,
                                  icon: Icons.error_outline,
                                  title: provider.lastError ??
                                      'Could not submit review');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PillBinColors.primary,
                      padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: submitting
                        ? SizedBox(
                            width: sw * 0.045,
                            height: sw * 0.045,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Submit Review',
                            style: PillBinMedium.style(
                                fontSize: sw * 0.037,
                                color: PillBinColors.textWhite)),
                  ),
                ),
                SizedBox(height: sh * 0.01),
              ],
            ),
          ),
        ),
      ),
    );

    commentCtrl.dispose();
  }

  Widget _donationCard(Map<String, dynamic> req, double sw, double sh,
      DonationProvider provider) {
    final status = req['status'] as String;
    final center = req['medicalCenterId'];
    final centerName = center is Map
        ? center['name'] as String? ?? 'Medical Center'
        : 'Medical Center';
    final centerPhone =
        center is Map ? center['phoneNumber'] as String? : null;
    final medicineList = (req['medicines'] as List?) ?? [];
    final medicines = medicineList
        .map((m) {
          final name = m['name'] as String? ?? '';
          final qty = (m['quantity'] as String? ?? '').trim();
          return qty.isEmpty ? name : '$name ($qty)';
        })
        .where((n) => n.isNotEmpty)
        .join(', ');
    final medicineCount = medicineList.length;
    final vendorNote = req['vendorNote'] as String?;
    final scheduled = req['scheduledDate'] as String?;
    final photos = (req['medicinePhotos'] as List?)
            ?.map((p) => p['url'] as String? ?? '')
            .where((u) => u.isNotEmpty)
            .toList() ??
        [];

    final statusColor = {
      'pending': Colors.orange,
      'approved': Colors.green,
      'completed': PillBinColors.primary,
      'rejected': Colors.red,
      'cancelled': PillBinColors.textSecondary,
    }[status] ??
        PillBinColors.textSecondary;

    final statusLabel = {
      'pending': 'Pending',
      'approved': 'Approved',
      'completed': 'Completed',
      'rejected': 'Rejected',
      'cancelled': 'Cancelled',
    }[status] ??
        status;

    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PillBinColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(sw * 0.025),
                decoration: BoxDecoration(
                  color: PillBinColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_hospital_outlined,
                    size: sw * 0.045, color: PillBinColors.primary),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Text(centerName,
                    style: PillBinMedium.style(
                        fontSize: sw * 0.04,
                        color: PillBinColors.textPrimary)),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.028, vertical: sh * 0.006),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(statusLabel,
                    style: PillBinMedium.style(
                        fontSize: sw * 0.028, color: statusColor)),
              ),
            ],
          ),
          SizedBox(height: sh * 0.012),
          Row(
            children: [
              Icon(Icons.medication_outlined,
                  size: sw * 0.038, color: PillBinColors.primary),
              SizedBox(width: sw * 0.015),
              Text(
                '$medicineCount ${medicineCount == 1 ? 'medicine' : 'medicines'}',
                style: PillBinMedium.style(
                    fontSize: sw * 0.032, color: PillBinColors.primary),
              ),
            ],
          ),
          SizedBox(height: sh * 0.006),
          Text(medicines,
              style: PillBinRegular.style(
                  fontSize: sw * 0.033,
                  color: PillBinColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          if (scheduled != null) ...[
            SizedBox(height: sh * 0.008),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: sw * 0.035, color: PillBinColors.textSecondary),
                SizedBox(width: sw * 0.015),
                Text(_formatDate(scheduled),
                    style: PillBinRegular.style(
                        fontSize: sw * 0.03,
                        color: PillBinColors.textSecondary)),
              ],
            ),
          ],
          if (vendorNote != null && vendorNote.isNotEmpty) ...[
            SizedBox(height: sh * 0.012),
            Container(
              padding: EdgeInsets.all(sw * 0.03),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.comment_outlined,
                      size: sw * 0.04, color: statusColor),
                  SizedBox(width: sw * 0.02),
                  Expanded(
                    child: Text(vendorNote,
                        style: PillBinRegular.style(
                            fontSize: sw * 0.032, color: statusColor)),
                  ),
                ],
              ),
            ),
          ],
          // Medicine photo thumbnails
          if (photos.isNotEmpty) ...[
            SizedBox(height: sh * 0.012),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: photos
                    .map((url) => Padding(
                          padding: EdgeInsets.only(right: sw * 0.025),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: sw * 0.22,
                              height: sw * 0.22,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: sw * 0.22,
                                height: sw * 0.22,
                                color: PillBinColors.greyLight,
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: sw * 0.22,
                                height: sw * 0.22,
                                color: PillBinColors.greyLight,
                                child: Icon(Icons.broken_image_outlined,
                                    color: PillBinColors.textSecondary),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
          SizedBox(height: sh * 0.006),
          StatusTimeline(
            history: req['statusHistory'] as List?,
            currentStatus: status,
            createdAt: req['createdAt'] as String?,
          ),
          if (status == 'completed') ...[
            SizedBox(height: sh * 0.015),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openReceipt(req),
                icon: Icon(Icons.receipt_long_rounded,
                    size: sw * 0.045, color: PillBinColors.primary),
                label: Text('Share Receipt',
                    style: PillBinMedium.style(
                        fontSize: sw * 0.035, color: PillBinColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: PillBinColors.primary),
                  padding: EdgeInsets.symmetric(vertical: sh * 0.013),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            SizedBox(height: sh * 0.008),
            _reviewSection(req, sw, sh, provider, centerName),
          ],
          // Actions
          if (status == 'approved') ...[
            SizedBox(height: sh * 0.015),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/donation-qr-screen',
                  arguments: {
                    'requestId': req['_id'],
                    'centerName': centerName,
                    'transition': TransitionType.bottomToTop,
                  },
                ),
                icon: Icon(Icons.qr_code_2_rounded, size: sw * 0.05),
                label: Text('Show Handover Code',
                    style: PillBinMedium.style(
                        fontSize: sw * 0.035, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PillBinColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: sh * 0.014),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
          if (status == 'pending' || status == 'approved') ...[
            SizedBox(height: sh * 0.015),
            Row(
              children: [
                if (status == 'approved' && centerPhone != null) ...[
                  Expanded(
                    child: _outlineBtn(sw, sh, Icons.phone, 'Call Center',
                        PillBinColors.primary,
                        () => _callCenter(centerPhone)),
                  ),
                  SizedBox(width: sw * 0.03),
                ],
                if (status == 'pending')
                  Expanded(
                    child: _outlineBtn(sw, sh, Icons.close, 'Cancel Request',
                        Colors.red,
                        () => _confirmCancel(req['_id'] as String, provider)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _outlineBtn(double sw, double sh, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: sh * 0.013),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: sw * 0.038, color: color),
            SizedBox(width: sw * 0.015),
            Text(label,
                style: PillBinMedium.style(
                    fontSize: sw * 0.032, color: color)),
          ],
        ),
      ),
    );
  }

  void _openReceipt(Map<String, dynamic> req) {
    final user = context.read<UserProvider>().user;

    Navigator.pushNamed(
      context,
      '/donation-receipt-screen',
      arguments: {
        'data': DonationReceiptData.fromRequestMap(
          req,
          donorName: user?.fullName ?? user?.email ?? 'PillBin user',
          donorEmail: user?.email,
          donorPhone: user?.phoneNumber,
        ),
        'transition': TransitionType.bottomToTop,
      },
    );
  }

  void _confirmCancel(String id, DonationProvider provider) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: isTablet ? sw * 0.4 : sw * 0.85,
          padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.04),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: isTablet ? sw * 0.05 : sw * 0.12,
                  color: Colors.red.shade600,
                ),
              ),
              SizedBox(height: sh * 0.02),
              // Title
              Text(
                'Cancel Request?',
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.028 : sw * 0.05,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: sh * 0.015),
              // Message
              Text(
                'Are you sure you want to cancel this donation request? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: sh * 0.025),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? sh * 0.015 : sh * 0.012),
                        backgroundColor:
                            PillBinColors.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'No',
                        style: PillBinBold.style(
                          fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                          color: PillBinColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final ok = await provider.cancelRequest(id);
                        if (!mounted) return;
                        if (ok) _load();
                        CustomSnackBar.show(
                          context: context,
                          icon: ok
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          title: ok
                              ? 'Request cancelled'
                              : (provider.lastError ?? 'Error cancelling request'),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: isTablet ? sh * 0.015 : sh * 0.012),
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Yes, Cancel',
                        style: PillBinBold.style(
                          fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callCenter(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    try {
      await launchUrl(Uri.parse('tel:$cleaned'),
          mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch dialer: $e');
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
