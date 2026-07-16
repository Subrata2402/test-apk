import 'package:flutter/material.dart';
import 'package:flutterapp/core/auth_service.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/presentations/app_list/screens/app_list_screen.dart';
import 'package:flutterapp/presentations/login/screens/login_screen.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/orb.dart';
import 'package:flutterapp/presentations/splash/widgets/splash_logo.dart';
import 'package:flutterapp/presentations/splash/widgets/splash_progress_pill.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final user = await AuthService.instance.tryAutoLogin();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => user != null ? const AppListScreen() : const LoginScreen()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          // iOS wallpaper gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D1B69), Color(0xFF11244D), Color(0xFF0A1628)],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Bokeh orbs
          Positioned(
            top: -context.scale(160),
            left: -context.scale(100),
            child: Orb(size: context.scale(400), color: const Color(0xFF7C3AED).withValues(alpha: 0.40)),
          ),
          Positioned(
            bottom: -context.scale(100),
            right: -context.scale(80),
            child: Orb(size: context.scale(320), color: const Color(0xFFEC4899).withValues(alpha: 0.25)),
          ),
          Positioned(
            top: context.scale(200),
            right: -context.scale(60),
            child: Orb(size: context.scale(240), color: const Color(0xFF3B82F6).withValues(alpha: 0.28)),
          ),

          // Content
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SplashLogo(),
                    SizedBox(height: context.scale(24)),
                    Text(
                      kAppName,
                      style: GoogleFonts.inter(
                        fontSize: context.scale(36),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -1.2,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: context.scale(8)),
                    Text(
                      kSplashSubtitle,
                      style: GoogleFonts.inter(
                        fontSize: context.scale(14),
                        color: Colors.white.withValues(alpha: 0.55),
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(height: context.scale(56)),
                    const SplashProgressPill(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
