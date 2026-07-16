import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants.dart';
import 'package:flutterapp/models/app_model.dart';
import 'package:flutterapp/models/release_model.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailGrid extends StatelessWidget {
  final ReleaseModel release;
  final AppModel app;

  const DetailGrid({super.key, required this.release, required this.app});

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String>>[
      {'label': kLabelBuildNumber, 'value': release.buildNumber.toString()},
      if (release.minSdkVersion != null) {'label': kLabelMinSdk, 'value': '$kApiPrefix${release.minSdkVersion}'},
      if (release.targetSdkVersion != null) {'label': kLabelTargetSdk, 'value': '$kApiPrefix${release.targetSdkVersion}'},
      {'label': kLabelSize, 'value': release.size},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: context.scale(10),
        crossAxisSpacing: context.scale(10),
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      padding: EdgeInsets.zero,
      itemBuilder: (_, i) {
        final item = items[i];
        return GlassPanel(
          padding: EdgeInsets.symmetric(horizontal: context.scale(14), vertical: context.scale(10)),
          borderRadius: 12,
          blur: 20,
          borderColor: Colors.white.withValues(alpha: 0.16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['label']!,
                style: GoogleFonts.inter(
                  fontSize: context.scale(10),
                  color: Colors.white.withValues(alpha: 0.40),
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: context.scale(3)),
              Text(
                item['value']!,
                style: GoogleFonts.inter(fontSize: context.scale(13), fontWeight: FontWeight.w600, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
