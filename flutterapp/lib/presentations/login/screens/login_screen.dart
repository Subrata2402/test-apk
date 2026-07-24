import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/core/auth_service.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/core/legal_texts.dart';
import 'package:flutterapp/presentations/app_list/screens/app_list_screen.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/orb.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:flutterapp/widgets/legal_document_viewer.dart';
import 'package:flutterapp/presentations/login/widgets/login_logo_tile.dart';
import 'package:flutterapp/presentations/login/widgets/login_info_row.dart';
import 'package:flutterapp/presentations/login/widgets/login_chip.dart';
import 'package:flutterapp/presentations/login/widgets/login_sign_in_button.dart';
import 'package:flutterapp/presentations/login/widgets/login_separator.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();

    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        LegalDocumentViewer.showModal(
          context,
          title: 'Terms of Service',
          lastUpdated: LegalTexts.termsOfServiceLastUpdated,
          sections: LegalTexts.termsOfService,
        );
      };
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () {
        LegalDocumentViewer.showModal(
          context,
          title: 'Privacy Policy',
          lastUpdated: LegalTexts.privacyPolicyLastUpdated,
          sections: LegalTexts.privacyPolicy,
        );
      };
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
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
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AppListScreen()));
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
      backgroundColor: AppColors.bg3,
      body: Stack(
        children: [
          // ── Vivid iOS-style wallpaper gradient ──────────────────────────
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

          // ── Bokeh orbs (iOS wallpaper depth) ────────────────────────────
          Positioned(
            top: -context.scale(140),
            left: -context.scale(100),
            child: Orb(size: context.scale(380), color: AppColors.orb1.withValues(alpha: 0.45)),
          ),
          Positioned(
            top: context.scale(160),
            right: -context.scale(80),
            child: Orb(size: context.scale(260), color: AppColors.orb4.withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: -context.scale(60),
            left: -context.scale(60),
            child: Orb(size: context.scale(280), color: AppColors.orb3.withValues(alpha: 0.28)),
          ),
          Positioned(
            bottom: context.scale(120),
            right: -context.scale(30),
            child: Orb(size: context.scale(200), color: AppColors.orb2.withValues(alpha: 0.30)),
          ),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(28)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: context.scale(20)),

                      // Logo tile
                      const LoginLogoTile(),
                      SizedBox(height: context.scale(20)),

                      // Title
                      Text(
                        kAppName,
                        style: GoogleFonts.inter(
                          fontSize: context.scale(34),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: context.scale(7)),
                      Text(
                        kLoginSubtitle,
                        style: GoogleFonts.inter(
                          fontSize: context.scale(15),
                          color: AppColors.textSecondary,
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
                          LoginChip(icon: Icons.android, label: kFeatureBetaTesting),
                          LoginChip(icon: Icons.download_rounded, label: kFeatureApkDownloads),
                          LoginChip(icon: Icons.notes_rounded, label: kFeatureReleaseNotes),
                          LoginChip(icon: Icons.verified_rounded, label: kFeatureVerifiedBuilds),
                          LoginChip(icon: Icons.security, label: kFeatureSha256),
                        ],
                      ),

                      SizedBox(height: context.scale(32)),

                      // Glass info card
                      GlassPanel(
                        padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(20)),
                        tint: AppColors.glass.withValues(alpha: 0.11),
                        borderRadius: 20,
                        borderColor: AppColors.glass.withValues(alpha: 0.22),
                        child: Column(
                          children: const [
                            LoginInfoRow(
                              icon: Icons.lock_person_rounded,
                              title: kInfoTitleTesterAccess,
                              subtitle: kInfoSubtitleTesterAccess,
                            ),
                            LoginSeparator(),
                            LoginInfoRow(
                              icon: Icons.cloud_done_rounded,
                              title: kInfoTitleSecureStorage,
                              subtitle: kInfoSubtitleSecureStorage,
                            ),
                            LoginSeparator(),
                            LoginInfoRow(
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
                        GlassPanel(
                          padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(20)),
                          tint: AppColors.error.withValues(alpha: 0.18),
                          borderRadius: 20,
                          borderColor: AppColors.glass.withValues(alpha: 0.22),
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
                      LoginSignInButton(isLoading: _isLoading, onPressed: _isLoading ? null : _handleGoogleSignIn),

                      SizedBox(height: context.scale(18)),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: context.scale(12),
                            color: AppColors.textTertiary,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'By signing in, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: const TextStyle(
                                color: AppColors.accentLight,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: _termsRecognizer,
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: const TextStyle(
                                color: AppColors.accentLight,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: _privacyRecognizer,
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
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
