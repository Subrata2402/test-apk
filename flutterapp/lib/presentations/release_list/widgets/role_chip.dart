import 'package:flutter/material.dart';
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
      color = const Color(0xFFC084FC);
      bg = const Color(0xFF8B5CF6).withValues(alpha: 0.15);
      border = const Color(0xFF8B5CF6).withValues(alpha: 0.30);
    } else if (role == 'Developer') {
      color = const Color(0xFF22D3EE);
      bg = const Color(0xFF06B6D4).withValues(alpha: 0.15);
      border = const Color(0xFF06B6D4).withValues(alpha: 0.30);
    } else {
      color = const Color(0xFF34D399);
      bg = const Color(0xFF10B981).withValues(alpha: 0.15);
      border = const Color(0xFF10B981).withValues(alpha: 0.30);
    }
    return TagChip(label: role, color: color, bg: bg, border: border);
  }
}
