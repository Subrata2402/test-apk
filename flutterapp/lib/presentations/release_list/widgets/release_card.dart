import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/models/release_model.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class ReleaseCard extends StatelessWidget {
  final ReleaseModel release;
  final VoidCallback onTap;

  const ReleaseCard({super.key, required this.release, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        margin: EdgeInsets.only(bottom: context.scale(12)),
        padding: EdgeInsets.all(context.scale(16)),
        borderRadius: 16,
        borderColor: Colors.white.withValues(alpha: 0.16),
        child: Row(
          children: [
            Container(
              width: context.scale(44),
              height: context.scale(44),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                    const Color(0xFF6D28D9).withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(context.scale(11)),
                border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.30), width: 0.8),
              ),
              child: Icon(Icons.android, color: const Color(0xFFDDD6FE), size: context.scale(24)),
            ),
            SizedBox(width: context.scale(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    release.appName ?? '$kBuildPrefix${release.buildNumber}',
                    style: GoogleFonts.inter(
                      fontSize: context.scale(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: context.scale(4)),
                  Text(
                    'v${release.version} (${release.buildNumber})',
                    style: GoogleFonts.inter(fontSize: context.scale(12), color: Colors.white.withValues(alpha: 0.45)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.30), size: context.scale(20)),
          ],
        ),
      ),
    );
  }
}
