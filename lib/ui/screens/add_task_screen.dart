import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../data/dummy_categories.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/size_config.dart';
import '../widgets/banner_ad_widget.dart';

class AddTaskScreen extends StatefulWidget {
  final String? taskId;

  const AddTaskScreen({super.key, this.taskId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDeadline;
  TimeOfDay? _selectedDeadlineTime;
  bool _reminderEnabled = false;
  DateTime? _reminderDateTime;

  bool _isEditing = false;
  Task? _editingTask;

  @override
  void initState() {
    super.initState();
    _loadTaskIfEditing();
  }

  void _loadTaskIfEditing() {
    if (widget.taskId != null) {
      final taskController = context.read<TaskController>();
      _editingTask = taskController.allTasks.firstWhere(
        (task) => task.id == widget.taskId,
      );

      _isEditing = true;
      _titleController.text = _editingTask!.title;
      _descriptionController.text = _editingTask!.description ?? '';
      _selectedCategoryId = _editingTask!.categoryId;
      _selectedPriority = TaskPriority.values[_editingTask!.priority];
      _selectedDeadline = _editingTask!.deadline;
      _reminderEnabled = _editingTask!.reminderEnabled;
      _reminderDateTime = _editingTask!.reminderTime;

      if (_selectedDeadline != null) {
        _selectedDeadlineTime = TimeOfDay.fromDateTime(_selectedDeadline!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
        actions: [
          if (_isEditing)
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteTask),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(context.rw(16)),
                children: [
                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title *',
                      hintText: 'Enter task title',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: Validators.validateTaskTitle,
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: !_isEditing,
                  ),
                  SizedBox(height: context.rh(16)),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter task description (optional)',
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: Validators.validateTaskDescription,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                  ),
                  SizedBox(height: context.rh(24)),

                  // Category selector
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: context.rh(12)),
                  Wrap(
                    spacing: context.rw(8),
                    runSpacing: context.rh(8),
                    children: DummyCategories.categories.map((category) {
                      final isSelected = _selectedCategoryId == category.id;
                      return FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: context.rw(16),
                              color: isSelected ? category.color : null,
                            ),
                            SizedBox(width: context.rw(4)),
                            Text(category.name),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: category.color.withValues(alpha: 0.2),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategoryId = selected ? category.id : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: context.rh(24)),

                  // Priority selector
                  Text(
                    'Priority',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: context.rh(12)),
                  Row(
                    children: TaskPriority.values.map((priority) {
                      final isSelected = _selectedPriority == priority;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.rw(4),
                          ),
                          child: ChoiceChip(
                            label: SizedBox(
                              width: double.infinity,
                              child: Text(
                                priority.displayName,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: priority.color.withValues(
                              alpha: 0.2,
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedPriority = priority;
                              });
                            },
                            avatar: isSelected
                                ? Icon(
                                    Icons.check,
                                    size: context.rw(16),
                                    color: priority.color,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: context.rh(24)),

                  // Deadline selector
                  Text(
                    'Deadline',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: context.rh(12)),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.rw(12)),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _selectedDeadline != null
                          ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                          : 'No deadline set',
                    ),
                    subtitle: _selectedDeadlineTime != null
                        ? Text(_selectedDeadlineTime!.format(context))
                        : null,
                    trailing: _selectedDeadline != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _selectedDeadline = null;
                                _selectedDeadlineTime = null;
                              });
                            },
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _selectDeadline,
                  ),
                  SizedBox(height: context.rh(24)),

                  // Reminder toggle
                  SwitchListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.rw(12)),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    title: const Text('Set Reminder'),
                    subtitle: _reminderDateTime != null
                        ? Text(
                            '${_reminderDateTime!.day}/${_reminderDateTime!.month}/${_reminderDateTime!.year} at ${TimeOfDay.fromDateTime(_reminderDateTime!).format(context)}',
                          )
                        : const Text('Get notified about this task'),
                    value: _reminderEnabled,
                    onChanged: (value) {
                      setState(() {
                        _reminderEnabled = value;
                        if (value && _reminderDateTime == null) {
                          _selectReminderDateTime();
                        }
                      });
                    },
                  ),

                  if (_reminderEnabled) ...[
                    SizedBox(height: context.rh(8)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.rw(16)),
                      child: TextButton.icon(
                        onPressed: _selectReminderDateTime,
                        icon: const Icon(Icons.edit),
                        label: const Text('Change Reminder Time'),
                      ),
                    ),
                  ],

                  SizedBox(height: context.rh(32)),

                  // Save button
                  FilledButton(
                    onPressed: _saveTask,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.all(context.rw(16)),
                    ),
                    child: Text(_isEditing ? 'Update Task' : 'Add Task'),
                  ),
                ],
              ),
            ),
          ),

          // Banner Ad at bottom
          const BannerAdWidget(screenId: 'add_task_screen'),
        ],
      ),
    );
  }

  Future<void> _selectDeadline() async {
    if (!mounted) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedDeadlineTime ?? TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.dialOnly,
      );

      if (time != null) {
        setState(() {
          _selectedDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          _selectedDeadlineTime = time;
        });
      } else {
        setState(() {
          _selectedDeadline = DateTime(date.year, date.month, date.day, 23, 59);
          _selectedDeadlineTime = const TimeOfDay(hour: 23, minute: 59);
        });
      }
    }
  }

  Future<void> _selectReminderDateTime() async {
    if (!mounted) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate:
          _selectedDeadline ?? DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _reminderDateTime != null
            ? TimeOfDay.fromDateTime(_reminderDateTime!)
            : TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.dialOnly,
      );

      if (time != null) {
        setState(() {
          _reminderDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final taskController = context.read<TaskController>();

    try {
      if (_isEditing && _editingTask != null) {
        // Update existing task
        final updatedTask = _editingTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _selectedCategoryId,
          priority: _selectedPriority.index,
          deadline: _selectedDeadline,
          reminderEnabled: _reminderEnabled,
          reminderTime: _reminderEnabled ? _reminderDateTime : null,
        );

        await taskController.updateTask(updatedTask);
      } else {
        // Create new task
        final newTask = taskController.createNewTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _selectedCategoryId,
          priority: _selectedPriority.index,
          deadline: _selectedDeadline,
          reminderEnabled: _reminderEnabled,
          reminderTime: _reminderEnabled ? _reminderDateTime : null,
        );

        await taskController.addTask(newTask);
      }

      // Close add/edit screen
      navigator.pop();

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Task updated successfully'
                : 'Task added successfully',
          ),
          backgroundColor: AppColors.lowPriority,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error saving task: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
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
    );

    if (confirmed == true && mounted) {
      final taskController = context.read<TaskController>();
      await taskController.deleteTask(widget.taskId!);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task deleted')));
      }
    }
  }
}
