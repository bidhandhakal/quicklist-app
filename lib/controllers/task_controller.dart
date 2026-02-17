import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../services/local_storage_service.dart';
import '../services/task_reminder_service.dart';
import '../services/home_widget_service.dart';
import '../services/interstitial_ad_manager.dart';
import '../services/gamification_service.dart';

class TaskController extends ChangeNotifier {
  final LocalStorageService _storageService = LocalStorageService.instance;
  final TaskReminderService _reminderService = TaskReminderService.instance;
  final HomeWidgetService _widgetService = HomeWidgetService.instance;
  final InterstitialAdManager _adManager = InterstitialAdManager();
  final GamificationService _gamificationService = GamificationService.instance;
  final Uuid _uuid = const Uuid();

  int _completedTasksCounter = 0;

  List<Task> _tasks = [];
  String? _selectedCategoryFilter;
  int? _selectedPriorityFilter;
  String _searchQuery = '';
  bool _showCompletedTasks = true;

  // Getters
  List<Task> get tasks => _getFilteredTasks();
  List<Task> get allTasks => _tasks;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  int? get selectedPriorityFilter => _selectedPriorityFilter;
  String get searchQuery => _searchQuery;
  bool get showCompletedTasks => _showCompletedTasks;

  int get totalTasks => _tasks.length;
  int get completedTasksCount => _tasks.where((t) => t.isCompleted).length;
  int get incompleteTasksCount => _tasks.where((t) => !t.isCompleted).length;
  int get overdueTasksCount =>
      _tasks.where((t) => !t.isCompleted && t.isOverdue).length;

  // Initialize
  Future<void> init() async {
    await loadTasks();
  }

  // Load tasks from storage
  Future<void> loadTasks() async {
    _tasks = _storageService.getAllTasks();
    _sortTasks();
    await _updateHomeWidget();
    notifyListeners();
  }

  // Sort tasks by priority and deadline
  void _sortTasks() {
    _tasks.sort((a, b) {
      // Incomplete tasks come first
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      // Sort by deadline (overdue first, then by date)
      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      } else if (a.deadline != null) {
        return -1;
      } else if (b.deadline != null) {
        return 1;
      }

      // Sort by priority (high to low)
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }

      // Sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  // Get filtered tasks
  List<Task> _getFilteredTasks() {
    List<Task> filtered = List.from(_tasks);

    // Filter by completion status
    if (!_showCompletedTasks) {
      filtered = filtered.where((task) => !task.isCompleted).toList();
    }

    // Filter by category
    if (_selectedCategoryFilter != null) {
      filtered = filtered
          .where((task) => task.categoryId == _selectedCategoryFilter)
          .toList();
    }

    // Filter by priority
    if (_selectedPriorityFilter != null) {
      filtered = filtered
          .where((task) => task.priority == _selectedPriorityFilter)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((task) {
        final titleMatch = task.title.toLowerCase().contains(query);
        final descriptionMatch =
            task.description?.toLowerCase().contains(query) ?? false;
        return titleMatch || descriptionMatch;
      }).toList();
    }

    return filtered;
  }

  // Add task
  Future<void> addTask(Task task) async {
    await _storageService.addTask(task);

    // Schedule reminder if enabled
    if (task.reminderEnabled && task.reminderTime != null) {
      await _reminderService.scheduleTaskReminder(task);
    }

    // Track task creation in gamification
    await _gamificationService.onTaskCreated();

    await loadTasks();
  }

  // Update task
  Future<void> updateTask(Task task) async {
    await _storageService.updateTask(task);

    // Update reminder
    if (task.reminderEnabled &&
        task.reminderTime != null &&
        !task.isCompleted) {
      await _reminderService.scheduleTaskReminder(task);
    } else {
      await _reminderService.cancelTaskReminder(task);
    }

    await loadTasks();
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    final task = _storageService.getTask(taskId);
    if (task != null) {
      await _reminderService.cancelTaskReminder(task);
    }

    await _storageService.deleteTask(taskId);
    await loadTasks();

    // Show interstitial ad every 2 deletions
    _completedTasksCounter++;
    if (_completedTasksCounter % 2 == 0) {
      _adManager.showAd();
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );

    await updateTask(updatedTask);

    // Track task completion/uncompletion in gamification
    if (!task.isCompleted) {
      await _gamificationService.onTaskCompleted();
      _completedTasksCounter++;
      if (_completedTasksCounter % 2 == 0) {
        _adManager.showAd();
      }
    } else {
      await _gamificationService.onTaskUncompleted();
    }
  }

  // Create new task
  Task createNewTask({
    required String title,
    String? description,
    DateTime? deadline,
    String? categoryId,
    int priority = 1,
    bool reminderEnabled = false,
    DateTime? reminderTime,
  }) {
    return Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      deadline: deadline,
      categoryId: categoryId,
      priority: priority,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
    );
  }

  // Filter operations
  void setCategoryFilter(String? categoryId) {
    _selectedCategoryFilter = categoryId;
    notifyListeners();
  }

  void setPriorityFilter(int? priority) {
    _selectedPriorityFilter = priority;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleShowCompletedTasks() {
    _showCompletedTasks = !_showCompletedTasks;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategoryFilter = null;
    _selectedPriorityFilter = null;
    _searchQuery = '';
    notifyListeners();
  }

  // Get tasks by category
  List<Task> getTasksByCategory(String categoryId) {
    return _tasks.where((task) => task.categoryId == categoryId).toList();
  }

  // Get tasks by date
  List<Task> getTasksByDate(DateTime date) {
    return _tasks.where((task) {
      if (task.deadline == null) return false;
      final taskDate = DateTime(
        task.deadline!.year,
        task.deadline!.month,
        task.deadline!.day,
      );
      final compareDate = DateTime(date.year, date.month, date.day);
      return taskDate == compareDate;
    }).toList();
  }

  // Clear all tasks
  Future<void> clearAllTasks() async {
    await _storageService.clearAllTasks();
    await loadTasks();
  }

  // Update home screen widget
  Future<void> _updateHomeWidget() async {
    // Show the most recent tasks (same sort as home page: incomplete first, then by deadline, priority, newest)
    final sortedTasks = List<Task>.from(_tasks);
    sortedTasks.sort((a, b) {
      // Incomplete tasks first
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Sort by deadline
      if (a.deadline != null && b.deadline != null) {
        return a.deadline!.compareTo(b.deadline!);
      } else if (a.deadline != null) {
        return -1;
      } else if (b.deadline != null) {
        return 1;
      }
      // Sort by priority (high to low)
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      // Sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    await _widgetService.updateWidget(
      recentTasks: sortedTasks.take(4).toList(),
    );
  }
}
