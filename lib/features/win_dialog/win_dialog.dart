import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/widgets/animated_button.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';

/// Win dialog screen shown after a successful level completion.
///
/// Accepts the [levelId] that was just completed so it can show the
/// correct rewards and navigation options.
class WinDialog extends StatelessWidget {
  const WinDialog({super.key, required this.levelId});

  /// The level that was just completed.
  final int levelId;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌟', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 16),
                Text(
                  AppStrings.winTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.gameLevel} $levelId',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),
                AnimatedButton(
                  onTap: () => context.go('/game/${levelId + 1}'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Center(
                    child: Text(
                      AppStrings.winNextLevel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedButton(
                  onTap: () => context.go('/home'),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  child: Center(
                    child: Text(
                      AppStrings.homePlay,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
