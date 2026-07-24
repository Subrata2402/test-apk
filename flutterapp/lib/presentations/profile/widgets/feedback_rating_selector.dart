import 'package:flutter/material.dart';
import 'package:flutterapp/utils/extensions.dart';
import 'package:flutterapp/widgets/glass_panel.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackRatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;

  const FeedbackRatingSelector({super.key, required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.symmetric(vertical: context.scale(12), horizontal: context.scale(16)),
      borderRadius: 14,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'How would you rate us?',
            style: GoogleFonts.inter(fontSize: context.scale(13), color: Colors.white.withValues(alpha: 0.70)),
          ),
          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isFilled = starIndex <= rating;
              return GestureDetector(
                onTap: () => onRatingChanged(starIndex),
                child: Padding(
                  padding: EdgeInsets.only(left: context.scale(4)),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFilled ? Colors.amber : Colors.white.withValues(alpha: 0.30),
                    size: context.scale(24),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
