import 'package:flutter/material.dart';

class Orb extends StatelessWidget {
  final double size;
  final Color color;
  const Orb({super.key, required this.size, required this.color});

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
