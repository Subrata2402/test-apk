import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackCategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const FeedbackCategorySelector({super.key, required this.selectedCategory, required this.onCategoryChanged});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _CategoryItem('bug', 'Bug', Icons.bug_report_outlined),
      _CategoryItem('feature_request', 'Feature', Icons.lightbulb_outline_rounded),
      _CategoryItem('other', 'Other', Icons.more_horiz_rounded),
    ];

    final selectedIndex = categories.indexWhere((item) => item.value == selectedCategory);

    return GlassPanel(
      padding: EdgeInsets.all(context.scale(4)),
      borderRadius: 14,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final itemWidth = totalWidth / categories.length;

          return Stack(
            children: [
              // Sliding background indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                left: selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(context.scale(10)),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.40), width: 1),
                  ),
                ),
              ),

              // Buttons
              Row(
                children: categories.map((item) {
                  final isSelected = item.value == selectedCategory;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onCategoryChanged(item.value),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: context.scale(10)),
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedRotation(
                              turns: isSelected ? 0.05 : 0.0,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                item.icon,
                                color: isSelected ? AppColors.accentLight : Colors.white.withValues(alpha: 0.50),
                                size: context.scale(16),
                              ),
                            ),
                            SizedBox(width: context.scale(6)),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: GoogleFonts.inter(
                                fontSize: context.scale(12),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.50),
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final String value;
  final String label;
  final IconData icon;

  _CategoryItem(this.value, this.label, this.icon);
}
