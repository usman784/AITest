import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/core/widgets/animated_button.dart';
import 'package:arrow_flow/features/game/game_provider.dart';

/// Frosted-glass overlay shown when the game is **paused**.
class PauseOverlay extends ConsumerWidget {
  const PauseOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final accent = ext?.accentColor ?? Theme.of(context).colorScheme.primary;

    return _BlurOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⏸', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            AppStrings.gamePaused,
            style: AppTypography.headlineLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXL),
          _OverlayButton(
            label: AppStrings.gameResume,
            icon: Icons.play_arrow_rounded,
            color: accent,
            onTap: notifier.resume,
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          _OverlayButton(
            label: AppStrings.gameRestart,
            icon: Icons.refresh_rounded,
            color: Theme.of(context).colorScheme.secondary,
            onTap: notifier.restart,
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          _OverlayButton(
            label: AppStrings.gameQuit,
            icon: Icons.home_rounded,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(0x88),
            onTap: () => context.go('/home'),
          ),
        ],
      ),
    );
  }
}

/// Frosted-glass overlay shown when the player runs out of lives.
class GameOverOverlay extends ConsumerWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return _BlurOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💔', style: TextStyle(fontSize: 56))
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: AppDimensions.spaceMD),
          Text(
            AppStrings.gameOver,
            style: AppTypography.headlineLarge.copyWith(
              color: const Color(0xFFEF233C),
              fontWeight: FontWeight.w800,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            'Better luck next time!',
            style: AppTypography.bodyLarge.copyWith(
              color: cs.onSurface.withAlpha(0xAA),
            ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: AppDimensions.spaceXL),
          _OverlayButton(
            label: AppStrings.gameTryAgain,
            icon: Icons.refresh_rounded,
            color: const Color(0xFFEF233C),
            onTap: notifier.restart,
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: AppDimensions.spaceMD),
          _OverlayButton(
            label: 'Home',
            icon: Icons.home_rounded,
            color: cs.onSurface.withAlpha(0x88),
            onTap: () => context.go('/home'),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BlurOverlay extends StatelessWidget {
  const _BlurOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        color: Theme.of(context).colorScheme.surface.withAlpha(0xCC),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceLG),
            child: child
                .animate()
                .fadeIn(duration: 250.ms)
                .scale(
                  begin: const Offset(0.92, 0.92),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                ),
          ),
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  const _OverlayButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: AppDimensions.buttonHeight,
      child: AnimatedButton(
        onTap: onTap,
        backgroundColor: color.withAlpha(0x22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppDimensions.spaceSM),
            Text(
              label,
              style: AppTypography.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
