import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterapp/core/auth_service.dart';
import 'package:flutterapp/screens/app_list/screens/app_list_screen.dart';
import 'package:flutterapp/screens/login_screen.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final user = await AuthService.instance.tryAutoLogin();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            user != null ? const AppListScreen() : const LoginScreen(),
      ),
    );
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
                colors: [
                  Color(0xFF2D1B69),
                  Color(0xFF11244D),
                  Color(0xFF0A1628),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Bokeh orbs
          Positioned(
            top: -context.scale(160),
            left: -context.scale(100),
            child: _Orb(size: context.scale(400), color: const Color(0xFF7C3AED).withValues(alpha: 0.40)),
          ),
          Positioned(
            bottom: -context.scale(100),
            right: -context.scale(80),
            child: _Orb(size: context.scale(320), color: const Color(0xFFEC4899).withValues(alpha: 0.25)),
          ),
          Positioned(
            top: context.scale(200),
            right: -context.scale(60),
            child: _Orb(size: context.scale(240), color: const Color(0xFF3B82F6).withValues(alpha: 0.28)),
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
                    // Glass logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(context.scale(26)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: context.scale(90),
                          height: context.scale(90),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(context.scale(26)),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.22),
                                Colors.white.withValues(alpha: 0.08),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.40),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C3AED).withValues(alpha: 0.55),
                                blurRadius: context.scale(40),
                                spreadRadius: -4,
                                offset: Offset(0, context.scale(10)),
                              ),
                            ],
                          ),
                          child: Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [Color(0xFFDDD6FE), Color(0xFFFFFFFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Icon(
                                Icons.android,
                                color: Colors.white,
                                size: context.scale(48),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: context.scale(24)),

                    Text(
                      'TestAPK',
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
                      'Release Manager for Testers',
                      style: GoogleFonts.inter(
                        fontSize: context.scale(14),
                        color: Colors.white.withValues(alpha: 0.55),
                        letterSpacing: -0.1,
                      ),
                    ),

                    SizedBox(height: context.scale(56)),

                    // Glass progress pill
                    ClipRRect(
                      borderRadius: BorderRadius.circular(context.scale(50)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: context.scale(20), vertical: context.scale(12)),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(context.scale(50)),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.20),
                                width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: context.scale(16),
                                height: context.scale(16),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withValues(alpha: 0.80),
                                  ),
                                ),
                              ),
                              SizedBox(width: context.scale(10)),
                              Text(
                                'Loading…',
                                style: GoogleFonts.inter(
                                  fontSize: context.scale(13),
                                  color: Colors.white.withValues(alpha: 0.70),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
