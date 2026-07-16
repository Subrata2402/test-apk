import 'package:flutter/material.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const LoginInfoRow({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: context.scale(38),
          height: context.scale(38),
          decoration: BoxDecoration(
            color: IosTheme.glass.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(context.scale(10)),
            border: Border.all(color: IosTheme.glass.withValues(alpha: 0.20), width: 0.8),
          ),
          child: Icon(icon, color: IosTheme.accentLight, size: context.scale(18)),
        ),
        SizedBox(width: context.scale(14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: context.scale(13),
                  fontWeight: FontWeight.w600,
                  color: IosTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: context.scale(2)),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: context.scale(12), color: IosTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
