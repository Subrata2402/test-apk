import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutSupportCard extends StatelessWidget {
  final Future<void> Function(BuildContext, String) onLaunchURL;

  const AboutSupportCard({super.key, required this.onLaunchURL});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Column(
        children: [
          _supportTile(
            context,
            icon: Icons.email_outlined,
            label: 'Email Support',
            value: 'support@testapk.com',
            onTap: () => onLaunchURL(context, 'mailto:support@testapk.com'),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 0.8, thickness: 0.8),
          _supportTile(
            context,
            icon: Icons.code_rounded,
            label: 'GitHub Issues',
            value: 'github.com/testapk/issues',
            onTap: () => onLaunchURL(context, 'https://github.com/testapk/issues'),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 0.8, thickness: 0.8),
          _supportTile(
            context,
            icon: Icons.forum_outlined,
            label: 'Discord Community',
            value: 'discord.gg/testapk',
            onTap: () => onLaunchURL(context, 'https://discord.gg/testapk'),
          ),
        ],
      ),
    );
  }

  Widget _supportTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final tileContent = Padding(
      padding: EdgeInsets.symmetric(horizontal: context.scale(18), vertical: context.scale(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentLight.withValues(alpha: 0.70), size: context.scale(18)),
          SizedBox(width: context.scale(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: context.scale(11),
                    color: Colors.white.withValues(alpha: 0.40),
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: context.scale(3)),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: context.scale(13),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: context.scale(8)),
            Icon(Icons.open_in_new_rounded, color: Colors.white.withValues(alpha: 0.30), size: context.scale(16)),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, child: tileContent),
      );
    }

    return tileContent;
  }
}
