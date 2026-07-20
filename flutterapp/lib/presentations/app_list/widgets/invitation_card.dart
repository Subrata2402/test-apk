import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_avatar.dart';
import 'package:flutterapp/widgets/glass_button.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class InvitationCard extends StatelessWidget {
  final AppModel app;
  final bool isAccepting;
  final bool isRejecting;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const InvitationCard({
    super.key,
    required this.app,
    required this.isAccepting,
    required this.isRejecting,
    required this.isProcessing,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: EdgeInsets.only(bottom: context.scale(12)),
      tint: Colors.amber.withValues(alpha: 0.06),
      borderColor: Colors.amber.withValues(alpha: 0.20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassAvatar(
                initials: app.initials,
                color: AppColors.warning,
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      app.packageName,
                      style: GoogleFonts.robotoMono(fontSize: context.scale(10), color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (app.description.isNotEmpty) ...[
            SizedBox(height: context.scale(10)),
            Text(
              app.description,
              style: GoogleFonts.inter(fontSize: context.scale(13), color: AppColors.textSecondary),
            ),
          ],
          SizedBox(height: context.scale(14)),
          Row(
            children: [
              GlassButton(
                label: kDeclineBtnLabel,
                isLoading: isRejecting,
                onPressed: isProcessing ? null : onReject,
                gradient: const LinearGradient(colors: [AppColors.error, AppColors.errorDark]),
              ),
              SizedBox(width: context.scale(8)),
              GlassButton(
                label: kAcceptBtnLabel,
                isLoading: isAccepting,
                onPressed: isProcessing ? null : onAccept,
                gradient: const LinearGradient(colors: [AppColors.warning, AppColors.warning]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
