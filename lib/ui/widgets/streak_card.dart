import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../utils/size_config.dart';
import '../../utils/constants.dart';

class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rw(14),
        vertical: context.rh(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.rw(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: context.rw(36),
            height: context.rw(36),
            decoration: BoxDecoration(
              color: const Color(
                0xFFFF9F1C,
              ).withValues(alpha: 0.1), // Light Orange
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.fire,
                color: const Color(0xFFFF9F1C),
                size: context.rw(18),
              ),
            ),
          ),
          SizedBox(width: context.rw(12)),
          // Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$currentStreak',
                style: GoogleFonts.manrope(
                  fontSize: context.rf(20),
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                  height: 1.0,
                ),
              ),
              SizedBox(height: context.rh(2)),
              Text(
                'Day Streak',
                style: GoogleFonts.manrope(
                  fontSize: context.rf(11),
                  color: AppColors.onSurfaceSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
