import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/models/user_model.dart';
import 'package:flutterapp/presentations/profile/screens/profile_screen.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class AppListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? user;
  final VoidCallback onSignOut;

  const AppListAppBar({super.key, required this.user, required this.onSignOut});

  void _openProfile(BuildContext context) {
    if (user == null) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen(user: user!)));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.white.withValues(alpha: 0.07),
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(14)),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 0.8)),
              ),
              child: Row(
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.scale(9)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: context.scale(34),
                        height: context.scale(34),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [IosTheme.accent, IosTheme.accentDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(context.scale(9)),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.30), width: 0.8),
                        ),
                        child: Icon(Icons.android, color: Colors.white, size: context.scale(18)),
                      ),
                    ),
                  ),
                  SizedBox(width: context.scale(12)),
                  Text(
                    kAppName,
                    style: GoogleFonts.inter(
                      fontSize: context.scale(18),
                      fontWeight: FontWeight.w700,
                      color: IosTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // Tappable Avatar → opens ProfileScreen
                  GestureDetector(
                    onTap: () => _openProfile(context),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.30), width: 1),
                      ),
                      child: user?.picture != null
                          ? CircleAvatar(radius: context.scale(16), backgroundImage: NetworkImage(user!.picture!))
                          : CircleAvatar(
                              radius: context.scale(16),
                              backgroundColor: IosTheme.accent.withValues(alpha: 0.25),
                              child: Text(
                                user?.initials ?? '?',
                                style: GoogleFonts.inter(
                                  fontSize: context.scale(12),
                                  fontWeight: FontWeight.w600,
                                  color: IosTheme.accentLight,
                                ),
                              ),
                            ),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}
