import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterapp/core/api_service.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/models/release_model.dart';
import 'package:flutterapp/presentations/release_detail/screens/release_detail_screen.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/orb.dart';
import 'package:flutterapp/presentations/release_list/widgets/release_card.dart';
import 'package:flutterapp/presentations/release_list/widgets/member_card.dart';
import 'package:google_fonts/google_fonts.dart';

class ReleaseListScreen extends StatefulWidget {
  final AppModel app;
  const ReleaseListScreen({super.key, required this.app});

  @override
  State<ReleaseListScreen> createState() => _ReleaseListScreenState();
}

class _ReleaseListScreenState extends State<ReleaseListScreen> {
  late AppModel _app;
  List<ReleaseModel> _releases = [];
  List<MemberModel> _members = [];
  bool _isLoadingReleases = false;
  bool _isLoadingMembers = false;

  @override
  void initState() {
    super.initState();
    _app = widget.app;
    _releases = widget.app.releases;
    _members = widget.app.members;
    _fetchReleases();
    _fetchMembers();
  }

  Future<void> _fetchReleases() async {
    setState(() => _isLoadingReleases = true);
    try {
      final response = await ApiService.instance.getAppReleases(_app.id);
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final list = body['data']['releases'] as List;
        final releases = list.map((r) => ReleaseModel.fromJson(r as Map<String, dynamic>)).toList();
        setState(() {
          _releases = releases;
        });
      }
    } catch (_) {
    } finally {
      setState(() => _isLoadingReleases = false);
    }
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final response = await ApiService.instance.getAppMembers(_app.id);
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final list = body['data']['members'] as List;
        final members = list.map((m) => MemberModel.fromJson(m as Map<String, dynamic>)).toList();
        setState(() {
          _members = members;
        });
      }
    } catch (_) {
    } finally {
      setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _refreshAppDetails() async {
    await Future.wait([_fetchReleases(), _fetchMembers()]);
    try {
      final response = await ApiService.instance.getApps();
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final list = body['data']['apps'] as List;
        final apps = list.map((a) => AppModel.fromJson(a as Map<String, dynamic>)).toList();
        final updatedApp = apps.firstWhere((a) => a.id == _app.id, orElse: () => _app);
        setState(() => _app = updatedApp);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bg3,
        body: Stack(
          children: [
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
            Positioned(
              top: -context.scale(120),
              right: -context.scale(80),
              child: Orb(size: context.scale(300), color: AppColors.orb1.withValues(alpha: 0.35)),
            ),
            Positioned(
              bottom: -context.scale(60),
              left: -context.scale(60),
              child: Orb(size: context.scale(260), color: AppColors.orb2.withValues(alpha: 0.22)),
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
                              padding: EdgeInsets.fromLTRB(
                                context.scale(4),
                                context.scale(8),
                                context.scale(16),
                                context.scale(4),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: context.scale(22)),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _app.name,
                                      style: GoogleFonts.inter(
                                        fontSize: context.scale(17),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TabBar(
                              indicatorColor: AppColors.accent,
                              indicatorWeight: 2,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white.withValues(alpha: 0.40),
                              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: context.scale(13)),
                              dividerColor: Colors.white.withValues(alpha: 0.10),
                              tabs: const [
                                Tab(text: kTabReleases),
                                Tab(text: kTabMembers),
                              ],
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
                        color: AppColors.accent,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(child: SizedBox(height: context.scale(20))),
                            if (_isLoadingReleases)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                              )
                            else if (_releases.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inbox_rounded,
                                        size: context.scale(48),
                                        color: Colors.white.withValues(alpha: 0.12),
                                      ),
                                      SizedBox(height: context.scale(12)),
                                      Text(
                                        kNoReleasesMsg,
                                        style: GoogleFonts.inter(
                                          color: Colors.white.withValues(alpha: 0.40),
                                          fontSize: context.scale(14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: context.scale(20)),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (_, i) => ReleaseCard(
                                      release: _releases[i],
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ReleaseDetailScreen(release: _releases[i], app: _app),
                                        ),
                                      ),
                                    ),
                                    childCount: _releases.length,
                                  ),
                                ),
                              ),
                            SliverToBoxAdapter(child: SizedBox(height: context.scale(20))),
                          ],
                        ),
                      ),
                      RefreshIndicator(
                        onRefresh: _refreshAppDetails,
                        color: AppColors.accent,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  context.scale(20),
                                  context.scale(24),
                                  context.scale(20),
                                  context.scale(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      kTeamMembersTitle,
                                      style: GoogleFonts.inter(
                                        fontSize: context.scale(16),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    SizedBox(height: context.scale(4)),
                                    Text(
                                      kTeamMembersSubtitle,
                                      style: GoogleFonts.inter(
                                        fontSize: context.scale(13),
                                        color: Colors.white.withValues(alpha: 0.45),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isLoadingMembers)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                              )
                            else if (_members.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people_outline_rounded,
                                        size: context.scale(48),
                                        color: Colors.white.withValues(alpha: 0.12),
                                      ),
                                      SizedBox(height: context.scale(12)),
                                      Text(
                                        kNoMembersMsg,
                                        style: GoogleFonts.inter(
                                          color: Colors.white.withValues(alpha: 0.40),
                                          fontSize: context.scale(14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: context.scale(20)),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (_, i) => MemberCard(member: _members[i]),
                                    childCount: _members.length,
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
