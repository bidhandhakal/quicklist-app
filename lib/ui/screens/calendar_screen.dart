import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/task_controller.dart';
import '../../config/routes.dart';
import '../../utils/size_config.dart';
import '../../utils/constants.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/banner_ad_widget.dart';
import 'add_task_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = _focusedDay;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<TaskController>(
              builder: (context, taskController, child) {
                return Column(
                  children: [
                    // Calendar widget
                    Card(
                      margin: EdgeInsets.all(context.rw(16)),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        eventLoader: (day) {
                          return taskController.getTasksByDate(day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 3,
                          outsideDaysVisible: false,
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonShowsNext: false,
                          formatButtonDecoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(context.rw(8)),
                          ),
                        ),
                      ),
                    ),

                    // Tasks for selected day
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.rw(16)),
                      child: Row(
                        children: [
                          Text(
                            _getSelectedDayText(),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          if (_selectedDay != null)
                            Consumer<TaskController>(
                              builder: (context, controller, child) {
                                final tasks = controller.getTasksByDate(
                                  _selectedDay!,
                                );
                                return Text(
                                  '${tasks.length} task${tasks.length != 1 ? 's' : ''}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.rh(8)),

                    // Task list for selected day
                    Expanded(child: _buildTaskList(taskController)),
                  ],
                );
              },
            ),
          ),
          const BannerAdWidget(screenId: 'calendar_screen'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await AddTaskScreen.show(context);
          if (mounted) {
            setState(() {}); // Refresh calendar
          }
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getSelectedDayText() {
    if (_selectedDay == null) return 'Select a date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    if (selected == today) {
      return 'Today';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}';
    }
  }

  Widget _buildTaskList(TaskController taskController) {
    if (_selectedDay == null) {
      return const EmptyState(
        icon: Icons.calendar_today,
        title: 'Select a Date',
        message: 'Choose a date to view tasks',
      );
    }

    final tasks = taskController.getTasksByDate(_selectedDay!);

    if (tasks.isEmpty) {
      return EmptyState(
        icon: Icons.event_available,
        title: 'No Tasks',
        message: 'No tasks scheduled for this date',
        action: FilledButton.icon(
          onPressed: () {
            AddTaskScreen.show(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Task'),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: context.rh(16)),
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
  }
}
