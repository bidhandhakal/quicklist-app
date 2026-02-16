import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/size_config.dart';

class DailyGoalCard extends StatelessWidget {
  final int targetTasks;
  final int completedTasks;
  final VoidCallback onTap;

  const DailyGoalCard({
    super.key,
    required this.targetTasks,
    required this.completedTasks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double progress = targetTasks > 0 ? completedTasks / targetTasks : 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.rw(24)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(16),
          vertical: context.rh(14),
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2C2C2E), // Dark grey
              Color(0xFF1C1C1E), // Near-black
            ],
          ),
          borderRadius: BorderRadius.circular(context.rw(20)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1C1C1E).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side: Text Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DAILY GOAL',
                  style: GoogleFonts.manrope(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: context.rf(11),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: context.rh(6)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$completedTasks',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: context.rf(26),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.rw(4)),
                      child: Text(
                        '/',
                        style: GoogleFonts.manrope(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: context.rf(18),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      '$targetTasks',
                      style: GoogleFonts.manrope(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: context.rf(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Right Side: Progress Indicator
            Container(
              width: context.rw(48),
              height: context.rw(48),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              padding: EdgeInsets.all(context.rw(3)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 1.0, // Background track
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.2),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    strokeCap: StrokeCap.round,
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
