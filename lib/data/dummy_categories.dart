import 'package:flutter/material.dart';

class TaskCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  TaskCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class DummyCategories {
  static final List<TaskCategory> categories = [
    TaskCategory(
      id: 'work',
      name: 'Work',
      icon: Icons.work_rounded,
      color: const Color(0xFF1C1C1E),
    ),
    TaskCategory(
      id: 'personal',
      name: 'Personal',
      icon: Icons.person_rounded,
      color: const Color(0xFF636366),
    ),
    TaskCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_cart_rounded,
      color: const Color(0xFF34C759),
    ),
    TaskCategory(
      id: 'health',
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: const Color(0xFFFF3B30),
    ),
    TaskCategory(
      id: 'home',
      name: 'Home',
      icon: Icons.home_rounded,
      color: const Color(0xFFFF9F0A),
    ),
    TaskCategory(
      id: 'learning',
      name: 'Learning',
      icon: Icons.school_rounded,
      color: const Color(0xFF48484A),
    ),
    TaskCategory(
      id: 'finance',
      name: 'Finance',
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFF8E8E93),
    ),
    TaskCategory(
      id: 'other',
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      color: const Color(0xFFAEAEB2),
    ),
  ];

  static TaskCategory getCategoryById(String id) {
    return categories.firstWhere(
      (category) => category.id == id,
      orElse: () => categories.last, // Return 'Other' if not found
    );
  }

  static TaskCategory? getCategoryByIdOrNull(String? id) {
    if (id == null) return null;
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
