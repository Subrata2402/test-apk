import 'package:flutter/material.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class AppListEmpty extends StatelessWidget {
  const AppListEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - context.scale(150),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_person_rounded, size: context.scale(56), color: Colors.white.withValues(alpha: 0.12)),
            SizedBox(height: context.scale(16)),
            Text(
              "You haven't been added\nto any app yet.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: IosTheme.textSecondary, fontSize: context.scale(15), letterSpacing: -0.2),
            ),
            SizedBox(height: context.scale(8)),
            Text(
              'Ask a developer to invite you as a Tester.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: IosTheme.textTertiary, fontSize: context.scale(13)),
            ),
          ],
        ),
      ),
    );
  }
}
