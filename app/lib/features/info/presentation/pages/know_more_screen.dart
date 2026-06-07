import 'package:flutter/material.dart';
import 'package:pillbin/features/info/data/repository/know_more_list.dart';
import 'package:pillbin/features/info/presentation/widgets/info_empty_state.dart';
import 'package:pillbin/features/info/presentation/widgets/know_more_card.dart';

class KnowMoreScreen extends StatelessWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const KnowMoreScreen({
    super.key,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    // Check if know_more_list exists and has data
    if (KnowMoreList.know_more_list.isEmpty) {
      return EmptyState(
        icon: Icons.school_outlined,
        title: "No Content Available",
        message: "Educational content will appear here once it's added.",
        sw: sw,
        sh: sh,
        isTablet: isTablet,
      );
    }

    return ListView(
      padding: EdgeInsets.only(
        top: sh * 0.01,
        bottom: sh * 0.03,
      ),
      children: [
        //* Category 1: For more information
        if (KnowMoreList.know_more_list.length > 0)
          KnowMoreCategoryCard(
            title: "For More Information",
            subtitle: "Learn about safe medicine disposal",
            icon: Icons.info_outline,
            iconColor: const Color(0xFF2196F3),
            links: KnowMoreList.know_more_list[0].links,
            sw: sw,
            sh: sh,
            isTablet: isTablet,
          ),

        //* Category 2: NGOs which collect unused medicines
        if (KnowMoreList.know_more_list.length > 1)
          KnowMoreCategoryCard(
            title: "NGOs Collecting Unused Medicines",
            subtitle: "Organizations that accept medicine donations",
            icon: Icons.volunteer_activism_outlined,
            iconColor: const Color(0xFF4CAF50),
            links: KnowMoreList.know_more_list[1].links,
            sw: sw,
            sh: sh,
            isTablet: isTablet,
          ),

        //* Category 3: Companies which do Bio-waste management
        if (KnowMoreList.know_more_list.length > 2)
          KnowMoreCategoryCard(
            title: "Bio-waste Management Companies",
            subtitle: "Professional waste management services",
            icon: Icons.recycling_outlined,
            iconColor: const Color(0xFF8BC34A),
            links: KnowMoreList.know_more_list[2].links,
            sw: sw,
            sh: sh,
            isTablet: isTablet,
          ),
      ],
    );
  }
}
