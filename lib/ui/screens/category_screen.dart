import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/task_controller.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart' as cat_model;
import 'package:provider/provider.dart';
import '../../utils/size_config.dart';
import '../../utils/constants.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/native_ad_widget.dart';
import 'category_management_screen.dart';
import 'add_task_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final CategoryService _categoryService = CategoryService();

  List<cat_model.Category> get _categories =>
      _categoryService.getAllCategories();

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<TaskController>(
          builder: (context, taskController, child) {
            final categories = _categories;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.rw(16),
                vertical: context.rh(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context, taskController),
                  SizedBox(height: context.rh(20)),

                  // Summary Cards
                  _buildSummaryRow(context, taskController, categories),
                  SizedBox(height: context.rh(24)),

                  // Section title
                  Text(
                    'All Categories',
                    style: GoogleFonts.manrope(
                      fontSize: context.rf(18),
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: context.rh(12)),

                  // Category list
                  _buildCategoryList(context, taskController, categories),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TaskController taskController) {
    final totalTasks = taskController.tasks.length;
    final completedTasks = taskController.tasks
        .where((t) => t.isCompleted)
        .length;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Categories',
                style: GoogleFonts.manrope(
                  color: AppColors.onSurface,
                  fontSize: context.rf(26),
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: context.rh(2)),
              Text(
                '$completedTasks of $totalTasks tasks completed',
                style: GoogleFonts.manrope(
                  color: AppColors.onSurfaceSecondary,
                  fontSize: context.rf(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Manage button
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoryManagementScreen(),
              ),
            );
            if (mounted) setState(() {});
          },
          child: Container(
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
            child: Icon(
              Icons.tune_rounded,
              color: AppColors.onSurface,
              size: context.rw(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    TaskController taskController,
    List<cat_model.Category> categories,
  ) {
    final totalCategories = categories.length;

    // Find the category with most tasks
    String topCategoryName = '—';
    int topTaskCount = 0;
    for (final cat in categories) {
      final count = taskController.getTasksByCategory(cat.id).length;
      if (count > topTaskCount) {
        topTaskCount = count;
        topCategoryName = cat.name;
      }
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.rw(16)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.rw(36),
                  height: context.rw(36),
                  decoration: BoxDecoration(
                    color: AppColors.darkAccent.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.folder_rounded,
                    color: AppColors.onSurface,
                    size: context.rw(18),
                  ),
                ),
                SizedBox(height: context.rh(10)),
                Text(
                  '$totalCategories',
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(22),
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Categories',
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(12),
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: context.rw(12)),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(context.rw(16)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.rw(36),
                  height: context.rw(36),
                  decoration: BoxDecoration(
                    color: AppColors.darkAccent.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: AppColors.onSurface,
                    size: context.rw(18),
                  ),
                ),
                SizedBox(height: context.rh(10)),
                Text(
                  topCategoryName,
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(16),
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Most active',
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(12),
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    TaskController taskController,
    List<cat_model.Category> categories,
  ) {
    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: context.rh(40)),
          child: Text(
            'No categories yet. Tap the manage button to add one.',
            style: GoogleFonts.manrope(
              fontSize: context.rf(14),
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final showAd = categories.length >= 3;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length + (showAd ? 1 : 0),
      separatorBuilder: (context, index) => SizedBox(height: context.rh(10)),
      itemBuilder: (context, index) {
        // Show native ad after 3rd category
        if (showAd && index == 3) {
          return NativeAdWidget(screenId: 'category_screen_category_list');
        }

        final categoryIndex = (showAd && index > 3) ? index - 1 : index;
        final category = categories[categoryIndex];
        final categoryTasks = taskController.getTasksByCategory(category.id);
        final taskCount = categoryTasks.length;
        final completedCount = categoryTasks.where((t) => t.isCompleted).length;
        final progress = taskCount > 0 ? completedCount / taskCount : 0.0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailScreen(category: category),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(context.rw(14)),
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
            child: Row(
              children: [
                // Category icon
                Container(
                  width: context.rw(44),
                  height: context.rw(44),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.rw(12)),
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
                        style: GoogleFonts.manrope(
                          fontSize: context.rf(15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: context.rh(2)),
                      Text(
                        '$taskCount task${taskCount != 1 ? 's' : ''} · $completedCount done',
                        style: GoogleFonts.manrope(
                          fontSize: context.rf(12),
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress ring
                if (taskCount > 0) ...[
                  SizedBox(width: context.rw(8)),
                  SizedBox(
                    width: context.rw(40),
                    height: context.rw(40),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: context.rw(36),
                          height: context.rw(36),
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 3,
                            backgroundColor: category.color.withValues(
                              alpha: 0.15,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              category.color,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: GoogleFonts.manrope(
                            fontSize: context.rf(9),
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(width: context.rw(4)),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.onSurfaceSecondary,
                  size: context.rw(20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CategoryDetailScreen extends StatelessWidget {
  final cat_model.Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rw(16),
                vertical: context.rh(8),
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
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
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.onSurface,
                        size: context.rw(16),
                      ),
                    ),
                  ),
                  SizedBox(width: context.rw(12)),
                  // Category info
                  Container(
                    width: context.rw(38),
                    height: context.rw(38),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.rw(10)),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: context.rw(18),
                    ),
                  ),
                  SizedBox(width: context.rw(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: GoogleFonts.manrope(
                            color: AppColors.onSurface,
                            fontSize: context.rf(20),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Task list
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
                          AddTaskScreen.show(context);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Task'),
                      ),
                    );
                  }

                  final completedCount = tasks
                      .where((t) => t.isCompleted)
                      .length;
                  final progress = tasks.isNotEmpty
                      ? completedCount / tasks.length
                      : 0.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rw(16),
                      vertical: context.rh(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress card
                        Container(
                          padding: EdgeInsets.all(context.rw(16)),
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
                          child: Row(
                            children: [
                              SizedBox(
                                width: context.rw(52),
                                height: context.rw(52),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: context.rw(48),
                                      height: context.rw(48),
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 4,
                                        backgroundColor: category.color
                                            .withValues(alpha: 0.15),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              category.color,
                                            ),
                                        strokeCap: StrokeCap.round,
                                      ),
                                    ),
                                    Text(
                                      '${(progress * 100).toInt()}%',
                                      style: GoogleFonts.manrope(
                                        fontSize: context.rf(12),
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: context.rw(14)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$completedCount of ${tasks.length} completed',
                                      style: GoogleFonts.manrope(
                                        fontSize: context.rf(15),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: context.rh(2)),
                                    Text(
                                      '${tasks.length - completedCount} remaining',
                                      style: GoogleFonts.manrope(
                                        fontSize: context.rf(13),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.rh(20)),

                        // Tasks heading
                        Text(
                          'Tasks',
                          style: GoogleFonts.manrope(
                            fontSize: context.rf(18),
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        SizedBox(height: context.rh(12)),

                        // Task list
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tasks.length + 1, // +1 for native ad
                          separatorBuilder: (context, index) =>
                              SizedBox(height: context.rh(8)),
                          itemBuilder: (context, index) {
                            // Show native ad after 4th task
                            if (index == 4 && tasks.length > 4) {
                              return NativeAdWidget(
                                screenId: 'category_screen_task_list',
                              );
                            }

                            final taskIndex = index > 4 ? index - 1 : index;
                            if (taskIndex >= tasks.length) {
                              return const SizedBox.shrink();
                            }

                            return Container(
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
                              child: TaskTile(
                                task: tasks[taskIndex],
                                onTap: () {
                                  AddTaskScreen.show(
                                    context,
                                    taskId: tasks[taskIndex].id,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(height: context.rh(80)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
