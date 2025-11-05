import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/features/info/presentation/pages/information_screen.dart';
import 'package:pillbin/features/info/presentation/pages/know_more_screen.dart';
import 'package:pillbin/features/info/presentation/pages/survey_screen.dart';
import 'package:pillbin/features/info/presentation/widgets/info_header.dart';
import 'package:pillbin/features/info/presentation/widgets/info_radio_buttons.dart';

class InformationHubBaseScreen extends StatefulWidget {
  const InformationHubBaseScreen({super.key});

  @override
  State<InformationHubBaseScreen> createState() =>
      _InformationHubBaseScreenState();
}

class _InformationHubBaseScreenState extends State<InformationHubBaseScreen> {
  //* 0: Information, 1: Surveys, 2: Know More
  int _selectedCategory = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(int index) {
    setState(() {
      _selectedCategory = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedCategory = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            PillBinHeader(
              title: "Information Hub",
              subtitle: "Learn about safe medicine disposal",
              sw: sw,
              sh: sh,
              isTablet: isTablet,
              trailing: Container(
                padding: EdgeInsets.all(isTablet ? sw * 0.015 : sw * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: isTablet ? sw * 0.03 : sw * 0.05,
                ),
              ),
            ),

            // Category Selector (Tab Buttons)
            CategorySelector(
              selectedIndex: _selectedCategory,
              onCategoryChanged: _onCategoryChanged,
              sw: sw,
              sh: sh,
              isTablet: isTablet,
            ),

            // PageView for different screens
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  // Information Screen
                  InformationScreen(
                    sw: sw,
                    sh: sh,
                    isTablet: isTablet,
                  ),

                  // Surveys Screen
                  SurveysScreen(
                    sw: sw,
                    sh: sh,
                    isTablet: isTablet,
                  ),

                  // Know More Screen
                  KnowMoreScreen(
                    sw: sw,
                    sh: sh,
                    isTablet: isTablet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
