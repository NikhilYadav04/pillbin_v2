import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/cards/full_image_preview.dart';
import 'package:pillbin/features/blog/data/services/blog_service.dart';


class AIImageGeneratorDialog extends StatefulWidget {
  const AIImageGeneratorDialog({Key? key}) : super(key: key);

  @override
  State<AIImageGeneratorDialog> createState() => _AIImageGeneratorDialogState();
}

class _AIImageGeneratorDialogState extends State<AIImageGeneratorDialog>
    with TickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final BlogServices _blogServices = BlogServices();

  String? _generatedImageBase64;
  Uint8List? _imageBytes;
  bool _isGenerating = false;
  String? _errorMessage;

  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation for the icon
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a prompt'),
          backgroundColor: PillBinColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedImageBase64 = null;
      _imageBytes = null;
      _errorMessage = null;
    });

    // Start animations
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();

    try {
      // Call the real API
      final response = await _blogServices.generateImage(
        query: _promptController.text.trim(),
      );

      if (mounted) {
        // Stop animations
        _pulseController.stop();
        _rotateController.stop();
        _pulseController.reset();
        _rotateController.reset();

        if (response.success && response.data != null) {
          // Extract base64 from response.data
          final base64Image = response.data!['base64'] as String?;

          if (base64Image != null && base64Image.isNotEmpty) {
            // Decode base64 to bytes for display
            final imageBytes = base64Decode(base64Image);

            setState(() {
              _generatedImageBase64 = base64Image;
              _imageBytes = imageBytes;
              _isGenerating = false;
            });
          } else {
            setState(() {
              _errorMessage =
                  'Failed to generate image. No image data received.';
              _isGenerating = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = response.message ?? 'Failed to generate image';
            _isGenerating = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // Stop animations
        _pulseController.stop();
        _rotateController.stop();
        _pulseController.reset();
        _rotateController.reset();

        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
          _isGenerating = false;
        });
      }
    }
  }

  void _useImage() {
    Navigator.pop(context, _generatedImageBase64);
  }

  void _viewFullScreen() {
    if (_imageBytes != null) {
      // Convert Uint8List to a data URI for the full screen preview
      final base64String = base64Encode(_imageBytes!);
      final dataUri = 'data:image/png;base64,$base64String';

      FullScreenImagePreview.show(context, dataUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: isTablet ? sw * 0.5 : sw * 0.85,
        constraints: BoxConstraints(maxHeight: sh * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isTablet, sw, sh),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPromptSection(isTablet, sw, sh),
                    SizedBox(height: sh * 0.02),
                    _buildImagePreview(isTablet, sw, sh),
                    if (_errorMessage != null) ...[
                      SizedBox(height: sh * 0.01),
                      _buildErrorMessage(isTablet, sw, sh),
                    ],
                    SizedBox(height: sh * 0.02),
                    _buildActionButtons(isTablet, sw, sh),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet, double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: PillBinColors.primary,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Image Generator',
                  style: PillBinMedium.style(
                    fontSize: 20,
                    color: PillBinColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Powered by FLUX.2-pro',
                  style: PillBinRegular.style(
                    fontSize: 14,
                    color: PillBinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!_isGenerating)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: PillBinColors.textSecondary,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildPromptSection(bool isTablet, double sw, double sh) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe your image',
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textPrimary,
          ),
        ),
        SizedBox(height: sh * 0.008),
        Container(
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            border: Border.all(
              color: PillBinColors.greyLight,
            ),
          ),
          child: TextField(
            controller: _promptController,
            maxLines: 4,
            enabled: !_isGenerating,
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.022 : sw * 0.035,
              color: PillBinColors.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., A professional medical illustration of...',
              hintStyle: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                color: PillBinColors.textLight,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(bool isTablet, double sw, double sh) {
    return Container(
      height: isTablet ? sh * 0.32 : sh * 0.25,
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        border: Border.all(
          color: PillBinColors.greyLight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        child: _isGenerating
            ? _buildAnimatedLoadingState(isTablet, sw, sh)
            : _imageBytes != null
                ? _buildImageDisplay(isTablet, sw, sh)
                : _buildEmptyState(isTablet, sw, sh),
      ),
    );
  }

  Widget _buildAnimatedLoadingState(bool isTablet, double sw, double sh) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PillBinColors.primary.withOpacity(0.05),
            PillBinColors.primaryLight.withOpacity(0.02),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _rotateController]),
        builder: (context, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated pulsing glow circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing glow
                    Container(
                      width: (isTablet ? sw * 0.12 : sw * 0.22) *
                          _pulseAnimation.value,
                      height: (isTablet ? sw * 0.12 : sw * 0.22) *
                          _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            PillBinColors.primary
                                .withOpacity(0.3 * _pulseAnimation.value),
                            PillBinColors.primary.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                    // Middle circle
                    Container(
                      width: isTablet ? sw * 0.08 : sw * 0.16,
                      height: isTablet ? sw * 0.08 : sw * 0.16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: PillBinColors.primary.withOpacity(0.1),
                        border: Border.all(
                          color: PillBinColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    // Rotating sparkle icon
                    Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Icon(
                        Icons.auto_awesome,
                        color: PillBinColors.primary,
                        size: isTablet ? sw * 0.035 : sw * 0.07,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sh * 0.03),

                // Animated dots text
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    int dotCount = (_pulseController.value * 3).floor() + 1;
                    return Text(
                      'Creating your image${'.' * dotCount}',
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                        color: PillBinColors.textPrimary,
                      ),
                    );
                  },
                ),

                SizedBox(height: sh * 0.008),

                Text(
                  'This may take a few seconds',
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                    color: PillBinColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageDisplay(bool isTablet, double sw, double sh) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Display the actual generated image (tappable for full screen)
        GestureDetector(
          onTap: _viewFullScreen,
          child: Image.memory(
            _imageBytes!,
            fit: BoxFit.cover,
          ),
        ),
        // Success overlay badge
        Positioned(
          top: isTablet ? sw * 0.015 : sw * 0.025,
          right: isTablet ? sw * 0.015 : sw * 0.025,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? sw * 0.015 : sw * 0.025,
              vertical: isTablet ? sw * 0.008 : sw * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: isTablet ? sw * 0.018 : sw * 0.035,
                  color: Colors.white,
                ),
                SizedBox(width: 4),
                Text(
                  'Generated',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.016 : sw * 0.028,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Full screen icon hint
        Positioned(
          bottom: isTablet ? sw * 0.015 : sw * 0.025,
          right: isTablet ? sw * 0.015 : sw * 0.025,
          child: Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.01 : sw * 0.02),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fullscreen,
              size: isTablet ? sw * 0.02 : sw * 0.04,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isTablet, double sw, double sh) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: isTablet ? sw * 0.06 : sw * 0.12,
            color: PillBinColors.textSecondary.withOpacity(0.3),
          ),
          SizedBox(height: sh * 0.015),
          Text(
            'No image generated yet',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.022 : sw * 0.038,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.008),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
            child: Text(
              'Enter a description above and tap Generate',
              textAlign: TextAlign.center,
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                color: PillBinColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(bool isTablet, double sw, double sh) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
      decoration: BoxDecoration(
        color: PillBinColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: PillBinColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: PillBinColors.error,
            size: isTablet ? sw * 0.022 : sw * 0.04,
          ),
          SizedBox(width: sw * 0.02),
          Expanded(
            child: Text(
              _errorMessage!,
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                color: PillBinColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet, double sw, double sh) {
    return Column(
      children: [
        // Generate button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _generateImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isGenerating
                  ? PillBinColors.greyLight
                  : PillBinColors.primary,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? sh * 0.018 : sh * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isGenerating) ...[
                  SizedBox(
                    width: isTablet ? sw * 0.022 : sw * 0.04,
                    height: isTablet ? sw * 0.022 : sw * 0.04,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  SizedBox(width: sw * 0.02),
                ] else
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: isTablet ? sw * 0.022 : sw * 0.042,
                  ),
                SizedBox(width: sw * 0.015),
                Text(
                  _isGenerating ? 'Generating...' : 'Generate Image',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Use image button (only when image is generated)
        if (_generatedImageBase64 != null && !_isGenerating) ...[
          SizedBox(height: sh * 0.012),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _useImage,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: PillBinColors.primary,
                  width: 1.5,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? sh * 0.018 : sh * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    color: PillBinColors.primary,
                    size: isTablet ? sw * 0.022 : sw * 0.042,
                  ),
                  SizedBox(width: sw * 0.015),
                  Text(
                    'Use This Image',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                      color: PillBinColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
