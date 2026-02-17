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
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.rw(20)),
          child: Stack(
            children: [
              // Glossy highlight overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.15, 0.4, 0.7, 1.0],
                      colors: [
                        Colors.white.withValues(alpha: 0.15),
                        Colors.white.withValues(alpha: 0.10),
                        Colors.white.withValues(alpha: 0.04),
                        Colors.white.withValues(alpha: 0.01),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Radial shine in top-left corner
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.8, -0.9),
                      radius: 1.2,
                      colors: [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Subtle border shine
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(context.rw(20)),
                  ),
                ),
              ),
              // Content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rw(14),
                    vertical: context.rh(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          SizedBox(height: context.rh(3)),
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.rw(4),
                                ),
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
                      SizedBox(width: context.rw(14)),
                      // Right Side: Progress Indicator
                      Container(
                        width: context.rw(44),
                        height: context.rw(44),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        padding: EdgeInsets.all(context.rw(3)),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: 1.0,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
