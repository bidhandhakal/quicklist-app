import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../config/routes.dart';
import '../../utils/constants.dart';
import '../../services/gamification_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/streak_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load tasks when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskController>().loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<TaskController>(
        builder: (context, taskController, child) {
          return Column(
            children: [
              // Stats cards
              _buildStatsCards(taskController),

              // Tabs
              Material(
                elevation: 2,
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Active'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),

              // Task list
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(taskController, showAll: true),
                    _buildTaskList(taskController, showActive: true),
                    _buildTaskList(taskController, showCompleted: true),
                  ],
                ),
              ),

              // Banner Ad at bottom
              const BannerAdWidget(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = context.read<TaskController>();
          await Navigator.pushNamed(context, AppRoutes.addTask);
          // Refresh tasks after returning from add screen
          if (mounted) {
            controller.loadTasks();
          }
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.2),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _isSearching
            ? TextField(
                key: const ValueKey('search'),
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  context.read<TaskController>().setSearchQuery(value);
                },
              )
            : const Text(AppConstants.appName, key: ValueKey('title')),
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                context.read<TaskController>().setSearchQuery('');
              }
            });
          },
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'filter',
              child: Row(
                children: [
                  Icon(Icons.filter_list),
                  SizedBox(width: 8),
                  Text('Filter'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'filter') {
              _showFilterBottomSheet();
            } else if (value == 'settings') {
              Navigator.pushNamed(context, AppRoutes.settings);
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatsCards(TaskController taskController) {
    final gamificationService = GamificationService.instance;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        children: [
          // Daily Goal and Streak Row
          ListenableBuilder(
            listenable: gamificationService,
            builder: (context, _) {
              return Row(
                children: [
                  Expanded(
                    child: DailyGoalCard(
                      targetTasks: gamificationService.dailyGoal.targetTasks,
                      completedTasks:
                          gamificationService.dailyGoal.todayCompleted,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.gamification),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.gamification),
                      child: StreakCard(
                        currentStreak: gamificationService.streak.currentStreak,
                        longestStreak: gamificationService.streak.longestStreak,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.checklist_rounded,
                  label: 'Total',
                  count: taskController.totalTasks,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pending_actions_rounded,
                  label: 'Active',
                  count: taskController.incompleteTasksCount,
                  color: AppColors.mediumPriority,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.warning_rounded,
                  label: 'Overdue',
                  count: taskController.overdueTasksCount,
                  color: AppColors.highPriority,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    TaskController taskController, {
    bool showAll = false,
    bool showActive = false,
    bool showCompleted = false,
  }) {
    List<dynamic> tasks;

    if (showAll) {
      tasks = taskController.tasks;
    } else if (showActive) {
      tasks = taskController.tasks.where((t) => !t.isCompleted).toList();
    } else {
      tasks = taskController.tasks.where((t) => t.isCompleted).toList();
    }

    if (tasks.isEmpty) {
      String message;
      String title;
      IconData icon;

      if (showCompleted) {
        icon = Icons.task_alt_rounded;
        title = 'No completed tasks yet';
        message = '🎯 Complete tasks to build your streak!';
      } else if (showActive) {
        icon = Icons.celebration_rounded;
        title = 'All caught up!';
        message = '✨ You\'ve completed all your tasks. Great job!';
      } else {
        icon = Icons.inbox_rounded;
        title = AppConstants.noTasksMessage;
        message = '💡 ${AppConstants.addTaskMessage}';
      }

      return EmptyState(icon: icon, title: title, message: message);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await taskController.loadTasks();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskTile(
            task: task,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.editTask,
                arguments: task.id,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        if (index == 0) {
          // Already on home - scroll to top if tapped again
          return;
        }
        switch (index) {
          case 1:
            Navigator.pushNamed(context, AppRoutes.category);
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.gamification);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.category_rounded),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.emoji_events_rounded),
          label: 'Achievements',
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<TaskController>(
          builder: (context, taskController, child) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Tasks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Priority filter
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected:
                              taskController.selectedPriorityFilter == null,
                          onSelected: (_) {
                            taskController.setPriorityFilter(null);
                          },
                        ),
                        ...TaskPriority.values.map((priority) {
                          return FilterChip(
                            label: Text(priority.displayName),
                            selected:
                                taskController.selectedPriorityFilter ==
                                priority.index,
                            onSelected: (_) {
                              taskController.setPriorityFilter(priority.index);
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Clear filters button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          taskController.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
