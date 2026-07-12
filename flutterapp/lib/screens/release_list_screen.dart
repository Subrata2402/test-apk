import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../models/app_model.dart';
import '../models/release_model.dart';
import 'release_detail_screen.dart';

class ReleaseListScreen extends StatefulWidget {
  final AppModel app;

  const ReleaseListScreen({super.key, required this.app});

  @override
  State<ReleaseListScreen> createState() => _ReleaseListScreenState();
}

class _ReleaseListScreenState extends State<ReleaseListScreen> {
  late AppModel _app;

  @override
  void initState() {
    super.initState();
    _app = widget.app;
  }

  Future<void> _refreshAppDetails() async {
    try {
      final response = await ApiClient.instance.get('/apps');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final list = body['data']['apps'] as List;
        final apps = list
            .map((a) => AppModel.fromJson(a as Map<String, dynamic>))
            .toList();

        final updatedApp = apps.firstWhere(
          (a) => a.id == _app.id,
          orElse: () => _app,
        );
        setState(() {
          _app = updatedApp;
        });
      }
    } catch (_) {}
  }

  void _navigateToReleaseDetail(ReleaseModel release) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReleaseDetailScreen(release: release, app: _app),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080710),
      appBar: AppBar(
        title: Text(
          _app.name,
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
          child: RefreshIndicator(
            onRefresh: _refreshAppDetails,
            color: const Color(0xFF8B5CF6),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_app.description.isNotEmpty)
                          Text(
                            _app.description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white60,
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          _app.packageName,
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            color: Colors.white30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'RELEASES',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white30,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_app.releases.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No releases yet',
                            style: GoogleFonts.inter(
                              color: Colors.white30,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ReleaseCard(
                          release: _app.releases[i],
                          onTap: () =>
                              _navigateToReleaseDetail(_app.releases[i]),
                        ),
                        childCount: _app.releases.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReleaseCard extends StatelessWidget {
  final ReleaseModel release;
  final VoidCallback onTap;

  const _ReleaseCard({required this.release, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String dateStr = release.date;
    try {
      final dt = DateTime.parse(release.date);
      dateStr = DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {}

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.android,
                color: Color(0xFF8B5CF6),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        release.appName ?? 'Build #${release.buildNumber}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TagChip(label: 'v${release.version}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr  •  ${release.size}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: const Color(0xFFD8B4FE),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
