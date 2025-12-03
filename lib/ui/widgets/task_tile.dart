import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';
import '../../data/dummy_categories.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import 'priority_tag.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskTile({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final taskController = Provider.of<TaskController>(context, listen: false);
    final category = DummyCategories.getCategoryByIdOrNull(task.categoryId);
    final priority = TaskPriority.values[task.priority];

    return Dismissible(
      key: Key(task.id),
      background: _buildSwipeBackground(context, isLeft: true),
      secondaryBackground: _buildSwipeBackground(context, isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete
          return await _showDeleteConfirmation(context);
        } else {
          // Toggle completion
          await taskController.toggleTaskCompletion(task);
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          taskController.deleteTask(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Task deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  taskController.addTask(task);
                },
              ),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () => taskController.toggleTaskCompletion(task),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: task.isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                      color: task.isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant
                                  : null,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Tags row
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // Category chip
                          if (category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: category.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    category.icon,
                                    size: 12,
                                    color: category.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: category.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Priority tag
                          PriorityTag(priority: priority, compact: true),

                          // Deadline chip
                          if (task.deadline != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: task.isOverdue
                                    ? AppColors.error.withValues(alpha: 0.1)
                                    : Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer
                                          .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    task.isOverdue
                                        ? Icons.warning_rounded
                                        : Icons.calendar_today_rounded,
                                    size: 12,
                                    color: task.isOverdue
                                        ? AppColors.error
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onTertiaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    Helpers.formatDateShort(task.deadline!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: task.isOverdue
                                          ? AppColors.error
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onTertiaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Reminder icon
                          if (task.reminderEnabled && task.reminderTime != null)
                            Icon(
                              Icons.notifications_active_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // More options
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showTaskOptions(context),
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    return Container(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isLeft
            ? Theme.of(context).colorScheme.primaryContainer
            : AppColors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isLeft ? Icons.check_circle_rounded : Icons.delete_rounded,
        color: isLeft
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Colors.white,
        size: 28,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showTaskOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final taskController = Provider.of<TaskController>(
          context,
          listen: false,
        );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  if (onTap != null) onTap!();
                },
              ),
              ListTile(
                leading: Icon(
                  task.isCompleted
                      ? Icons.remove_done_rounded
                      : Icons.check_circle_rounded,
                ),
                title: Text(
                  task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                ),
                onTap: () {
                  Navigator.pop(context);
                  taskController.toggleTaskCompletion(task);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded),
                title: const Text('Delete'),
                textColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await _showDeleteConfirmation(context);
                  if (confirmed) {
                    taskController.deleteTask(task.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
