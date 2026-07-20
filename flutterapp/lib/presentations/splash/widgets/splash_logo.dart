import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/utils/extensions.dart';

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(26)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: context.scale(90),
          height: context.scale(90),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.scale(26)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0.08)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.40), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.orb1.withValues(alpha: 0.55),
                blurRadius: context.scale(40),
                spreadRadius: -4,
                offset: Offset(0, context.scale(10)),
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.accentLight, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Icon(Icons.android, color: Colors.white, size: context.scale(48)),
            ),
          ),
        ),
      ),
    );
  }
}
