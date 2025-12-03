import 'package:flutter/material.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/add_task_screen.dart';
import '../ui/screens/category_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/calendar_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task';
  static const String category = '/category';
  static const String settings = '/settings';
  static const String calendar = '/calendar';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      addTask: (context) => const AddTaskScreen(),
      category: (context) => const CategoryScreen(),
      settings: (context) => const SettingsScreen(),
      calendar: (context) => const CalendarScreen(),
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
