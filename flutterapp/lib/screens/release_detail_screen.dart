import 'package:flutter/material.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/models/release_model.dart';
import 'package:flutterapp/widgets/release_action_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ReleaseDetailScreen extends StatefulWidget {
  final ReleaseModel release;
  final AppModel app;

  const ReleaseDetailScreen({
    super.key,
    required this.release,
    required this.app,
  });

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
    String cleanStr = base64Str;
    if (cleanStr.contains(',')) {
      cleanStr = cleanStr.split(',').last;
    }
    return MemoryImage(base64Decode(cleanStr.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final release = widget.release;
    final dateStr = release.date.isNotEmpty
        ? _formatDate(release.date)
        : 'Unknown date';

    return Scaffold(
      backgroundColor: const Color(0xFF080710),
      appBar: AppBar(
        title: Text(
          'Release Details',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F19), Color(0xFF1A0B2E), Color(0xFF080710)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (release.appIcon != null && release.appIcon!.isNotEmpty)
                      Container(
                        width: 56,
                        height: 56,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image:
                                _iconProvider ??
                                _getIconProvider(release.appIcon!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 56,
                        height: 56,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF8B5CF6,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF8B5CF6,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.android_rounded,
                          color: Color(0xFFC084FC),
                          size: 32,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            release.appName ?? widget.app.name,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.app.packageName,
                            style: GoogleFonts.robotoMono(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'v${release.version}  •  Build #${release.buildNumber}  •  $dateStr',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Metadata grid
                _buildSectionTitle('Details'),
                const SizedBox(height: 12),
                _DetailGrid(release: release, app: widget.app),
                if (release.uploadedByName != null &&
                    release.uploadedByName!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Uploaded By'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(
                            0xFF06B6D4,
                          ).withValues(alpha: 0.15),
                          child: Text(
                            release.uploadedByName!
                                .substring(
                                  0,
                                  release.uploadedByName!.length >= 2 ? 2 : 1,
                                )
                                .toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF22D3EE),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                release.uploadedByName!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                release.uploadedByEmail ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (release.sha256 != null && release.sha256!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('SHA-256 Hash'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      release.sha256!,
                      style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        color: Colors.white54,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                if (release.releaseNotes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Release Notes'),
                  const SizedBox(height: 8),
                  Text(
                    release.releaseNotes,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white60,
                      height: 1.6,
                    ),
                  ),
                ],
                if (release.permissions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    'Permissions (${release.permissions.length})',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: release.permissions
                        .map((p) => _PermissionChip(permission: p))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F19),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: SafeArea(
          child: ReleaseActionButton(app: widget.app, release: widget.release),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.white38,
      letterSpacing: 0.8,
    ),
  );

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }
}

class _DetailGrid extends StatelessWidget {
  final ReleaseModel release;
  final AppModel app;
  const _DetailGrid({required this.release, required this.app});

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String>>[
      {'label': 'Package', 'value': app.packageName},
      if (release.minSdkVersion != null)
        {'label': 'Min SDK', 'value': 'API ${release.minSdkVersion}'},
      if (release.targetSdkVersion != null)
        {'label': 'Target SDK', 'value': 'API ${release.targetSdkVersion}'},
      {'label': 'Size', 'value': release.size},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['label']!,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white30,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item['value']!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PermissionChip extends StatelessWidget {
  final String permission;
  const _PermissionChip({required this.permission});

  @override
  Widget build(BuildContext context) {
    final short = permission.split('.').last;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        short,
        style: GoogleFonts.robotoMono(fontSize: 11, color: Colors.white54),
      ),
    );
  }
}
