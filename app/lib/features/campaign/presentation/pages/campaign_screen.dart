import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/campaign/presentation/widgets/campaign_card.dart';
import 'package:pillbin/features/campaign/presentation/widgets/campaign_widgets.dart';
import 'package:pillbin/features/campaign/presentation/widgets/campaigns_display.dart';

class MyCampaignsScreen extends StatefulWidget {
  const MyCampaignsScreen({Key? key}) : super(key: key);

  @override
  State<MyCampaignsScreen> createState() => _MyCampaignsScreenState();
}

class _MyCampaignsScreenState extends State<MyCampaignsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  List<Campaign> _allCampaigns = [];
  List<Campaign> _filteredCampaigns = [];

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
    _loadCampaigns();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadCampaigns() {
    // Sample data - replace with actual data loading
    _allCampaigns = [
      Campaign(
        title: 'Apollo Take-Back Program',
        description: 'Monthly medicine collection at Apollo Pharmacy',
        date: DateTime.now().add(const Duration(days: 15)),
        location: 'Apollo Pharmacy, Bandra West',
        status: 'Ongoing',
        joinedDate: DateTime.now().subtract(const Duration(days: 5)),
        medicinesCollected: 25,
        participantsCount: 150,
      ),
      Campaign(
        title: 'Community Health Drive',
        description: 'Neighborhood awareness and collection event',
        date: DateTime.now().add(const Duration(days: 30)),
        location: 'Community Center, Linking Road',
        status: 'Upcoming',
        joinedDate: DateTime.now().subtract(const Duration(days: 2)),
        medicinesCollected: 0,
        participantsCount: 45,
      ),
      Campaign(
        title: 'Hospital Disposal Event',
        description: 'Special collection drive at Lilavati Hospital',
        date: DateTime.now().subtract(const Duration(days: 15)),
        location: 'Lilavati Hospital, Bandra',
        status: 'Completed',
        joinedDate: DateTime.now().subtract(const Duration(days: 30)),
        medicinesCollected: 78,
        participantsCount: 200,
      ),
      Campaign(
        title: 'Bandra Medicine Drive',
        description: 'Local community medicine disposal initiative',
        date: DateTime.now().subtract(const Duration(days: 45)),
        location: 'Bandra Community Hall',
        status: 'Completed',
        joinedDate: DateTime.now().subtract(const Duration(days: 60)),
        medicinesCollected: 156,
        participantsCount: 320,
      ),
      Campaign(
        title: 'School Awareness Program',
        description: 'Educational campaign about safe medicine disposal',
        date: DateTime.now().add(const Duration(days: 7)),
        location: 'St. Xavier\'s School, Mumbai',
        status: 'Upcoming',
        joinedDate: DateTime.now().subtract(const Duration(days: 1)),
        medicinesCollected: 0,
        participantsCount: 25,
      ),
      Campaign(
        title: 'Pharmacy Collection Week',
        description: 'Week-long collection drive across multiple pharmacies',
        date: DateTime.now().add(const Duration(days: 60)),
        location: 'Various Locations, Mumbai',
        status: 'Upcoming',
        joinedDate: DateTime.now().subtract(const Duration(days: 3)),
        medicinesCollected: 0,
        participantsCount: 89,
      ),
    ];
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredCampaigns = _allCampaigns.where((campaign) {
        // Search filter
        bool matchesSearch = _searchController.text.isEmpty ||
            campaign.title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            campaign.description
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            campaign.location
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        return matchesSearch;
      }).toList();

      // Sort by status priority and date
      _filteredCampaigns.sort((a, b) {
        int statusPriority(String status) {
          switch (status) {
            case 'Ongoing':
              return 0;
            case 'Upcoming':
              return 1;
            case 'Completed':
              return 2;
            default:
              return 3;
          }
        }

        int statusComparison =
            statusPriority(a.status).compareTo(statusPriority(b.status));
        if (statusComparison != 0) return statusComparison;

        // For same status, sort by date
        if (a.status == 'Completed') {
          return b.date.compareTo(a.date); // Most recent completed first
        } else {
          return a.date.compareTo(b.date); // Nearest upcoming first
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              buildCampaignHeader(sw, sh, isTablet,context),
              SizedBox(height: sh * 0.02),
              _buildSearchBar(sw, sh, isTablet),
              SizedBox(height: sh * 0.015),
              _buildResultsCount(sw, sh, isTablet),
              Expanded(
                child: _buildCampaignsList(sw, sh, isTablet),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(double sw, double sh, bool isTablet) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isTablet ? sw * 0.05 : sw * 0.04),
      child: Container(
        decoration: BoxDecoration(
          color: PillBinColors.surface,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _applyFilters(),
          decoration: InputDecoration(
            hintText: 'Search campaigns by name, location, or description...',
            hintStyle: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.022 : sw * 0.035,
              color: PillBinColors.textLight,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: PillBinColors.textSecondary,
              size: isTablet ? sw * 0.025 : sw * 0.05,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                    child: Icon(
                      Icons.clear,
                      color: PillBinColors.textSecondary,
                      size: isTablet ? sw * 0.025 : sw * 0.05,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
          ),
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.022 : sw * 0.035,
            color: PillBinColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCount(double sw, double sh, bool isTablet) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isTablet ? sw * 0.05 : sw * 0.04),
      child: Row(
        children: [
          Text(
            '${_filteredCampaigns.length} campaign${_filteredCampaigns.length != 1 ? 's' : ''} found',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.022 : sw * 0.035,
              color: PillBinColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _applyFilters();
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? sw * 0.02 : sw * 0.03,
                  vertical: isTablet ? sh * 0.005 : sh * 0.008,
                ),
                decoration: BoxDecoration(
                  color: PillBinColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
                child: Text(
                  'Clear Search',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                    color: PillBinColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCampaignsList(double sw, double sh, bool isTablet) {
    if (_filteredCampaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isTablet ? sw * 0.08 : sw * 0.15,
              color: PillBinColors.textLight,
            ),
            SizedBox(height: sh * 0.02),
            Text(
              'No campaigns found',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.textSecondary,
              ),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              'Try adjusting your search keywords',
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                color: PillBinColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.05 : sw * 0.04,
        vertical: sh * 0.01,
      ),
      itemCount: _filteredCampaigns.length,
      itemBuilder: (context, index) {
        return CampaignListItem(
          campaign: _filteredCampaigns[index],
          sw: sw,
          sh: sh,
          onTap: () => _showCampaignDetails(_filteredCampaigns[index]),
        );
      },
    );
  }

  void _showCampaignDetails(Campaign campaign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CampaignDetailsModal(campaign: campaign),
    );
  }
}
