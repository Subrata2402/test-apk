import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPlatformInfoCard extends StatelessWidget {
  final Future<void> Function(BuildContext, String) onLaunchURL;

  const AboutPlatformInfoCard({super.key, required this.onLaunchURL});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Column(
        children: [
          _infoTile(
            context,
            icon: Icons.language_rounded,
            title: 'Web Dashboard',
            subtitle: 'Google Drive Storage, Team Management, Release History',
            onTap: () => onLaunchURL(context, 'https://testapk.clipboux.online/'),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 0.8, thickness: 0.8),
          _infoTile(
            context,
            icon: Icons.smartphone_rounded,
            title: 'Flutter Client',
            subtitle: 'Glassmorphic UI, One-Tap Install, Version Detection',
          ),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 0.8, thickness: 0.8),
          _infoTile(
            context,
            icon: Icons.terminal_rounded,
            title: 'CLI Tool',
            subtitle: 'Device Auth Flow, Real-Time Progress, Drive Upload Status',
            onTap: () => onLaunchURL(context, 'https://www.npmjs.com/package/testapk-cli'),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final tileContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: context.scale(18), vertical: context.scale(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentLight.withValues(alpha: 0.70), size: context.scale(20)),
          SizedBox(width: context.scale(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: context.scale(14),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.scale(4)),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: context.scale(12),
                    color: Colors.white.withValues(alpha: 0.55),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: context.scale(8)),
            Icon(
              Icons.open_in_new_rounded,
              color: Colors.white.withValues(alpha: 0.30),
              size: context.scale(16),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: tileContent,
        ),
      );
    }

    return tileContent;
  }
}
