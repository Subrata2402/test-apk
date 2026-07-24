import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/models/user_model.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileAvatar extends StatelessWidget {
  final UserModel user;

  const ProfileAvatar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: context.scale(24),
            spreadRadius: context.scale(4),
          ),
        ],
      ),
      child: user.picture != null
          ? CircleAvatar(
              radius: context.scale(44),
              backgroundImage: NetworkImage(user.picture!),
              backgroundColor: Colors.transparent,
            )
          : CircleAvatar(
              radius: context.scale(44),
              backgroundColor: AppColors.accent.withValues(alpha: 0.25),
              child: Text(
                user.initials,
                style: GoogleFonts.inter(
                  fontSize: context.scale(32),
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentLight,
                ),
              ),
            ),
    );
  }
}
