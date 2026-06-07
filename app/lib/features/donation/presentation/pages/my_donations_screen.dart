import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/shimmerCard.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/donation/data/repository/donation_provider.dart';
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String?> _filters = [
    null,
    'pending',
    'approved',
    'completed',
    'rejected'
  ];
  final List<String> _labels = [
    'All',
    'Pending',
    'Approved',
    'Completed',
    'Rejected'
  ];
  final List<IconData> _icons = [
    Icons.list_alt_outlined,
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
    context.read<DonationProvider>().fetchMyRequests(
          status: _filters[_selectedIndex],
        );
  }

  void _selectFilter(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    // Only hit the API when switching to "All" tab with no data yet;
    // other tabs filter in-memory from the already-loaded full list.
    final provider = context.read<DonationProvider>();
    if (provider.myRequests.isEmpty) _load();
  }

  @override
  void dispose() {
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
              child: provider.isLoading
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
    final filter = _filters[_selectedIndex];
    final isAll = filter == null;

    if (isAll) {
      // Grouped sections
      const statusOrder = ['pending', 'approved', 'completed', 'rejected'];
      final statusLabels = {
        'pending': 'Pending',
        'approved': 'Approved',
        'completed': 'Completed',
        'rejected': 'Rejected',
      };
      final statusColors = {
        'pending': Colors.orange,
        'approved': Colors.green,
        'completed': PillBinColors.primary,
        'rejected': Colors.red,
      };

      // Build section list: only include sections with items
      final sections = statusOrder.map((status) {
        final items = _applySearch(
            provider.myRequests.where((r) => r['status'] == status).toList());
        return (status: status, items: items);
      }).where((s) => s.items.isNotEmpty).toList();

      if (sections.isEmpty) return _buildEmpty(sw, sh);

      // Flatten into a list of widgets
      final widgets = <Widget>[];
      for (final section in sections) {
        final color = statusColors[section.status]!;
        widgets.add(
          Padding(
            padding: EdgeInsets.fromLTRB(
                sw * 0.05, widgets.isEmpty ? sh * 0.01 : sh * 0.02, sw * 0.05, sh * 0.01),
            child: Row(
              children: [
                Container(
                  width: sw * 0.012,
                  height: sw * 0.038,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: sw * 0.025),
                Text(
                  '${statusLabels[section.status]!} (${section.items.length})',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.038, color: PillBinColors.textPrimary),
                ),
              ],
            ),
          ),
        );
        for (final item in section.items) {
          widgets.add(
            Padding(
              padding: EdgeInsets.fromLTRB(
                  sw * 0.05, 0, sw * 0.05, sh * 0.015),
              child: _donationCard(item, sw, sh, provider),
            ),
          );
        }
      }

      return RefreshIndicator(
        onRefresh: () async => _load(),
        color: PillBinColors.primary,
        child: ListView(
          padding: EdgeInsets.only(bottom: sh * 0.02),
          children: widgets,
        ),
      );
    }

    // Single-status tab
    final items = _applySearch(
        provider.myRequests.where((r) => r['status'] == filter).toList());

    if (items.isEmpty) return _buildEmpty(sw, sh);

    return RefreshIndicator(
      onRefresh: () async => _load(),
      color: PillBinColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.05, vertical: sh * 0.01),
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: sh * 0.015),
        itemBuilder: (_, i) => _donationCard(items[i], sw, sh, provider),
      ),
    );
  }

  Widget _buildEmpty(double sw, double sh) {
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

  Widget _donationCard(Map<String, dynamic> req, double sw, double sh,
      DonationProvider provider) {
    final status = req['status'] as String;
    final center = req['medicalCenterId'];
    final centerName = center is Map
        ? center['name'] as String? ?? 'Medical Center'
        : 'Medical Center';
    final centerPhone =
        center is Map ? center['phoneNumber'] as String? : null;
    final medicines = (req['medicines'] as List?)
            ?.map((m) => m['name'] as String? ?? '')
            .where((n) => n.isNotEmpty)
            .join(', ') ??
        '';
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
    }[status] ??
        PillBinColors.textSecondary;

    final statusLabel = {
      'pending': 'Pending',
      'approved': 'Approved',
      'completed': 'Completed',
      'rejected': 'Rejected',
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
          // Actions
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
