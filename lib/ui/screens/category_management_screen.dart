import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/task_controller.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart';
import '../../config/routes.dart';
import '../../utils/constants.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await _showCategoryDialog();
              _loadCategories();
            },
          ),
        ],
      ),
      body: Consumer<TaskController>(
        builder: (context, taskController, child) {
          if (_categories.isEmpty) {
            return const EmptyState(
              icon: Icons.category_rounded,
              title: 'No Categories',
              message: 'Create categories to organize your tasks',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final categoryTasks = taskController.getTasksByCategory(
                category.id,
              );
              final taskCount = categoryTasks.length;
              final completedCount = categoryTasks
                  .where((t) => t.isCompleted)
                  .length;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  onLongPress: () => _showCategoryOptions(category),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Category icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(
                              category.colorValue,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            IconData(
                              category.iconCodePoint,
                              fontFamily: 'MaterialIcons',
                            ),
                            color: Color(category.colorValue),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Category info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (category.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  category.description!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '$taskCount task${taskCount != 1 ? 's' : ''}',
                                style: Theme.of(context).textTheme.bodySmall,
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
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Color(category.colorValue),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 60,
                                child: LinearProgressIndicator(
                                  value: completedCount / taskCount,
                                  backgroundColor: Color(
                                    category.colorValue,
                                  ).withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(category.colorValue),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(width: 8),
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
    );
  }

  void _showCategoryOptions(Category category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit Category'),
              onTap: () async {
                Navigator.pop(context);
                await _showCategoryDialog(category: category);
                _loadCategories();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text(
                'Delete Category',
                style: TextStyle(color: Colors.red),
              ),
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
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog({Category? category}) async {
    final nameController = TextEditingController(text: category?.name);
    final descController = TextEditingController(text: category?.description);
    Color selectedColor = category != null
        ? Color(category.colorValue)
        : AppColors.categoryColors.first;
    IconData selectedIcon = category != null
        ? IconData(category.iconCodePoint, fontFamily: 'MaterialIcons')
        : Icons.category_rounded;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(category == null ? 'New Category' : 'Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g., Work, Personal',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Text('Color', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppColors.categoryColors.map((color) {
                    final isSelected =
                        color.toARGB32() == selectedColor.toARGB32();
                    return InkWell(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Icon', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getIconOptions().map((icon) {
                    final isSelected = icon.codePoint == selectedIcon.codePoint;
                    return InkWell(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withValues(alpha: 0.2)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: selectedColor, width: 2)
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(icon, color: selectedColor),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final newCategory = Category(
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
              child: Text(category == null ? 'Create' : 'Save'),
            ),
          ],
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
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: Color(category.colorValue),
            ),
            const SizedBox(width: 8),
            Text(category.name),
          ],
        ),
      ),
      body: Consumer<TaskController>(
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
            padding: const EdgeInsets.only(bottom: 80),
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
        },
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
