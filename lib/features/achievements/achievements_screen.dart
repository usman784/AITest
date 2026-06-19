import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';

/// Achievements screen displaying all unlockable achievements.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const List<_Achievement> _achievements = [
    _Achievement(
      emoji: '🏅',
      name: AppStrings.achievementFirstClear,
      description: AppStrings.achievementFirstClearDesc,
      unlocked: true,
    ),
    _Achievement(
      emoji: '⚡',
      name: AppStrings.achievementSpeedrun,
      description: AppStrings.achievementSpeedrunDesc,
      unlocked: false,
    ),
    _Achievement(
      emoji: '💎',
      name: AppStrings.achievementPerfect,
      description: AppStrings.achievementPerfectDesc,
      unlocked: false,
    ),
    _Achievement(
      emoji: '🌿',
      name: AppStrings.achievementWorld1,
      description: AppStrings.achievementWorld1Desc,
      unlocked: false,
    ),
    _Achievement(
      emoji: '🌆',
      name: AppStrings.achievementWorld2,
      description: AppStrings.achievementWorld2Desc,
      unlocked: false,
    ),
    _Achievement(
      emoji: '💯',
      name: AppStrings.achievementCentury,
      description: AppStrings.achievementCenturyDesc,
      unlocked: false,
    ),
    _Achievement(
      emoji: '🔥',
      name: AppStrings.achievementDailyStreak,
      description: AppStrings.achievementDailyStreakDesc,
      unlocked: false,
    ),
    _Achievement(
      emoji: '🧠',
      name: AppStrings.achievementNoHints,
      description: AppStrings.achievementNoHintsDesc,
      unlocked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.achievementsTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _achievements.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final a = _achievements[i];
            return ListTile(
              tileColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withAlpha(180),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Text(
                a.emoji,
                style: TextStyle(
                  fontSize: 32,
                  color: a.unlocked ? null : Colors.grey,
                ),
              ),
              title: Text(
                a.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: a.unlocked ? null : Colors.grey,
                    ),
              ),
              subtitle: Text(
                a.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: a.unlocked ? null : Colors.grey,
                    ),
              ),
              trailing: Icon(
                a.unlocked ? Icons.check_circle : Icons.lock,
                color: a.unlocked
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Achievement {
  const _Achievement({
    required this.emoji,
    required this.name,
    required this.description,
    required this.unlocked,
  });

  final String emoji;
  final String name;
  final String description;
  final bool unlocked;
}
