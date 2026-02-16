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
  // Core palette (black & white — aligned with nav bar design)
  static const Color primary = Color(0xFF1C1C1E); // Near-black (matches FAB)
  static const Color primaryContainer = Color(0xFFE5E5EA); // iOS light grey
  static const Color secondary = Color(0xFF8E8E93); // iOS system grey
  static const Color secondaryContainer = Color(0xFFF2F2F7); // iOS grouped bg
  static const Color tertiary = Color(0xFF636366); // iOS grey 2
  static const Color tertiaryContainer = Color(0xFFE5E5EA);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE5E5EA);
  static const Color surfaceSecondary = Color(0xFFF2F2F7); // Nav bar/tab bg
  static const Color background = Color(0xFFF6F6F9);
  static const Color error = Color(0xFFFF3B30); // iOS red

  // On-colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1C1C1E);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1C1C1E);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF1C1C1E);
  static const Color onSurface = Color(0xFF1C1C1E); // Unified dark tone
  static const Color onSurfaceVariant = Color(0xFF48484A); // iOS grey 3
  static const Color onSurfaceSecondary = Color(0xFF8E8E93); // iOS system grey
  static const Color onError = Color(0xFFFFFFFF);

  // Borders
  static const Color outline = Color(0xFFC7C7CC); // iOS separator
  static const Color outlineVariant = Color(0xFFD1D1D6); // iOS light separator

  // Status Colors
  static const Color success = Color(0xFF34C759); // iOS green
  static const Color warning = Color(0xFFFF9F0A); // iOS orange
  static const Color info = Color(0xFF1C1C1E); // Matches primary

  // Priority Colors
  static const Color highPriority = Color(0xFF1C1C1E); // Dark
  static const Color mediumPriority = Color(0xFF636366); // Mid grey
  static const Color lowPriority = Color(0xFFAEAEB2); // Light grey

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF1C1C1E),
    Color(0xFF636366),
    Color(0xFF34C759),
    Color(0xFFFF9F0A),
    Color(0xFFFF3B30),
    Color(0xFF8E8E93),
    Color(0xFF48484A),
    Color(0xFFAEAEB2),
  ];

  // Design system tokens
  static const Color cardShadow = Color(0x0A000000); // 0.04 opacity
  static const Color darkAccent = Color(0xFF1C1C1E); // Nav FAB color
  static const Color iconDefault = Color(0xFFAEAEB2); // Soft grey for icons

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
