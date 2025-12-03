# QuickList - Flutter To-Do List App

A modern, feature-rich To-Do List application built with Flutter featuring a clean Material 3 UI, local storage, smart reminders, and comprehensive task management capabilities.

## 🌟 Features

### Core Functionality

- ✅ **Complete Task Management** - Create, edit, delete, and complete tasks
- 📱 **Material 3 UI** - Clean, modern interface following Material Design 3 guidelines
- 💾 **Local Storage** - Persistent data storage using Hive
- 🔔 **Smart Notifications** - Task reminders and deadline alerts using flutter_local_notifications
- 🎨 **Beautiful Animations** - Smooth transitions and animated splash screen

### Task Organization

- 📂 **Categories** - 8 predefined categories (Work, Personal, Shopping, Health, Home, Learning, Finance, Other)
- ⚡ **Priority Levels** - Low, Medium, High priority indicators with color coding
- 📅 **Deadlines** - Set due dates and times for tasks
- ⏰ **Reminders** - Schedule custom reminder notifications
- 🔍 **Search & Filter** - Find tasks quickly with search and filter by category/priority

### Views & Navigation

- 🏠 **Home Screen** - View all tasks with stats and tabs (All/Active/Completed)
- 📋 **Category View** - Browse tasks organized by categories
- 📆 **Calendar View** - See tasks on a calendar interface
- ⚙️ **Settings** - Manage notifications and app preferences

## 🚀 Getting Started

### Installation

1. **Install dependencies**

   ```bash
   flutter pub get
   ```

2. **Generate Hive adapters**

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Key Dependencies

- `provider: ^6.1.1` - State management
- `hive: ^2.2.3` & `hive_flutter: ^1.1.0` - Local database
- `flutter_local_notifications: ^17.0.0` - Notifications
- `table_calendar: ^3.0.9` - Calendar widget
- `intl: ^0.19.0` - Date/time formatting

## 🎯 Usage Guide

### Creating a Task

1. Tap the **+ Add Task** button
2. Enter task details (title, description, category, priority)
3. Set optional deadline and reminder
4. Tap **Add Task** to save

### Managing Tasks

- **Complete**: Tap checkbox or swipe right
- **Edit**: Tap on task card
- **Delete**: Swipe left
- **Filter**: Use search and filter options in home screen

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12.0+)

## 🔧 Troubleshooting

If you encounter build errors:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

**Made with ❤️ using Flutter**
