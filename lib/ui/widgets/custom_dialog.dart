import 'package:flutter/material.dart';
import 'custom_button.dart';

/// Custom dialog with consistent styling
class CustomDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDanger;
  final IconData? icon;

  const CustomDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDanger = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color:
                      (isDanger ? theme.colorScheme.error : theme.primaryColor)
                          .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isDanger
                      ? theme.colorScheme.error
                      : theme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (content != null) ...[const SizedBox(height: 16), content!],
            const SizedBox(height: 24),
            Row(
              children: [
                if (cancelText != null)
                  Expanded(
                    child: CustomButton(
                      text: cancelText!,
                      isOutlined: true,
                      onPressed: onCancel ?? () => Navigator.pop(context),
                    ),
                  ),
                if (cancelText != null && confirmText != null)
                  const SizedBox(width: 12),
                if (confirmText != null)
                  Expanded(
                    child: CustomButton(
                      text: confirmText!,
                      backgroundColor: isDanger
                          ? theme.colorScheme.error
                          : theme.primaryColor,
                      onPressed: onConfirm ?? () => Navigator.pop(context),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    String? message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDanger: isDanger,
        icon: icon,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
  }

  /// Show info dialog
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    String? message,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        confirmText: buttonText,
        icon: icon,
        onConfirm: () => Navigator.pop(context),
      ),
    );
  }
}

/// Bottom sheet with consistent styling
class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;
  final double? height;

  const CustomBottomSheet({
    super.key,
    this.title,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: child,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    double? height,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CustomBottomSheet(title: title, height: height, child: child),
    );
  }
}
