import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class CategorySelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onCategoryChanged;
  final double sw;
  final double sh;
  final bool isTablet;

  const CategorySelector({
    super.key,
    required this.selectedIndex,
    required this.onCategoryChanged,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'label': 'Information', 'icon': Icons.info_outline},
      {'label': 'Surveys', 'icon': Icons.poll_outlined},
      {'label': 'Know More', 'icon': Icons.school_outlined},
    ];

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.03 : sw * 0.05,
        vertical: sh * 0.02,
      ),
      padding: EdgeInsets.all(isTablet ? sw * 0.008 : sw * 0.012),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.02 : sw * 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(categories.length, (index) {
          final isSelected = selectedIndex == index;
          final category = categories[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onCategoryChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? sh * 0.015 : sh * 0.018,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? PillBinColors.primary : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(isTablet ? sw * 0.015 : sw * 0.025),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      color: isSelected
                          ? Colors.white
                          : PillBinColors.textSecondary,
                      size: isTablet ? sw * 0.025 : sw * 0.045,
                    ),
                    SizedBox(width: sw * 0.015),
                    Text(
                      category['label'] as String,
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                        color: isSelected
                            ? Colors.white
                            : PillBinColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
