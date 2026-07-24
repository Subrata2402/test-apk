import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/core/legal_texts.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/orb.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalDocumentViewer extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;
  final bool isFullScreen;

  const LegalDocumentViewer({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
    this.isFullScreen = false,
  });

  static void showModal(
    BuildContext context, {
    required String title,
    required String lastUpdated,
    required List<LegalSection> sections,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) =>
          LegalDocumentViewer(title: title, lastUpdated: lastUpdated, sections: sections, isFullScreen: false),
    );
  }

  static void pushScreen(
    BuildContext context, {
    required String title,
    required String lastUpdated,
    required List<LegalSection> sections,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            LegalDocumentViewer(title: title, lastUpdated: lastUpdated, sections: sections, isFullScreen: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFullScreen) {
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.inter(
                                        fontSize: context.scale(18),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    SizedBox(height: context.scale(2)),
                                    Text(
                                      'Last Updated: $lastUpdated',
                                      style: GoogleFonts.inter(
                                        fontSize: context.scale(11),
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Content list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      context.scale(20),
                      context.scale(24),
                      context.scale(20),
                      context.scale(32) + MediaQuery.of(context).padding.bottom,
                    ),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: context.scale(24)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              section.title,
                              style: GoogleFonts.inter(
                                fontSize: context.scale(15),
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentLight,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: context.scale(8)),
                            ...section.paragraphs.map(
                              (para) => Padding(
                                padding: EdgeInsets.only(bottom: context.scale(8)),
                                child: Text(
                                  para,
                                  style: GoogleFonts.inter(
                                    fontSize: context.scale(13),
                                    color: Colors.white.withValues(alpha: 0.75),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Modal bottom sheet layout (80% height)
    final double height = MediaQuery.of(context).size.height * 0.8;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bg3.withValues(alpha: 0.85),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.scale(24)),
          topRight: Radius.circular(context.scale(24)),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.scale(24)),
          topRight: Radius.circular(context.scale(24)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            children: [
              // Drag handle
              SizedBox(height: context.scale(12)),
              Container(
                width: context.scale(36),
                height: context.scale(5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(context.scale(2.5)),
                ),
              ),
              SizedBox(height: context.scale(16)),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.scale(20)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: context.scale(20),
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: context.scale(4)),
                          Text(
                            'Last Updated: $lastUpdated',
                            style: GoogleFonts.inter(fontSize: context.scale(12), color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: context.scale(22),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.scale(12)),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 0.8, thickness: 0.8),

              // Content
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    context.scale(20),
                    context.scale(20),
                    context.scale(20),
                    context.scale(32) + MediaQuery.of(context).padding.bottom,
                  ),
                  itemCount: sections.length,
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: context.scale(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: GoogleFonts.inter(
                              fontSize: context.scale(15),
                              fontWeight: FontWeight.w600,
                              color: AppColors.accentLight,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: context.scale(8)),
                          ...section.paragraphs.map(
                            (para) => Padding(
                              padding: EdgeInsets.only(bottom: context.scale(8)),
                              child: Text(
                                para,
                                style: GoogleFonts.inter(
                                  fontSize: context.scale(13),
                                  color: Colors.white.withValues(alpha: 0.75),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
