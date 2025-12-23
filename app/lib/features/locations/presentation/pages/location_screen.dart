import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/core/utils/deBouncer.dart';
import 'package:pillbin/core/utils/locationCardShimmer.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/locations/data/repository/medical_center_provider.dart';
import 'package:pillbin/features/locations/presentation/pages/location_map_card.dart';
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

  //* debounce to prevent multiple search calls
  final Debouncer _deBouncer = Debouncer(milliseconds: 2000);

  //* Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  double _searchRadius = 5.0; //* Default 5 km radius

  //* switch to map view
  bool isMapView = false;

  //* switch to map view and initialize
  Future<void> prepareMap() async {
    final provider = Provider.of<MedicalCenterProvider>(context, listen: false);

    final double? latitude = provider.latitude;
    final double? longitude = provider.longitude;

    if ((latitude == null || latitude == 0.0) &&
        (longitude == null || longitude == 0.0)) {
      CustomSnackBar.show(
          context: context,
          icon: Icons.maps_home_work_rounded,
          title: "Please set your location first. Location cannot be empty.");
      return;
    }

    setState(() {
      isMapView = true;
    });

    provider.clearMarkers();
  }

  //* lock scroll when interacting with map
  bool _lockScroll = false;

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
    _deBouncer.dispose();
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
                  InkWell(
                      onTap: () {
                        var logger = Logger();
                        logger.d(provider.markers);
                        logger.d(provider.markers.length);
                      },
                      child: _buildRadiusSlider(sw, sh, isTablet)),
                  Expanded(
                    child: isTablet
                        ? _buildTabletLayout(sw, sh, provider.latitude,
                            provider.longitude, provider.placeName, provider)
                        : _buildMobileLayout(sw, sh, provider.latitude,
                            provider.longitude, provider.placeName, provider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusSlider(double sw, double sh, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * (isTablet ? 0.05 : 0.04),
        vertical: sh * 0.015,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.03,
          vertical: sh * (isTablet ? 0.012 : 0.018),
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
                    InkWell(
                      child: Text(
                        'Search Radius',
                        style: TextStyle(
                          fontSize: sw * (isTablet ? 0.02 : 0.038),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
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
                  _deBouncer.run(() {
                    _performSearch();
                  });
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

  Widget _buildMobileLayout(
    double sw,
    double sh,
    double latitude,
    double longitude,
    String name,
    MedicalCenterProvider provider,
  ) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation);

            return SlideTransition(
              position: offset,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: isMapView
              ? LocationMapCard(
                  key: const ValueKey('map'),
                  isTablet: false,
                  sh: sh,
                  sw: sw,
                  onMapTouch: (isTouching) {
                    setState(() {
                      _lockScroll = isTouching;
                    });
                  },
                )
              : buildMapContainer(
                  sw,
                  sh,
                  false,
                  prepareMap,
                ),
        ),

        /// 🔽 SCROLLABLE CONTENT
        Expanded(
          child: ListView(
            controller: _scrollController,
            physics: _lockScroll
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: sh * 0.02),
              buildCurrentLocationButton(sw, sh, false, context),
              SizedBox(height: sh * 0.02),
              buildLocationInfo(sw, sh, false, latitude, longitude, name),
              SizedBox(height: sh * 0.03),
              provider.isLoadingFetch && provider.fetchedCenters.isEmpty
                  ? LocationCardShimmer(sw: sw, sh: sh)
                  : buildNearbyLocations(
                      sw,
                      sh,
                      false,
                      provider,
                      _scrollController,
                    ),
              SizedBox(height: sh * 0.02),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(double sw, double sh, double latitude,
      double longitude, String name, MedicalCenterProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
      child: ListView(
        controller: _scrollController,
        physics: _lockScroll
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        children: [
          SizedBox(height: sh * 0.02),
          buildCurrentLocationButton(sw, sh, true, context),
          SizedBox(height: sh * 0.02),
          buildLocationInfo(sw, sh, false, latitude, longitude, name),
          SizedBox(height: sh * 0.02),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(animation);

              return SlideTransition(
                position: offset,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: isMapView
                ? LocationMapCard(
                    key: const ValueKey('map'),
                    isTablet: false,
                    sh: sh,
                    sw: sw,
                    onMapTouch: (isTouching) {
                      setState(() {
                        _lockScroll = isTouching;
                      });
                    },
                  )
                : buildMapContainer(
                    sw,
                    sh,
                    true,
                    prepareMap,
                  ),
          ),
          SizedBox(height: sh * 0.02),
          provider.isLoadingFetch && provider.fetchedCenters.isEmpty
              ? LocationCardShimmer(sw: sw, sh: sh)
              : buildNearbyLocations(sw, sh, true, provider, _scrollController),
          SizedBox(height: sh * 0.02),
        ],
      ),
    );
  }
}
