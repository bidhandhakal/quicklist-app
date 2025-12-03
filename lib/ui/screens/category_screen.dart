import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../data/dummy_categories.dart';
import '../../config/routes.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/banner_ad_widget.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Column(
        children: [
          Expanded(
            child: Consumer<TaskController>(
              builder: (context, taskController, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: DummyCategories.categories.length,
                  itemBuilder: (context, index) {
                    final category = DummyCategories.categories[index];
                    final categoryTasks = taskController.getTasksByCategory(
                      category.id,
                    );
                    final taskCount = categoryTasks.length;
                    final completedCount = categoryTasks
                        .where((t) => t.isCompleted)
                        .length;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CategoryDetailScreen(category: category),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Category icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: category.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Category info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$taskCount task${taskCount != 1 ? 's' : ''}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),

                              // Progress indicator
                              if (taskCount > 0)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$completedCount/$taskCount',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: category.color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: 60,
                                      child: LinearProgressIndicator(
                                        value: completedCount / taskCount,
                                        backgroundColor: category.color
                                            .withValues(alpha: 0.2),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              category.color,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}

class CategoryDetailScreen extends StatelessWidget {
  final TaskCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, color: category.color),
            const SizedBox(width: 8),
            Text(category.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<TaskController>(
              builder: (context, taskController, child) {
                final tasks = taskController.getTasksByCategory(category.id);

                if (tasks.isEmpty) {
                  return EmptyState(
                    icon: category.icon,
                    title: 'No ${category.name} Tasks',
                    message: 'Add tasks to this category to see them here',
                    action: FilledButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.addTask);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Task'),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskTile(
                      task: tasks[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editTask,
                          arguments: tasks[index].id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addTask);
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
