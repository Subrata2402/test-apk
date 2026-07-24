import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/presentations/profile/widgets/about_platform_info_card.dart';
import 'package:flutterapp/presentations/profile/widgets/about_support_card.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/orb.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                              'About TestAPK',
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
                        // App Logo
                        Container(
                          width: context.scale(80),
                          height: context.scale(80),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.accent, AppColors.accentDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(context.scale(20)),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.30), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.30),
                                blurRadius: context.scale(24),
                                spreadRadius: context.scale(4),
                              ),
                            ],
                          ),
                          child: Icon(Icons.android, color: Colors.white, size: context.scale(44)),
                        ),
                        SizedBox(height: context.scale(20)),

                        // App Name
                        Text(
                          kAppName,
                          style: GoogleFonts.inter(
                            fontSize: context.scale(24),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: context.scale(4)),

                        // Version
                        Text(
                          'Version 1.0.0+3',
                          style: GoogleFonts.inter(fontSize: context.scale(13), color: AppColors.textSecondary),
                        ),
                        SizedBox(height: context.scale(12)),

                        // Description
                        Text(
                          'A modern, secure, and self-hosted APK release management platform.',
                          style: GoogleFonts.inter(
                            fontSize: context.scale(14),
                            color: Colors.white.withValues(alpha: 0.75),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: context.scale(32)),

                        // Platform Info Card
                        _buildSectionHeader('PLATFORM INFO'),
                        SizedBox(height: context.scale(10)),
                        AboutPlatformInfoCard(onLaunchURL: _launchURL),
                        SizedBox(height: context.scale(28)),

                        // Support Channels Card
                        _buildSectionHeader('SUPPORT CHANNELS'),
                        SizedBox(height: context.scale(10)),
                        AboutSupportCard(onLaunchURL: _launchURL),
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

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.45),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
