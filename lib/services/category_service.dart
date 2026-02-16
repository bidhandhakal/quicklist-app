import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryService {
  static const String _boxName = 'categories';
  Box<Category>? _categoryBox;

  // Singleton pattern
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  // Cache
  List<Category>? _cachedCategories;

  // Initialize the category box
  Future<void> init() async {
    _categoryBox = await Hive.openBox<Category>(_boxName);
    _refreshCache();

    // Initialize with default categories if empty
    if (_categoryBox!.isEmpty) {
      await _initializeDefaultCategories();
      _refreshCache();
    }
  }

  // Initialize default categories
  Future<void> _initializeDefaultCategories() async {
    final now = DateTime.now();
    final defaultCategories = {
      'work': Category(
        id: 'work',
        name: 'Work',
        colorValue: const Color(0xFF1C1C1E).toARGB32(),
        iconCodePoint: Icons.work_rounded.codePoint,
        createdAt: now,
      ),
      'personal': Category(
        id: 'personal',
        name: 'Personal',
        colorValue: const Color(0xFF636366).toARGB32(),
        iconCodePoint: Icons.person_rounded.codePoint,
        createdAt: now,
      ),
      'shopping': Category(
        id: 'shopping',
        name: 'Shopping',
        colorValue: const Color(0xFF34C759).toARGB32(),
        iconCodePoint: Icons.shopping_cart_rounded.codePoint,
        createdAt: now,
      ),
      'health': Category(
        id: 'health',
        name: 'Health',
        colorValue: const Color(0xFFFF3B30).toARGB32(),
        iconCodePoint: Icons.favorite_rounded.codePoint,
        createdAt: now,
      ),
      'home': Category(
        id: 'home',
        name: 'Home',
        colorValue: const Color(0xFFFF9F0A).toARGB32(),
        iconCodePoint: Icons.home_rounded.codePoint,
        createdAt: now,
      ),
      'learning': Category(
        id: 'learning',
        name: 'Learning',
        colorValue: const Color(0xFF48484A).toARGB32(),
        iconCodePoint: Icons.school_rounded.codePoint,
        createdAt: now,
      ),
      'finance': Category(
        id: 'finance',
        name: 'Finance',
        colorValue: const Color(0xFF8E8E93).toARGB32(),
        iconCodePoint: Icons.account_balance_wallet_rounded.codePoint,
        createdAt: now,
      ),
      'other': Category(
        id: 'other',
        name: 'Other',
        colorValue: const Color(0xFFAEAEB2).toARGB32(),
        iconCodePoint: Icons.more_horiz_rounded.codePoint,
        createdAt: now,
      ),
    };

    // Batch write - much faster than loop
    await _categoryBox!.putAll(defaultCategories);
  }

  // Refresh cache
  void _refreshCache() {
    _cachedCategories = _categoryBox?.values.toList();
  }

  // Get all categories (cached)
  List<Category> getAllCategories() {
    return _cachedCategories ?? [];
  }

  // Get category by ID (cached)
  Category? getCategoryById(String id) {
    return _cachedCategories?.firstWhere(
      (cat) => cat.id == id,
      orElse: () =>
          _categoryBox?.get(id) ??
          Category(
            id: id,
            name: 'Unknown',
            colorValue: Colors.grey.toARGB32(),
            iconCodePoint: Icons.category.codePoint,
            createdAt: DateTime.now(),
          ),
    );
  }

  // Add new category
  Future<void> addCategory(Category category) async {
    await _categoryBox?.put(category.id, category);
    _refreshCache();
  }

  // Update category
  Future<void> updateCategory(Category category) async {
    await _categoryBox?.put(category.id, category);
    _refreshCache();
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    await _categoryBox?.delete(id);
    _refreshCache();
  }

  // Check if category exists (cached)
  bool categoryExists(String id) {
    return _cachedCategories?.any((cat) => cat.id == id) ?? false;
  }
}
