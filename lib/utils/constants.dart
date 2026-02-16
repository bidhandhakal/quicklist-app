import 'package:flutter/material.dart';

// App Constants
class AppConstants {
  static const String appName = 'QuickList';
  static const String noTasksMessage = 'No tasks yet!';
  static const String addTaskMessage = 'Tap + to add your first task';

  // Notification IDs
  static const int dailyReminderNotificationId = 0;
  static const int overdueTaskNotificationId = 1;

  // Hive Box Names
  static const String tasksBoxName = 'tasks';
  static const String settingsBoxName = 'settings';

  // Settings Keys
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String dailyReminderTimeKey = 'daily_reminder_time';
}

// App Colors
class AppColors {
  // Core palette (aligned with nav bar design)
  static const Color primary = Color(0xFF007AFF); // iOS Blue
  static const Color primaryContainer = Color(0xFFD6E4FF);
  static const Color secondary = Color(0xFF625B71);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color tertiary = Color(0xFF7D5260);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color surfaceSecondary = Color(0xFFF2F2F7); // Nav bar/tab bg
  static const Color background = Color(0xFFF6F8FB);
  static const Color error = Color(0xFFB3261E);

  // On-colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF001B3D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1D192B);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF31111D);
  static const Color onSurface = Color(0xFF1C1C1E); // Unified dark tone
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color onSurfaceSecondary = Color(0xFF9E9E9E); // Grey[500]
  static const Color onError = Color(0xFFFFFFFF);

  // Borders
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // Status Colors
  static const Color success = Color(0xFF34C759); // iOS green
  static const Color warning = Color(0xFFFF9F0A); // iOS orange
  static const Color info = Color(0xFF007AFF);

  // Priority Colors
  static const Color highPriority = Color(0xFFFF3B30); // iOS red
  static const Color mediumPriority = Color(0xFFFF9F0A); // iOS orange
  static const Color lowPriority = Color(0xFF34C759); // iOS green

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF6750A4),
    Color(0xFF007AFF),
    Color(0xFF34C759),
    Color(0xFFFF9F0A),
    Color(0xFFFF3B30),
    Color(0xFF6200EA),
    Color(0xFF00BFA5),
    Color(0xFFFF6D00),
  ];

  // Design system tokens
  static const Color cardShadow = Color(0x0A000000); // 0.04 opacity
  static const Color darkAccent = Color(0xFF1C1C1E); // Nav FAB color

  // Standard border radii
  static const double radiusXS = 8;
  static const double radiusSM = 12;
  static const double radiusMD = 16;
  static const double radiusLG = 20;
  static const double radiusXL = 28;
  static const double radiusFull = 40;
}

// Priority Enum
enum TaskPriority {
  low,
  medium,
  high;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return AppColors.lowPriority;
      case TaskPriority.medium:
        return AppColors.mediumPriority;
      case TaskPriority.high:
        return AppColors.highPriority;
    }
  }
}
