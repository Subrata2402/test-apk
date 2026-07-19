import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/models/release_model.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:flutterapp/widgets/orb.dart';
import 'package:flutterapp/widgets/release_action_button.dart';
import 'package:flutterapp/widgets/section_label.dart';
import 'package:flutterapp/presentations/release_detail/widgets/detail_grid.dart';
import 'package:flutterapp/presentations/release_detail/widgets/permission_chip.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReleaseDetailScreen extends StatefulWidget {
  final ReleaseModel release;
  final AppModel app;
  const ReleaseDetailScreen({super.key, required this.release, required this.app});

  @override
  State<ReleaseDetailScreen> createState() => _ReleaseDetailScreenState();
}

class _ReleaseDetailScreenState extends State<ReleaseDetailScreen> {
  ImageProvider? _iconProvider;

  @override
  void initState() {
    super.initState();
    if (widget.release.appIcon != null && widget.release.appIcon!.isNotEmpty) {
      _iconProvider = _getIconProvider(widget.release.appIcon!);
    }
  }

  ImageProvider _getIconProvider(String base64Str) {
    String s = base64Str;
    if (s.contains(',')) s = s.split(',').last;
    return MemoryImage(base64Decode(s.trim()));
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      if (raw.contains('T')) {
        return DateFormat('MMM d, yyyy • h:mm a').format(dt);
      } else {
        return DateFormat('MMM d, yyyy').format(dt);
      }
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final release = widget.release;
    final dateStr = release.date.isNotEmpty ? _formatDate(release.date) : kUnknownDate;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          // Background gradient
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
            top: -context.scale(100),
            left: -context.scale(80),
            child: Orb(size: context.scale(300), color: const Color(0xFF7C3AED).withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: -context.scale(60),
            right: -context.scale(60),
            child: Orb(size: context.scale(240), color: const Color(0xFFEC4899).withValues(alpha: 0.22)),
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
                              kReleaseDetailsTitle,
                              style: GoogleFonts.inter(
                                fontSize: context.scale(17),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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

              // Scrollable body
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.scale(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.scale(4)),

                      // Header card
                      GlassPanel(
                        padding: EdgeInsets.all(context.scale(18)),
                        borderRadius: 18,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (release.appIcon != null && release.appIcon!.isNotEmpty)
                              Container(
                                width: context.scale(56),
                                height: context.scale(56),
                                margin: EdgeInsets.only(right: context.scale(16)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(context.scale(14)),
                                  image: DecorationImage(
                                    image: _iconProvider ?? _getIconProvider(release.appIcon!),
                                    fit: BoxFit.cover,
                                  ),
                                  // border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1),
                                ),
                              )
                            else
                              Container(
                                width: context.scale(56),
                                height: context.scale(56),
                                margin: EdgeInsets.only(right: context.scale(16)),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(context.scale(14)),
                                  border: Border.all(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.30),
                                    width: 0.8,
                                  ),
                                ),
                                child: Icon(
                                  Icons.android_rounded,
                                  color: const Color(0xFFDDD6FE),
                                  size: context.scale(32),
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    release.appName ?? widget.app.name,
                                    style: GoogleFonts.inter(
                                      fontSize: context.scale(20),
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: context.scale(4)),
                                  Text(
                                    widget.app.packageName,
                                    style: GoogleFonts.robotoMono(
                                      fontSize: context.scale(11),
                                      color: Colors.white.withValues(alpha: 0.45),
                                    ),
                                  ),
                                  SizedBox(height: context.scale(6)),
                                  Text(
                                    'v${release.version}  •  $dateStr',
                                    style: GoogleFonts.inter(
                                      fontSize: context.scale(13),
                                      color: Colors.white.withValues(alpha: 0.50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: context.scale(20)),
                      const SectionLabel(label: kSectionDetails),
                      SizedBox(height: context.scale(12)),
                      DetailGrid(release: release, app: widget.app),

                      if (release.uploadedByName != null && release.uploadedByName!.isNotEmpty) ...[
                        SizedBox(height: context.scale(20)),
                        const SectionLabel(label: kSectionUploadedBy),
                        SizedBox(height: context.scale(12)),
                        GlassPanel(
                          padding: EdgeInsets.all(context.scale(18)),
                          borderRadius: 18,
                          child: Row(
                            children: [
                              Container(
                                width: context.scale(38),
                                height: context.scale(38),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.30),
                                    width: 0.8,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    release.uploadedByName!
                                        .substring(0, release.uploadedByName!.length >= 2 ? 2 : 1)
                                        .toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: context.scale(11),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF22D3EE),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: context.scale(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      release.uploadedByName!,
                                      style: GoogleFonts.inter(
                                        fontSize: context.scale(13),
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: context.scale(2)),
                                    Text(
                                      release.uploadedByEmail ?? '',
                                      style: GoogleFonts.inter(
                                        fontSize: context.scale(11),
                                        color: Colors.white.withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (release.releaseNotes.isNotEmpty) ...[
                        SizedBox(height: context.scale(20)),
                        const SectionLabel(label: kSectionReleaseNotes),
                        SizedBox(height: context.scale(12)),
                        GlassPanel(
                          padding: EdgeInsets.all(context.scale(18)),
                          borderRadius: 18,
                          child: Text(
                            release.releaseNotes,
                            style: GoogleFonts.inter(
                              fontSize: context.scale(14),
                              color: Colors.white.withValues(alpha: 0.75),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],

                      if (release.permissions.isNotEmpty) ...[
                        SizedBox(height: context.scale(20)),
                        SectionLabel(label: '$kSectionPermissionsPrefix${release.permissions.length})'),
                        SizedBox(height: context.scale(12)),
                        Wrap(
                          spacing: context.scale(8),
                          runSpacing: context.scale(8),
                          children: release.permissions.map((p) => PermissionChip(permission: p)).toList(),
                        ),
                      ],

                      SizedBox(height: context.scale(150)), // space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Glass bottom action bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.14), width: 0.8)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.all(context.scale(20)),
                      child: ReleaseActionButton(app: widget.app, release: widget.release),
                    ),
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
