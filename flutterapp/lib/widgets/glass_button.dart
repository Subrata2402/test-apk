import 'package:flutter/material.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final LinearGradient gradient;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.gradient,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(10)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(context.scale(10)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.8),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.scale(18), vertical: context.scale(10)),
              child: isLoading
                  ? SizedBox(
                      width: context.scale(16),
                      height: context.scale(16),
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: context.scale(13),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
