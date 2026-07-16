import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashProgressPill extends StatelessWidget {
  const SplashProgressPill({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(50)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(12)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(context.scale(50)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: context.scale(16),
                height: context.scale(16),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withValues(alpha: 0.80)),
                ),
              ),
              SizedBox(width: context.scale(10)),
              Text(
                'Loading…',
                style: GoogleFonts.inter(
                  fontSize: context.scale(13),
                  color: Colors.white.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
