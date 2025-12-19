import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/local_storage_service.dart';
import '../../services/notification_service.dart';
import '../../services/rewarded_ad_manager.dart';
import '../../controllers/task_controller.dart';
import '../../utils/constants.dart';
import '../widgets/widgets.dart';
import '../widgets/native_ad_widget.dart';
import '../widgets/banner_ad_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storageService = LocalStorageService.instance;
  final _notificationService = NotificationService.instance;
  final _rewardedAdManager = RewardedAdManager();

  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = _storageService.notificationsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Notifications section
                _buildSectionHeader('Notifications'),
                const SizedBox(height: 8),

                CustomCard(
                  child: SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Get reminders for your tasks'),
                    value: _notificationsEnabled,
                    onChanged: (value) async {
                      if (value) {
                        await _notificationService.requestPermissions();
                      }
                      await _storageService.setNotificationsEnabled(value);
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Native Ad
                const NativeAdWidget(screenId: 'settings_screen'),

                const SizedBox(height: 24),

                // Data section
                _buildSectionHeader('Data'),
                const SizedBox(height: 8),

                Consumer<TaskController>(
                  builder: (context, taskController, child) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                label: 'Total',
                                value: '${taskController.totalTasks}',
                                icon: Icons.task_alt,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatsCard(
                                label: 'Active',
                                value: '${taskController.incompleteTasksCount}',
                                icon: Icons.pending_actions,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatsCard(
                                label: 'Completed',
                                value: '${taskController.completedTasksCount}',
                                icon: Icons.check_circle,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatsCard(
                                label: 'Progress',
                                value: taskController.totalTasks > 0
                                    ? '${((taskController.completedTasksCount / taskController.totalTasks) * 100).toInt()}%'
                                    : '0%',
                                icon: Icons.trending_up,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                InfoCard(
                  icon: Icons.delete_sweep,
                  title: 'Clear All Tasks',
                  subtitle: 'Delete all tasks permanently',
                  iconColor: AppColors.error,
                  onTap: _clearAllTasks,
                ),

                const SizedBox(height: 24),

                // About section
                _buildSectionHeader('About'),
                const SizedBox(height: 8),

                InfoCard(
                  icon: Icons.info,
                  title: AppConstants.appName,
                  subtitle: 'Version 1.1.0',
                  iconColor: Theme.of(context).primaryColor,
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Made with ❤️ using Flutter',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          // Banner Ad at bottom
          const BannerAdWidget(screenId: 'settings_screen'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _clearAllTasks() async {
    // Check if user has delete permission (from watching ad in this session)
    final hasPermission = _storageService.hasDeletePermission;

    if (!hasPermission) {
      // User needs to watch ad first - show dialog with Watch Ad button
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _ClearTasksDialog(
          rewardedAdManager: _rewardedAdManager,
          storageService: _storageService,
        ),
      );

      if (result == null || result != 'delete') return;

      if (!mounted) return;

      // Delete all tasks
      final taskController = context.read<TaskController>();
      await taskController.clearAllTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All tasks deleted'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      // User has permission, show simple confirmation dialog
      final confirmed = await CustomDialog.showConfirmation(
        context,
        title: 'Clear All Tasks',
        message:
            'Are you sure you want to delete all tasks? This action cannot be undone.',
        confirmText: 'Delete All',
        cancelText: 'Cancel',
        isDanger: true,
        icon: Icons.delete_forever,
      );

      if (confirmed == true && mounted) {
        final taskController = context.read<TaskController>();
        await taskController.clearAllTasks();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All tasks deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }
}

class _ClearTasksDialog extends StatefulWidget {
  final RewardedAdManager rewardedAdManager;
  final LocalStorageService storageService;

  const _ClearTasksDialog({
    required this.rewardedAdManager,
    required this.storageService,
  });

  @override
  State<_ClearTasksDialog> createState() => _ClearTasksDialogState();
}

class _ClearTasksDialogState extends State<_ClearTasksDialog> {
  bool _hasWatchedAd = false;
  bool _isLoadingAd = false;

  Future<void> _watchAd() async {
    setState(() {
      _isLoadingAd = true;
    });

    // Show rewarded ad
    final rewardEarned = await widget.rewardedAdManager.showAd();

    if (!mounted) return;

    setState(() {
      _isLoadingAd = false;
    });

    if (!rewardEarned) {
      // Ad not available or user didn't complete it
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not available or not completed. Please try again.'),
        ),
      );
      return;
    }

    // Grant delete permission for this session
    await widget.storageService.setDeletePermission(true);

    // Update UI to show Delete button
    setState(() {
      _hasWatchedAd = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.delete_forever),
      title: const Text('Clear All Tasks'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _hasWatchedAd
                ? 'You can now delete all tasks. This action cannot be undone.'
                : 'To delete tasks, you must watch a short ad first.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _hasWatchedAd
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  _hasWatchedAd ? Icons.warning : Icons.info_outline,
                  color: _hasWatchedAd
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _hasWatchedAd
                        ? 'This will permanently delete all your tasks!'
                        : 'After watching, you can delete as many times as you want until you restart the app.',
                    style: TextStyle(
                      color: _hasWatchedAd
                          ? Theme.of(context).colorScheme.onErrorContainer
                          : Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoadingAd ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (!_hasWatchedAd)
          FilledButton.icon(
            onPressed: _isLoadingAd ? null : _watchAd,
            icon: _isLoadingAd
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_isLoadingAd ? 'Loading...' : 'Watch Ad'),
          )
        else
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, 'delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete All Tasks'),
          ),
      ],
    );
  }
}
