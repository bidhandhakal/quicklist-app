# Changelog

## Version 1.0.0 - Initial Release

### Features

✅ Complete To-Do List app with Material 3 design
✅ Task management (Create, Read, Update, Delete)
✅ Categories with color-coded organization (8 default categories)
✅ Priority levels (High, Medium, Low) with visual indicators
✅ Deadline support with overdue detection
✅ Task reminders and notifications
✅ Search and filter functionality
✅ Calendar view for task visualization
✅ Animated splash screen
✅ Settings page with notification controls
✅ Local storage using Hive
✅ Clean, minimal, modern UI

### Recent Fixes (Latest)

✅ Fixed all deprecation warnings (41 issues resolved)

- Replaced deprecated `withOpacity()` with `withValues(alpha:)` (15 instances)
- Removed debug print statements (15 instances)
- Fixed BuildContext async gaps with proper mounted checks (4 instances)
- Fixed widget property ordering (3 instances)
  ✅ Improved task persistence and display
  ✅ Enhanced error handling in task save operations
  ✅ Fixed FAB shape to circular design
  ✅ Zero compilation errors
  ✅ Zero linter warnings

### Technical Stack

- Flutter SDK 3.10.1
- Dart 3.10.0
- Provider 6.1.1 (State Management)
- Hive 2.2.3 (Local Storage)
- flutter_local_notifications 17.0.0
- table_calendar 3.0.9
- Material 3 Design System

### Architecture

- MVVM pattern with Provider
- Service layer for storage, notifications, and reminders
- Type-safe models with Hive code generation
- Modular folder structure
- Separation of concerns

### Known Issues

None currently reported.

### Testing Instructions

1. Run `flutter pub get` to install dependencies
2. Run `flutter pub run build_runner build` to generate Hive adapters
3. Run the app on your device/emulator
4. Add a task and verify it appears in the list
5. Test filtering by category, priority, and completion status
6. Test calendar view
7. Test notifications (requires permissions)
