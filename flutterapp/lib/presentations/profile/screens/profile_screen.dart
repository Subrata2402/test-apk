import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/core/auth_service.dart';
import 'package:flutterapp/models/user_model.dart';
import 'package:flutterapp/presentations/login/screens/login_screen.dart';
import 'package:flutterapp/presentations/profile/widgets/logout_confirmation_dialog.dart';
import 'package:flutterapp/presentations/profile/widgets/profile_avatar.dart';
import 'package:flutterapp/presentations/profile/widgets/profile_info_card.dart';
import 'package:flutterapp/presentations/profile/widgets/profile_legal_card.dart';
import 'package:flutterapp/presentations/profile/widgets/profile_logout_button.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/orb.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onSignedOut;

  const ProfileScreen({super.key, required this.user, this.onSignedOut});

  Future<void> _handleSignOut(BuildContext context) async {
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(opacity: anim1, child: const LogoutConfirmationDialog()),
        );
      },
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
      await AuthService.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss the dialog
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg3,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bg1, AppColors.bg2, AppColors.bg3],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Bokeh orbs
          Positioned(
            top: -context.scale(120),
            left: -context.scale(80),
            child: Orb(size: context.scale(300), color: AppColors.orb1.withValues(alpha: 0.30)),
          ),
          Positioned(
            bottom: -context.scale(60),
            right: -context.scale(60),
            child: Orb(size: context.scale(240), color: AppColors.orb4.withValues(alpha: 0.22)),
          ),

          // Content
          Column(
            children: [
              // Glass AppBar
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.07),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.scale(4),
                          context.scale(8),
                          context.scale(16),
                          context.scale(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: context.scale(22)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Text(
                              'Profile',
                              style: GoogleFonts.inter(
                                fontSize: context.scale(18),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(32)),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        // Avatar
                        ProfileAvatar(user: user),

                        SizedBox(height: context.scale(20)),

                        // Name
                        Text(
                          user.name,
                          style: GoogleFonts.inter(
                            fontSize: context.scale(22),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.scale(6)),

                        // Email
                        Text(
                          user.email,
                          style: GoogleFonts.inter(fontSize: context.scale(14), color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: context.scale(8)),

                        // Role badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(4)),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(context.scale(20)),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.35), width: 0.8),
                          ),
                          child: Text(
                            user.role[0].toUpperCase() + user.role.substring(1),
                            style: GoogleFonts.inter(
                              fontSize: context.scale(12),
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentLight,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),

                        SizedBox(height: context.scale(36)),

                        // Info card
                        ProfileInfoCard(user: user),

                        SizedBox(height: context.scale(20)),

                        // Legal card
                        const ProfileLegalCard(),

                        SizedBox(height: context.scale(32)),

                        // Logout button
                        ProfileLogoutButton(onTap: () => _handleSignOut(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
