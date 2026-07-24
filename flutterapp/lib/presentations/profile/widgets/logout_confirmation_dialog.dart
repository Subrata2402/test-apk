import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: context.scale(40)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.scale(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(context.scale(24)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(context.scale(20)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(context.scale(12)),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(Icons.logout_rounded, color: Colors.redAccent, size: context.scale(28)),
                ),
                SizedBox(height: context.scale(16)),
                // Title
                Text(
                  'Sign Out',
                  style: GoogleFonts.inter(
                    fontSize: context.scale(18),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: context.scale(8)),
                // Content
                Text(
                  'Are you sure you want to sign out of your account?',
                  style: GoogleFonts.inter(
                    fontSize: context.scale(13),
                    color: Colors.white.withValues(alpha: 0.60),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.scale(24)),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.scale(10)),
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: context.scale(14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.scale(12)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: context.scale(12)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.scale(10))),
                        ),
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: context.scale(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
