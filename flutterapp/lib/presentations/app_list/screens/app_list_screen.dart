import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterapp/core/api_client.dart';
import 'package:flutterapp/core/auth_service.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/models/user_model.dart';
import 'package:flutterapp/presentations/app_list/widgets/app_list_app_bar.dart';
import 'package:flutterapp/presentations/app_list/widgets/app_list_content.dart';
import 'package:flutterapp/presentations/app_list/widgets/app_list_error.dart';
import 'package:flutterapp/presentations/app_list/widgets/app_list_shimmer.dart';
import 'package:flutterapp/presentations/login/screens/login_screen.dart';
import 'package:flutterapp/presentations/release_list/screens/release_list_screen.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/orb.dart';
import 'package:flutterapp/notification_manager.dart';

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
    NotificationManager().addListener(_onNotificationReceived);
  }

  @override
  void dispose() {
    NotificationManager().removeListener(_onNotificationReceived);
    super.dispose();
  }

  void _onNotificationReceived() {
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final appsResponse = await ApiClient.instance.get('/apps');
      final invitesResponse = await ApiClient.instance.get('/apps/invitations');

      if (appsResponse.statusCode == 200 && invitesResponse.statusCode == 200) {
        final appsBody = jsonDecode(appsResponse.body) as Map<String, dynamic>;
        final appsList = appsBody['data']['apps'] as List;
        final apps = appsList.map((a) => AppModel.fromJson(a as Map<String, dynamic>)).toList();
        apps.sort((a, b) {
          final aRelease = a.latestRelease;
          final bRelease = b.latestRelease;
          if (aRelease == null && bRelease == null) return 0;
          if (aRelease == null) return 1;
          if (bRelease == null) return -1;
          final dateCompare = bRelease.date.compareTo(aRelease.date);
          if (dateCompare != 0) return dateCompare;
          return bRelease.buildNumber.compareTo(aRelease.buildNumber);
        });

        final invitesBody = jsonDecode(invitesResponse.body) as Map<String, dynamic>;
        final invitesList = invitesBody['data']['apps'] as List;
        final invitations = invitesList.map((a) => AppModel.fromJson(a as Map<String, dynamic>)).toList();

        setState(() {
          _apps = apps;
          _invitations = invitations;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = kAppListErrorFailedToLoad;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '$kAppListErrorConnection${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptInvitation(String appId) async {
    setState(() => _processingActions[appId] = 'accept');
    try {
      final response = await ApiClient.instance.post('/apps/$appId/invitations/accept', {});
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(kInviteAcceptedMsg), backgroundColor: Color(0xFF10B981)));
        _fetchData();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(kInviteAcceptFailedMsg), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$kErrorPrefix$e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _processingActions.remove(appId));
    }
  }

  Future<void> _rejectInvitation(String appId) async {
    setState(() => _processingActions[appId] = 'reject');
    try {
      final response = await ApiClient.instance.post('/apps/$appId/invitations/reject', {});
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(kInviteRejectedMsg), backgroundColor: Colors.orange));
        _fetchData();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(kInviteRejectFailedMsg), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$kErrorPrefix$e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _processingActions.remove(appId));
    }
  }

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
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
            child: Orb(size: context.scale(360), color: IosTheme.orb1.withValues(alpha: 0.38)),
          ),
          Positioned(
            top: context.scale(200),
            right: -context.scale(80),
            child: Orb(size: context.scale(250), color: IosTheme.orb4.withValues(alpha: 0.28)),
          ),
          Positioned(
            bottom: -context.scale(80),
            left: -context.scale(50),
            child: Orb(size: context.scale(280), color: IosTheme.orb3.withValues(alpha: 0.22)),
          ),

          // Main content
          Column(
            children: [
              AppListAppBar(user: _user, onSignOut: _signOut),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: RefreshIndicator(
                    onRefresh: _fetchData,
                    color: IosTheme.accent,
                    child: _isLoading
                        ? const AppListShimmer()
                        : _error != null
                        ? AppListError(error: _error!, onRetry: _fetchData)
                        : AppListContent(
                            apps: _apps,
                            invitations: _invitations,
                            processingActions: _processingActions,
                            onAcceptInvitation: _acceptInvitation,
                            onRejectInvitation: _rejectInvitation,
                            onAppTap: (app) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => ReleaseListScreen(app: app)))
                                  .then((_) => _fetchData());
                            },
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
}
