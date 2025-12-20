import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7), // iOS light grey
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.check_circle_outline_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                fontFamily: 'SF Pro Display',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            if (action != null)
              action!
            else if (buttonText != null)
              TextButton(
                onPressed: onButtonPressed,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF007AFF),
                  textStyle: const TextStyle(
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
