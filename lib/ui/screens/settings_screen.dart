import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/local_storage_service.dart';
import '../../services/notification_service.dart';
import '../../services/rewarded_ad_manager.dart';
import '../../services/task_reminder_service.dart';
import '../../controllers/task_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
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
                  SizedBox(width: context.rw(14)),
                  Text(
                    'Settings',
                    style: GoogleFonts.manrope(
                      fontSize: context.rf(22),
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rw(16),
                  vertical: context.rh(4),
                ),
                children: [
                  // Notifications section
                  _buildSectionHeader('Notifications'),
                  SizedBox(height: context.rh(8)),
                  _buildSettingsTile(
                    context,
                    icon: Icons.notifications_rounded,
                    title: 'Push Notifications',
                    subtitle: 'Get reminders for your tasks',
                    trailing: Switch.adaptive(
                      value: _notificationsEnabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.darkAccent,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: AppColors.onSurfaceSecondary
                          .withValues(alpha: 0.25),
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (value) async {
                        if (value) {
                          final granted = await _notificationService
                              .requestPermissions();
                          if (!granted) return;
                        }
                        await _storageService.setNotificationsEnabled(value);
                        setState(() {
                          _notificationsEnabled = value;
                        });
                        if (value) {
                          // Re-schedule all existing task reminders
                          await TaskReminderService.instance
                              .rescheduleAllReminders();
                        } else {
                          // Cancel all pending notifications
                          await _notificationService.cancelAllNotifications();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: context.rh(16)),

                  // Appearance section
                  _buildSectionHeader('Appearance'),
                  SizedBox(height: context.rh(8)),
                  _buildSettingsTile(
                    context,
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    subtitle: 'Coming soon',
                    trailing: Switch.adaptive(
                      value: false,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.darkAccent,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: AppColors.onSurfaceSecondary
                          .withValues(alpha: 0.25),
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: null,
                    ),
                  ),
                  SizedBox(height: context.rh(20)),

                  // Native Ad
                  const NativeAdWidget(screenId: 'settings_screen'),
                  SizedBox(height: context.rh(20)),

                  // Danger zone
                  _buildSectionHeader('Danger Zone'),
                  SizedBox(height: context.rh(8)),
                  GestureDetector(
                    onTap: _clearAllTasks,
                    child: _buildSettingsTile(
                      context,
                      icon: Icons.delete_sweep_rounded,
                      title: 'Clear All Tasks',
                      subtitle: 'Delete all tasks permanently',
                      iconColor: AppColors.error,
                      titleColor: AppColors.error,
                    ),
                  ),
                  SizedBox(height: context.rh(24)),

                  // About section
                  _buildSectionHeader('About'),
                  SizedBox(height: context.rh(8)),
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_rounded,
                    title: AppConstants.appName,
                    subtitle: 'Version 1.3.0',
                  ),
                  SizedBox(height: context.rh(20)),
                  GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse('https://x.com/bidhanxcode'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Center(
                      child: Text(
                        'Made by @bidhanxcode',
                        style: GoogleFonts.manrope(
                          fontSize: context.rf(12),
                          fontWeight: FontWeight.w500,
                          color: const Color.fromARGB(255, 29, 29, 29),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.rh(16)),
                ],
              ),
            ),
            const BannerAdWidget(screenId: 'settings_screen'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Container(
      padding: EdgeInsets.all(context.rw(14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.rw(14)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: context.rw(40),
            height: context.rw(40),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.darkAccent).withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(context.rw(10)),
            ),
            child: Icon(
              icon,
              size: context.rw(20),
              color: iconColor ?? AppColors.onSurface,
            ),
          ),
          SizedBox(width: context.rw(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(15),
                    fontWeight: FontWeight.w700,
                    color: titleColor ?? AppColors.onSurface,
                  ),
                ),
                SizedBox(height: context.rh(2)),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: context.rf(12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.rw(4),
        top: context.rh(8),
        bottom: context.rh(4),
      ),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: context.rf(13),
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Future<void> _clearAllTasks() async {
    final hasPermission = _storageService.hasDeletePermission;

    if (!hasPermission) {
      final result = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _ClearTasksSheet(
          rewardedAdManager: _rewardedAdManager,
          storageService: _storageService,
        ),
      );

      if (result == null || result != 'delete') return;
      if (!mounted) return;

      final taskController = context.read<TaskController>();
      await taskController.clearAllTasks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'All tasks deleted',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.darkAccent,
          ),
        );
      }
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Clear All Tasks',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Are you sure you want to delete all tasks? This action cannot be undone.',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(
                'Delete All',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        final taskController = context.read<TaskController>();
        await taskController.clearAllTasks();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'All tasks deleted',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
              backgroundColor: AppColors.darkAccent,
            ),
          );
        }
      }
    }
  }
}

