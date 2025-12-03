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
  // Material 3 inspired colors
  static const Color primary = Color(0xFF6750A4);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color secondary = Color(0xFF625B71);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color tertiary = Color(0xFF7D5260);
  static const Color tertiaryContainer = Color(0xFFFFD8E4);

  static const Color surface = Color(0xFFFFFBFE);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color background = Color(0xFFFFFBFE);
  static const Color error = Color(0xFFB3261E);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1D192B);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF31111D);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color onError = Color(0xFFFFFFFF);

  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // Status Colors
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF0091EA);

  // Priority Colors
  static const Color highPriority = Color(0xFFD32F2F);
  static const Color mediumPriority = Color(0xFFF57C00);
  static const Color lowPriority = Color(0xFF388E3C);

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF6750A4),
    Color(0xFF0091EA),
    Color(0xFF00C853),
    Color(0xFFFFAB00),
    Color(0xFFD32F2F),
    Color(0xFF6200EA),
    Color(0xFF00BFA5),
    Color(0xFFFF6D00),
  ];
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
