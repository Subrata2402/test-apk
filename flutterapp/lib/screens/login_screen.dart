import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/core/auth_service.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/screens/app_list/screens/app_list_screen.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

// ── iOS palette (used only within this file) ──────────────────────────────────
class IosTheme {
  static const bg1 = Color(0xFF2D1B69); // deep violet
  static const bg2 = Color(0xFF11244D); // midnight blue
  static const bg3 = Color(0xFF0A1628); // near-black navy
  static const orb1 = Color(0xFF7C3AED); // vivid purple
  static const orb2 = Color(0xFF06B6D4); // cyan
  static const orb3 = Color(0xFFEC4899); // pink
  static const orb4 = Color(0xFF3B82F6); // blue
  static const glass = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF); // 70%
  static const textTertiary = Color(0x80FFFFFF); // 50%
  static const accentLight = Color(0xFFDDD6FE);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final user = await AuthService.instance.signInWithGoogle();
    if (!mounted) return;
    if (user != null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AppListScreen()));
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = kLoginErrorMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IosTheme.bg3,
      body: Stack(
        children: [
          // ── Vivid iOS-style wallpaper gradient ──────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [IosTheme.bg1, IosTheme.bg2, IosTheme.bg3],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ── Bokeh orbs (iOS wallpaper depth) ────────────────────────────
          Positioned(
            top: -context.scale(140),
            left: -context.scale(100),
            child: _Orb(size: context.scale(380), color: IosTheme.orb1.withValues(alpha: 0.45)),
          ),
          Positioned(
            top: context.scale(160),
            right: -context.scale(80),
            child: _Orb(size: context.scale(260), color: IosTheme.orb4.withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: -context.scale(60),
            left: -context.scale(60),
            child: _Orb(size: context.scale(280), color: IosTheme.orb3.withValues(alpha: 0.28)),
          ),
          Positioned(
            bottom: context.scale(120),
            right: -context.scale(30),
            child: _Orb(size: context.scale(200), color: IosTheme.orb2.withValues(alpha: 0.30)),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.scale(20), vertical: context.scale(28)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: context.scale(20)),

                      // Logo tile
                      _LogoTile(),
                      SizedBox(height: context.scale(20)),

                      // Title
                      Text(
                        kAppName,
                        style: GoogleFonts.inter(
                          fontSize: context.scale(34),
                          fontWeight: FontWeight.w700,
                          color: IosTheme.textPrimary,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: context.scale(7)),
                      Text(
                        kLoginSubtitle,
                        style: GoogleFonts.inter(
                          fontSize: context.scale(15),
                          color: IosTheme.textSecondary,
                          letterSpacing: -0.1,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: context.scale(32)),

                      // Feature chips — iOS vibrancy pill row
                      Wrap(
                        spacing: context.scale(8),
                        runSpacing: context.scale(8),
                        alignment: WrapAlignment.center,
                        children: const [
                          _Chip(icon: Icons.android, label: kFeatureBetaTesting),
                          _Chip(icon: Icons.download_rounded, label: kFeatureApkDownloads),
                          _Chip(icon: Icons.notes_rounded, label: kFeatureReleaseNotes),
                          _Chip(icon: Icons.verified_rounded, label: kFeatureVerifiedBuilds),
                          _Chip(icon: Icons.security, label: kFeatureSha256),
                        ],
                      ),

                      SizedBox(height: context.scale(32)),

                      // Glass info card
                      _GlassPanel(
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.lock_person_rounded,
                              title: kInfoTitleTesterAccess,
                              subtitle: kInfoSubtitleTesterAccess,
                            ),
                            _Separator(),
                            _InfoRow(
                              icon: Icons.cloud_done_rounded,
                              title: kInfoTitleSecureStorage,
                              subtitle: kInfoSubtitleSecureStorage,
                            ),
                            _Separator(),
                            _InfoRow(
                              icon: Icons.notifications_active_rounded,
                              title: kInfoTitleAlwaysUpToDate,
                              subtitle: kInfoSubtitleAlwaysUpToDate,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: context.scale(32)),

                      // Error
                      if (_errorMessage != null) ...[
                        _GlassPanel(
                          tint: Colors.red.withValues(alpha: 0.18),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFF6B6B),
                              fontSize: context.scale(13),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: context.scale(14)),
                      ],

                      // Sign-in button
                      _SignInButton(
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                      ),

                      SizedBox(height: context.scale(18)),
                      Text(
                        kLoginConfirmation,
                        style: GoogleFonts.inter(
                          fontSize: context.scale(12),
                          color: IosTheme.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.scale(12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bokeh orb ──────────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      );
}

// ── Logo tile ──────────────────────────────────────────────────────────────────
class _LogoTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: context.scale(84),
          height: context.scale(84),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.scale(24)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                IosTheme.glass.withValues(alpha: 0.30),
                IosTheme.glass.withValues(alpha: 0.10),
              ],
            ),
            border: Border.all(
              color: IosTheme.glass.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: IosTheme.orb1.withValues(alpha: 0.50),
                blurRadius: context.scale(32),
                spreadRadius: -4,
                offset: Offset(0, context.scale(8)),
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFDDD6FE), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Icon(Icons.android, color: Colors.white, size: context.scale(44)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable frosted-glass panel ───────────────────────────────────────────────
class _GlassPanel extends StatelessWidget {
  final Widget child;
  final Color? tint;
  const _GlassPanel({required this.child, this.tint});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(20)),
          decoration: BoxDecoration(
            color: tint ?? IosTheme.glass.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(context.scale(20)),
            border: Border.all(
              color: IosTheme.glass.withValues(alpha: 0.22),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Thin iOS-style separator ───────────────────────────────────────────────────
class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: context.scale(13)),
        child: Container(
          height: 0.5,
          color: IosTheme.glass.withValues(alpha: 0.18),
        ),
      );
}

// ── Info row ───────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoRow(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: context.scale(38),
          height: context.scale(38),
          decoration: BoxDecoration(
            color: IosTheme.glass.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(context.scale(10)),
            border: Border.all(
                color: IosTheme.glass.withValues(alpha: 0.20), width: 0.8),
          ),
          child: Icon(icon, color: IosTheme.accentLight, size: context.scale(18)),
        ),
        SizedBox(width: context.scale(14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: context.scale(13),
                  fontWeight: FontWeight.w600,
                  color: IosTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: context.scale(2)),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: context.scale(12),
                  color: IosTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Vibrancy chip ──────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(50)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.scale(12), vertical: context.scale(7)),
          decoration: BoxDecoration(
            color: IosTheme.glass.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(context.scale(50)),
            border: Border.all(
                color: IosTheme.glass.withValues(alpha: 0.25), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: context.scale(13), color: IosTheme.accentLight),
              SizedBox(width: context.scale(5)),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: context.scale(12),
                  color: IosTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── iOS-style sign-in button ───────────────────────────────────────────────────
class _SignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  const _SignInButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          height: context.scale(54),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLoading
                  ? [
                      AppColors.primary.withValues(alpha: 0.40),
                      AppColors.primaryDark.withValues(alpha: 0.40),
                    ]
                  : [
                      AppColors.primary.withValues(alpha: 0.90),
                      AppColors.primaryDark,
                    ],
            ),
            borderRadius: BorderRadius.circular(context.scale(16)),
            border: Border.all(
              color: IosTheme.glass.withValues(alpha: 0.35),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isLoading ? 0.15 : 0.50),
                blurRadius: context.scale(22),
                spreadRadius: -2,
                offset: Offset(0, context.scale(6)),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              splashColor: IosTheme.glass.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(context.scale(16)),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: context.scale(20),
                        height: context.scale(20),
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    else
                      Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        width: context.scale(20),
                        height: context.scale(20),
                        errorBuilder: (_, _, _) =>
                            Icon(Icons.login, color: Colors.white, size: context.scale(20)),
                      ),
                    SizedBox(width: context.scale(10)),
                    Text(
                      isLoading ? kLoginSigningIn : kLoginContinueWithGoogle,
                      style: GoogleFonts.inter(
                        fontSize: context.scale(15),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
