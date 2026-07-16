import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutterapp/core/api_client.dart';
import 'package:flutterapp/core/auth_service.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/models/user_model.dart';
import 'package:flutterapp/screens/login_screen.dart';
import 'package:flutterapp/screens/release_list_screen.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/release_action_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

// ── iOS palette ───────────────────────────────────────────────────────────────
class IosTheme {
  static const bg1 = Color(0xFF2D1B69);
  static const bg2 = Color(0xFF11244D);
  static const bg3 = Color(0xFF0A1628);
  static const orb1 = Color(0xFF7C3AED);
  static const orb3 = Color(0xFFEC4899);
  static const orb4 = Color(0xFF3B82F6);
  static const accent = Color(0xFF8B5CF6);
  static const accentDark = Color(0xFF6D28D9);
  static const accentLight = Color(0xFFDDD6FE);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xB3FFFFFF);
  static const textTertiary = Color(0x80FFFFFF);
}

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
  final Map<String, String> _processingActions = {};

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
      final appsResponse = await ApiClient.instance.get('/apps');
      final invitesResponse =
          await ApiClient.instance.get('/apps/invitations');

      if (appsResponse.statusCode == 200 &&
          invitesResponse.statusCode == 200) {
        final appsBody =
            jsonDecode(appsResponse.body) as Map<String, dynamic>;
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
    setState(() => _processingActions[appId] = 'accept');
    try {
      final response =
          await ApiClient.instance.post('/apps/$appId/invitations/accept', {});
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invitation accepted!'),
              backgroundColor: Color(0xFF10B981)),
        );
        _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to accept invitation'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _processingActions.remove(appId));
    }
  }

  Future<void> _rejectInvitation(String appId) async {
    setState(() => _processingActions[appId] = 'reject');
    try {
      final response =
          await ApiClient.instance.post('/apps/$appId/invitations/reject', {});
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invitation rejected'),
              backgroundColor: Colors.orange),
        );
        _fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to reject invitation'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _processingActions.remove(appId));
    }
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  ImageProvider _getIconProvider(String base64Str) {
    String cleanStr = base64Str;
    if (cleanStr.contains(',')) cleanStr = cleanStr.split(',').last;
    return MemoryImage(base64Decode(cleanStr.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IosTheme.bg3,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [IosTheme.bg1, IosTheme.bg2, IosTheme.bg3],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // Bokeh orbs
          Positioned(
            top: -context.scale(140),
            left: -context.scale(100),
            child: _Orb(size: context.scale(360), color: IosTheme.orb1.withValues(alpha: 0.38)),
          ),
          Positioned(
            top: context.scale(200),
            right: -context.scale(80),
            child: _Orb(size: context.scale(250), color: IosTheme.orb4.withValues(alpha: 0.28)),
          ),
          Positioned(
            bottom: -context.scale(80),
            left: -context.scale(50),
            child: _Orb(size: context.scale(280), color: IosTheme.orb3.withValues(alpha: 0.22)),
          ),

          // Main content
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: RefreshIndicator(
                    onRefresh: _fetchData,
                    color: IosTheme.accent,
                    child: _isLoading
                        ? _buildShimmer()
                        : _error != null
                            ? _buildError()
                            : _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.white.withValues(alpha: 0.07),
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.scale(20), vertical: context.scale(14)),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12), width: 0.8),
                ),
              ),
              child: Row(
                children: [
                  // Logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.scale(9)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: context.scale(34),
                        height: context.scale(34),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [IosTheme.accent, IosTheme.accentDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(context.scale(9)),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                              width: 0.8),
                        ),
                        child: Icon(Icons.android, color: Colors.white, size: context.scale(18)),
                      ),
                    ),
                  ),
                  SizedBox(width: context.scale(12)),
                  Text(
                    'TestAPK',
                    style: GoogleFonts.inter(
                      fontSize: context.scale(18),
                      fontWeight: FontWeight.w700,
                      color: IosTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // Avatar
                  if (_user?.picture != null)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.30), width: 1),
                      ),
                      child: CircleAvatar(
                          radius: context.scale(16),
                          backgroundImage: NetworkImage(_user!.picture!)),
                    )
                  else
                    CircleAvatar(
                      radius: context.scale(16),
                      backgroundColor: IosTheme.accent.withValues(alpha: 0.25),
                      child: Text(
                        _user?.initials ?? '?',
                        style: GoogleFonts.inter(
                            fontSize: context.scale(12),
                            fontWeight: FontWeight.w600,
                            color: IosTheme.accentLight),
                      ),
                    ),
                  SizedBox(width: context.scale(4)),
                  IconButton(
                    icon: Icon(Icons.logout_rounded,
                        color: Colors.white.withValues(alpha: 0.45), size: context.scale(20)),
                    onPressed: _signOut,
                    tooltip: 'Sign out',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_apps.isEmpty && _invitations.isEmpty) return _buildEmpty();

    return ListView(
      padding: EdgeInsets.all(context.scale(20)),
      children: [
        if (_invitations.isNotEmpty) ...[
          _SectionLabel(
              label: 'PENDING INVITATIONS (${_invitations.length})',
              color: const Color(0xFFFCD34D)),
          SizedBox(height: context.scale(12)),
          ..._invitations.map((app) => _buildInvitationCard(app)),
          SizedBox(height: context.scale(24)),
        ],
        _SectionLabel(label: 'MY APPLICATIONS (${_apps.length})'),
        SizedBox(height: context.scale(12)),
        if (_apps.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.scale(24)),
            child: Center(
              child: Text(
                'No accepted applications yet.',
                style: GoogleFonts.inter(
                    color: IosTheme.textTertiary, fontSize: context.scale(13)),
              ),
            ),
          )
        else
          ..._apps.map((app) => _buildAppCard(app)),
      ],
    );
  }

  Widget _buildInvitationCard(AppModel app) {
    final isAccepting = _processingActions[app.id] == 'accept';
    final isRejecting = _processingActions[app.id] == 'reject';
    final isProcessing = _processingActions.containsKey(app.id);

    return _GlassCard(
      margin: EdgeInsets.only(bottom: context.scale(12)),
      tint: Colors.amber.withValues(alpha: 0.06),
      borderColor: Colors.amber.withValues(alpha: 0.20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _GlassAvatar(
                initials: app.initials,
                color: const Color(0xFFFCD34D),
                bgColor: Colors.amber.withValues(alpha: 0.15),
              ),
              SizedBox(width: context.scale(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: GoogleFonts.inter(
                          fontSize: context.scale(14),
                          fontWeight: FontWeight.w600,
                          color: IosTheme.textPrimary),
                    ),
                    Text(app.packageName,
                        style: GoogleFonts.robotoMono(
                            fontSize: context.scale(10), color: IosTheme.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
          if (app.description.isNotEmpty) ...[
            SizedBox(height: context.scale(10)),
            Text(app.description,
                style: GoogleFonts.inter(
                    fontSize: context.scale(13), color: IosTheme.textSecondary)),
          ],
          SizedBox(height: context.scale(14)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: isProcessing ? null : () => _rejectInvitation(app.id),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B6B)),
                child: isRejecting
                    ? SizedBox(
                        width: context.scale(16),
                        height: context.scale(16),
                        child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF6B6B))),
                      )
                    : const Text('Decline'),
              ),
              SizedBox(width: context.scale(8)),
              _GlassButton(
                label: 'Accept',
                isLoading: isAccepting,
                onPressed: isProcessing ? null : () => _acceptInvitation(app.id),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppCard(AppModel app) {
    final latestRelease = app.releases.isNotEmpty
        ? 'v${app.releases.first.version} (${app.releases.first.buildNumber})'
        : 'None';

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (_) => ReleaseListScreen(app: app)))
            .then((_) => _fetchData());
      },
      child: _GlassCard(
        margin: EdgeInsets.only(bottom: context.scale(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // App icon
                if (app.releases.isNotEmpty &&
                    app.releases.first.appIcon != null &&
                    app.releases.first.appIcon!.isNotEmpty)
                  Container(
                    width: context.scale(56),
                    height: context.scale(56),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 1),
                      image: DecorationImage(
                          image: _getIconProvider(
                              app.releases.first.appIcon!),
                          fit: BoxFit.cover),
                    ),
                  )
                else
                  Container(
                    width: context.scale(56),
                    height: context.scale(56),
                    decoration: BoxDecoration(
                      color: IosTheme.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(context.scale(28)),
                      border: Border.all(
                          color: IosTheme.accent.withValues(alpha: 0.25),
                          width: 1),
                    ),
                    child: Icon(Icons.android_rounded,
                        color: const Color(0xFFC084FC), size: context.scale(32)),
                  ),
                SizedBox(width: context.scale(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.name,
                        style: GoogleFonts.inter(
                            fontSize: context.scale(16),
                            fontWeight: FontWeight.w600,
                            color: IosTheme.textPrimary,
                            letterSpacing: -0.3),
                      ),
                      SizedBox(height: context.scale(2)),
                      Text(app.packageName,
                          style: GoogleFonts.robotoMono(
                              fontSize: context.scale(11), color: IosTheme.textTertiary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.30), size: context.scale(20)),
              ],
            ),
            SizedBox(height: context.scale(14)),
            Container(
                height: 0.5,
                color: Colors.white.withValues(alpha: 0.12)),
            SizedBox(height: context.scale(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardStat('Latest Version', latestRelease),
                if (app.releases.isNotEmpty)
                  ReleaseActionButton(app: app, release: app.releases.first, compact: true),
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
              fontSize: context.scale(9),
              fontWeight: FontWeight.w600,
              color: IosTheme.textTertiary,
              letterSpacing: 0.5),
        ),
        SizedBox(height: context.scale(2)),
        Text(
          value,
          style: GoogleFonts.inter(
              fontSize: context.scale(12),
              fontWeight: FontWeight.w600,
              color: IosTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.06),
      highlightColor: Colors.white.withValues(alpha: 0.14),
      child: Padding(
        padding: EdgeInsets.all(context.scale(20)),
        child: Column(
          children: List.generate(
            4,
            (_) => Container(
              margin: EdgeInsets.only(bottom: context.scale(12)),
              height: context.scale(110),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.scale(16))),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - context.scale(150),
        alignment: Alignment.center,
        padding: EdgeInsets.all(context.scale(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: context.scale(48), color: Colors.white.withValues(alpha: 0.25)),
            SizedBox(height: context.scale(16)),
            Text(
              _error!,
              style: GoogleFonts.inter(
                  color: IosTheme.textSecondary, fontSize: context.scale(14)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.scale(20)),
            _GlassButton(
              label: 'Retry',
              onPressed: _fetchData,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - context.scale(150),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_person_rounded,
                size: context.scale(56), color: Colors.white.withValues(alpha: 0.12)),
            SizedBox(height: context.scale(16)),
            Text(
              "You haven't been added\nto any app yet.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: IosTheme.textSecondary, fontSize: context.scale(15), letterSpacing: -0.2),
            ),
            SizedBox(height: context.scale(8)),
            Text(
              'Ask a developer to invite you as a Tester.',
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.inter(color: IosTheme.textTertiary, fontSize: context.scale(13)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

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

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final Color? tint;
  final Color? borderColor;
  const _GlassCard(
      {required this.child, this.margin, this.tint, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.scale(18)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.all(context.scale(16)),
            decoration: BoxDecoration(
              color: tint ?? Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(context.scale(18)),
              border: Border.all(
                  color: borderColor ?? Colors.white.withValues(alpha: 0.18),
                  width: 0.8),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GlassAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final Color bgColor;
  const _GlassAvatar(
      {required this.initials, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) => Container(
        width: context.scale(36),
        height: context.scale(36),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.30), width: 0.8),
        ),
        child: Center(
          child: Text(
            initials,
            style: GoogleFonts.inter(
                fontSize: context.scale(11), fontWeight: FontWeight.w700, color: color),
          ),
        ),
      );
}

class _GlassButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  const _GlassButton({
    required this.label,
    required this.onPressed,
    required this.gradient,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(10)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(context.scale(10)),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25), width: 0.8),
            ),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: context.scale(18), vertical: context.scale(10)),
              child: isLoading
                  ? SizedBox(
                      width: context.scale(16),
                      height: context.scale(16),
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.inter(
                          fontSize: context.scale(13),
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color? color;
  const _SectionLabel({required this.label, this.color});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.inter(
          fontSize: context.scale(11),
          fontWeight: FontWeight.w600,
          color: color ?? Colors.white.withValues(alpha: 0.40),
          letterSpacing: 0.8,
        ),
      );
}
