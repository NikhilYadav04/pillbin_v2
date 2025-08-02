import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/features/locations/presentation/widgets/location_widgets.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    super.dispose();
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
              buildLocationHeader(sw, sh, isTablet),
              Expanded(
                child: isTablet
                    ? _buildTabletLayout(sw, sh)
                    : _buildMobileLayout(sw, sh),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(double sw, double sh) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: sh * 0.02),
          buildCurrentLocationButton(sw, sh, false),
          SizedBox(height: sh * 0.025),
          buildMapContainer(sw, sh, false),
          SizedBox(height: sh * 0.03),
          buildNearbyLocations(sw, sh, false),
          SizedBox(height: sh * 0.02),
          buildImportantNote(sw, sh, false),
          SizedBox(height: sh * 0.02),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - Map and location button (Fixed content, scrollable if needed)
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: sh * 0.02),
                  buildCurrentLocationButton(sw, sh, true),
                  SizedBox(height: sh * 0.025),
                  buildMapContainer(sw, sh, true),
                  SizedBox(height: sh * 0.02),
                  buildImportantNote(sw, sh, true),
                  SizedBox(height: sh * 0.02), // Bottom padding
                ],
              ),
            ),
          ),
          SizedBox(width: sw * 0.03),
          // Right column - Nearby locations (Independent scrolling for large cards)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                SizedBox(height: sh * 0.02),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        buildNearbyLocations(sw, sh, true),
                        SizedBox(height: sh * 0.02), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
