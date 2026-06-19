import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/widgets/animated_button.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';

/// Home screen — entry point after the splash / onboarding.
///
/// Displays navigation buttons to all major sections of the app.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⬆️', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 8),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 40),
                _NavButton(
                  emoji: '▶️',
                  label: AppStrings.homePlay,
                  onTap: () => context.go('/level-select'),
                ),
                const SizedBox(height: 12),
                _NavButton(
                  emoji: '📅',
                  label: AppStrings.homeDaily,
                  onTap: () => context.go('/game/daily'),
                ),
                const SizedBox(height: 12),
                _NavButton(
                  emoji: '🎨',
                  label: AppStrings.homeSkinShop,
                  onTap: () => context.go('/skin-shop'),
                ),
                const SizedBox(height: 12),
                _NavButton(
                  emoji: '🏆',
                  label: AppStrings.homeAchievements,
                  onTap: () => context.go('/achievements'),
                ),
                const SizedBox(height: 12),
                _NavButton(
                  emoji: '📊',
                  label: AppStrings.homeLeaderboard,
                  onTap: () => context.go('/leaderboard'),
                ),
                const SizedBox(height: 12),
                _NavButton(
                  emoji: '⚙️',
                  label: AppStrings.homeSettings,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: onTap,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ],
      ),
    );
  }
}
