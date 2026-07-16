import 'package:flutter/material.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final Color? color;

  const SectionLabel({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: GoogleFonts.inter(
      fontSize: context.scale(11),
      fontWeight: FontWeight.w600,
      color: color ?? Colors.white.withValues(alpha: 0.40),
      letterSpacing: 0.8,
    ),
  );
}
