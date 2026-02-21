import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/task_controller.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart' as cat_model;
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/native_ad_widget.dart';
import 'add_task_screen.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryService _categoryService = CategoryService();
  List<cat_model.Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categories = _categoryService.getAllCategories();
    });
  }

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Categories',
                          style: GoogleFonts.manrope(
                            color: AppColors.onSurface,
                            fontSize: context.rf(20),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: context.rh(2)),
                        Text(
                          '${_categories.length} categories',
                          style: GoogleFonts.manrope(
                            color: AppColors.onSurfaceSecondary,
                            fontSize: context.rf(13),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add button
                  GestureDetector(
                    onTap: () async {
                      await _showCategoryDialog();
                      _loadCategories();
                    },
                    child: Container(
                      width: context.rw(38),
                      height: context.rw(38),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.darkAccent,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: context.rw(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.rh(8)),

            // Category list
            Expanded(
              child: Consumer<TaskController>(
                builder: (context, taskController, child) {
                  if (_categories.isEmpty) {
                    return const EmptyState(
                      icon: Icons.category_rounded,
                      title: 'No Categories',
                      message: 'Create categories to organize your tasks',
                    );
                  }

                  // Create list with ads interspersed
                  final itemsWithAds = <dynamic>[];
                  for (int i = 0; i < _categories.length; i++) {
                    itemsWithAds.add(_categories[i]);
                    if ((i + 1) % 3 == 0 && i != _categories.length - 1) {
                      itemsWithAds.add('ad_$i');
                    }
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rw(16),
                      vertical: context.rh(8),
                    ),
                    itemCount: itemsWithAds.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: context.rh(10)),
                    itemBuilder: (context, index) {
                      final item = itemsWithAds[index];

                      // Check if this is an ad
                      if (item is String && item.startsWith('ad_')) {
                        return NativeAdWidget(
                          screenId: 'category_management_screen_$item',
                        );
                      }

                      // Otherwise it's a category
                      final category = item as cat_model.Category;
                      final categoryTasks = taskController.getTasksByCategory(
                        category.id,
                      );
                      final taskCount = categoryTasks.length;
                      final completedCount = categoryTasks
                          .where((t) => t.isCompleted)
                          .length;
                      final progress = taskCount > 0
                          ? completedCount / taskCount
                          : 0.0;

                      return GestureDetector(
                        onTap: () {
                          _showCategoryOptions(category);
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
                                  borderRadius: BorderRadius.circular(
                                    context.rw(12),
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
                                      style: GoogleFonts.manrope(
                                        fontSize: context.rf(15),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    if (category.description != null) ...[
                                      SizedBox(height: context.rh(2)),
                                      Text(
                                        category.description!,
                                        style: GoogleFonts.manrope(
                                          fontSize: context.rf(12),
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.onSurfaceSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
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
                                Icons.more_vert_rounded,
                                color: AppColors.onSurfaceSecondary,
                                size: context.rw(20),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Banner Ad
            const BannerAdWidget(screenId: 'category_management_screen'),
          ],
        ),
      ),
    );
  }

  void _showCategoryOptions(cat_model.Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.rw(20)),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.rw(16),
            vertical: context.rh(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: context.rw(40),
                height: context.rh(4),
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: context.rh(16)),
              // Category header
              Row(
                children: [
                  Container(
                    width: context.rw(40),
                    height: context.rw(40),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.rw(10)),
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: context.rw(20),
                    ),
                  ),
                  SizedBox(width: context.rw(12)),
                  Expanded(
                    child: Text(
                      category.name,
                      style: GoogleFonts.manrope(
                        fontSize: context.rf(18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.rh(20)),
              // Edit option
              _buildOptionTile(
                context,
                icon: Icons.edit_rounded,
                label: 'Edit Category',
                color: AppColors.onSurface,
                onTap: () async {
                  Navigator.pop(context);
                  await _showCategoryDialog(category: category);
                  _loadCategories();
                },
              ),
              SizedBox(height: context.rh(8)),
              // Delete option
              _buildOptionTile(
                context,
                icon: Icons.delete_rounded,
                label: 'Delete Category',
                color: AppColors.error,
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Category'),
                      content: const Text(
                        'Are you sure? Tasks in this category will not be deleted.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    await _categoryService.deleteCategory(category.id);
                    _loadCategories();
                  }
                },
              ),
              SizedBox(height: context.rh(8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(14),
          vertical: context.rh(14),
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(context.rw(12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: context.rw(20)),
            SizedBox(width: context.rw(12)),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: context.rf(15),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog({cat_model.Category? category}) async {
    final nameController = TextEditingController(text: category?.name);
    final descController = TextEditingController(text: category?.description);
    Color selectedColor = category != null
        ? Color(category.colorValue)
        : AppColors.categoryColors.first;
    IconData selectedIcon = category != null
        ? category.icon
        : Icons.category_rounded;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.rw(20)),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            left: context.rw(20),
            right: context.rw(20),
            top: context.rh(16),
            bottom: MediaQuery.of(context).viewInsets.bottom + context.rh(20),
          ),
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
                      color: AppColors.onSurfaceSecondary.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: context.rh(16)),
                // Title
                Text(
                  category == null ? 'New Category' : 'Edit Category',
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(22),
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: context.rh(20)),
                // Name field
                Text(
                  'Name',
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceSecondary,
                  ),
                ),
                SizedBox(height: context.rh(6)),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(15),
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., Work, Personal',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: context.rf(15),
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceSecondary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.rw(12)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.rw(14),
                      vertical: context.rh(14),
                    ),
                  ),
                ),
                SizedBox(height: context.rh(16)),
                // Description field
                Text(
                  'Description (Optional)',
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceSecondary,
                  ),
                ),
                SizedBox(height: context.rh(6)),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(15),
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Brief description...',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: context.rf(15),
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceSecondary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceSecondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(context.rw(12)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.rw(14),
                      vertical: context.rh(14),
                    ),
                  ),
                ),
                SizedBox(height: context.rh(20)),
                // Color picker
                Text(
                  'Color',
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceSecondary,
                  ),
                ),
                SizedBox(height: context.rh(10)),
                Wrap(
                  spacing: context.rw(10),
                  runSpacing: context.rh(10),
                  children: AppColors.categoryColors.map((color) {
                    final isSelected =
                        color.toARGB32() == selectedColor.toARGB32();
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: context.rw(38),
                        height: context.rw(38),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: AppColors.onSurface, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: context.rw(18),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: context.rh(20)),
                // Icon picker
                Text(
                  'Icon',
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceSecondary,
                  ),
                ),
                SizedBox(height: context.rh(10)),
                Wrap(
                  spacing: context.rw(10),
                  runSpacing: context.rh(10),
                  children: _getIconOptions().map((icon) {
                    final isSelected = icon.codePoint == selectedIcon.codePoint;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: context.rw(44),
                        height: context.rw(44),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withValues(alpha: 0.15)
                              : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(context.rw(12)),
                          border: isSelected
                              ? Border.all(color: selectedColor, width: 2)
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? selectedColor
                              : AppColors.onSurfaceSecondary,
                          size: context.rw(22),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: context.rh(24)),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: context.rh(14),
                          ),
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
                      child: GestureDetector(
                        onTap: () async {
                          if (nameController.text.trim().isEmpty) return;

                          final newCategory = cat_model.Category(
                            id: category?.id ?? const Uuid().v4(),
                            name: nameController.text.trim(),
                            description: descController.text.trim().isEmpty
                                ? null
                                : descController.text.trim(),
                            colorValue: selectedColor.toARGB32(),
                            iconCodePoint: selectedIcon.codePoint,
                            createdAt: category?.createdAt ?? DateTime.now(),
                          );

                          if (category == null) {
                            await _categoryService.addCategory(newCategory);
                          } else {
                            await _categoryService.updateCategory(newCategory);
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: context.rh(14),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkAccent,
                            borderRadius: BorderRadius.circular(context.rw(12)),
                          ),
                          child: Center(
                            child: Text(
                              category == null ? 'Create' : 'Save',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<IconData> _getIconOptions() {
    return [
      Icons.category_rounded,
      Icons.work_rounded,
      Icons.person_rounded,
      Icons.home_rounded,
      Icons.shopping_cart_rounded,
      Icons.favorite_rounded,
      Icons.school_rounded,
      Icons.fitness_center_rounded,
      Icons.restaurant_rounded,
      Icons.local_cafe_rounded,
      Icons.sports_soccer_rounded,
      Icons.movie_rounded,
      Icons.music_note_rounded,
      Icons.flight_rounded,
      Icons.beach_access_rounded,
      Icons.pets_rounded,
    ];
  }
}

class CategoryDetailScreen extends StatelessWidget {
  final cat_model.Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rw(16),
                vertical: context.rh(12),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: context.rw(40),
                      height: context.rw(40),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(context.rw(12)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: context.rw(18),
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: context.rw(12)),
                  Container(
                    width: context.rw(40),
                    height: context.rw(40),
                    decoration: BoxDecoration(
                      color: Color(category.colorValue).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(context.rw(10)),
                    ),
                    child: Icon(
                      IconData(
                        category.iconCodePoint,
                        fontFamily: 'MaterialIcons',
                      ),
                      color: Color(category.colorValue),
                      size: context.rw(20),
                    ),
                  ),
                  SizedBox(width: context.rw(10)),
                  Expanded(
                    child: Text(
                      category.name,
                      style: GoogleFonts.manrope(
                        fontSize: context.rf(22),
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
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
                      icon: IconData(
                        category.iconCodePoint,
                        fontFamily: 'MaterialIcons',
                      ),
                      title: 'No ${category.name} Tasks',
                      message: 'Add tasks to this category to see them here',
                      action: GestureDetector(
                        onTap: () {
                          AddTaskScreen.show(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.rw(20),
                            vertical: context.rh(12),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkAccent,
                            borderRadius: BorderRadius.circular(context.rw(12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: context.rw(18),
                              ),
                              SizedBox(width: context.rw(6)),
                              Text(
                                'Add Task',
                                style: GoogleFonts.manrope(
                                  fontSize: context.rf(14),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rw(16),
                      vertical: context.rh(12),
                    ),
                    itemCount: tasks.length,
                    separatorBuilder: (_, _) => SizedBox(height: context.rh(8)),
                    itemBuilder: (context, index) {
                      return TaskTile(
                        task: tasks[index],
                        onTap: () {
                          AddTaskScreen.show(context, taskId: tasks[index].id);
                        },
                      );
                    },
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
