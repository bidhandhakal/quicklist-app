import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/size_config.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String currentValue;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.unit,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.rw(20)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(14),
          vertical: context.rh(12),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.rw(20)),
          // No heavy border, subtle shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                  0xFF6C63FF,
                ).withValues(alpha: 0.1), // Light version of icon color usually
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: context.rw(18)),
            ),
            SizedBox(width: context.rw(12)),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentValue,
                    style: GoogleFonts.manrope(
                      fontSize: context.rf(20),
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: context.rh(2)),
                  Text(
                    title, // "To Do" passed here usually as title
                    style: GoogleFonts.manrope(
                      fontSize: context.rf(11),
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: context.rw(8)),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
