import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutterapp/core/app_colors.dart';
import 'package:flutterapp/core/ios_theme.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const LoginSignInButton({super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.scale(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          height: context.scale(54),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLoading
                  ? [AppColors.primary.withValues(alpha: 0.40), AppColors.primaryDark.withValues(alpha: 0.40)]
                  : [AppColors.primary.withValues(alpha: 0.90), AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(context.scale(16)),
            border: Border.all(color: IosTheme.glass.withValues(alpha: 0.35), width: 0.8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isLoading ? 0.15 : 0.50),
                blurRadius: context.scale(22),
                spreadRadius: -2,
                offset: Offset(0, context.scale(6)),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              splashColor: IosTheme.glass.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(context.scale(16)),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: context.scale(20),
                        height: context.scale(20),
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    else
                      Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        width: context.scale(20),
                        height: context.scale(20),
                        errorBuilder: (_, _, _) => Icon(Icons.login, color: Colors.white, size: context.scale(20)),
                      ),
                    SizedBox(width: context.scale(10)),
                    Text(
                      isLoading ? 'Signing in…' : 'Continue with Google',
                      style: GoogleFonts.inter(
                        fontSize: context.scale(15),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
