import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/core/utils/locationCardShimmer.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/locations/data/repository/medical_center_provider.dart';
import 'package:pillbin/features/locations/presentation/widgets/location_widgets.dart';
import 'package:provider/provider.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  //* Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  double _searchRadius = 5.0; //* Default 5 km radius

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

    //* scrollController
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<MedicalCenterProvider>();

        print("Raeched bottom");
        if (provider.hasMoreFetch && !provider.isLoadingFetch) {
          provider.getNearbyMedicalCenters(
              context: context,
              latitude: provider.latitude,
              longitude: provider.longitude,
              radius: _searchRadius.toInt());
        }
      }
    });
  }

  void _refresh() {
    final provider = context.read<MedicalCenterProvider>();
    provider.resetFetch();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  //* scrollController
  late ScrollController _scrollController;

  void _performSearch() {
    MedicalCenterProvider _provider = context.read<MedicalCenterProvider>();

    double latitude = _provider.latitude;
    double longitude = _provider.longitude;

    if (longitude == 0.0 && latitude == 0.0) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.maps_home_work_rounded,
          title: "Please set your location first. Location cannot be empty.");
      return;
    }

    if (_searchRadius == 1.0) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.maps_home_work_rounded,
          title: "Search Radius must be > 1km");

      return;
    }

    _provider.resetFetch();
    _provider.getNearbyMedicalCenters(
        context: context,
        latitude: latitude,
        longitude: longitude,
        radius: _searchRadius.toInt());
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
          child: Consumer<MedicalCenterProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  buildLocationHeader(sw, sh, isTablet),
                  _buildSearchBar(sw, sh, isTablet),
                  _buildRadiusSlider(sw, sh, isTablet),
                  Expanded(
                    child: isTablet
                        ? provider.isLoadingFetch &&
                                (provider.fetchedCenters.isEmpty ||
                                    provider.isLoadingNearby)
                            ? LocationCardShimmer(sw: sw, sh: sh)
                            : _buildTabletLayout(
                                sw,
                                sh,
                                provider.latitude,
                                provider.longitude,
                                provider.placeName,
                                provider)
                        : provider.isLoadingFetch &&
                                (provider.fetchedCenters.isEmpty ||
                                    provider.isLoadingNearby)
                            ? LocationCardShimmer(sw: sw, sh: sh)
                            : _buildMobileLayout(
                                sw,
                                sh,
                                provider.latitude,
                                provider.longitude,
                                provider.placeName,
                                provider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(double sw, double sh, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * (isTablet ? 0.05 : 0.04),
        vertical: sh * 0.015,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: sh * (isTablet ? 0.055 : 0.06),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(sw * (isTablet ? 0.015 : 0.03)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: sw * 0.02,
                    offset: Offset(0, sh * 0.002),
                  ),
                ],
              ),
              child: Center(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _performSearch(),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: 'Search location, address, or pharmacy...',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: sw * (isTablet ? 0.023 : 0.038),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: sw * (isTablet ? 0.032 : 0.06),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey[600],
                              size: sw * (isTablet ? 0.028 : 0.055),
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: sw * 0.04,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Update UI to show/hide clear button
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: sw * 0.02),
          Container(
            height: sh * (isTablet ? 0.055 : 0.06),
            width: sh * (isTablet ? 0.055 : 0.06),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PillBinColors.primary,
                  PillBinColors.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(sw * (isTablet ? 0.015 : 0.03)),
              boxShadow: [
                BoxShadow(
                  color: PillBinColors.primary.withOpacity(0.3),
                  blurRadius: sw * 0.02,
                  offset: Offset(0, sh * 0.004),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(sw * (isTablet ? 0.015 : 0.03)),
                onTap: _performSearch,
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: sw * (isTablet ? 0.032 : 0.065),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusSlider(double sw, double sh, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * (isTablet ? 0.05 : 0.04),
        vertical: sh * 0.01,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.03,
          vertical: sh * (isTablet ? 0.012 : 0.015),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * (isTablet ? 0.015 : 0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: sw * 0.015,
              offset: Offset(0, sh * 0.002),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      size: sw * (isTablet ? 0.025 : 0.05),
                      color: PillBinColors.primary,
                    ),
                    SizedBox(width: sw * 0.02),
                    Text(
                      'Search Radius',
                      style: TextStyle(
                        fontSize: sw * (isTablet ? 0.02 : 0.038),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * (isTablet ? 0.015 : 0.03),
                    vertical: sh * 0.008,
                  ),
                  decoration: BoxDecoration(
                    color: PillBinColors.primary.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(sw * (isTablet ? 0.025 : 0.05)),
                  ),
                  child: Text(
                    '${_searchRadius.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: sw * (isTablet ? 0.02 : 0.038),
                      fontWeight: FontWeight.bold,
                      color: PillBinColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: sh * (isTablet ? 0.004 : 0.005),
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: sw * (isTablet ? 0.012 : 0.022),
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius: sw * (isTablet ? 0.024 : 0.044),
                ),
                activeTrackColor: PillBinColors.primary,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: PillBinColors.primary,
                overlayColor: PillBinColors.primary.withOpacity(0.2),
              ),
              child: Slider(
                value: _searchRadius,
                min: 1.0,
                max: 50.0,
                divisions: 49,
                label: '${_searchRadius.toStringAsFixed(1)} km',
                onChanged: (value) {
                  setState(() {
                    _searchRadius = value;
                  });
                },
                onChangeEnd: (value) {
                  _performSearch();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1 km',
                    style: TextStyle(
                      fontSize: sw * (isTablet ? 0.02 : 0.03),
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '50 km',
                    style: TextStyle(
                      fontSize: sw * (isTablet ? 0.02 : 0.03),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(double sw, double sh, double latitude,
      double longitude, String name, MedicalCenterProvider provider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: sh * 0.02),
          buildCurrentLocationButton(sw, sh, false, context),
          SizedBox(height: sh * 0.02),
          buildLocationInfo(sw, sh, false, latitude, longitude, name),
          SizedBox(height: sh * 0.025),
          buildMapContainer(sw, sh, false),
          SizedBox(height: sh * 0.03),
          buildNearbyLocations(sw, sh, false, provider),
          SizedBox(height: sh * 0.02),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(double sw, double sh, double latitude,
      double longitude, String name, MedicalCenterProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: sh * 0.02),
            buildCurrentLocationButton(sw, sh, true, context),
            SizedBox(height: sh * 0.02),
            buildLocationInfo(sw, sh, false, latitude, longitude, name),
            SizedBox(height: sh * 0.02),
            buildMapContainer(sw, sh, true),
            SizedBox(height: sh * 0.02),
            buildNearbyLocations(sw, sh, true, provider),
            SizedBox(height: sh * 0.02),
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     // Left column - Map and location button (Fixed content, scrollable if needed)
            //     Expanded(
            //       flex: 1,
            //       child: SingleChildScrollView(
            //         physics: const BouncingScrollPhysics(),
            //         child: Column(
            //           children: [
            //             SizedBox(height: sh * 0.02),
            //           ],
            //         ),
            //       ),
            //     ),
            //     SizedBox(width: sw * 0.03),
            //     // Right column - Nearby locations (Independent scrolling for large cards)
            //     Expanded(
            //       flex: 1,
            //       child: Column(
            //         children: [
            //           SizedBox(height: sh * 0.02),
            //           Expanded(
            //             child: SingleChildScrollView(
            //               physics: const BouncingScrollPhysics(),
            //               child: Column(
            //                 children: [
            //                   buildNearbyLocations(sw, sh, true, provider),
            //                   SizedBox(height: sh * 0.02), // Bottom padding
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