class _ClearTasksSheet extends StatefulWidget {
  final RewardedAdManager rewardedAdManager;
  final LocalStorageService storageService;

  const _ClearTasksSheet({
    required this.rewardedAdManager,
    required this.storageService,
  });

  @override
  State<_ClearTasksSheet> createState() => _ClearTasksSheetState();
}

class _ClearTasksSheetState extends State<_ClearTasksSheet> {
  bool _hasWatchedAd = false;
  bool _isLoadingAd = false;

  Future<void> _watchAd() async {
    setState(() => _isLoadingAd = true);

    final rewardEarned = await widget.rewardedAdManager.showAd();

    if (!mounted) return;
    setState(() => _isLoadingAd = false);

    if (!rewardEarned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ad not available or not completed. Please try again.',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w500),
          ),
        ),
      );
      return;
    }

    await widget.storageService.setDeletePermission(true);
    setState(() => _hasWatchedAd = true);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.rw(20),
        vertical: context.rh(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: context.rw(40),
              height: context.rh(4),
              decoration: BoxDecoration(
                color: AppColors.onSurfaceSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: context.rh(16)),
          // Title
          Text(
            'Clear All Tasks',
            style: GoogleFonts.manrope(
              fontSize: context.rf(22),
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: context.rh(12)),
          // Info
          Text(
            _hasWatchedAd
                ? 'You can now delete all tasks. This action cannot be undone.'
                : 'To delete tasks, you must watch a short ad first.',
            style: GoogleFonts.manrope(
              fontSize: context.rf(14),
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceSecondary,
            ),
          ),
          SizedBox(height: context.rh(14)),
          // Info card
          Container(
            padding: EdgeInsets.all(context.rw(14)),
            decoration: BoxDecoration(
              color: _hasWatchedAd
                  ? AppColors.error.withValues(alpha: 0.08)
                  : AppColors.darkAccent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(context.rw(12)),
            ),
            child: Row(
              children: [
                Icon(
                  _hasWatchedAd ? Icons.warning_rounded : Icons.info_rounded,
                  size: context.rw(20),
                  color: _hasWatchedAd ? AppColors.error : AppColors.onSurface,
                ),
                SizedBox(width: context.rw(12)),
                Expanded(
                  child: Text(
                    _hasWatchedAd
                        ? 'This will permanently delete all your tasks!'
                        : 'After watching, you can delete as many times as you want until you restart the app.',
                    style: GoogleFonts.manrope(
                      fontSize: context.rf(13),
                      fontWeight: FontWeight.w600,
                      color: _hasWatchedAd
                          ? AppColors.error
                          : AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rh(20)),
          // Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _isLoadingAd ? null : () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: context.rh(14)),
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
                flex: 2,
                child: GestureDetector(
                  onTap: _isLoadingAd
                      ? null
                      : (_hasWatchedAd
                            ? () => Navigator.pop(context, 'delete')
                            : _watchAd),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: context.rh(14)),
                    decoration: BoxDecoration(
                      color: _hasWatchedAd
                          ? AppColors.error
                          : AppColors.darkAccent,
                      borderRadius: BorderRadius.circular(context.rw(12)),
                    ),
                    child: Center(
                      child: _isLoadingAd
                          ? SizedBox(
                              width: context.rw(20),
                              height: context.rw(20),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _hasWatchedAd
                                      ? Icons.delete_forever_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: context.rw(18),
                                ),
                                SizedBox(width: context.rw(6)),
                                Text(
                                  _hasWatchedAd
                                      ? 'Delete All Tasks'
                                      : 'Watch Ad',
                                  style: GoogleFonts.manrope(
                                    fontSize: context.rf(15),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.rh(8)),
        ],
      ),
    );
  }
}
