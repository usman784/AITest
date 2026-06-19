import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/features/game/game_provider.dart';
import 'package:arrow_flow/game/models/game_state.dart';

/// Top HUD bar displayed during active gameplay.
///
/// Shows lives (hearts), move count, elapsed timer, hint button and pause
/// button. All values are read from [GamePlaying].
class GameHud extends ConsumerWidget {
  const GameHud({super.key, required this.playing});

  final GamePlaying playing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final accent = ext?.accentColor ?? cs.primary;

    return Container(
      height: AppDimensions.appBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: cs.surface.withAlpha(0xDD),
        border: Border(
          bottom: BorderSide(color: cs.outline.withAlpha(0x22)),
        ),
      ),
      child: Row(
        children: [
          // ── Lives ────────────────────────────────────────────────────
          _LivesRow(lives: playing.livesRemaining),

          const SizedBox(width: AppDimensions.spaceMD),

          // ── Moves ────────────────────────────────────────────────────
          _HudChip(
            icon: Icons.touch_app_rounded,
            label: playing.moveCount.toString(),
            color: cs.onSurface.withAlpha(0xAA),
          ),

          const Spacer(),

          // ── Timer ────────────────────────────────────────────────────
          _TimerDisplay(elapsed: playing.elapsedTime),

          const Spacer(),

          // ── Hint ─────────────────────────────────────────────────────
          _HintButton(
            count: playing.hintCount,
            accent: accent,
            onTap: notifier.useHint,
          ),

          const SizedBox(width: AppDimensions.spaceXS),

          // ── Pause ────────────────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.pause_rounded),
            color: cs.onSurface,
            onPressed: notifier.pause,
            tooltip: AppStrings.gamePause,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _LivesRow extends StatelessWidget {
  const _LivesRow({required this.lives});

  final int lives;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < lives;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey('life_${i}_$filled'),
            color: filled
                ? SemanticColors.livesColor
                : SemanticColors.livesColor.withAlpha(0x33),
            size: 20,
          ),
        );
      }),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay({required this.elapsed});

  final Duration elapsed;

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_outlined, color: cs.onSurface.withAlpha(0x88), size: 16),
        const SizedBox(width: 3),
        Text(
          _format(elapsed),
          style: AppTypography.monoScore.copyWith(
            color: cs.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _HintButton extends StatelessWidget {
  const _HintButton({
    required this.count,
    required this.accent,
    required this.onTap,
  });

  final int count;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final available = count > 0;
    return GestureDetector(
      onTap: available ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceSM,
          vertical: AppDimensions.spaceXS,
        ),
        decoration: BoxDecoration(
          color: available ? accent.withAlpha(0x22) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
            color: available ? accent.withAlpha(0x88) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              color: available ? accent : Theme.of(context).colorScheme.onSurface.withAlpha(0x33),
              size: 16,
            ),
            const SizedBox(width: 3),
            Text(
              count.toString(),
              style: AppTypography.labelMedium.copyWith(
                color: available
                    ? accent
                    : Theme.of(context).colorScheme.onSurface.withAlpha(0x33),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
