import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';

/// Level-select screen.
///
/// Optionally accepts a [worldId] parameter from the router to scroll
/// directly to a specific world.
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key, this.worldId});

  /// The world to display, or `null` to show all worlds.
  final int? worldId;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.levelSelectTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(
                AppStrings.levelSelectTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              if (worldId != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.levelSelectWorld} $worldId',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
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
