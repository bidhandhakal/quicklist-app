import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class HomeWidgetService {
  static HomeWidgetService? _instance;
  static HomeWidgetService get instance {
    _instance ??= HomeWidgetService._();
    return _instance!;
  }

  HomeWidgetService._();

  static const String _widgetName = 'QuickListWidget';
  static const String _androidProviderName = 'QuickListWidgetProvider';

  /// Update widget with task data
  Future<void> updateWidget({
    required int totalTasks,
    required int completedTasks,
    required int activeTasks,
    List<Task>? upcomingTasks,
  }) async {
    try {
      // Save data to widget
      await HomeWidget.saveWidgetData<int>('total_tasks', totalTasks);
      await HomeWidget.saveWidgetData<int>('completed_tasks', completedTasks);
      await HomeWidget.saveWidgetData<int>('active_tasks', activeTasks);

      // Save next task if available
      if (upcomingTasks != null && upcomingTasks.isNotEmpty) {
        final nextTask = upcomingTasks.first;
        await HomeWidget.saveWidgetData<String>(
          'next_task_title',
          nextTask.title,
        );
        await HomeWidget.saveWidgetData<String>(
          'next_task_category',
          nextTask.categoryId,
        );
      } else {
        await HomeWidget.saveWidgetData<String>(
          'next_task_title',
          'No upcoming tasks',
        );
        await HomeWidget.saveWidgetData<String>('next_task_category', '');
      }

      // Update the widget
      await HomeWidget.updateWidget(
        androidName: _androidProviderName,
        iOSName: _widgetName,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating home widget: $e');
      }
    }
  }

  /// Initialize widget callbacks
  Future<void> initialize() async {
    // Set up background callback for widget interactions
    HomeWidget.setAppGroupId('group.com.example.quicklist');

    // Register callback for widget taps
    HomeWidget.registerInteractivityCallback(backgroundCallback);
  }

  /// Handle widget interactions
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'open_app') {
      // Widget was tapped, app will open automatically
    }
  }

  /// Check if widgets are supported on this platform
  Future<bool> isWidgetSupported() async {
    try {
      // Widgets are supported on Android and iOS
      return true;
    } catch (e) {
      return false;
    }
  }
}
