import 'package:flutter/material.dart';

extension ScreenWidthExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double scale(double value) => screenWidth * (value / 440.0);
}
