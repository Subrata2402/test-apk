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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: TabBar(
            indicatorColor: const Color(0xFF8B5CF6),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'Releases'),
              Tab(text: 'Members'),
            ],
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
            child: TabBarView(
              children: [
                // Releases Tab
                RefreshIndicator(
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
                // Members Tab
                RefreshIndicator(
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
                              Text(
                                'Team Members',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Collaborators invited to this application.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_app.members.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  size: 48,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No members yet',
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
                              (_, i) => _MemberCard(member: _app.members[i]),
                              childCount: _app.members.length,
                            ),
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
                      _TagChip(
                        label: 'v${release.version} (${release.buildNumber})',
                      ),
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

class _MemberCard extends StatelessWidget {
  final MemberModel member;

  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final displayName = member.name.isNotEmpty
        ? member.name
        : member.email.split('@')[0];
    final initials = displayName
        .substring(0, displayName.length >= 2 ? 2 : 1)
        .toUpperCase();
    final isPending = member.status == 'Pending';

    return Container(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF06B6D4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  member.email,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _RoleChip(role: member.role),
                    if (isPending) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(
                              0xFFF59E0B,
                            ).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          'Pending',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFFFCD34D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    Color borderColor;

    if (role == 'Owner') {
      color = const Color(0xFFC084FC);
      bgColor = const Color(0xFF8B5CF6).withValues(alpha: 0.12);
      borderColor = const Color(0xFF8B5CF6).withValues(alpha: 0.25);
    } else if (role == 'Developer') {
      color = const Color(0xFF22D3EE);
      bgColor = const Color(0xFF06B6D4).withValues(alpha: 0.12);
      borderColor = const Color(0xFF06B6D4).withValues(alpha: 0.25);
    } else {
      color = const Color(0xFF34D399);
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.12);
      borderColor = const Color(0xFF10B981).withValues(alpha: 0.25);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        role,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
