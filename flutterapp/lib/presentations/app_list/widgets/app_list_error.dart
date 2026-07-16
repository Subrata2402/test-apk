import 'package:flutter/material.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_button.dart';
import 'package:google_fonts/google_fonts.dart';

class AppListError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AppListError({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - context.scale(150),
        alignment: Alignment.center,
        padding: EdgeInsets.all(context.scale(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: context.scale(48), color: Colors.white.withValues(alpha: 0.25)),
            SizedBox(height: context.scale(16)),
            Text(
              error,
              style: GoogleFonts.inter(color: IosTheme.textSecondary, fontSize: context.scale(14)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.scale(20)),
            GlassButton(
              label: 'Retry',
              onPressed: onRetry,
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
            ),
          ],
        ),
      ),
    );
  }
}
