import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/models/user_model.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserModel user;

  const ProfileInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(context.scale(16)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.8),
          ),
          child: Column(
            children: [
              _infoRow(context, icon: Icons.person_outline_rounded, label: 'Full Name', value: user.name),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 0.8, thickness: 0.8),
              _infoRow(context, icon: Icons.email_outlined, label: 'Email', value: user.email),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 0.8, thickness: 0.8),
              _infoRow(
                context,
                icon: Icons.shield_outlined,
                label: 'Role',
                value: user.role[0].toUpperCase() + user.role.substring(1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
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
        ],
      ),
    );
  }
}
