import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/utils/extensions.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? blur;
  final Color? tint;
  final Color? borderColor;
  final double? borderWidth;
  final double? width;
  final double? height;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur,
    this.tint,
    this.borderColor,
    this.borderWidth,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? 18;
    final double blurSigma = blur ?? 24;
    final Color panelTint = tint ?? Colors.white.withValues(alpha: 0.09);
    final Color borderCol = borderColor ?? Colors.white.withValues(alpha: 0.18);
    final double borderW = borderWidth ?? 0.8;

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(radius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? EdgeInsets.all(context.scale(16)),
          decoration: BoxDecoration(
            color: panelTint,
            borderRadius: BorderRadius.circular(context.scale(radius)),
            border: Border.all(color: borderCol, width: borderW),
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    return card;
  }
}
