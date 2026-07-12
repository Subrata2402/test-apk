import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../core/api_client.dart';
import '../core/auth_service.dart';
import '../models/app_model.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'release_list_screen.dart';

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  List<AppModel> _apps = [];
  List<AppModel> _invitations = [];
  bool _isLoading = true;
  String? _error;
  UserModel? get _user => AuthService.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Fetch accepted apps
      final appsResponse = await ApiClient.instance.get('/apps');
      // Fetch pending invitations
      final invitesResponse = await ApiClient.instance.get('/apps/invitations');

      if (appsResponse.statusCode == 200 && invitesResponse.statusCode == 200) {
        final appsBody = jsonDecode(appsResponse.body) as Map<String, dynamic>;
        final appsList = appsBody['data']['apps'] as List;
        final apps = appsList
            .map((a) => AppModel.fromJson(a as Map<String, dynamic>))
            .toList();

        final invitesBody =
            jsonDecode(invitesResponse.body) as Map<String, dynamic>;
        final invitesList = invitesBody['data']['apps'] as List;
        final invitations = invitesList
            .map((a) => AppModel.fromJson(a as Map<String, dynamic>))
            .toList();

        setState(() {
          _apps = apps;
          _invitations = invitations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Connection error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptInvitation(String appId) async {
    try {
      final response = await ApiClient.instance.post(
        '/apps/$appId/invitations/accept',
        {},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation accepted!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept invitation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectInvitation(String appId) async {
    try {
      final response = await ApiClient.instance.post(
        '/apps/$appId/invitations/reject',
        {},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation rejected'),
            backgroundColor: Colors.orange,
          ),
        );
        _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject invitation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080710),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F19), Color(0xFF1A0B2E), Color(0xFF080710)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchData,
                  color: const Color(0xFF8B5CF6),
                  child: _isLoading
                      ? _buildShimmer()
                      : _error != null
                      ? _buildError()
                      : _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
            ),
            child: const Icon(Icons.android, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            'TestAPK',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (_user?.picture != null)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(_user!.picture!),
            )
          else
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              child: Text(
                _user?.initials ?? '?',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white38,
              size: 20,
            ),
            onPressed: _signOut,
            tooltip: 'Sign out',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_apps.isEmpty && _invitations.isEmpty) {
      return _buildEmpty();
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_invitations.isNotEmpty) ...[
          Text(
            'PENDING INVITATIONS (${_invitations.length})',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade300,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ..._invitations.map((app) => _buildInvitationCard(app)),
          const SizedBox(height: 24),
        ],
        Text(
          'MY APPLICATIONS (${_apps.length})',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white30,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        if (_apps.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No accepted applications yet.',
                style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
              ),
            ),
          )
        else
          ..._apps.map((app) => _buildAppCard(app)),
      ],
    );
  }

  Widget _buildInvitationCard(AppModel app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.amber.withValues(alpha: 0.15),
                child: Text(
                  app.initials,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade300,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      app.packageName,
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: Colors.white30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (app.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              app.description,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _rejectInvitation(app.id),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade300,
                ),
                child: const Text('Decline'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _acceptInvitation(app.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Accept'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppCard(AppModel app) {
    final latestRelease = app.releases.isNotEmpty
        ? app.releases.first.version
        : 'None';
    final totalReleases = app.releases.length;
    final totalMembers = app.members.length;

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(builder: (_) => ReleaseListScreen(app: app)),
            )
            .then((_) => _fetchData()); // Refresh on return
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(
                    0xFF8B5CF6,
                  ).withValues(alpha: 0.15),
                  child: Text(
                    app.initials,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD8B4FE),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        app.packageName,
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          color: Colors.white30,
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
            if (app.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                app.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardStat(
                  'Latest',
                  latestRelease == 'None' ? 'None' : 'v$latestRelease',
                ),
                _buildCardStat('Releases', '$totalReleases'),
                _buildCardStat('Members', '$totalMembers'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white30,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.87),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: List.generate(
            4,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_person_rounded,
            size: 56,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            "You haven't been added\nto any app yet.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask a developer to invite you as a Tester.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
