import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:flutterapp/widgets/release_action_button.dart';
import 'package:google_fonts/google_fonts.dart';

class AppCard extends StatelessWidget {
  final AppModel app;
  final VoidCallback onTap;

  const AppCard({super.key, required this.app, required this.onTap});

  ImageProvider _getIconProvider(String base64Str) {
    String cleanStr = base64Str;
    if (cleanStr.contains(',')) cleanStr = cleanStr.split(',').last;
    return MemoryImage(base64Decode(cleanStr.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final latestRelease = app.releases.isNotEmpty
        ? 'v${app.releases.first.version} (${app.releases.first.buildNumber})'
        : kNone;

    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        margin: EdgeInsets.only(bottom: context.scale(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // App icon
                if (app.releases.isNotEmpty &&
                    app.releases.first.appIcon != null &&
                    app.releases.first.appIcon!.isNotEmpty)
                  Container(
                    width: context.scale(56),
                    height: context.scale(56),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                      // border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1),
                      image: DecorationImage(image: _getIconProvider(app.releases.first.appIcon!), fit: BoxFit.cover),
                    ),
                  )
                else
                  Container(
                    width: context.scale(56),
                    height: context.scale(56),
                    decoration: BoxDecoration(
                      color: IosTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(context.scale(28)),
                      border: Border.all(color: IosTheme.accent.withValues(alpha: 0.25), width: 1),
                    ),
                    child: Icon(Icons.android_rounded, color: const Color(0xFFC084FC), size: context.scale(32)),
                  ),
                SizedBox(width: context.scale(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: GoogleFonts.inter(
                          fontSize: context.scale(16),
                          fontWeight: FontWeight.w600,
                          color: IosTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: context.scale(2)),
                      Text(
                        app.packageName,
                        style: GoogleFonts.robotoMono(fontSize: context.scale(11), color: IosTheme.textTertiary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.30), size: context.scale(20)),
              ],
            ),
            SizedBox(height: context.scale(14)),
            Container(height: 0.5, color: Colors.white.withValues(alpha: 0.12)),
            SizedBox(height: context.scale(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardStat(context, kLabelLatestVersion, latestRelease),
                if (app.releases.isNotEmpty) ReleaseActionButton(app: app, release: app.releases.first, compact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: context.scale(9),
            fontWeight: FontWeight.w600,
            color: IosTheme.textTertiary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: context.scale(2)),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: context.scale(12),
            fontWeight: FontWeight.w600,
            color: IosTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
