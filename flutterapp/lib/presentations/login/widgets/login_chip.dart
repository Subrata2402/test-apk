import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const LoginChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(50)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(7)),
          decoration: BoxDecoration(
            color: IosTheme.glass.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(context.scale(50)),
            border: Border.all(color: IosTheme.glass.withValues(alpha: 0.25), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: context.scale(13), color: IosTheme.accentLight),
              SizedBox(width: context.scale(5)),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: context.scale(12),
                  color: IosTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
