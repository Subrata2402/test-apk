import 'package:flutter/material.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/presentations/app_list/widgets/app_card_widget.dart';
import 'package:flutterapp/presentations/app_list/widgets/invitation_card.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/section_label.dart';
import 'package:flutterapp/presentations/app_list/widgets/app_list_empty.dart';
import 'package:google_fonts/google_fonts.dart';

class AppListContent extends StatelessWidget {
  final List<AppModel> apps;
  final List<AppModel> invitations;
  final Map<String, String> processingActions;
  final Function(String) onAcceptInvitation;
  final Function(String) onRejectInvitation;
  final Function(AppModel) onAppTap;

  const AppListContent({
    super.key,
    required this.apps,
    required this.invitations,
    required this.processingActions,
    required this.onAcceptInvitation,
    required this.onRejectInvitation,
    required this.onAppTap,
  });

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty && invitations.isEmpty) return const AppListEmpty();

    return ListView(
      padding: EdgeInsets.all(context.scale(20)),
      children: [
        if (invitations.isNotEmpty) ...[
          SectionLabel(label: 'PENDING INVITATIONS (${invitations.length})', color: const Color(0xFFFCD34D)),
          SizedBox(height: context.scale(12)),
          ...invitations.map(
            (app) => InvitationCard(
              app: app,
              isAccepting: processingActions[app.id] == 'accept',
              isRejecting: processingActions[app.id] == 'reject',
              isProcessing: processingActions.containsKey(app.id),
              onAccept: () => onAcceptInvitation(app.id),
              onReject: () => onRejectInvitation(app.id),
            ),
          ),
          SizedBox(height: context.scale(24)),
        ],
        const SectionLabel(label: 'MY APPLICATIONS'),
        SizedBox(height: context.scale(12)),
        if (apps.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.scale(24)),
            child: Center(
              child: Text(
                'No accepted applications yet.',
                style: GoogleFonts.inter(color: IosTheme.textTertiary, fontSize: context.scale(13)),
              ),
            ),
          )
        else
          ...apps.map((app) => AppCard(app: app, onTap: () => onAppTap(app))),
      ],
    );
  }
}
