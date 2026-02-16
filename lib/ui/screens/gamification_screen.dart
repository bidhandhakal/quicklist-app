import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final gamificationService = GamificationService.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: gamificationService,
          builder: (context, _) {
            return Column(
              children: [
                // Scrollable header area
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rw(16),
                    vertical: context.rh(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: context.rh(20)),
                      _buildTabs(context),
                    ],
                  ),
                ),
                SizedBox(height: context.rh(8)),
                // Tab content
                Expanded(
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return IndexedStack(
                        index: _tabController.index,
                        children: [
                          _buildOverviewTab(gamificationService),
                          _buildAchievementsTab(gamificationService),
                          _buildStatisticsTab(gamificationService),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Achievements',
                style: GoogleFonts.manrope(
                  color: AppColors.onSurface,
                  fontSize: context.rf(26),
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: context.rh(2)),
              Text(
                'Track your progress',
                style: GoogleFonts.manrope(
                  color: AppColors.onSurfaceSecondary,
                  fontSize: context.rf(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      height: context.rh(42),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(context.rw(12)),
      ),
      padding: EdgeInsets.all(context.rw(4)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.darkAccent,
          borderRadius: BorderRadius.circular(context.rw(10)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.onSurfaceSecondary,
        labelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          fontSize: context.rf(12),
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: context.rf(12),
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_rounded, size: context.rw(14)),
                SizedBox(width: context.rw(5)),
                const Text('Overview'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_rounded, size: context.rw(14)),
                SizedBox(width: context.rw(5)),
                const Text('Badges'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart_rounded, size: context.rw(14)),
                SizedBox(width: context.rw(5)),
                const Text('Stats'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(GamificationService service) {
    final dailyGoal = service.dailyGoal;
    final streak = service.streak;
    final unlockedCount = service.unlockedAchievements.length;
    final totalCount = service.achievements.length;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.rw(16),
        vertical: context.rh(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            'Daily Progress',
            style: GoogleFonts.manrope(
              fontSize: context.rf(18),
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: context.rh(12)),

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
                    Container(
                      width: context.rw(40),
                      height: context.rw(40),
                      decoration: BoxDecoration(
                        color:
                            (dailyGoal.isTodayGoalAchieved
                                    ? Colors.amber
                                    : AppColors.iconDefault)
                                .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        dailyGoal.isTodayGoalAchieved
                            ? Icons.emoji_events
                            : Icons.flag_rounded,
                        color: dailyGoal.isTodayGoalAchieved
                            ? Colors.amber.shade700
                            : AppColors.iconDefault,
                        size: context.rw(20),
                      ),
                    ),
                    SizedBox(width: context.rw(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Goal',
                            style: GoogleFonts.manrope(
                              fontSize: context.rf(15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          SizedBox(height: context.rh(2)),
                          Text(
                            '${dailyGoal.todayCompleted} / ${dailyGoal.targetTasks} tasks',
                            style: GoogleFonts.manrope(
                              fontSize: context.rf(13),
                              fontWeight: FontWeight.w600,
                              color: dailyGoal.isTodayGoalAchieved
                                  ? Colors.amber.shade700
                                  : AppColors.onSurfaceSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _showEditGoalDialog,
                      child: Container(
                        width: context.rw(34),
                        height: context.rw(34),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: AppColors.onSurfaceSecondary,
                          size: context.rw(16),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.rh(14)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.rw(8)),
                  child: LinearProgressIndicator(
                    value: dailyGoal.todayProgress,
                    minHeight: context.rh(8),
                    backgroundColor: AppColors.surfaceSecondary,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      dailyGoal.isTodayGoalAchieved
                          ? Colors.amber
                          : AppColors.primary,
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
                Container(
                  width: context.rw(40),
                  height: context.rw(40),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '🔥',
                      style: TextStyle(fontSize: context.rf(20)),
                    ),
                  ),
                ),
                SizedBox(width: context.rw(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Streak',
                        style: GoogleFonts.manrope(
                          fontSize: context.rf(15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: context.rh(2)),
                      Text(
                        '${streak.currentStreak} ${streak.currentStreak == 1 ? 'day' : 'days'}',
                        style: GoogleFonts.manrope(
                          fontSize: context.rf(22),
                          fontWeight: FontWeight.w800,
                          color: streak.currentStreak > 0
                              ? Colors.orange.shade700
                              : AppColors.onSurfaceSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Best',
                      style: GoogleFonts.manrope(
                        fontSize: context.rf(11),
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceSecondary,
                      ),
                    ),
                    Text(
                      '${streak.longestStreak}d',
                      style: GoogleFonts.manrope(
                        fontSize: context.rf(16),
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.rh(16)),

          // Native Ad
          const NativeAdWidget(screenId: 'gamification_screen_top'),

          // Achievements Summary
          Text(
            'Achievements',
            style: GoogleFonts.manrope(
              fontSize: context.rf(18),
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: context.rh(12)),

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
                    Container(
                      width: context.rw(40),
                      height: context.rw(40),
                      decoration: BoxDecoration(
                        color: AppColors.iconDefault.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.stars,
                        color: AppColors.iconDefault,
                        size: context.rw(20),
                      ),
                    ),
                    SizedBox(width: context.rw(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress',
                            style: GoogleFonts.manrope(
                              fontSize: context.rf(15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          SizedBox(height: context.rh(2)),
                          Text(
                            '$unlockedCount / $totalCount unlocked',
                            style: GoogleFonts.manrope(
                              fontSize: context.rf(13),
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.rh(14)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(context.rw(8)),
                  child: LinearProgressIndicator(
                    value: totalCount > 0 ? unlockedCount / totalCount : 0,
                    minHeight: context.rh(8),
                    backgroundColor: AppColors.surfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(GamificationService service) {
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
            vertical: context.rh(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', count: achievements.length),
                SizedBox(width: context.rw(8)),
                _buildFilterChip(
                  'Unlocked',
                  'unlocked',
                  count: achievements.where((a) => a.isUnlocked).length,
                ),
                SizedBox(width: context.rw(8)),
                _buildFilterChip(
                  'Locked',
                  'locked',
                  count: achievements.where((a) => !a.isUnlocked).length,
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
                    size: context.rw(48),
                    color: AppColors.onSurfaceSecondary,
                  ),
                  SizedBox(height: context.rh(12)),
                  Text(
                    'No achievements found',
                    style: GoogleFonts.manrope(
                      fontSize: context.rf(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurfaceSecondary,
                    ),
                  ),
                  SizedBox(height: context.rh(4)),
                  Text(
                    'Complete tasks to unlock achievements!',
                    style: GoogleFonts.manrope(
                      fontSize: context.rf(13),
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: context.rw(16),
                vertical: context.rh(8),
              ),
              children: [
                if (unlockedAchievements.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: AppColors.onSurface,
                        size: context.rw(20),
                      ),
                      SizedBox(width: context.rw(8)),
                      Text(
                        'Unlocked (${unlockedAchievements.length})',
                        style: GoogleFonts.manrope(
                          fontSize: context.rf(16),
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.rh(12)),
                  ...groupedUnlocked.entries.map(
                    (entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: context.rw(4),
                            bottom: context.rh(8),
                          ),
                          child: Text(
                            _getCategoryName(entry.key),
                            style: GoogleFonts.manrope(
                              fontSize: context.rf(12),
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceSecondary,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (achievement) => Padding(
                            padding: EdgeInsets.only(bottom: context.rh(10)),
                            child: AchievementCard(achievement: achievement),
                          ),
                        ),
                        SizedBox(height: context.rh(8)),
                      ],
                    ),
                  ),
                  SizedBox(height: context.rh(12)),
                ],
                if (lockedAchievements.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: AppColors.onSurfaceSecondary,
                        size: context.rw(20),
                      ),
                      SizedBox(width: context.rw(8)),
                      Text(
                        'Locked (${lockedAchievements.length})',
                        style: GoogleFonts.manrope(
                          fontSize: context.rf(16),
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.rh(12)),
                  ...groupedLocked.entries.map(
                    (entry) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: context.rw(4),
                            bottom: context.rh(8),
                          ),
                          child: Text(
                            _getCategoryName(entry.key),
                            style: GoogleFonts.manrope(
                              fontSize: context.rf(12),
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceSecondary,
                            ),
                          ),
                        ),
                        ...entry.value.map(
                          (achievement) => Padding(
                            padding: EdgeInsets.only(bottom: context.rh(10)),
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
                        SizedBox(height: context.rh(8)),
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

  Widget _buildFilterChip(
    String label,
    String filterValue, {
    required int count,
  }) {
    final isSelected = _achievementFilter == filterValue;
    return GestureDetector(
      onTap: () => setState(() => _achievementFilter = filterValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(14),
          vertical: context.rh(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(context.rw(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          filterValue == 'all' ? label : '$label ($count)',
          style: GoogleFonts.manrope(
            fontSize: context.rf(12),
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.onSurfaceSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(GamificationService service) {
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
      padding: EdgeInsets.symmetric(
        horizontal: context.rw(16),
        vertical: context.rh(8),
      ),
      children: [
        Text(
          'Your Stats',
          style: GoogleFonts.manrope(
            fontSize: context.rf(18),
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        SizedBox(height: context.rh(12)),
        _buildStatCard(
          icon: Icons.task_alt,
          title: 'Total Tasks Completed',
          value: totalCompleted.toString(),
          color: AppColors.iconDefault,
        ),
        SizedBox(height: context.rh(10)),
        _buildStatCard(
          icon: Icons.add_task,
          title: 'Total Tasks Created',
          value: totalCreated.toString(),
          color: AppColors.iconDefault,
        ),
        SizedBox(height: context.rh(10)),
        _buildStatCard(
          icon: Icons.trending_up,
          title: 'Completion Rate',
          value: '$completionRate%',
          color: AppColors.iconDefault,
        ),
        SizedBox(height: context.rh(10)),

        // Native Ad
        const NativeAdWidget(screenId: 'gamification_screen_stats'),
        SizedBox(height: context.rh(10)),

        _buildStatCard(
          icon: Icons.emoji_events,
          title: 'Daily Goals Achieved',
          value: goalsAchieved.toString(),
          color: AppColors.iconDefault,
        ),
        SizedBox(height: context.rh(10)),
        _buildStatCard(
          icon: Icons.calendar_today,
          title: 'Perfect Weeks',
          value: perfectWeeks.toString(),
          color: AppColors.iconDefault,
        ),
        SizedBox(height: context.rh(10)),
        _buildStatCard(
          icon: Icons.stars,
          title: 'Achievements Unlocked',
          value:
              '${service.unlockedAchievements.length} / ${service.achievements.length}',
          color: AppColors.iconDefault,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.rw(AppColors.radiusMD)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: context.rf(13),
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceSecondary,
                    ),
                  ),
                  SizedBox(height: context.rh(4)),
                  Text(
                    value,
                    style: GoogleFonts.manrope(
                      fontSize: context.rf(20),
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
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
