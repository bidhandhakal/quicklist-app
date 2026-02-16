import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/routes.dart';
import '../../controllers/task_controller.dart';
import '../../data/dummy_categories.dart';
import 'package:provider/provider.dart';
import '../../utils/size_config.dart';
import '../../utils/constants.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/native_ad_widget.dart';
import '../widgets/banner_ad_widget.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Categories'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<TaskController>(
              builder: (context, taskController, child) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: context.rh(8)),
                  itemCount:
                      DummyCategories.categories.length + 1, // +1 for native ad
                  itemBuilder: (context, index) {
                    // Show native ad after 3rd category
                    if (index == 3) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rw(16),
                          vertical: context.rh(8),
                        ),
                        child: NativeAdWidget(
                          screenId: 'category_screen_category_list',
                        ),
                      );
                    }

                    // Adjust index for categories after ad
                    final categoryIndex = index > 3 ? index - 1 : index;
                    final category = DummyCategories.categories[categoryIndex];
                    final categoryTasks = taskController.getTasksByCategory(
                      category.id,
                    );
                    final taskCount = categoryTasks.length;
                    final completedCount = categoryTasks
                        .where((t) => t.isCompleted)
                        .length;

                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: context.rw(16),
                        vertical: context.rh(6),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          context.rw(AppColors.radiusMD),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                        borderRadius: BorderRadius.circular(
                          context.rw(AppColors.radiusMD),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(context.rw(14)),
                          child: Row(
                            children: [
                              // Category icon
                              Container(
                                padding: EdgeInsets.all(context.rw(10)),
                                decoration: BoxDecoration(
                                  color: category.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    context.rw(10),
                                  ),
                                ),
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                  size: context.rw(22),
                                ),
                              ),
                              SizedBox(width: context.rw(12)),
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
                                    SizedBox(height: context.rh(4)),
                                    SizedBox(
                                      width: context.rw(50),
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

                              SizedBox(width: context.rw(8)),
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
          // Banner ad at bottom
          const BannerAdWidget(screenId: 'category'),
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
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, color: category.color),
            SizedBox(width: context.rw(8)),
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
                  padding: EdgeInsets.only(bottom: context.rh(80)),
                  itemCount: tasks.length + 1, // +1 for native ad
                  itemBuilder: (context, index) {
                    // Show native ad after 4th task
                    if (index == 4 && tasks.length > 4) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rw(16),
                          vertical: context.rh(8),
                        ),
                        child: NativeAdWidget(
                          screenId: 'category_screen_task_list',
                        ),
                      );
                    }

                    // Adjust index for tasks after ad
                    final taskIndex = index > 4 ? index - 1 : index;
                    if (taskIndex >= tasks.length) {
                      return const SizedBox.shrink();
                    }

                    return TaskTile(
                      task: tasks[taskIndex],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editTask,
                          arguments: tasks[taskIndex].id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Banner Ad at bottom
          const BannerAdWidget(screenId: 'category_screen'),
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
