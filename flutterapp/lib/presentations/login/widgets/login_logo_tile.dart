import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/utils/extensions.dart';

class LoginLogoTile extends StatelessWidget {
  const LoginLogoTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: context.scale(84),
          height: context.scale(84),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.scale(24)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [IosTheme.glass.withValues(alpha: 0.30), IosTheme.glass.withValues(alpha: 0.10)],
            ),
            border: Border.all(color: IosTheme.glass.withValues(alpha: 0.45), width: 1),
            boxShadow: [
              BoxShadow(
                color: IosTheme.orb1.withValues(alpha: 0.50),
                blurRadius: context.scale(32),
                spreadRadius: -4,
                offset: Offset(0, context.scale(8)),
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFDDD6FE), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Icon(Icons.android, color: Colors.white, size: context.scale(44)),
            ),
          ),
        ),
      ),
    );
  }
}
