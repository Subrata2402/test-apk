import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterapp/core/api_client.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/models/release_model.dart';
import 'package:flutterapp/screens/release_detail_screen.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

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
        final updatedApp =
            apps.firstWhere((a) => a.id == _app.id, orElse: () => _app);
        setState(() => _app = updatedApp);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        body: Stack(
          children: [
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
            Positioned(
              top: -context.scale(120), right: -context.scale(80),
              child: _Orb(size: context.scale(300), color: const Color(0xFF7C3AED).withValues(alpha: 0.35)),
            ),
            Positioned(
              bottom: -context.scale(60), left: -context.scale(60),
              child: _Orb(size: context.scale(260), color: const Color(0xFF06B6D4).withValues(alpha: 0.22)),
            ),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(context.scale(4), context.scale(8), context.scale(16), context.scale(4)),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: context.scale(22)),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _app.name,
                                        style: GoogleFonts.inter(fontSize: context.scale(17), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TabBar(
                                indicatorColor: const Color(0xFF8B5CF6),
                                indicatorWeight: 2,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white.withValues(alpha: 0.40),
                                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: context.scale(13)),
                                dividerColor: Colors.white.withValues(alpha: 0.10),
                                tabs: const [Tab(text: 'Releases'), Tab(text: 'Members')],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        RefreshIndicator(
                          onRefresh: _refreshAppDetails,
                          color: const Color(0xFF8B5CF6),
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(child: SizedBox(height: context.scale(20))),
                              if (_app.releases.isEmpty)
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.inbox_rounded, size: context.scale(48), color: Colors.white.withValues(alpha: 0.12)),
                                        SizedBox(height: context.scale(12)),
                                        Text('No releases yet', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.40), fontSize: context.scale(14))),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(horizontal: context.scale(20)),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (_, i) => _ReleaseCard(
                                        release: _app.releases[i],
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => ReleaseDetailScreen(release: _app.releases[i], app: _app)),
                                        ),
                                      ),
                                      childCount: _app.releases.length,
                                    ),
                                  ),
                                ),
                              SliverToBoxAdapter(child: SizedBox(height: context.scale(20))),
                            ],
                          ),
                        ),
                        RefreshIndicator(
                          onRefresh: _refreshAppDetails,
                          color: const Color(0xFF8B5CF6),
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(context.scale(20), context.scale(24), context.scale(20), context.scale(16)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Team Members', style: GoogleFonts.inter(fontSize: context.scale(16), fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.4)),
                                      SizedBox(height: context.scale(4)),
                                      Text('Collaborators invited to this application.', style: GoogleFonts.inter(fontSize: context.scale(13), color: Colors.white.withValues(alpha: 0.45))),
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
                                        Icon(Icons.people_outline_rounded, size: context.scale(48), color: Colors.white.withValues(alpha: 0.12)),
                                        SizedBox(height: context.scale(12)),
                                        Text('No members yet', style: GoogleFonts.inter(color: Colors.white.withValues(alpha: 0.40), fontSize: context.scale(14))),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(horizontal: context.scale(20)),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (_, i) => _MemberCard(member: _app.members[i]),
                                      childCount: _app.members.length,
                                    ),
                                  ),
                                ),
                              SliverToBoxAdapter(child: SizedBox(height: context.scale(20))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );
}

class _ReleaseCard extends StatelessWidget {
  final ReleaseModel release;
  final VoidCallback onTap;
  const _ReleaseCard({required this.release, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.scale(12)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.scale(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: EdgeInsets.all(context.scale(16)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(context.scale(16)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 0.8),
              ),
              child: Row(
                children: [
                  Container(
                    width: context.scale(44), height: context.scale(44),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF8B5CF6).withValues(alpha: 0.25), const Color(0xFF6D28D9).withValues(alpha: 0.15)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(context.scale(11)),
                      border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.30), width: 0.8),
                    ),
                    child: Icon(Icons.android, color: const Color(0xFFDDD6FE), size: context.scale(24)),
                  ),
                  SizedBox(width: context.scale(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          release.appName ?? 'Build #${release.buildNumber}',
                          style: GoogleFonts.inter(fontSize: context.scale(14), fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.2),
                        ),
                        SizedBox(height: context.scale(4)),
                        Text('v${release.version} (${release.buildNumber})', style: GoogleFonts.inter(fontSize: context.scale(12), color: Colors.white.withValues(alpha: 0.45))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.30), size: context.scale(20)),
                ],
              ),
            ),
          ),
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
    final displayName = member.name.isNotEmpty ? member.name : member.email.split('@')[0];
    final initials = displayName.substring(0, displayName.length >= 2 ? 2 : 1).toUpperCase();
    final isPending = member.status == 'Pending';

    return Container(
      margin: EdgeInsets.only(bottom: context.scale(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.scale(16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.all(context.scale(16)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(context.scale(16)),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: context.scale(42), height: context.scale(42),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.30), width: 0.8),
                  ),
                  child: Center(
                    child: Text(initials, style: GoogleFonts.inter(fontSize: context.scale(13), fontWeight: FontWeight.w700, color: const Color(0xFF22D3EE))),
                  ),
                ),
                SizedBox(width: context.scale(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: GoogleFonts.inter(fontSize: context.scale(14), fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.2), overflow: TextOverflow.ellipsis),
                      SizedBox(height: context.scale(2)),
                      Text(member.email, style: GoogleFonts.inter(fontSize: context.scale(12), color: Colors.white.withValues(alpha: 0.45)), overflow: TextOverflow.ellipsis),
                      SizedBox(height: context.scale(5)),
                      Row(
                        children: [
                          _RoleChip(role: member.role),
                          if (isPending) ...[
                            SizedBox(width: context.scale(8)),
                            _TagChip(label: 'Pending', color: const Color(0xFFFCD34D), bg: const Color(0xFFF59E0B).withValues(alpha: 0.15), border: const Color(0xFFF59E0B).withValues(alpha: 0.30)),
                          ],
                        ],
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

class _TagChip extends StatelessWidget {
  final String label;
  final Color color, bg, border;
  const _TagChip({required this.label, required this.color, required this.bg, required this.border});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: context.scale(8), vertical: context.scale(2)),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(context.scale(6)), border: Border.all(color: border)),
        child: Text(label, style: GoogleFonts.inter(fontSize: context.scale(10), color: color, fontWeight: FontWeight.w600)),
      );
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    late Color color, bg, border;
    if (role == 'Owner') {
      color = const Color(0xFFC084FC); bg = const Color(0xFF8B5CF6).withValues(alpha: 0.15); border = const Color(0xFF8B5CF6).withValues(alpha: 0.30);
    } else if (role == 'Developer') {
      color = const Color(0xFF22D3EE); bg = const Color(0xFF06B6D4).withValues(alpha: 0.15); border = const Color(0xFF06B6D4).withValues(alpha: 0.30);
    } else {
      color = const Color(0xFF34D399); bg = const Color(0xFF10B981).withValues(alpha: 0.15); border = const Color(0xFF10B981).withValues(alpha: 0.30);
    }
    return _TagChip(label: role, color: color, bg: bg, border: border);
  }
}
