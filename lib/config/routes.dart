import 'package:flutter/material.dart';
import '../ui/screens/main_shell.dart';
import '../ui/screens/add_task_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/calendar_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
  static const String category = '/category';
  static const String settings = '/settings';
  static const String calendar = '/calendar';
  static const String gamification = '/gamification';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const MainShell(initialIndex: 0),
      addTask: (context) => const AddTaskScreen(),
      category: (context) => const MainShell(initialIndex: 1),
      settings: (context) => const SettingsScreen(),
      calendar: (context) => const CalendarScreen(),
      gamification: (context) => const MainShell(initialIndex: 2),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case editTask:
        final taskId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => AddTaskScreen(taskId: taskId),
        );
      default:
        return null;
    }
  }
}
