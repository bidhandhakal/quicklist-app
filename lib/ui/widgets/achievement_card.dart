import 'package:flutter/material.dart';
import '../../models/achievement_model.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool showProgress;
  final int? currentProgress;
  final int? requiredProgress;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.showProgress = false,
    this.currentProgress,
    this.requiredProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = achievement.isUnlocked;
    final progress =
        (currentProgress != null &&
            requiredProgress != null &&
            requiredProgress! > 0)
        ? (currentProgress! / requiredProgress!).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: isUnlocked ? 2 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: isUnlocked
                          ? Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        achievement.icon,
                        style: TextStyle(
                          fontSize: 22,
                          color: isUnlocked ? null : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                achievement.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked
                                      ? null
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            if (isUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Unlocked',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isUnlocked
                                ? theme.textTheme.bodySmall?.color
                                : Colors.grey.shade600,
                          ),
                        ),
                        if (isUnlocked && achievement.unlockedAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Lock indicator for locked achievements
                  if (!isUnlocked)
                    Icon(
                      Icons.lock_outline,
                      color: Colors.grey.shade400,
                      size: 24,
                    ),
                ],
              ),

              // Progress bar for locked achievements
              if (!isUnlocked &&
                  showProgress &&
                  currentProgress != null &&
                  requiredProgress != null) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$currentProgress / $requiredProgress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
