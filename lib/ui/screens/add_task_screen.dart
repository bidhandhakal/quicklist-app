import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';
import '../../services/category_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/size_config.dart';
import '../widgets/banner_ad_widget.dart';

class AddTaskScreen extends StatefulWidget {
  final String? taskId;

  const AddTaskScreen({super.key, this.taskId});

  /// Show the add/edit task bottom sheet.
  /// Pass [taskId] to edit an existing task.
  static Future<void> show(BuildContext context, {String? taskId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TaskController>(),
        child: AddTaskScreen(taskId: taskId),
      ),
    );
  }

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

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.rw(12)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.rw(12)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.rw(12)),
        borderSide: BorderSide(color: AppColors.darkAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.rw(12)),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.rw(12)),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.rw(14),
        vertical: context.rh(14),
      ),
      hintStyle: GoogleFonts.manrope(
        fontSize: context.rf(14),
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceSecondary.withValues(alpha: 0.7),
      ),
      labelStyle: GoogleFonts.manrope(
        fontSize: context.rf(14),
        fontWeight: FontWeight.w500,
        color: AppColors.onSurfaceSecondary,
      ),
      errorStyle: GoogleFonts.manrope(
        fontSize: context.rf(11),
        fontWeight: FontWeight.w500,
        color: AppColors.error,
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: context.rw(20),
        right: context.rw(20),
        top: context.rh(12),
        bottom: MediaQuery.of(context).viewInsets.bottom + context.rh(16),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: context.rw(40),
                  height: context.rh(4),
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: context.rh(14)),

              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Task' : 'New Task',
                      style: GoogleFonts.manrope(
                        fontSize: context.rf(22),
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  if (_isEditing)
                    GestureDetector(
                      onTap: _deleteTask,
                      child: Container(
                        width: context.rw(38),
                        height: context.rw(38),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(context.rw(10)),
                        ),
                        child: Icon(
                          Icons.delete_rounded,
                          size: context.rw(18),
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: context.rh(18)),

              // Title field
              _buildSectionLabel(context, 'Title'),
              SizedBox(height: context.rh(6)),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.manrope(
                  fontSize: context.rf(15),
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
                decoration: inputDecoration.copyWith(
                  hintText: 'What do you need to do?',
                ),
                validator: Validators.validateTaskTitle,
                textCapitalization: TextCapitalization.sentences,
                autofocus: !_isEditing,
              ),
              SizedBox(height: context.rh(16)),

              // Description field
              _buildSectionLabel(context, 'Description (Optional)'),
              SizedBox(height: context.rh(6)),
              TextFormField(
                controller: _descriptionController,
                style: GoogleFonts.manrope(
                  fontSize: context.rf(15),
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
                decoration: inputDecoration.copyWith(
                  hintText: 'Add some details...',
                ),
                validator: Validators.validateTaskDescription,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
              SizedBox(height: context.rh(18)),

              // Category selector
              _buildSectionLabel(context, 'Category'),
              SizedBox(height: context.rh(8)),
              Wrap(
                spacing: context.rw(8),
                runSpacing: context.rh(8),
                children: CategoryService().getAllCategories().map((category) {
                  final isSelected = _selectedCategoryId == category.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = isSelected ? null : category.id;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.rw(12),
                        vertical: context.rh(7),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.color.withValues(alpha: 0.12)
                            : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(context.rw(10)),
                        border: Border.all(
                          color: isSelected
                              ? category.color
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: context.rw(15),
                            color: isSelected
                                ? category.color
                                : AppColors.onSurfaceSecondary,
                          ),
                          SizedBox(width: context.rw(5)),
                          Text(
                            category.name,
                            style: GoogleFonts.manrope(
                              fontSize: context.rf(12),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? category.color
                                  : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: context.rh(18)),

              // Priority selector
              _buildSectionLabel(context, 'Priority'),
              SizedBox(height: context.rh(8)),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.rw(3)),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedPriority = priority);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            vertical: context.rh(10),
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? priority.color.withValues(alpha: 0.12)
                                : AppColors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(context.rw(10)),
                            border: Border.all(
                              color: isSelected
                                  ? priority.color
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: context.rw(18),
                                color: isSelected
                                    ? priority.color
                                    : AppColors.onSurfaceSecondary,
                              ),
                              SizedBox(height: context.rh(4)),
                              Text(
                                priority.displayName,
                                style: GoogleFonts.manrope(
                                  fontSize: context.rf(11),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? priority.color
                                      : AppColors.onSurfaceSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: context.rh(18)),

              // Deadline & Reminder row
              Row(
                children: [
                  // Deadline
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectDeadline,
                      child: Container(
                        padding: EdgeInsets.all(context.rw(12)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(context.rw(12)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: context.rw(18),
                              color: _selectedDeadline != null
                                  ? AppColors.onSurface
                                  : AppColors.onSurfaceSecondary,
                            ),
                            SizedBox(width: context.rw(8)),
                            Expanded(
                              child: Text(
                                _selectedDeadline != null
                                    ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                                    : 'Deadline',
                                style: GoogleFonts.manrope(
                                  fontSize: context.rf(12),
                                  fontWeight: FontWeight.w600,
                                  color: _selectedDeadline != null
                                      ? AppColors.onSurface
                                      : AppColors.onSurfaceSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_selectedDeadline != null)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDeadline = null;
                                    _selectedDeadlineTime = null;
                                  });
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  size: context.rw(16),
                                  color: AppColors.onSurfaceSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.rw(10)),
                  // Reminder toggle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _reminderEnabled = !_reminderEnabled;
                        if (_reminderEnabled && _reminderDateTime == null) {
                          _selectReminderDateTime();
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(context.rw(12)),
                      decoration: BoxDecoration(
                        color: _reminderEnabled
                            ? AppColors.darkAccent.withValues(alpha: 0.1)
                            : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(context.rw(12)),
                        border: Border.all(
                          color: _reminderEnabled
                              ? AppColors.darkAccent
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _reminderEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            size: context.rw(18),
                            color: _reminderEnabled
                                ? AppColors.darkAccent
                                : AppColors.onSurfaceSecondary,
                          ),
                          SizedBox(width: context.rw(6)),
                          Text(
                            'Remind',
                            style: GoogleFonts.manrope(
                              fontSize: context.rf(12),
                              fontWeight: FontWeight.w600,
                              color: _reminderEnabled
                                  ? AppColors.darkAccent
                                  : AppColors.onSurfaceSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (_reminderEnabled && _reminderDateTime != null) ...[
                SizedBox(height: context.rh(6)),
                GestureDetector(
                  onTap: _selectReminderDateTime,
                  child: Padding(
                    padding: EdgeInsets.only(left: context.rw(4)),
                    child: Text(
                      '${_reminderDateTime!.day}/${_reminderDateTime!.month}/${_reminderDateTime!.year} at ${TimeOfDay.fromDateTime(_reminderDateTime!).format(context)}',
                      style: GoogleFonts.manrope(
                        fontSize: context.rf(11),
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: context.rh(22)),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: context.rh(14)),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(context.rw(12)),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.manrope(
                              fontSize: context.rf(15),
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.rw(12)),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _saveTask,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: context.rh(14)),
                        decoration: BoxDecoration(
                          color: AppColors.darkAccent,
                          borderRadius: BorderRadius.circular(context.rw(12)),
                        ),
                        child: Center(
                          child: Text(
                            _isEditing ? 'Update Task' : 'Add Task',
                            style: GoogleFonts.manrope(
                              fontSize: context.rf(15),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.rh(16)),

              // Banner Ad
              const BannerAdWidget(screenId: 'add_task_screen'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: GoogleFonts.manrope(
        fontSize: context.rf(13),
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface.withValues(alpha: 0.7),
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
