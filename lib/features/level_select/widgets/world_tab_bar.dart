import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/core/utils/haptic_helper.dart';
import 'package:arrow_flow/features/home/home_provider.dart'
    show homeProvider;
import 'package:arrow_flow/features/level_select/level_select_provider.dart';

/// Horizontally scrollable world-selector tab bar.
///
/// Reads unlock status from [homeProvider] and the current selection from
/// [levelSelectProvider]. Tapping an unlocked tab triggers [loadWorld].
class WorldTabBar extends ConsumerWidget {
  const WorldTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectState = ref.watch(levelSelectProvider);
    final homeState = ref.watch(homeProvider);
    final notifier = ref.read(levelSelectProvider.notifier);
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final accent = ext?.accentColor ?? Theme.of(context).colorScheme.primary;

    // Build a quick lookup: worldId → isUnlocked
    final unlockedMap = {
      for (final w in homeState.worlds) w.id: w.isUnlocked,
    };

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(0xCC),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(0x22),
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceSM,
        ),
        itemCount: kWorldInfoList.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppDimensions.spaceXS),
        itemBuilder: (_, i) {
          final world = kWorldInfoList[i];
          final isSelected = world.id == selectState.selectedWorldId;
          final isUnlocked = unlockedMap[world.id] ?? (world.id == 1);

          return _WorldTab(
            world: world,
            isSelected: isSelected,
            isUnlocked: isUnlocked,
            accent: accent,
            index: i,
            onTap: () {
              if (!isUnlocked) return;
              HapticHelper.onUiTap();
              notifier.loadWorld(world.id);
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual tab chip
// ─────────────────────────────────────────────────────────────────────────────

class _WorldTab extends StatelessWidget {
  const _WorldTab({
    required this.world,
    required this.isSelected,
    required this.isUnlocked,
    required this.accent,
    required this.index,
    required this.onTap,
  });

  final LevelWorldInfo world;
  final bool isSelected;
  final bool isUnlocked;
  final Color accent;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceXS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? accent
              : cs.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
            color: isSelected
                ? accent
                : cs.outline.withAlpha(isUnlocked ? 0x55 : 0x22),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withAlpha(0x44),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              world.emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: AppDimensions.spaceXS),
            Text(
              world.name,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : isUnlocked
                        ? cs.onSurface
                        : cs.onSurface.withAlpha(0x44),
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (!isUnlocked) ...[
              const SizedBox(width: AppDimensions.spaceXS),
              Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: cs.onSurface.withAlpha(0x44),
              ),
            ],
          ],
        ),
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 40 * index),
            duration: 250.ms,
          ),
    );
  }
}
