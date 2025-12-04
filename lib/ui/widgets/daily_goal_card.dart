import 'package:flutter/material.dart';

class DailyGoalCard extends StatelessWidget {
  final int targetTasks;
  final int completedTasks;
  final VoidCallback onTap;

  const DailyGoalCard({
    super.key,
    required this.targetTasks,
    required this.completedTasks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGoalAchieved = completedTasks >= targetTasks;
    final cardColor = isGoalAchieved ? Colors.amber : theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isGoalAchieved ? Icons.emoji_events : Icons.flag_rounded,
              color: cardColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              '$completedTasks / $targetTasks',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cardColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Daily Goal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cardColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
