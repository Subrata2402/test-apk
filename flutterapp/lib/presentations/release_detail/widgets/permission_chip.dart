import 'package:flutter/material.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class PermissionChip extends StatelessWidget {
  final String permission;

  const PermissionChip({super.key, required this.permission});

  @override
  Widget build(BuildContext context) {
    final short = permission.split('.').last;
    return GlassPanel(
      padding: EdgeInsets.symmetric(horizontal: context.scale(10), vertical: context.scale(5)),
      borderRadius: 8,
      blur: 12,
      borderColor: Colors.white.withValues(alpha: 0.16),
      child: Text(
        short,
        style: GoogleFonts.robotoMono(fontSize: context.scale(11), color: Colors.white.withValues(alpha: 0.65)),
      ),
    );
  }
}
