import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/task_controller.dart';
import '../../config/routes.dart';
import '../../services/gamification_service.dart';
import '../../utils/size_config.dart';
import '../../utils/constants.dart';
import '../widgets/task_tile.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/native_ad_widget.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskController>().loadTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize SizeConfig
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<TaskController>(
          builder: (context, taskController, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.rw(16),
                vertical: context.rh(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Header
                  _buildHeader(context),
                  SizedBox(height: context.rh(20)),

                  // Dashboard (2 Column Layout)
                  _buildDashboard(taskController, context),
                  SizedBox(height: context.rh(24)),

                  // Tasks Header & Tabs
                  Text(
                    'Tasks',
                    style: GoogleFonts.manrope(
                      fontSize: context.rf(18),
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: context.rh(12)),
                  _buildTabs(context),
                  SizedBox(height: context.rh(16)),

                  // Task List
                  _buildSyncedTaskList(taskController),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final dayName = DateFormat('EEEE').format(now);
    final dateString = DateFormat('MMMM d').format(now);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayName,
                style: GoogleFonts.manrope(
                  color: AppColors.onSurface,
                  fontSize: context.rf(26),
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: context.rh(2)),
              Text(
                dateString,
                style: GoogleFonts.manrope(
                  color: AppColors.onSurfaceSecondary,
                  fontSize: context.rf(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Settings Button
        Container(
          width: context.rw(38),
          height: context.rw(38),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.onSurface,
              size: context.rw(20),
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard(TaskController taskController, BuildContext context) {
    final gamificationService = GamificationService.instance;
    // Responsive heights for perfect alignment
    final double subCardHeight = context.rh(90); // Responsive height
    final double gap = context.rh(12);
    final double mainCardHeight = (subCardHeight * 2) + gap;

    return SizedBox(
      height: mainCardHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Daily Goal
          Expanded(
            flex: 5, // Slightly larger proportional width if needed, or equal
            child: ListenableBuilder(
              listenable: gamificationService,
              builder: (context, _) {
                return DailyGoalCard(
                  targetTasks: gamificationService.dailyGoal.targetTasks,
                  completedTasks: gamificationService.dailyGoal.todayCompleted,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.gamification),
                );
              },
            ),
          ),
          SizedBox(width: context.rw(12)),
          // Right: Stats Column
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Expanded(
                  child: ListenableBuilder(
                    listenable: gamificationService,
                    builder: (context, _) {
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.gamification,
                        ),
                        child: StreakCard(
                          currentStreak:
                              gamificationService.streak.currentStreak,
                          longestStreak:
                              gamificationService.streak.longestStreak,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: context.rh(12)),
                Expanded(
                  child: StatCard(
                    title: 'To Do',
                    currentValue: taskController.incompleteTasksCount
                        .toString(),
                    unit: '',
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.iconDefault,
                    onTap: () => _tabController.animateTo(0),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(context, AppColors.onSurface),
                        SizedBox(height: context.rh(4)),
                        _buildDot(context, AppColors.onSurfaceSecondary),
                        SizedBox(height: context.rh(4)),
                        _buildDot(context, AppColors.outlineVariant),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, Color color) {
    return Container(
      width: context.rw(6),
      height: context.rw(6),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      height: context.rh(42),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(context.rw(12)),
      ),
      padding: EdgeInsets.all(context.rw(4)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.darkAccent,
          borderRadius: BorderRadius.circular(context.rw(10)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.onSurfaceSecondary,
        labelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          fontSize: context.rf(12),
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: context.rf(12),
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_view_rounded, size: context.rw(14)),
                SizedBox(width: context.rw(5)),
                const Text('To do'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, size: context.rw(14)),
                SizedBox(width: context.rw(5)),
                const Text('Completed'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: context.rw(14)),
                SizedBox(width: context.rw(5)),
                const Text('Pending'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncedTaskList(TaskController taskController) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        int index = _tabController.index;
        bool active = index == 0;
        bool completed = index == 1;
        bool pending = index == 2;

        return _buildTaskList(
          taskController,
          showActive: active,
          showCompleted: completed,
          showPending: pending,
        );
      },
    );
  }

  Widget _buildTaskList(
    TaskController taskController, {
    bool showActive = false,
    bool showCompleted = false,
    bool showPending = false,
  }) {
    List<dynamic> tasks;

    if (showCompleted) {
      tasks = taskController.tasks.where((t) => t.isCompleted).toList();
    } else if (showPending) {
      tasks = taskController.tasks
          .where((t) => !t.isCompleted && t.deadline != null)
          .toList();
    } else {
      tasks = taskController.tasks.where((t) => !t.isCompleted).toList();
    }

    if (tasks.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: context.rh(32)),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.task_outlined,
                size: context.rw(40),
                color: AppColors.iconDefault,
              ),
              SizedBox(height: context.rh(12)),
              Text(
                "No tasks found",
                style: GoogleFonts.manrope(
                  color: AppColors.onSurfaceSecondary,
                  fontSize: context.rf(13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final itemsWithAds = <dynamic>[];
    for (int i = 0; i < tasks.length; i++) {
      itemsWithAds.add(tasks[i]);
      if ((i + 1) % 3 == 0 && i != tasks.length - 1) {
        itemsWithAds.add('ad_$i');
      }
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemsWithAds.length,
      separatorBuilder: (context, index) => SizedBox(height: context.rh(8)),
      itemBuilder: (context, index) {
        final item = itemsWithAds[index];
        if (item is String && item.startsWith('ad_')) {
          return NativeAdWidget(screenId: 'home_list_$item');
        }
        final task = item;
        // Apply custom cleaner styling for tasks if possible, but for now we reuse TaskTile
        // Consider modifying TaskTile if it doesn't match the "clean" look.
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(context.rw(AppColors.radiusMD)),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TaskTile(
            task: task,
            onTap: () {
              AddTaskScreen.show(context, taskId: task.id);
            },
          ),
        );
      },
    );
  }
}
