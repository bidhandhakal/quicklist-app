import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/gamification_service.dart';
import '../../services/ad_service.dart';
import '../../services/interstitial_ad_manager.dart';
import '../../models/achievement_model.dart';
import '../../utils/size_config.dart';
import '../../utils/constants.dart';
import '../widgets/achievement_card.dart';
import '../widgets/native_ad_widget.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _achievementFilter = 'all'; // 'all', 'unlocked', 'locked'
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBannerAd();
    _setupAchievementListener();
  }

  void _loadBannerAd() {
    if (!AdService.isAdsSupported) return;

    _bannerAd = AdService().createBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        _bannerAd = null;
      },
    );
    _bannerAd?.load();
  }

  void _setupAchievementListener() {
    GamificationService.instance.onAchievementUnlocked = () {
      // Show interstitial ad when achievement is unlocked
      InterstitialAdManager().showAd();
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bannerAd?.dispose();
    GamificationService.instance.onAchievementUnlocked = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final theme = Theme.of(context);
    final gamificationService = GamificationService.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievements & Stats'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Achievements'),
            Tab(text: 'Statistics'),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: gamificationService,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(gamificationService, theme),
              _buildAchievementsTab(gamificationService, theme),
              _buildStatisticsTab(gamificationService, theme),
            ],
          );
        },
      ),
      bottomNavigationBar: (_isBannerAdLoaded && _bannerAd != null)
          ? Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
    );
  }

  Widget _buildOverviewTab(GamificationService service, ThemeData theme) {
    final dailyGoal = service.dailyGoal;
    final streak = service.streak;
    final unlockedCount = service.unlockedAchievements.length;
    final totalCount = service.achievements.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.rw(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Goal Card
          Container(
            padding: EdgeInsets.all(context.rw(16)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      dailyGoal.isTodayGoalAchieved
                          ? Icons.emoji_events
                          : Icons.flag_rounded,
                      color: dailyGoal.isTodayGoalAchieved
                          ? Colors.amber
                          : theme.colorScheme.primary,
                      size: context.rw(22),
                    ),
                    SizedBox(width: context.rw(10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Goal',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${dailyGoal.todayCompleted} / ${dailyGoal.targetTasks} tasks',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: dailyGoal.isTodayGoalAchieved
                                  ? Colors.amber.shade700
                                  : theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: dailyGoal.isTodayGoalAchieved
                            ? Colors.amber.shade700
                            : theme.colorScheme.primary,
                      ),
                      onPressed: () => _showEditGoalDialog(),
                      tooltip: 'Edit goal',
                    ),
                  ],
                ),
                SizedBox(height: context.rh(12)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.rw(8)),
                  child: LinearProgressIndicator(
                    value: dailyGoal.todayProgress,
                    minHeight: context.rh(8),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      dailyGoal.isTodayGoalAchieved
                          ? Colors.amber
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rh(12)),

          // Streak Card
          Container(
            padding: EdgeInsets.all(context.rw(16)),
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
                Text('🔥', style: TextStyle(fontSize: context.rf(26))),
                SizedBox(width: context.rw(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Streak',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.rh(4)),
                      Text(
                        '${streak.currentStreak} ${streak.currentStreak == 1 ? 'day' : 'days'}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: streak.currentStreak > 0
                              ? Colors.orange.shade700
                              : Colors.grey,
                        ),
                      ),
                      Text(
                        'Longest: ${streak.longestStreak} ${streak.longestStreak == 1 ? 'day' : 'days'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: streak.currentStreak > 0
                              ? Colors.orange.shade900
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rh(12)),

          // Native Ad (AdMob Compliant)
          const NativeAdWidget(screenId: 'gamification_screen_top'),

          // Achievements Summary
          Container(
            padding: EdgeInsets.all(context.rw(16)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: theme.colorScheme.primary,
                      size: context.rw(22),
                    ),
                    SizedBox(width: context.rw(10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievements',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$unlockedCount / $totalCount unlocked',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.rh(12)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.rw(8)),
                  child: LinearProgressIndicator(
                    value: totalCount > 0 ? unlockedCount / totalCount : 0,
                    minHeight: context.rh(8),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(GamificationService service, ThemeData theme) {
    final achievements = service.achievements;
    var filteredAchievements = achievements;

    if (_achievementFilter == 'unlocked') {
      filteredAchievements = achievements.where((a) => a.isUnlocked).toList();
    } else if (_achievementFilter == 'locked') {
      filteredAchievements = achievements.where((a) => !a.isUnlocked).toList();
    }

    final unlockedAchievements = filteredAchievements
        .where((a) => a.isUnlocked)
        .toList();
    final lockedAchievements = filteredAchievements
        .where((a) => !a.isUnlocked)
        .toList();

    // Group by category
    final Map<AchievementType, List<dynamic>> groupedUnlocked = {};
    final Map<AchievementType, List<dynamic>> groupedLocked = {};

    for (var achievement in unlockedAchievements) {
      groupedUnlocked.putIfAbsent(achievement.type, () => []).add(achievement);
    }

    for (var achievement in lockedAchievements) {
      groupedLocked.putIfAbsent(achievement.type, () => []).add(achievement);
    }

    return Column(
      children: [
        // Native Ad at top of achievements
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.rw(16),
            vertical: context.rh(8),
          ),
          child: NativeAdWidget(screenId: 'gamification_screen_achievements'),
        ),
        // Filter chips
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.rw(16),
            vertical: context.rh(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _achievementFilter == 'all',
                  onSelected: (_) => setState(() => _achievementFilter = 'all'),
                ),
                SizedBox(width: context.rw(8)),
                FilterChip(
                  label: Text(
                    'Unlocked (${achievements.where((a) => a.isUnlocked).length})',
                  ),
                  selected: _achievementFilter == 'unlocked',
                  onSelected: (_) =>
                      setState(() => _achievementFilter = 'unlocked'),
                ),
                SizedBox(width: context.rw(8)),
                FilterChip(
                  label: Text(
                    'Locked (${achievements.where((a) => !a.isUnlocked).length})',
                  ),
                  selected: _achievementFilter == 'locked',
                  onSelected: (_) =>
                      setState(() => _achievementFilter = 'locked'),
                ),
              ],
            ),
          ),
        ),

        // Empty state
        if (filteredAchievements.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: context.rw(60),
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: context.rh(16)),
                  Text(
                    'No achievements found',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: context.rh(8)),
                  Text(
                    'Complete tasks to unlock achievements!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(context.rw(16)),
              children: [
                if (unlockedAchievements.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: theme.colorScheme.primary,
                        size: context.rw(24),
                      ),
                      SizedBox(width: context.rw(8)),
                      Text(
                        'Unlocked (${unlockedAchievements.length})',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...groupedUnlocked.entries.map(
                    (entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            _getCategoryName(entry.key),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (achievement) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AchievementCard(achievement: achievement),
                          ),
                        ),
                        SizedBox(height: context.rh(8)),
                      ],
                    ),
                  ),
                  SizedBox(height: context.rh(16)),
                ],
                if (lockedAchievements.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Colors.grey.shade600,
                        size: context.rw(24),
                      ),
                      SizedBox(width: context.rw(8)),
                      Text(
                        'Locked (${lockedAchievements.length})',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...groupedLocked.entries.map(
                    (entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            _getCategoryName(entry.key),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (achievement) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AchievementCard(
                              achievement: achievement,
                              showProgress: true,
                              currentProgress: _getAchievementProgress(
                                achievement,
                                service,
                              ),
                              requiredProgress: _getAchievementRequirement(
                                achievement,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatisticsTab(GamificationService service, ThemeData theme) {
    final totalCompleted = service.totalTasksCompleted;
    final totalCreated = service.totalTasksCreated;
    final completionRate = totalCreated > 0
        ? ((totalCompleted / totalCreated) * 100).toStringAsFixed(1)
        : '0.0';
    final perfectWeeks = service.perfectWeeksCount;
    final dailyGoal = service.dailyGoal;
    final goalsAchieved = dailyGoal.dailyProgress.values
        .where((count) => count >= dailyGoal.targetTasks)
        .length;

    return ListView(
      padding: EdgeInsets.all(context.rw(16)),
      children: [
        _buildStatCard(
          icon: Icons.task_alt,
          title: 'Total Tasks Completed',
          value: totalCompleted.toString(),
          color: Colors.green,
          theme: theme,
        ),
        SizedBox(height: context.rh(12)),
        _buildStatCard(
          icon: Icons.add_task,
          title: 'Total Tasks Created',
          value: totalCreated.toString(),
          color: Colors.blue,
          theme: theme,
        ),
        SizedBox(height: context.rh(12)),
        _buildStatCard(
          icon: Icons.trending_up,
          title: 'Completion Rate',
          value: '$completionRate%',
          color: Colors.purple,
          theme: theme,
        ),
        SizedBox(height: context.rh(12)),

        // Native Ad
        const NativeAdWidget(screenId: 'gamification_screen_stats'),
        SizedBox(height: context.rh(12)),

        _buildStatCard(
          icon: Icons.emoji_events,
          title: 'Daily Goals Achieved',
          value: goalsAchieved.toString(),
          color: Colors.amber,
          theme: theme,
        ),
        SizedBox(height: context.rh(12)),
        _buildStatCard(
          icon: Icons.calendar_today,
          title: 'Perfect Weeks',
          value: perfectWeeks.toString(),
          color: Colors.orange,
          theme: theme,
        ),
        SizedBox(height: context.rh(12)),
        _buildStatCard(
          icon: Icons.stars,
          title: 'Achievements Unlocked',
          value:
              '${service.unlockedAchievements.length} / ${service.achievements.length}',
          color: Colors.pink,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(context.rw(16)),
        child: Row(
          children: [
            Container(
              width: context.rw(44),
              height: context.rw(44),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: context.rw(22)),
            ),
            SizedBox(width: context.rw(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium),
                  SizedBox(height: context.rh(4)),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGoalDialog() {
    final service = GamificationService.instance;
    final controller = TextEditingController(
      text: service.dailyGoal.targetTasks.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Daily Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target tasks per day',
            hintText: 'Enter number',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newTarget = int.tryParse(controller.text);
              if (newTarget != null && newTarget > 0) {
                service.updateDailyGoalTarget(newTarget);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(AchievementType type) {
    switch (type) {
      case AchievementType.tasksCompleted:
        return '📝 Task Completion';
      case AchievementType.streak:
        return '🔥 Streaks';
      case AchievementType.dailyGoal:
        return '🎯 Daily Goals';
      case AchievementType.perfectWeek:
        return '📅 Perfect Weeks';
      case AchievementType.earlyBird:
        return '🌅 Early Bird';
      case AchievementType.productivity:
        return '⚡ Productivity';
    }
  }

  int? _getAchievementProgress(
    Achievement achievement,
    GamificationService service,
  ) {
    switch (achievement.type) {
      case AchievementType.tasksCompleted:
        return service.totalTasksCompleted;
      case AchievementType.streak:
        return service.streak.longestStreak;
      case AchievementType.dailyGoal:
        return service.dailyGoal.dailyProgress.values
            .where((count) => count >= service.dailyGoal.targetTasks)
            .length;
      case AchievementType.perfectWeek:
        return service.perfectWeeksCount;
      default:
        return null;
    }
  }

  int? _getAchievementRequirement(Achievement achievement) {
    final title = achievement.title.toLowerCase();
    if (title.contains('first')) return 1;
    if (title.contains('10')) return 10;
    if (title.contains('50')) return 50;
    if (title.contains('100')) return 100;
    if (title.contains('7')) return 7;
    if (title.contains('30')) return 30;
    if (title.contains('3')) return 3;
    if (title.contains('5')) return 5;
    return null;
  }
}
