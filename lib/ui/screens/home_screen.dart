import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/task_controller.dart';
import '../../config/routes.dart';
import '../../services/gamification_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/native_ad_widget.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB), // Light greyish blue match
      body: SafeArea(
        child: Consumer<TaskController>(
          builder: (context, taskController, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Header
                  _buildHeader(),
                  const SizedBox(height: 28),

                  // Dashboard (2 Column Layout)
                  _buildDashboard(taskController),
                  const SizedBox(height: 32),

                  // Tasks Header & Tabs
                  Text(
                    'Tasks',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTabs(context),
                  const SizedBox(height: 20),

                  // Task List
                  _buildSyncedTaskList(taskController),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = context.read<TaskController>();
          await Navigator.pushNamed(context, AppRoutes.addTask);
          if (mounted) {
            controller.loadTasks();
          }
        },
        backgroundColor: const Color(0xFF007AFF),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final dateString = DateFormat('EEEE, MMMM d').format(now).toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateString,
                style: GoogleFonts.manrope(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Today',
                style: GoogleFonts.manrope(
                  color: Colors.black87,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        // Search Button
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.black87, size: 22),
            onPressed: () {
              // Search action
            },
          ),
        ),
        const SizedBox(width: 12),
        // Settings Button
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87, size: 22),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard(TaskController taskController) {
    final gamificationService = GamificationService.instance;
    // Fixed heights for perfect alignment
    const double subCardHeight = 120; // Reduced height for compactness
    const double gap = 16;
    const double mainCardHeight = (subCardHeight * 2) + gap;

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
                  onTap: () => Navigator.pushNamed(context, AppRoutes.gamification),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
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
                        onTap: () => Navigator.pushNamed(context, AppRoutes.gamification),
                        child: StreakCard(
                           currentStreak: gamificationService.streak.currentStreak,
                           longestStreak: gamificationService.streak.longestStreak,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StatCard(
                    title: 'To Do',
                    currentValue: taskController.incompleteTasksCount.toString(),
                    unit: '',
                    icon: Icons.calendar_today_rounded,
                    iconColor: const Color(0xFF6C63FF),
                    onTap: () => _tabController.animateTo(0),
                    trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            _buildDot(Colors.redAccent),
                            const SizedBox(height: 4),
                            _buildDot(Colors.blueAccent),
                            const SizedBox(height: 4),
                            _buildDot(Colors.greenAccent),
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
  
  Widget _buildDot(Color color) {
      return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
          ),
      );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(10),
           boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
              )
           ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 13),
        tabs: const [
          Tab(text: 'Today'),
          Tab(text: 'Done'),
          Tab(text: 'All'),
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
              bool all = index == 2;
              
              return _buildTaskList(taskController, showActive: active, showCompleted: completed, showAll: all);
          },
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
       return Padding(
         padding: const EdgeInsets.only(top: 40),
         child: Center(
            child: Column(
                children: [
                    Icon(Icons.task_outlined, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text("No tasks found", style: GoogleFonts.manrope(color: Colors.grey[400])),
                ],
            )
        ),
       );
    }

    final itemsWithAds = <dynamic>[];
    for (int i = 0; i < tasks.length; i++) {
      itemsWithAds.add(tasks[i]);
      if ((i + 1) % 6 == 0 && i != tasks.length - 1) {
        itemsWithAds.add('ad_$i');
      }
    }

    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemsWithAds.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
                ]
            ),
            child: TaskTile(
              task: task,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.editTask,
                  arguments: task.id,
                );
              },
            ),
          );
        },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
              )
          ]
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF007AFF),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) return;
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
            icon: Icon(Icons.folder_outlined),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            label: 'Achievements',
          ),
        ],
      ),
    );
  }
}

