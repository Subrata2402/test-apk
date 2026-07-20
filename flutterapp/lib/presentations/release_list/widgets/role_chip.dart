import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class TagChip extends StatelessWidget {
  final String label;
  final Color color, bg, border;

  const TagChip({super.key, required this.label, required this.color, required this.bg, required this.border});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(2)),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(context.scale(6)),
      border: Border.all(color: border),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(fontSize: context.scale(10), color: color, fontWeight: FontWeight.w600),
    ),
  );
}

class RoleChip extends StatelessWidget {
  final String role;

  const RoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    late Color color, bg, border;
    if (role == 'Owner') {
      color = AppColors.accentLight;
      bg = AppColors.accent.withValues(alpha: 0.15);
      border = AppColors.accent.withValues(alpha: 0.30);
    } else if (role == 'Developer') {
      color = AppColors.orb2;
      bg = AppColors.orb2.withValues(alpha: 0.15);
      border = AppColors.orb2.withValues(alpha: 0.30);
    } else {
      color = AppColors.success;
      bg = AppColors.success.withValues(alpha: 0.15);
      border = AppColors.success.withValues(alpha: 0.30);
    }
    return TagChip(label: role, color: color, bg: bg, border: border);
  }
}
