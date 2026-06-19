import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/features/level_select/level_select_provider.dart';
import 'package:arrow_flow/features/level_select/widgets/level_cell.dart';

/// Grid of [LevelCell] tiles for the currently selected world.
///
/// Handles the loading spinner, "Coming Soon" placeholder, and the
/// completed all-levels success banner automatically.
class LevelGrid extends ConsumerWidget {
  const LevelGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(levelSelectProvider);
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final accent = ext?.accentColor ?? cs.primary;

    // ── Loading ────────────────────────────────────────────────────────
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ── Coming soon ───────────────────────────────────────────────────
    if (state.isComingSoon) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🚧',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              'Coming Soon',
              style: AppTypography.headlineLarge.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'This world is still being built.\nStay tuned!',
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: cs.onSurface.withAlpha(0x88),
              ),
            ),
          ],
        ),
      );
    }

    // ── Level grid ────────────────────────────────────────────────────
    final levels = state.levels;
    final completedAll =
        levels.every((l) => state.starsFor(state.selectedWorldId, l.id) > 0);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Completed-all banner
        if (completedAll)
          SliverToBoxAdapter(
            child: _CompletedBanner(accent: accent),
          ),

        // Level count header
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spaceLG,
            AppDimensions.spaceMD,
            AppDimensions.spaceLG,
            AppDimensions.spaceSM,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Text(
                  '${levels.length} Levels',
                  style: AppTypography.titleMedium.copyWith(
                    color: cs.onSurface.withAlpha(0xAA),
                  ),
                ),
                const Spacer(),
                _DifficultyLegend(),
              ],
            ),
          ),
        ),

        // Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLG,
          ),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final level = levels[i];
                final stars =
                    state.starsFor(state.selectedWorldId, level.id);
                final isUnlocked = state.isLevelUnlocked(i);
                return LevelCell(
                  level: level,
                  stars: stars,
                  isUnlocked: isUnlocked,
                  index: i,
                );
              },
              childCount: levels.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppDimensions.spaceSM,
              crossAxisSpacing: AppDimensions.spaceSM,
              childAspectRatio: 0.9,
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: AppDimensions.spaceLG),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.spaceLG,
        AppDimensions.spaceMD,
        AppDimensions.spaceLG,
        0,
      ),
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withAlpha(0x33), accent.withAlpha(0x1A)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: accent.withAlpha(0x88)),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 28)),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'World Complete!',
                  style: AppTypography.titleLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'You\'ve cleared every level in this world.',
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(0xAA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const dots = [
      (label: 'Easy', color: Color(0xFF4361EE)),
      (label: 'Med', color: Color(0xFFFFD60A)),
      (label: 'Hard', color: Color(0xFFFF9500)),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: dots.map((d) {
        return Padding(
          padding: const EdgeInsets.only(left: AppDimensions.spaceXS),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: d.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                d.label,
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(0x88),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
