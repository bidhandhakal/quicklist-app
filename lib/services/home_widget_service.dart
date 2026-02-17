import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/category_service.dart';

class HomeWidgetService {
  static HomeWidgetService? _instance;
  static HomeWidgetService get instance {
    _instance ??= HomeWidgetService._();
    return _instance!;
  }

  HomeWidgetService._();

  static const String _widgetName = 'QuickListWidget';
  static const String _androidProviderName = 'QuickListWidgetProvider';
  static const int _maxWidgetTasks = 4;

  /// Format deadline text matching the home page style (Helpers.formatDateShort)
  static String _formatDeadline(Task task) {
    if (task.deadline == null) return '';
    return DateFormat('MMM dd').format(task.deadline!);
  }

  /// Update widget with the 4 most recent tasks (same as home page)
  Future<void> updateWidget({required List<Task> recentTasks}) async {
    try {
      final taskCount = recentTasks.length.clamp(0, _maxWidgetTasks);
      await HomeWidget.saveWidgetData<int>('task_count', taskCount);

      for (int i = 0; i < _maxWidgetTasks; i++) {
        if (i < recentTasks.length) {
          final task = recentTasks[i];

          // Title
          await HomeWidget.saveWidgetData<String>('task_title_$i', task.title);

          // Completed status (for checkbox)
          await HomeWidget.saveWidgetData<bool>(
            'task_completed_$i',
            task.isCompleted,
          );

          // Priority (0=low, 1=medium, 2=high)
          await HomeWidget.saveWidgetData<int>(
            'task_priority_$i',
            task.priority,
          );

          // Category name
          String categoryName = '';
          if (task.categoryId != null) {
            final category = CategoryService().getCategoryById(
              task.categoryId!,
            );
            if (category != null) {
              categoryName = category.name;
            }
          }
          await HomeWidget.saveWidgetData<String>(
            'task_category_$i',
            categoryName,
          );

          // Deadline text
          final deadlineText = _formatDeadline(task);
          await HomeWidget.saveWidgetData<String>(
            'task_deadline_$i',
            deadlineText,
          );

          // Overdue status (for red color)
          await HomeWidget.saveWidgetData<bool>(
            'task_overdue_$i',
            task.isOverdue,
          );
        } else {
          await HomeWidget.saveWidgetData<String>('task_title_$i', '');
          await HomeWidget.saveWidgetData<bool>('task_completed_$i', false);
          await HomeWidget.saveWidgetData<int>('task_priority_$i', 1);
          await HomeWidget.saveWidgetData<String>('task_category_$i', '');
          await HomeWidget.saveWidgetData<String>('task_deadline_$i', '');
          await HomeWidget.saveWidgetData<bool>('task_overdue_$i', false);
        }
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
    HomeWidget.setAppGroupId('group.com.rimaoli.quicklist');
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
      return true;
    } catch (e) {
      return false;
    }
  }
}
