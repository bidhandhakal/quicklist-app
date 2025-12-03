class Validators {
  // Task Title Validation
  static String? validateTaskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a task title';
    }
    if (value.trim().length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  // Task Description Validation
  static String? validateTaskDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Description is optional
    }
    if (value.trim().length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }

  // Category Name Validation
  static String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a category name';
    }
    if (value.trim().length < 2) {
      return 'Category name must be at least 2 characters';
    }
    if (value.trim().length > 30) {
      return 'Category name must be less than 30 characters';
    }
    return null;
  }
}
