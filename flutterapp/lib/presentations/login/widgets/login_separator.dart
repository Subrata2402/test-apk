import 'package:flutter/material.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/utils/extensions.dart';

class LoginSeparator extends StatelessWidget {
  const LoginSeparator({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.scale(13)),
    child: Container(height: 0.5, color: IosTheme.glass.withValues(alpha: 0.18)),
  );
}
