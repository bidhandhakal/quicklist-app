import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_model.dart';
import '../../controllers/task_controller.dart';
import '../../data/dummy_categories.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.rw(16)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.rw(14),
            vertical: context.rh(10),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => taskController.toggleTaskCompletion(task),
                child: Container(
                  width: context.rw(22),
                  height: context.rw(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? const Color(0xFF007AFF)
                          : Colors.grey.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    color: task.isCompleted
                        ? const Color(0xFF007AFF)
                        : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? Icon(
                          Icons.check,
                          size: context.rw(14),
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              SizedBox(width: context.rw(12)),

              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: GoogleFonts.manrope(
                        fontSize: context.rf(15),
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? Colors.grey[400]
                            : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      SizedBox(height: context.rh(4)),
                      Text(
                        task.description!,
                        style: GoogleFonts.manrope(
                          fontSize: context.rf(12),
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    SizedBox(height: context.rh(6)),

                    // Tags row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Category chip
                        if (category != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.rw(8),
                              vertical: context.rh(4),
                            ),
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                context.rw(6),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category.icon,
                                  size: context.rw(12),
                                  color: category.color,
                                ),
                                SizedBox(width: context.rw(4)),
                                Text(
                                  category.name,
                                  style: GoogleFonts.manrope(
                                    fontSize: context.rf(11),
                                    color: category.color,
                                    fontWeight: FontWeight.w600,
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
                                  : Colors.blueGrey.withValues(alpha: 0.05),
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
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  Helpers.formatDateShort(task.deadline!),
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    color: task.isOverdue
                                        ? AppColors.error
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // More options
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                onPressed: () => _showTaskOptions(context),
                iconSize: 20,
              ),
            ],
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
            ? const Color(0xFF007AFF).withValues(alpha: 0.2)
            : AppColors.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isLeft ? Icons.check_circle_rounded : Icons.delete_rounded,
        color: isLeft ? const Color(0xFF007AFF) : AppColors.error,
        size: 28,
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete Task',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to delete this task?',
              style: GoogleFonts.manrope(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.manrope()),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                child: Text('Delete', style: GoogleFonts.manrope()),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showTaskOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final taskController = Provider.of<TaskController>(
          context,
          listen: false,
        );

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: Text('Edit', style: GoogleFonts.manrope()),
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
                    task.isCompleted
                        ? 'Mark as Incomplete'
                        : 'Mark as Complete',
                    style: GoogleFonts.manrope(),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    taskController.toggleTaskCompletion(task);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_rounded),
                  title: Text('Delete', style: GoogleFonts.manrope()),
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
          ),
        );
      },
    );
  }
}
