import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/utils/haptic_helper.dart';
import 'package:arrow_flow/game/models/level_data.dart';

/// A single tappable cell in the level grid.
///
/// Shows the level number, difficulty colour, star count and a lock overlay
/// for levels the player has not yet unlocked.
class LevelCell extends StatelessWidget {
  const LevelCell({
    super.key,
    required this.level,
    required this.stars,
    required this.isUnlocked,
    required this.index,
  });

  final LevelData level;

  /// Stars earned for this level (0 = not completed, 1–3).
  final int stars;

  /// Whether the player can tap this cell.
  final bool isUnlocked;

  /// Position in the grid — used to stagger the entrance animation.
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              HapticHelper.onUiTap();
              context.go('/game/${level.id}');
            }
          : null,
      child: _CellContent(
        level: level,
        stars: stars,
        isUnlocked: isUnlocked,
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 30 * (index % 20)),
            duration: 300.ms,
          )
          .scale(
            begin: const Offset(0.85, 0.85),
            end: const Offset(1, 1),
            delay: Duration(milliseconds: 30 * (index % 20)),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cell appearance
// ─────────────────────────────────────────────────────────────────────────────

class _CellContent extends StatelessWidget {
  const _CellContent({
    required this.level,
    required this.stars,
    required this.isUnlocked,
  });

  final LevelData level;
  final int stars;
  final bool isUnlocked;

  static Color _difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'tutorial':
        return const Color(0xFF2DC653);
      case 'easy':
        return const Color(0xFF4361EE);
      case 'medium':
        return const Color(0xFFFFD60A);
      case 'hard':
        return const Color(0xFFFF9500);
      case 'expert':
        return const Color(0xFFEF233C);
      case 'nightmare':
        return const Color(0xFF9D00FF);
      default:
        return const Color(0xFF4361EE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseColor = _difficultyColor(level.difficulty);
    final isCompleted = stars > 0;

    return Stack(
      children: [
        // ── Background ──────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isUnlocked
                  ? [
                      baseColor.withAlpha(0x33),
                      baseColor.withAlpha(0x1A),
                    ]
                  : [
                      cs.surface.withAlpha(0xAA),
                      cs.surface.withAlpha(0x66),
                    ],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(
              color: isCompleted
                  ? baseColor.withAlpha(0xCC)
                  : isUnlocked
                      ? baseColor.withAlpha(0x44)
                      : cs.outline.withAlpha(0x22),
              width: isCompleted ? 2 : 1,
            ),
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: baseColor.withAlpha(0x33),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceXS),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Level number
                Text(
                  level.id.toString(),
                  style: AppTypography.headlineMedium.copyWith(
                    color: isUnlocked
                        ? (isCompleted ? baseColor : cs.onSurface)
                        : cs.onSurface.withAlpha(0x33),
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceXS),

                // 3 star icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final filled = i < stars;
                    return Icon(
                      filled
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 12,
                      color: filled
                          ? const Color(0xFFFFD60A)
                          : cs.onSurface.withAlpha(0x33),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        // ── Lock overlay ────────────────────────────────────────────────
        if (!isUnlocked)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            child: Container(
              color: cs.surface.withAlpha(0xAA),
              child: Center(
                child: Icon(
                  Icons.lock_rounded,
                  size: 20,
                  color: cs.onSurface.withAlpha(0x44),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
