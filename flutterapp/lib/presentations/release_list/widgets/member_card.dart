import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:flutterapp/presentations/release_list/widgets/role_chip.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberCard extends StatelessWidget {
  final MemberModel member;

  const MemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final displayName = member.name.isNotEmpty ? member.name : member.email.split('@')[0];
    final initials = displayName.substring(0, displayName.length >= 2 ? 2 : 1).toUpperCase();
    final isPending = member.status == 'Pending';

    return GlassPanel(
      margin: EdgeInsets.only(bottom: context.scale(12)),
      padding: EdgeInsets.all(context.scale(16)),
      borderRadius: 16,
      borderColor: Colors.white.withValues(alpha: 0.16),
      child: Row(
        children: [
          Container(
            width: context.scale(42),
            height: context.scale(42),
            decoration: BoxDecoration(
              color: AppColors.orb2.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.orb2.withValues(alpha: 0.30), width: 0.8),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.inter(
                  fontSize: context.scale(13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.orb2,
                ),
              ),
            ),
          ),
          SizedBox(width: context.scale(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.inter(
                    fontSize: context.scale(14),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.scale(2)),
                Text(
                  member.email,
                  style: GoogleFonts.inter(fontSize: context.scale(12), color: Colors.white.withValues(alpha: 0.45)),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.scale(5)),
                Row(
                  children: [
                    RoleChip(role: member.role),
                    if (isPending) ...[
                      SizedBox(width: context.scale(8)),
                      TagChip(
                        label: 'Pending',
                        color: AppColors.warning,
                        bg: AppColors.warning.withValues(alpha: 0.15),
                        border: AppColors.warning.withValues(alpha: 0.30),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
