# QuickList To-Do App - Quick Start Guide

## 🚀 Running the App

### First Time Setup

```bash
# 1. Get dependencies
flutter pub get

# 2. Generate Hive adapters (required!)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run on your device/emulator
flutter run
```

### Subsequent Runs

```bash
flutter run
```

## 📱 App Features Overview

### Main Screens

1. **Splash Screen**

   - Beautiful animated intro when app starts
   - Auto-navigates to home after 2.5 seconds

2. **Home Screen** (Bottom Nav: Home)

   - Quick stats dashboard (Total, Active, Overdue tasks)
   - Three tabs: All, Active, Completed
   - Search functionality
   - Filter by priority
   - Pull to refresh

3. **Category Screen** (Bottom Nav: Categories)

   - View tasks organized by 8 categories:
     - Work, Personal, Shopping, Health
     - Home, Learning, Finance, Other
   - Each category shows task count and progress

4. **Calendar Screen** (Bottom Nav: Calendar)

   - Month/Week view
   - See tasks on specific dates
   - Visual indicators for days with tasks
   - Tap date to see all tasks for that day

5. **Settings Screen** (Menu → Settings)
   - Enable/disable notifications
   - Test notifications
   - View task statistics
   - Clear all tasks option

### Task Operations

#### Creating a Task

1. Tap the **+ Add Task** floating button (any screen)
2. Fill in details:
   - **Title\*** (required, 3-100 chars)
   - **Description** (optional, max 500 chars)
   - **Category** (tap chips to select)
   - **Priority** (Low/Medium/High)
   - **Deadline** (date + time)
   - **Reminder** (toggle + set time)
3. Tap **Add Task**

#### Editing a Task

1. Tap on any task card
2. Modify details
3. Tap **Update Task**
4. Or tap trash icon to delete

#### Quick Actions

- **Mark Complete**: Tap checkbox OR swipe right →
- **Delete**: Swipe left ← (confirmation required)
- **More Options**: Tap ⋮ on task card

### Smart Features

#### Notifications

- **Task Reminders**: Set when creating/editing task
- **Daily Digest**: Tasks due today
- **Overdue Alerts**: Hourly check for overdue tasks
- **Configure**: Settings → Enable Notifications

#### Filtering & Search

- **Search**: Top-right search icon
  - Searches in titles and descriptions
  - Real-time filtering
- **Priority Filter**: Menu → Filter
  - All, Low, Medium, High
- **Category Filter**: Categories screen
- **Date Filter**: Calendar screen

#### Task Statistics

Home screen shows:

- **Total**: All tasks count
- **Active**: Incomplete tasks
- **Overdue**: Past deadline tasks

### Swipe Gestures

| Gesture       | Action            | Color  |
| ------------- | ----------------- | ------ |
| Swipe Right → | Toggle completion | Purple |
| Swipe Left ←  | Delete task       | Red    |

### Visual Indicators

#### Priority Colors

- 🔴 **High**: Red
- 🟠 **Medium**: Orange
- 🟢 **Low**: Green

#### Task Status

- ⚠️ **Overdue**: Red warning icon
- 📅 **Has Deadline**: Calendar icon
- 🔔 **Has Reminder**: Bell icon
- ✓ **Completed**: Strikethrough text

## 🎨 UI Elements

### Categories & Icons

Each category has unique icon and color:

- 💼 Work (Purple)
- 👤 Personal (Blue)
- 🛒 Shopping (Green)
- ❤️ Health (Red)
- 🏠 Home (Orange)
- 📚 Learning (Purple)
- 💰 Finance (Teal)
- ⋯ Other (Gray)

## ⚙️ Settings Options

### Notifications

- **Toggle**: Enable/disable all notifications
- **Test**: Send test notification
- **Permissions**: Requested automatically

### Data Management

- **Statistics**: View task counts
- **Clear All**: Delete all tasks (⚠️ irreversible)

## 🔧 Troubleshooting

### Common Issues

**App won't build:**

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**No notifications:**

1. Check Settings → Enable Notifications
2. Grant permission in device settings
3. For Android 13+: Manually enable in app settings

**Tasks not saving:**

- Ensure Hive adapters are generated
- Check app permissions for storage

**Calendar not showing tasks:**

- Tasks need a deadline date to appear
- Check date is correct

## 💡 Tips & Best Practices

### Organization

1. **Use Categories**: Group related tasks
2. **Set Priorities**: Focus on what matters
3. **Add Deadlines**: Stay on track
4. **Use Reminders**: Never forget important tasks

### Workflow

1. **Morning**: Check Calendar for today's tasks
2. **Throughout Day**: Complete tasks, check boxes
3. **Evening**: Review Active tab, plan tomorrow
4. **Weekly**: Review by Category

### Efficiency

- Use **Search** for quick task lookup
- **Swipe** for fast completion/deletion
- Set **Reminders** day before deadline
- Review **Statistics** to track progress

## 🎯 Example Workflows

### Daily Planning

```
1. Open Calendar → Today
2. Review tasks due today
3. Set priorities for new tasks
4. Enable reminders for important ones
```

### Weekly Review

```
1. Go to Categories
2. Check each category progress
3. Complete/delete old tasks
4. Add tasks for next week
```

### Quick Task Entry

```
1. Tap + Add Task
2. Enter title only (minimum)
3. Tap Add Task
4. Edit later for more details
```

## 📊 Data & Privacy

- **Storage**: All data saved locally on device
- **No Cloud**: No internet connection needed
- **No Tracking**: No analytics or tracking
- **Your Data**: Complete control over your tasks

## 🆘 Support

If you encounter issues:

1. Check this guide
2. Try troubleshooting steps
3. Clear app data and restart
4. Reinstall app

---

**Enjoy staying organized with QuickList! 📝✨**
