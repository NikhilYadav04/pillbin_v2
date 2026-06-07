import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/info/data/model/info_model.dart';
import 'package:pillbin/features/info/data/repository/information_list.dart';

class InfoCarouselWidget extends StatefulWidget {
  final double sw;
  final double sh;

  const InfoCarouselWidget({
    Key? key,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  State<InfoCarouselWidget> createState() => _InfoCarouselWidgetState();
}

class _InfoCarouselWidgetState extends State<InfoCarouselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  //* Get only first 5 carousel items from InformationList
  List<InfoModel> get _carouselItems =>
      InformationList.information_list.take(5).toList();

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _carouselItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _resetAutoScroll() {
    _autoScrollTimer?.cancel();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  //* Extract plain text from TextSpan (first 150 characters)
  String _extractDescription(List<TextSpan> description) {
    if (description.isEmpty) return '';

    StringBuffer buffer = StringBuffer();

    void extractText(InlineSpan span) {
      if (span is TextSpan) {
        if (span.text != null) {
          buffer.write(span.text);
        }
        if (span.children != null) {
          for (var child in span.children!) {
            extractText(child);
          }
        }
      }
    }

    for (var span in description) {
      extractText(span);
    }

    String fullText = buffer.toString().trim();
    //* Remove bullet points and clean up
    fullText = fullText.replaceAll(RegExp(r'^[•\s]+'), '');
    fullText = fullText.replaceAll('\n\n', ' ');
    fullText = fullText.replaceAll('\n', ' ');
    fullText = fullText.replaceAll(RegExp(r'\s+'), ' ');

    //* Return first 150 characters
    // if (fullText.length > 150) {
    //   return fullText.substring(0, 150).trim() + '...';
    // }
    return fullText;
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = widget.sw > 600;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isTablet ? 0 : widget.sw * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/info-screen',
                arguments: {
                  'transition': TransitionType.topToBottom,
                  'duration': 300,
                },
              );
            },
            child: Text(
              'Information Hub',
              style: PillBinMedium.style(
                fontSize: isTablet ? widget.sw * 0.035 : widget.sw * 0.05,
                color: PillBinColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: widget.sh * 0.02),
          SizedBox(
            height: widget.sh * 0.35,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
                _resetAutoScroll();
              },
              itemCount: _carouselItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.sw * 0.01,
                  ),
                  child: _buildCarouselCard(
                    _carouselItems[index],
                    index,
                    isTablet,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: widget.sh * 0.015),
          _buildDotIndicators(isTablet),
        ],
      ),
    );
  }

  Widget _buildCarouselCard(InfoModel data, int index, bool isTablet) {
    final description = _extractDescription(data.description);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/info-screen',
          arguments: {
            'transition': TransitionType.topToBottom,
            'duration': 300,
          },
        );
      },
      child: Container(
        padding:
            EdgeInsets.all(isTablet ? widget.sw * 0.025 : widget.sw * 0.035),
        decoration: BoxDecoration(
          color: PillBinColors.surface,
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          border: Border.all(
            color: PillBinColors.primary.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: PillBinColors.primary.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: widget.sw * 0.025,
                vertical: widget.sh * 0.01,
              ),
              decoration: BoxDecoration(
                color: PillBinColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                border: Border.all(
                  color: PillBinColors.primary.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Text(
                data.title,
                style: PillBinMedium.style(
                  fontSize: isTablet ? widget.sw * 0.028 : widget.sw * 0.045,
                  color: PillBinColors.primary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: widget.sh * 0.012),

            // Description
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                    isTablet ? widget.sw * 0.018 : widget.sw * 0.028),
                decoration: BoxDecoration(
                  color: PillBinColors.background,
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                  border: Border.all(
                    color: PillBinColors.greyLight.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Text(
                    description,
                    style: PillBinRegular.style(
                      fontSize:
                          isTablet ? widget.sw * 0.018 : widget.sw * 0.035,
                      color: PillBinColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotIndicators(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _carouselItems.length,
        (index) {
          bool isActive = index == _currentPage;
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: widget.sw * 0.008),
              width: isActive
                  ? (isTablet ? widget.sw * 0.025 : widget.sw * 0.035)
                  : (isTablet ? widget.sw * 0.012 : widget.sw * 0.02),
              height: isActive
                  ? (isTablet ? widget.sw * 0.012 : widget.sw * 0.02)
                  : (isTablet ? widget.sw * 0.012 : widget.sw * 0.02),
              decoration: BoxDecoration(
                color:
                    isActive ? PillBinColors.primary : PillBinColors.greyLight,
                borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
              ),
            ),
          );
        },
      ),
    );
  }
}
