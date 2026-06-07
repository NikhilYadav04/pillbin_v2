import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/locations/data/network/medical_center_services.dart';
import 'package:pillbin/features/vendor/data/repository/vendor_provider.dart';
import 'package:pillbin/network/utils/http_client.dart';
import 'package:provider/provider.dart';

class VendorClaimCenterScreen extends StatefulWidget {
  const VendorClaimCenterScreen({Key? key}) : super(key: key);

  @override
  State<VendorClaimCenterScreen> createState() =>
      _VendorClaimCenterScreenState();
}

class _VendorClaimCenterScreenState extends State<VendorClaimCenterScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final MedicalCenterServices _service = MedicalCenterServices();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  bool _isClaiming = false;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    final response = await _service.searchMedicalCenters(
      query: query.trim(),
      facilityType: 'all',
      page: 1,
      limit: 20,
    );
    setState(() {
      _isSearching = false;
      if (response.statusCode == 200) {
        final raw = response.data?['centers'] ?? response.data?['medicalCenters'] ?? [];
        _results = List<Map<String, dynamic>>.from(raw);
      }
    });
  }

  Future<void> _claim(Map<String, dynamic> center) async {
    final centerId = center['_id'] as String? ?? '';
    if (centerId.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final sw = MediaQuery.of(ctx).size.width;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Claim Center',
              style: PillBinBold.style(
                  fontSize: sw * 0.045, color: PillBinColors.textPrimary)),
          content: Text(
            'Claim "${center['name']}"?\nYou will become the managing vendor for this center.',
            style: PillBinRegular.style(
                fontSize: sw * 0.035, color: PillBinColors.textSecondary),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: PillBinMedium.style(
                        fontSize: sw * 0.038,
                        color: PillBinColors.textSecondary))),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: PillBinColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
              child: Text('Claim',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.038, color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _isClaiming = true);
    final success =
        await context.read<VendorProvider>().claimCenter(centerId);
    setState(() => _isClaiming = false);

    if (success && mounted) {
      final newCenterId = context.read<VendorProvider>().center?.id;
      await HttpClient().saveVendorCenterId(newCenterId);
      // Go back to onboarding at step 3 (verification) instead of directly home
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/vendor-onboarding-screen',
        (route) => false,
        arguments: {'startAtStep': 3},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.background,
        elevation: 0,
        title: Text('Claim Existing Center',
            style: PillBinBold.style(
                fontSize: sw * 0.048, color: PillBinColors.textPrimary)),
        iconTheme: const IconThemeData(color: PillBinColors.primary),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(sw * 0.05),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: 'Search by center name...',
                  hintStyle: PillBinRegular.style(
                      fontSize: sw * 0.038, color: PillBinColors.textLight),
                  prefixIcon: Icon(Icons.search,
                      color: PillBinColors.textSecondary, size: sw * 0.055),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              size: sw * 0.05,
                              color: PillBinColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _results = []);
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: PillBinColors.surface,
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
              ),
            ),
            if (_isSearching || _isClaiming)
              const LinearProgressIndicator(
                  color: PillBinColors.primary,
                  backgroundColor: PillBinColors.greyLight),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_outlined,
                              size: sw * 0.15, color: PillBinColors.textLight),
                          SizedBox(height: sh * 0.02),
                          Text(
                            _searchCtrl.text.isEmpty
                                ? 'Search for your center above'
                                : 'No centers found',
                            style: PillBinRegular.style(
                                fontSize: sw * 0.038,
                                color: PillBinColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
                      itemCount: _results.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: sh * 0.012),
                      itemBuilder: (_, i) =>
                          _buildCenterTile(_results[i], sw, sh),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterTile(
      Map<String, dynamic> center, double sw, double sh) {
    final alreadyClaimed = center['isVendorManaged'] == true;
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: alreadyClaimed
                ? PillBinColors.greyLight
                : PillBinColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.025),
            decoration: BoxDecoration(
              color: PillBinColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.local_hospital_outlined,
                color: PillBinColors.primary, size: sw * 0.055),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(center['name'] ?? '',
                    style: PillBinMedium.style(
                        fontSize: sw * 0.038,
                        color: PillBinColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: sh * 0.004),
                Text(center['address'] ?? '',
                    style: PillBinRegular.style(
                        fontSize: sw * 0.03,
                        color: PillBinColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (alreadyClaimed) ...[
                  SizedBox(height: sh * 0.004),
                  Text('Already claimed',
                      style: PillBinRegular.style(
                          fontSize: sw * 0.028, color: Colors.red)),
                ],
              ],
            ),
          ),
          if (!alreadyClaimed)
            ElevatedButton(
              onPressed: () => _claim(center),
              style: ElevatedButton.styleFrom(
                backgroundColor: PillBinColors.primary,
                padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04, vertical: sh * 0.01),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Claim',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.032, color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
