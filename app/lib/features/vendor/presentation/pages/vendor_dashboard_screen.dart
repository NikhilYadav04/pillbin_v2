import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/core/widgets/notification_bell.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/vendor/data/models/vendor_models.dart';
import 'package:pillbin/features/vendor/data/repository/vendor_provider.dart';
import 'package:pillbin/features/vendor/presentation/widgets/vendor_analytics_section.dart';
import 'package:pillbin/features/vendor/presentation/widgets/vendor_center_sheets.dart';
import 'package:pillbin/features/vendor/presentation/widgets/vendor_reviews_section.dart';
import 'package:provider/provider.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VendorProvider>();
      provider.fetchMyCenter().then((_) => provider.fetchReviews());
      provider.ensureRequests(status: 'pending');
      provider.fetchAnalytics();
      context.read<NotificationProvider>().fetchNotifications(context: context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context
          .read<NotificationProvider>()
          .fetchNotifications(context: context, forceRefresh: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final provider = context.watch<VendorProvider>();
    final center = provider.center;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: provider.isLoading && center == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await provider.fetchMyCenter(forceRefresh: true);
                  await provider.refreshRequests(status: 'pending');
                  await provider.fetchAnalytics(forceRefresh: true);
                  await provider.fetchReviews(forceRefresh: true);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(sw * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(sw, sh, center),
                      SizedBox(height: sh * 0.018),
                      _buildVerificationBanner(sw, sh, center),
                      if (center != null && center.images.isNotEmpty) ...[
                        SizedBox(height: sh * 0.02),
                        _buildCenterPhotos(sw, sh, center),
                      ],
                      SizedBox(height: sh * 0.025),
                      _buildStatCards(sw, sh, provider),
                      SizedBox(height: sh * 0.025),
                      _buildQuickActions(sw, sh, center),
                      SizedBox(height: sh * 0.025),
                      VendorAnalyticsSection(
                        analytics: provider.analytics,
                        isLoading: provider.isLoadingAnalytics,
                      ),
                      SizedBox(height: sh * 0.025),
                      VendorReviewsSection(
                        rating: provider.analytics?.rating ?? 0,
                        totalReviews: provider.analytics?.totalReviews ?? 0,
                        reviews: provider.reviews,
                        breakdown:
                            provider.analytics?.ratingBreakdown ?? const {},
                        isLoading: provider.isLoadingReviews,
                      ),
                      SizedBox(height: sh * 0.025),
                      _buildPendingRequests(sw, sh, provider),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildHeader(double sw, double sh, VendorCenter? center) {
    final bool isActive = center?.isActive == true;
    final String facilityType = center?.facilityType ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PillBinColors.primary, PillBinColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PillBinColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.03),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.local_hospital_outlined,
                color: Colors.white, size: sw * 0.07),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center?.name ?? 'Your Center',
                  style: PillBinBold.style(
                      fontSize: sw * 0.044, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: sh * 0.002),
                if (facilityType.isNotEmpty)
                  Text(
                    facilityType[0].toUpperCase() +
                        facilityType.substring(1).replaceAll('_', ' '),
                    style: PillBinRegular.style(
                        fontSize: sw * 0.032,
                        color: Colors.white.withValues(alpha: 0.85)),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showStatusDialog(center),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.025, vertical: sh * 0.006),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withValues(alpha: 0.25)
                    : Colors.red.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isActive
                        ? Colors.greenAccent.withValues(alpha: 0.6)
                        : Colors.redAccent.withValues(alpha: 0.6)),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: PillBinMedium.style(
                  fontSize: sw * 0.03,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const NotificationBell(compact: true),
        ],
      ),
    );
  }

  Widget _buildStatCards(
      double sw, double sh, VendorProvider provider) {
    final pending = provider.pendingCount;
    final donations = provider.center?.donationCount ?? 0;
    final inventory = provider.inventory.length;

    return Row(
      children: [
        _statCard(sw, sh, Icons.inbox_outlined, '$pending', 'Pending', Colors.orange),
        SizedBox(width: sw * 0.03),
        _statCard(sw, sh, Icons.volunteer_activism_outlined, '$donations', 'Donations', Colors.green),
        SizedBox(width: sw * 0.03),
        _statCard(sw, sh, Icons.inventory_2_outlined, '$inventory', 'Categories', PillBinColors.primary),
      ],
    );
  }

  Widget _statCard(double sw, double sh, IconData icon, String value,
      String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: sh * 0.02),
        decoration: BoxDecoration(
          color: PillBinColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PillBinColors.greyLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: sw * 0.06),
            SizedBox(height: sh * 0.008),
            Text(value,
                style: PillBinBold.style(
                    fontSize: sw * 0.05, color: PillBinColors.textPrimary)),
            Text(label,
                style: PillBinRegular.style(
                    fontSize: sw * 0.028, color: PillBinColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
      double sw, double sh, VendorCenter? center) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: PillBinBold.style(
                fontSize: sw * 0.045, color: PillBinColors.textPrimary)),
        SizedBox(height: sh * 0.015),
        Row(
          children: [
            _actionBtn(sw, sh, Icons.inventory_2_outlined, 'Inventory',
                () => Navigator.pushNamed(context, '/vendor-inventory-screen')),
            SizedBox(width: sw * 0.03),
            _actionBtn(sw, sh, Icons.list_alt_outlined, 'Requests',
                () => Navigator.pushNamed(context, '/vendor-requests-screen')),
            SizedBox(width: sw * 0.03),
            _actionBtn(sw, sh, Icons.info_outline, 'Details',
                () => showVendorCenterDetailsSheet(context, center)),
          ],
        ),
      ],
    );
  }

  Widget _actionBtn(
      double sw, double sh, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: sh * 0.018),
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PillBinColors.greyLight),
          ),
          child: Column(
            children: [
              Icon(icon, color: PillBinColors.primary, size: sw * 0.06),
              SizedBox(height: sh * 0.006),
              Text(label,
                  style: PillBinMedium.style(
                      fontSize: sw * 0.03,
                      color: PillBinColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingRequests(
      double sw, double sh, VendorProvider provider) {
    final pending = provider.requestsFor('pending');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pending Requests',
                style: PillBinBold.style(
                    fontSize: sw * 0.045, color: PillBinColors.textPrimary)),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/vendor-requests-screen'),
              child: Text('View All',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.035, color: PillBinColors.primary)),
            ),
          ],
        ),
        if (pending.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(sw * 0.06),
            decoration: BoxDecoration(
              color: PillBinColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PillBinColors.greyLight),
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined,
                    color: PillBinColors.textLight, size: sw * 0.1),
                SizedBox(height: sh * 0.01),
                Text('No pending requests',
                    style: PillBinRegular.style(
                        fontSize: sw * 0.035,
                        color: PillBinColors.textSecondary)),
              ],
            ),
          )
        else
          ...pending.take(3).map((req) => _requestCard(sw, sh, req, provider)),
      ],
    );
  }

  Widget _requestCard(double sw, double sh, DonationRequest req,
      VendorProvider provider) {
    final medicines = req.medicines.map((m) => m.name).join(', ');
    final userName = req.user?.displayName ?? 'User';

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.012),
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PillBinColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: sw * 0.045, color: PillBinColors.textSecondary),
              SizedBox(width: sw * 0.02),
              Text(userName,
                  style: PillBinMedium.style(
                      fontSize: sw * 0.038, color: PillBinColors.textPrimary)),
            ],
          ),
          SizedBox(height: sh * 0.008),
          Text(medicines,
              style: PillBinRegular.style(
                  fontSize: sw * 0.032, color: PillBinColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          SizedBox(height: sh * 0.012),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showResponseSheet(req.id, 'rejected'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Reject',
                      style: PillBinMedium.style(fontSize: sw * 0.035, color: Colors.red)),
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showResponseSheet(req.id, 'approved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Approve',
                      style: PillBinMedium.style(fontSize: sw * 0.035, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPhotos(double sw, double sh, VendorCenter center) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library_outlined,
                size: sw * 0.045, color: PillBinColors.primary),
            SizedBox(width: sw * 0.02),
            Text('Center Photos',
                style: PillBinMedium.style(
                    fontSize: sw * 0.04, color: PillBinColors.textPrimary)),
          ],
        ),
        SizedBox(height: sh * 0.012),
        SizedBox(
          height: sw * 0.45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: center.images.length,
            separatorBuilder: (_, __) => SizedBox(width: sw * 0.03),
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: center.images[i].url,
                width: sw * 0.55,
                height: sw * 0.45,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: sw * 0.55,
                  height: sw * 0.45,
                  color: PillBinColors.greyLight,
                  child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: sw * 0.55,
                  height: sw * 0.45,
                  decoration: BoxDecoration(
                    color: PillBinColors.greyLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.broken_image_outlined,
                      color: PillBinColors.textSecondary, size: sw * 0.08),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showStatusDialog(VendorCenter? center) {
    if (center == null) return;
    final isActive = center.isActive;
    final sw = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isActive ? 'Deactivate Center?' : 'Activate Center?',
          style: PillBinBold.style(fontSize: sw * 0.045, color: PillBinColors.textPrimary),
        ),
        content: Text(
          isActive
              ? 'Users will no longer see your center as available for donations.'
              : 'Your center will be visible to users for donations.',
          style: PillBinRegular.style(fontSize: sw * 0.035, color: PillBinColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: PillBinMedium.style(
                    fontSize: sw * 0.038,
                    color: PillBinColors.textSecondary)),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(ctx);
              await context
                  .read<VendorProvider>()
                  .updateCenter({'isActive': !isActive});
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.05, vertical: sw * 0.025),
              decoration: BoxDecoration(
                color: isActive ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isActive ? 'Deactivate' : 'Activate',
                style: PillBinMedium.style(
                    fontSize: sw * 0.038, color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: sw * 0.02),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner(
      double sw, double sh, VendorCenter? center) {
    final status = center?.verificationStatus ?? 'unverified';
    if (status == 'approved') {
      return _buildVerifiedBadge(sw, sh, center?.verifiedAt);
    }

    final Color bgColor;
    final Color borderColor;
    final IconData icon;
    final String title;
    final String subtitle;
    final Color iconColor;

    switch (status) {
      case 'pending':
        bgColor = Colors.amber.withValues(alpha: 0.1);
        borderColor = Colors.amber.withValues(alpha: 0.4);
        iconColor = Colors.amber.shade700;
        icon = Icons.hourglass_top_rounded;
        title = 'Verification Pending';
        subtitle = 'Your documents are under review. Usually takes 24-48 hours.';
        break;
      case 'rejected':
        bgColor = PillBinColors.error.withValues(alpha: 0.08);
        borderColor = PillBinColors.error.withValues(alpha: 0.3);
        iconColor = PillBinColors.error;
        icon = Icons.cancel_outlined;
        title = 'Verification Not Approved';
        final reason = center?.verificationRejectionReason ?? '';
        subtitle = reason.isNotEmpty ? reason : 'Please re-submit valid documents.';
        break;
      default: // unverified
        bgColor = PillBinColors.primary.withValues(alpha: 0.07);
        borderColor = PillBinColors.primary.withValues(alpha: 0.25);
        iconColor = PillBinColors.primary;
        icon = Icons.verified_outlined;
        title = 'Get Your Center Verified';
        subtitle = 'Upload your registration docs to earn the verified badge.';
    }

    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(sw * 0.025),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: sw * 0.05),
            ),
            SizedBox(width: sw * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: PillBinBold.style(
                          fontSize: sw * 0.034,
                          color: PillBinColors.textPrimary)),
                  SizedBox(height: sh * 0.003),
                  Text(subtitle,
                      style: PillBinRegular.style(
                          fontSize: sw * 0.028,
                          color: PillBinColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (status == 'unverified' || status == 'rejected') ...[
              SizedBox(width: sw * 0.02),
              GestureDetector(
                onTap: () => _showUploadDocsSheet(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03, vertical: sh * 0.008),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      PillBinColors.primary,
                      PillBinColors.primaryLight
                    ]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Upload',
                      style: PillBinMedium.style(
                          fontSize: sw * 0.028, color: Colors.white)),
                ),
              ),
            ],
          ],
        ),
    );
  }

  void _showUploadDocsSheet() {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final List<File> docs = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PillBinColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSS) {
        return Padding(
          padding: EdgeInsets.only(
            left: sw * 0.06,
            right: sw * 0.06,
            top: sh * 0.025,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + sh * 0.04,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: sw * 0.1,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PillBinColors.greyLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: sh * 0.02),
                Text('Upload Verification Documents',
                    style: PillBinBold.style(
                        fontSize: sw * 0.045,
                        color: PillBinColors.textPrimary)),
                SizedBox(height: sh * 0.008),
                Text('Registration certificate, operating license, or any govt-issued document (max 5)',
                    style: PillBinRegular.style(
                        fontSize: sw * 0.03,
                        color: PillBinColors.textSecondary)),
                SizedBox(height: sh * 0.02),
                Wrap(
                  spacing: sw * 0.03,
                  runSpacing: sw * 0.03,
                  children: [
                    ...docs.asMap().entries.map((e) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(e.value,
                                  width: sw * 0.25,
                                  height: sw * 0.25,
                                  fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 3,
                              right: 3,
                              child: GestureDetector(
                                onTap: () =>
                                    setSS(() => docs.removeAt(e.key)),
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.close,
                                      size: 13, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        )),
                    if (docs.length < 5)
                      GestureDetector(
                        onTap: () async {
                          final xfile = await ImagePicker()
                              .pickImage(source: ImageSource.gallery, imageQuality: 90);
                          if (xfile != null) setSS(() => docs.add(File(xfile.path)));
                        },
                        child: Container(
                          width: sw * 0.25,
                          height: sw * 0.25,
                          decoration: BoxDecoration(
                            color: PillBinColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: PillBinColors.greyLight, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  color: PillBinColors.primary, size: sw * 0.065),
                              const SizedBox(height: 4),
                              Text('Add',
                                  style: PillBinRegular.style(
                                      fontSize: sw * 0.028,
                                      color: PillBinColors.primary)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: sh * 0.025),
                if (docs.isNotEmpty)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        PillBinColors.primary,
                        PillBinColors.primaryLight
                      ]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: PillBinColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          Navigator.pop(ctx);
                          final vp = context.read<VendorProvider>();
                          final ok = await vp.uploadVerificationDocs(docs);
                          if (!context.mounted) return;
                          CustomSnackBar.show(
                            context: context,
                            icon: ok
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            title: ok
                                ? 'Documents submitted for review'
                                : (vp.lastError ?? 'Failed to submit documents'),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                          child: Center(
                            child: Text('Submit for Verification',
                                style: PillBinMedium.style(
                                    fontSize: sw * 0.042,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVerifiedBadge(double sw, double sh, String? verifiedAt) {
    String? when;
    if (verifiedAt != null) {
      final parsed = DateTime.tryParse(verifiedAt);
      if (parsed != null) {
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final d = parsed.toLocal();
        when = '${months[d.month - 1]} ${d.day}, ${d.year}';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PillBinColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: sw * 0.013,
              decoration: BoxDecoration(
                color: PillBinColors.success,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(13)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04, vertical: sh * 0.018),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(sw * 0.021),
                      decoration: BoxDecoration(
                        color: PillBinColors.success.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.verified_rounded,
                          size: sw * 0.048, color: PillBinColors.success),
                    ),
                    SizedBox(width: sw * 0.035),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Verified Center',
                              style: PillBinMedium.style(
                                  fontSize: sw * 0.038,
                                  color: PillBinColors.textDark)),
                          SizedBox(height: sh * 0.004),
                          Text(
                            when != null
                                ? 'Approved $when'
                                : 'Visible to donors nearby',
                            style: PillBinRegular.style(
                                fontSize: sw * 0.031,
                                color: PillBinColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResponseSheet(String requestId, String status) {
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PillBinColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final sw = MediaQuery.of(ctx).size.width;
        final sh = MediaQuery.of(ctx).size.height;
        return Padding(
          padding: EdgeInsets.only(
            left: sw * 0.06,
            right: sw * 0.06,
            top: sh * 0.025,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + sh * 0.025,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: sw * 0.1,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PillBinColors.greyLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: sh * 0.02),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(sw * 0.025),
                    decoration: BoxDecoration(
                      color: (status == 'approved' ? Colors.green : Colors.red)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      status == 'approved'
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      color: status == 'approved' ? Colors.green : Colors.red,
                      size: sw * 0.05,
                    ),
                  ),
                  SizedBox(width: sw * 0.03),
                  Text(
                    status == 'approved' ? 'Approve Request' : 'Reject Request',
                    style: PillBinBold.style(
                        fontSize: sw * 0.048, color: PillBinColors.textPrimary),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.02),
              Text('Note for User',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.038, color: PillBinColors.textPrimary)),
              SizedBox(height: sh * 0.008),
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Optional — e.g. Please bring original packaging',
                  hintStyle: PillBinRegular.style(
                      fontSize: sw * 0.033, color: PillBinColors.textLight),
                  filled: true,
                  fillColor: PillBinColors.background,
                  contentPadding: EdgeInsets.all(sw * 0.04),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: PillBinColors.greyLight)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: PillBinColors.greyLight)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: PillBinColors.primary, width: 2)),
                ),
                style: PillBinRegular.style(
                    fontSize: sw * 0.035, color: PillBinColors.textDark),
              ),
              SizedBox(height: sh * 0.025),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: status == 'approved'
                        ? [Colors.green.shade600, Colors.green.shade400]
                        : [Colors.red.shade600, Colors.red.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (status == 'approved' ? Colors.green : Colors.red)
                          .withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final vp = context.read<VendorProvider>();
                      final ok = await vp.updateRequestStatus(
                        requestId,
                        status,
                        vendorNote: noteCtrl.text.trim().isNotEmpty
                            ? noteCtrl.text.trim()
                            : null,
                      );
                      if (!context.mounted) return;
                      if (ok) vp.ensureRequests(status: 'pending');
                      CustomSnackBar.show(
                        context: context,
                        icon: ok
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        title: ok
                            ? 'Request $status successfully'
                            : (vp.lastError ?? 'Failed to update request'),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                      child: Center(
                        child: Text(
                          status == 'approved'
                              ? 'Confirm Approval'
                              : 'Confirm Rejection',
                          style: PillBinMedium.style(
                              fontSize: sw * 0.042, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
