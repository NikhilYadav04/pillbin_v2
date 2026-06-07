import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/shimmerCard.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/vendor/data/models/vendor_models.dart';
import 'package:pillbin/features/vendor/data/repository/vendor_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorRequestsScreen extends StatefulWidget {
  const VendorRequestsScreen({Key? key}) : super(key: key);

  @override
  State<VendorRequestsScreen> createState() => _VendorRequestsScreenState();
}

class _VendorRequestsScreenState extends State<VendorRequestsScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final List<String> _statuses = ['pending', 'approved', 'completed', 'rejected'];
  final List<String> _labels = ['Pending', 'Approved', 'Completed', 'Rejected'];
  final List<IconData> _icons = [
    Icons.hourglass_empty_outlined,
    Icons.check_circle_outline,
    Icons.done_all_outlined,
    Icons.cancel_outlined,
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
  }

  void _load() {
    context.read<VendorProvider>().fetchRequests(
          status: _statuses[_selectedIndex],
        );
  }

  void _selectFilter(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _load();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final provider = context.watch<VendorProvider>();

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Donation Requests',
            style: PillBinBold.style(
                fontSize: sw * 0.048, color: PillBinColors.textPrimary)),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildFilterRow(sw, sh),
            SizedBox(height: sh * 0.01),
            Expanded(
              child: provider.isLoading
                  ? ShimmerCards.buildDonationRequestListShimmer(sw, sh)
                  : _buildList(provider, sw, sh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(double sw, double sh) {
    return Container(
      color: PillBinColors.background,
      padding: EdgeInsets.fromLTRB(
          sw * 0.04, sh * 0.005, sw * 0.04, sh * 0.01),
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
                        ? const LinearGradient(colors: [
                            PillBinColors.primary,
                            PillBinColors.primaryLight,
                          ])
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
                              color: PillBinColors.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_icons[i],
                          size: sw * 0.035,
                          color: selected
                              ? Colors.white
                              : PillBinColors.textSecondary),
                      SizedBox(width: sw * 0.015),
                      Text(_labels[i],
                          style: selected
                              ? PillBinMedium.style(
                                  fontSize: sw * 0.032,
                                  color: Colors.white)
                              : PillBinRegular.style(
                                  fontSize: sw * 0.032,
                                  color: PillBinColors.textSecondary)),
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

  Widget _buildList(VendorProvider provider, double sw, double sh) {
    final status = _statuses[_selectedIndex];
    final items = provider.requests.where((r) => r.status == status).toList();

    if (items.isEmpty) {
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
              child: Icon(Icons.inbox_outlined,
                  size: sw * 0.12,
                  color: PillBinColors.primary.withValues(alpha: 0.5)),
            ),
            SizedBox(height: sh * 0.02),
            Text('No $status requests',
                style: PillBinMedium.style(
                    fontSize: sw * 0.04, color: PillBinColors.textPrimary)),
            SizedBox(height: sh * 0.006),
            Text('Pull down to refresh',
                style: PillBinRegular.style(
                    fontSize: sw * 0.032, color: PillBinColors.textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: ListView.separated(
        padding: EdgeInsets.all(sw * 0.05),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
        itemBuilder: (_, i) => _requestCard(items[i], sw, sh, provider),
      ),
    );
  }

  Widget _requestCard(DonationRequest req, double sw, double sh,
      VendorProvider provider) {
    final status = req.status;
    final medicines = req.medicines
        .map((m) => '${m.name} (${m.quantity})')
        .join(', ');
    final userName = req.user?.displayName ?? 'User';
    final userPhone = req.user?.phoneNumber;
    final contact = req.contactPreference ?? 'either';
    final userNote = req.userNote;
    final vendorNote = req.vendorNote;
    final scheduled = req.scheduledDate;

    final statusColor = {
      'pending': Colors.orange,
      'approved': Colors.green,
      'completed': PillBinColors.primary,
      'rejected': Colors.red,
    }[status] ?? PillBinColors.textSecondary;

    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PillBinColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: sw * 0.045, color: PillBinColors.textSecondary),
              SizedBox(width: sw * 0.02),
              Expanded(
                child: Text(userName,
                    style: PillBinMedium.style(
                        fontSize: sw * 0.04,
                        color: PillBinColors.textPrimary)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sh * 0.005),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status,
                    style: PillBinMedium.style(
                        fontSize: sw * 0.028, color: statusColor)),
              ),
            ],
          ),
          SizedBox(height: sh * 0.01),
          // Medicines
          Text('Medicines: $medicines',
              style: PillBinRegular.style(
                  fontSize: sw * 0.032, color: PillBinColors.textSecondary),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          if (req.medicinePhotoUrls.isNotEmpty) ...[
            SizedBox(height: sh * 0.01),
            SizedBox(
              height: sw * 0.22,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: req.medicinePhotoUrls.length,
                separatorBuilder: (_, __) => SizedBox(width: sw * 0.025),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: req.medicinePhotoUrls[i],
                    width: sw * 0.22,
                    height: sw * 0.22,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: sw * 0.22,
                      height: sw * 0.22,
                      color: PillBinColors.greyLight,
                      child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
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
              ),
            ),
          ],
          if (userNote != null && userNote.isNotEmpty) ...[
            SizedBox(height: sh * 0.008),
            Text('Note: $userNote',
                style: PillBinRegular.style(
                    fontSize: sw * 0.03, color: PillBinColors.textSecondary)),
          ],
          if (vendorNote != null && vendorNote.isNotEmpty) ...[
            SizedBox(height: sh * 0.008),
            Text('Your note: $vendorNote',
                style: PillBinRegular.style(
                    fontSize: sw * 0.03, color: PillBinColors.primary)),
          ],
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
          SizedBox(height: sh * 0.01),
          Row(
            children: [
              Icon(Icons.contact_phone_outlined,
                  size: sw * 0.035, color: PillBinColors.textSecondary),
              SizedBox(width: sw * 0.015),
              Text('Prefers: $contact',
                  style: PillBinRegular.style(
                      fontSize: sw * 0.03,
                      color: PillBinColors.textSecondary)),
            ],
          ),
          // Actions
          if (status == 'pending') ...[
            SizedBox(height: sh * 0.015),
            Row(
              children: [
                if (userPhone != null) ...[
                  Expanded(child: _outlineBtn(sw, sh, Icons.phone, 'Call',
                      PillBinColors.primary, () => _callUser(userPhone))),
                  SizedBox(width: sw * 0.02),
                ],
                Expanded(child: _outlineBtn(sw, sh, Icons.close, 'Reject',
                    Colors.red,
                    () => _showResponseSheet(req.id, 'rejected', provider))),
                SizedBox(width: sw * 0.02),
                Expanded(child: _gradientBtn(sw, sh, Icons.check, 'Approve',
                    Colors.green, Colors.green.shade300,
                    () => _showResponseSheet(req.id, 'approved', provider))),
              ],
            ),
          ] else if (status == 'approved') ...[
            SizedBox(height: sh * 0.015),
            _gradientBtn(sw, sh, Icons.done_all, 'Mark as Completed',
                PillBinColors.primary, PillBinColors.primaryLight, () async {
              final ok = await provider.completeRequest(req.id);
              if (!mounted) return;
              CustomSnackBar.show(
                context: context,
                icon: ok ? Icons.check_circle_outline : Icons.error_outline,
                title: ok
                    ? 'Request marked as completed'
                    : (provider.lastError ?? 'Failed to complete request'),
              );
            }),
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
                style: PillBinMedium.style(fontSize: sw * 0.032, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _gradientBtn(double sw, double sh, IconData icon, String label,
      Color c1, Color c2, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: sh * 0.013),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c1, c2]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: c1.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: sw * 0.038, color: Colors.white),
            SizedBox(width: sw * 0.015),
            Text(label,
                style: PillBinMedium.style(
                    fontSize: sw * 0.032, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showResponseSheet(
      String requestId, String status, VendorProvider provider) {
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
        final isApprove = status == 'approved';
        final actionColor = isApprove ? Colors.green : Colors.red;
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
                      color: actionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
                      color: actionColor,
                      size: sw * 0.05,
                    ),
                  ),
                  SizedBox(width: sw * 0.03),
                  Text(
                    isApprove ? 'Approve Request' : 'Reject Request',
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
                    colors: isApprove
                        ? [Colors.green.shade600, Colors.green.shade400]
                        : [Colors.red.shade600, Colors.red.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: actionColor.withValues(alpha: 0.35),
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
                      final ok = await provider.updateRequestStatus(
                        requestId,
                        status,
                        vendorNote: noteCtrl.text.trim().isNotEmpty
                            ? noteCtrl.text.trim()
                            : null,
                      );
                      if (!mounted) return;
                      CustomSnackBar.show(
                        context: context,
                        icon: ok
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        title: ok
                            ? 'Request $status successfully'
                            : (provider.lastError ?? 'Failed to update request'),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                      child: Center(
                        child: Text(
                          isApprove ? 'Confirm Approval' : 'Confirm Rejection',
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

  Future<void> _callUser(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    try {
      await launchUrl(Uri.parse('tel:$cleaned'), mode: LaunchMode.externalApplication);
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
