import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';

/// Main game screen.
///
/// Accepts either a [levelId] (for regular levels) or [isDaily] flag
/// (for the daily challenge).
class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    this.levelId,
    this.isDaily = false,
  }) : assert(
          isDaily || levelId != null,
          'Either levelId or isDaily must be provided.',
        );

  /// The level to load from the repository.
  final int? levelId;

  /// Whether to load the daily challenge level.
  final bool isDaily;

  @override
  Widget build(BuildContext context) {
    final title = isDaily
        ? AppStrings.homeDaily
        : '${AppStrings.gameLevel} ${levelId ?? ''}';

    return GradientScaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('➡️', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              Text(
                AppStrings.comingSoon,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
