import 'package:flutter/material.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final Color bgColor;
  final double? size;

  const GlassAvatar({super.key, required this.initials, required this.color, required this.bgColor, this.size});

  @override
  Widget build(BuildContext context) {
    final double avatarSize = size ?? 36;
    return Container(
      width: context.scale(avatarSize),
      height: context.scale(avatarSize),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.30), width: 0.8),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.inter(
            fontSize: context.scale(avatarSize * 0.3),
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
