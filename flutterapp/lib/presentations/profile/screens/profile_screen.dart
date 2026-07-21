import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/core/auth_service.dart';
import 'package:flutterapp/models/user_model.dart';
import 'package:flutterapp/presentations/login/screens/login_screen.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/orb.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onSignedOut;

  const ProfileScreen({super.key, required this.user, this.onSignedOut});

  Future<void> _handleSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          backgroundColor: AppColors.bg3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Sign Out',
            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Text('Are you sure you want to sign out?', style: GoogleFonts.inter(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'Sign Out',
                style: GoogleFonts.inter(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
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
          CustomScrollView(
            slivers: [
              // Glass AppBar
              SliverToBoxAdapter(
                child: ClipRect(
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
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(32)),
                  child: Column(
                    children: [
                      // Avatar
                      _buildAvatar(context),

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
                      _buildInfoCard(context),

                      SizedBox(height: context.scale(32)),

                      // Logout button
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final size = context.scale(90);
    if (user.picture != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.50), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.30),
              blurRadius: context.scale(24),
              spreadRadius: context.scale(4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(user.picture!, width: size, height: size, fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.50), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.30),
            blurRadius: context.scale(24),
            spreadRadius: context.scale(4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          user.initials,
          style: GoogleFonts.inter(fontSize: context.scale(32), fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
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
                    fontSize: context.scale(14),
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

  Widget _buildLogoutButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(14)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleSignOut(context),
            borderRadius: BorderRadius.circular(context.scale(14)),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: context.scale(16)),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(context.scale(14)),
                border: Border.all(color: Colors.red.withValues(alpha: 0.30), width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent, size: context.scale(18)),
                  SizedBox(width: context.scale(10)),
                  Text(
                    'Sign Out',
                    style: GoogleFonts.inter(
                      fontSize: context.scale(15),
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
