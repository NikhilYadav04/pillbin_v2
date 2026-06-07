// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pillbin/config/theme/appColors.dart';

class LocationMapCard extends StatefulWidget {
  final bool isTablet;
  final double sh;
  final double sw;
  final Function(bool) onMapTouch;
  final double latitude;
  final double longitude;
  final Set<Marker> markers;

  const LocationMapCard({
    Key? key,
    required this.isTablet,
    required this.sh,
    required this.sw,
    required this.onMapTouch,
    required this.latitude,
    required this.longitude,
    required this.markers,
  }) : super(key: key);

  @override
  State<LocationMapCard> createState() => _LocationMapCardState();
}

class _LocationMapCardState extends State<LocationMapCard> {
  GoogleMapController? _mapController;
  int _lastMarkerCount = 0;

  void _animateCamera(LatLng newLocation) {
    if (_mapController == null) return;

    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(newLocation, 16),
    );
  }

  //* animate camera to show all locations
  void _fitCameraToMarkers(Set<Marker> markers) {
    if (_mapController == null || markers.isEmpty) return;

    //* Handle single marker
    if (markers.length == 1) {
      final pos = markers.first.position;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(pos, 15),
      );
      return;
    }

    double minLat = markers.first.position.latitude;
    double maxLat = minLat;
    double minLng = markers.first.position.longitude;
    double maxLng = minLng;

    for (final marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      //* Skip invalid coordinates
      if (lat.abs() > 90 || lng.abs() > 180) continue;

      minLat = min(minLat, lat);
      maxLat = max(maxLat, lat);
      minLng = min(minLng, lng);
      maxLng = max(maxLng, lng);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          80,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double latitude = widget.latitude;
    final double longitude = widget.longitude;

    if (latitude == 0.0 && longitude == 0.0) {
      return Container(
        height: widget.isTablet ? widget.sh * 0.5 : widget.sh * 0.35,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    final LatLng currLocation = LatLng(latitude, longitude);

    //* Animate camera when marker count changes
    if (_mapController != null &&
        widget.markers.isNotEmpty &&
        widget.markers.length != _lastMarkerCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitCameraToMarkers(widget.markers);
      });

      _lastMarkerCount = widget.markers.length;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: widget.isTablet ? 0 : widget.sw * 0.04,
      ),
      height: widget.isTablet ? widget.sh * 0.5 : widget.sh * 0.28,
      decoration: BoxDecoration(
        color: PillBinColors.greyLight,
        borderRadius: BorderRadius.circular(widget.isTablet ? 24 : 16),
        border: Border.all(color: PillBinColors.greyLight),
      ),
      child: Listener(
        onPointerDown: (_) => widget.onMapTouch(true),
        onPointerUp: (_) => widget.onMapTouch(false),
        onPointerCancel: (_) => widget.onMapTouch(false),
        child: GoogleMap(
          onLongPress: (argument) {
            _animateCamera(currLocation);
          },
          onMapCreated: (controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: currLocation,
            zoom: 15,
          ),
          markers: widget.markers,
        ),
      ),
    );
  }
}
