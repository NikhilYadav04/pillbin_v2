import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/features/info/data/repository/information_list.dart';
import 'package:pillbin/features/info/presentation/widgets/info_card.dart';

class InformationScreen extends StatelessWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const InformationScreen({
    super.key,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        top: sh * 0.01,
        bottom: sh * 0.03,
      ),
      itemCount: InformationList.information_list.length,
      itemBuilder: (context, index) {
        final info = InformationList.information_list[index];
        return InfoCard(
          title: info.title,
          content: info.description.isNotEmpty
              ? info.description[0].children ?? []
              : [],
          image: info.image,
          icon: _getIconForCategory(info.title),
          iconColor: _getColorForIcon(info.title),
          sw: sw,
          sh: sh,
          isTablet: isTablet,
          isSurvey: false,
        );
      },
    );
  }

  IconData _getIconForCategory(String title) {
    if (title.toLowerCase().contains('disposal') ||
        title.toLowerCase().contains('dispose')) {
      return Icons.delete_outline;
    } else if (title.toLowerCase().contains('storage') ||
        title.toLowerCase().contains('store')) {
      return Icons.storage_outlined;
    } else if (title.toLowerCase().contains('safety') ||
        title.toLowerCase().contains('safe')) {
      return Icons.shield_outlined;
    } else if (title.toLowerCase().contains('expir') ||
        title.toLowerCase().contains('date')) {
      return Icons.schedule_outlined;
    } else if (title.toLowerCase().contains('environment') ||
        title.toLowerCase().contains('eco')) {
      return Icons.eco_outlined;
    } else if (title.toLowerCase().contains('guide') ||
        title.toLowerCase().contains('how')) {
      return Icons.menu_book_outlined;
    } else {
      return Icons.info_outline;
    }
  }

  Color _getColorForIcon(String title) {
    if (title.toLowerCase().contains('disposal')) {
      return const Color(0xFF4CAF50);
    } else if (title.toLowerCase().contains('storage')) {
      return const Color(0xFF2196F3);
    } else if (title.toLowerCase().contains('safety')) {
      return const Color(0xFFF44336);
    } else if (title.toLowerCase().contains('expir')) {
      return const Color(0xFFFF9800);
    } else if (title.toLowerCase().contains('environment')) {
      return const Color(0xFF8BC34A);
    } else {
      return PillBinColors.primary;
    }
  }
}
