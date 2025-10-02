import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/locationCardShimmer.dart';
import 'package:pillbin/features/locations/presentation/widgets/location_card.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/network/models/medical_center_model.dart';
import 'package:pillbin/network/models/user_model.dart';
import 'package:provider/provider.dart';

class SavedMedicalCentersScreen extends StatefulWidget {
  const SavedMedicalCentersScreen({super.key});

  @override
  State<SavedMedicalCentersScreen> createState() =>
      _SavedMedicalCentersScreenState();
}

class _SavedMedicalCentersScreenState extends State<SavedMedicalCentersScreen> {
  final TextEditingController _searchController = TextEditingController();

  //* Filter variables
  double _maxDistance = 10.0; // in km
  double _minRating = 0.0;

  //* bool
  bool isSaved = true;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<UserProvider>();

        print("Raeched bottom");
        if (provider.hasMore && !provider.isLoading) {
          provider.getSavedMedicalCenters(context: context);
        }
      }
    });

    final provider = context.read<UserProvider>();
    if (provider.hasMore &&
        !provider.isLoading &&
        provider.medicalCenter!.isEmpty) {
      provider.resetAllCenters();
      provider.getSavedMedicalCenters(context: context);
    }
  }

  void _refresh() {
    final provider = context.read<UserProvider>();
    if (!provider.isLoading) {
      provider.resetAllCenters();
      provider.getSavedMedicalCenters(context: context);
    }
  }

  double _getDistance(double lat, double long) {
    UserProvider provider = context.read<UserProvider>();
    UserModel user = provider.user!;

    double lat1 = user.location!.coordinates!.latitude!;
    double long1 = user.location!.coordinates!.longitude!;

    //* Distance in meters
    double distanceInMeters = Geolocator.distanceBetween(
      lat1,
      long1,
      lat,
      long,
    );

    return distanceInMeters / 1000;
  }

  void _applyFilters() {
    final provider = context.read<UserProvider>();
    List<MedicalCenter> _filtered = provider.medicalCenter!.where((center) {
      return _getDistance(center.coordinates.last, center.coordinates.first) <=
              _maxDistance &&
          center.rating >= _minRating;
    }).toList();

    provider.updateFilterSearch(_filtered);
  }

  void _applyFiltersSearch() {
    final provider = context.read<UserProvider>();
    final searchQuery = _searchController.text.trim();

    if (searchQuery.isEmpty) {
      provider.clearFilterSearch();
      return;
    }

    List<MedicalCenter> _filtered = provider.medicalCenter!.where((center) {
      return center.name
              .trim()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          center.address
              .trim()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();

    provider.updateFilterSearch(_filtered);
  }

  void _showFilterBottomSheet(double sw, double sh, bool isTablet) {
    double tempMaxDistance = _maxDistance;
    double tempMinRating = _minRating;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(sw * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: sw * 0.12,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PillBinColors.greyLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: sh * 0.02),

              // Title
              Text(
                'Filter Options',
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.028 : sw * 0.05,
                  color: PillBinColors.textPrimary,
                ),
              ),
              SizedBox(height: sh * 0.03),

              // Distance Filter
              Text(
                'Maximum Distance',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                  color: PillBinColors.textPrimary,
                ),
              ),
              SizedBox(height: sh * 0.01),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: tempMaxDistance,
                      min: 0.5,
                      max: 10.0,
                      divisions: 19,
                      activeColor: PillBinColors.primary,
                      inactiveColor: PillBinColors.greyLight,
                      label: '${tempMaxDistance.toStringAsFixed(1)} km',
                      onChanged: (value) {
                        setModalState(() {
                          tempMaxDistance = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03,
                      vertical: sh * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: PillBinColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${tempMaxDistance.toStringAsFixed(1)} km',
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                        color: PillBinColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.03),

              // Rating Filter
              Text(
                'Minimum Rating',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                  color: PillBinColors.textPrimary,
                ),
              ),
              SizedBox(height: sh * 0.01),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: tempMinRating,
                      min: 0.0,
                      max: 5.0,
                      divisions: 10,
                      activeColor: PillBinColors.primary,
                      inactiveColor: PillBinColors.greyLight,
                      label: tempMinRating.toStringAsFixed(1),
                      onChanged: (value) {
                        setModalState(() {
                          tempMinRating = value;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.03,
                      vertical: sh * 0.008,
                    ),
                    decoration: BoxDecoration(
                      color: PillBinColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: isTablet ? sw * 0.02 : sw * 0.035,
                        ),
                        SizedBox(width: sw * 0.01),
                        Text(
                          tempMinRating.toStringAsFixed(1),
                          style: PillBinMedium.style(
                            fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                            color: PillBinColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sh * 0.03),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          tempMaxDistance = 10.0;
                          tempMinRating = 0.0;
                        });

                        //* Reset filters
                        final provider = context.read<UserProvider>();
                        provider.clearFilterSearch();
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: PillBinColors.primary),
                        padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reset',
                        style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.022 : sw * 0.036,
                          color: PillBinColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _maxDistance = tempMaxDistance;
                          _minRating = tempMinRating;
                        });

                        //* Apply FIlters
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PillBinColors.primary,
                        padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.022 : sw * 0.036,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: PillBinColors.textPrimary,
            size: isTablet ? sw * 0.025 : sw * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Centers',
          style: PillBinBold.style(
            fontSize: isTablet ? sw * 0.03 : sw * 0.045,
            color: PillBinColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: PillBinColors.greyLight.withOpacity(0.3),
            height: 1,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _refresh();
              },
              icon: Icon(
                Icons.refresh,
                color: PillBinColors.primary,
              )),
          SizedBox(
            width: 5,
          )
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildSearchBar(sw, sh, isTablet),
              _buildResultsCount(sw, sh, isTablet, provider),
              Expanded(
                child: (provider.isLoading &&
                        (provider.medicalCenter!.isEmpty || provider.isDelete))
                    ? LocationCardShimmer(sw: sw, sh: sh)
                    : _buildCentersList(sw, sh, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(double sw, double sh, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      color: PillBinColors.surface,
      child: Container(
        decoration: BoxDecoration(
          color: PillBinColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: PillBinColors.greyLight.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _applyFiltersSearch(),
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.022 : sw * 0.036,
            color: PillBinColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search saved centers...',
            hintStyle: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.022 : sw * 0.036,
              color: PillBinColors.textSecondary,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: PillBinColors.textSecondary,
              size: isTablet ? sw * 0.025 : sw * 0.045,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: PillBinColors.textSecondary,
                      size: isTablet ? sw * 0.025 : sw * 0.045,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _applyFiltersSearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.015,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCount(
      double sw, double sh, bool isTablet, UserProvider provider) {
    bool hasActiveFilters = _maxDistance < 10.0 || _minRating > 0.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.025 : sw * 0.04,
        vertical: sh * 0.01,
      ),
      child: Row(
        children: [
          Icon(
            Icons.bookmark,
            color: PillBinColors.primary,
            size: isTablet ? sw * 0.02 : sw * 0.035,
          ),
          SizedBox(width: sw * 0.015),
          Text(
            '${provider.medicalCenter!.length} saved centers',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(sw, sh, isTablet),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.025,
                vertical: sh * 0.005,
              ),
              decoration: BoxDecoration(
                color: hasActiveFilters
                    ? PillBinColors.primary
                    : PillBinColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    color:
                        hasActiveFilters ? Colors.white : PillBinColors.primary,
                    size: isTablet ? sw * 0.02 : sw * 0.035,
                  ),
                  SizedBox(width: sw * 0.01),
                  Text(
                    'Filter',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                      color: hasActiveFilters
                          ? Colors.white
                          : PillBinColors.primary,
                    ),
                  ),
                  if (hasActiveFilters) ...[
                    SizedBox(width: sw * 0.015),
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: PillBinColors.primary,
                        size: isTablet ? sw * 0.015 : sw * 0.025,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentersList(double sw, double sh, UserProvider provider) {
    if (provider.medicalCenter!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: sw * 0.15,
              color: PillBinColors.greyLight,
            ),
            SizedBox(height: sh * 0.02),
            Text(
              'No saved centers',
              style: PillBinMedium.style(
                fontSize: sw * 0.04,
                color: PillBinColors.textSecondary,
              ),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              _searchController.text.isNotEmpty ||
                      _maxDistance < 10.0 ||
                      _minRating > 0.0
                  ? 'Try adjusting your filters'
                  : 'Save centers to see them here',
              style: PillBinRegular.style(
                fontSize: sw * 0.032,
                color: PillBinColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: PillBinColors.primary,
      onRefresh: () async {
        _refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.01,
        ),
        itemCount: provider.medicalCenter!.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          //* 👇 Handle pagination loader at the end
          if (index == provider.medicalCenter!.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: sh * 0.02),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final center = provider.medicalCenter![index];

          return LocationCard(
            sh: sh,
            sw: sw,
            medicalCenter: center,
            isSaved: isSaved,
          );
        },
      ),
    );
  }
}
