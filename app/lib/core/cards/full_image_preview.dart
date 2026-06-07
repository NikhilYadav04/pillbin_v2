import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Full screen image preview with zoom and close button
class FullScreenImagePreview extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const FullScreenImagePreview({
    Key? key,
    required this.imageUrl,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen image with pinch to zoom
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: heroTag != null
                  ? Hero(
                      tag: heroTag!,
                      child: _buildImage(),
                    )
                  : _buildImage(),
            ),
          ),

          // Close button (top-right)
          SafeArea(
            child: Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tap anywhere to close hint (optional)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Pinch to zoom • Tap X to close',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Check if imageUrl is a data URI (base64)
    if (imageUrl.startsWith('data:image')) {
      // Extract base64 string from data URI
      final base64String = imageUrl.split(',').last;
      final bytes = const Base64Decoder().convert(base64String);
      
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.broken_image,
            size: 100,
            color: Colors.white54,
          ),
        ),
      );
    } else {
      // Regular network URL
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => Center(
          child: Icon(
            Icons.broken_image,
            size: 100,
            color: Colors.white54,
          ),
        ),
      );
    }
  }

  /// Helper method to show full screen preview
  static void show(BuildContext context, String imageUrl, {String? heroTag}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenImagePreview(
          imageUrl: imageUrl,
          heroTag: heroTag,
        ),
      ),
    );
  }
}