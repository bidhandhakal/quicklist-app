import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Widget? action; // Support for custom action widget (e.g. Button)
  // Keeping these for backward compatibility if needed, but 'action' is what user uses now
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    this.title = 'All Caught Up! 🎉',
    this.message = 'You have no tasks for today. Enjoy your free time!',
    this.icon,
    this.action,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.check_circle_outline_rounded,
                size: 40,
                color: AppColors.iconDefault,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.onSurfaceSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (action != null)
              action!
            else if (buttonText != null)
              TextButton(
                onPressed: onButtonPressed,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(buttonText!),
              ),
          ],
        ),
      ),
    );
  }
}
