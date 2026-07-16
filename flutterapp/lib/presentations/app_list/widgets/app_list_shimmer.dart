import 'package:flutter/material.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:shimmer/shimmer.dart';

class AppListShimmer extends StatelessWidget {
  const AppListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
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
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(context.scale(16))),
            ),
          ),
        ),
      ),
    );
  }
}
