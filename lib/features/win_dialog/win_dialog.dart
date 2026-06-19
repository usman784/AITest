import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/core/widgets/animated_button.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';
import 'package:arrow_flow/features/win_dialog/win_provider.dart';

/// Full-screen win celebration shown after a level is completed.
///
/// Reads the [WinResult] written by [GameScreen] via [winProvider].
/// Falls back gracefully if the provider is empty (e.g. deep-link).
class WinDialog extends ConsumerStatefulWidget {
  const WinDialog({super.key, required this.levelId});

  final int levelId;

  @override
  ConsumerState<WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends ConsumerState<WinDialog> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    // Start confetti after the entrance animations begin.
    WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(winProvider);
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final cs = Theme.of(context).colorScheme;
    final accent = ext?.accentColor ?? cs.primary;

    // Use result data if available, else fall back to placeholder values.
    final stars = result?.stars ?? 1;
    final coins = result?.coinsEarned ?? 0;
    final xp = result?.xpEarned ?? 0;
    final moves = result?.moveCount ?? 0;
    final elapsed = result?.elapsedTime ?? Duration.zero;
    final isPerfect = result?.isPerfect ?? false;

    return GradientScaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // ── Confetti ────────────────────────────────────────────────────
            ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.06,
              numberOfParticles: 30,
              gravity: 0.35,
              colors: const [
                Color(0xFFFFD60A),
                Color(0xFF4FC3F7),
                Color(0xFF81C784),
                Color(0xFFFF006E),
                Color(0xFF7C3AED),
              ],
            ),

            // ── Main content ─────────────────────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceLG,
                vertical: AppDimensions.spaceMD,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.spaceXL),

                  // ── Trophy ────────────────────────────────────────────────
                  _TrophyIcon(stars: stars, isPerfect: isPerfect),

                  const SizedBox(height: AppDimensions.spaceLG),

                  // ── Title ─────────────────────────────────────────────────
                  Text(
                    isPerfect ? 'Perfect! 🏆' : AppStrings.winTitle,
                    style: AppTypography.headlineLarge.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.2, end: 0, delay: 300.ms),

                  Text(
                    '${AppStrings.gameLevel} ${widget.levelId}',
                    style: AppTypography.bodyLarge.copyWith(
                      color: cs.onSurface.withAlpha(0x88),
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // ── Stars ─────────────────────────────────────────────────
                  _StarsRow(stars: stars),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // ── Rewards card ──────────────────────────────────────────
                  _RewardsCard(
                    coins: coins,
                    xp: xp,
                    moves: moves,
                    elapsed: elapsed,
                    accent: accent,
                  ),

                  const SizedBox(height: AppDimensions.spaceXL),

                  // ── Action buttons ────────────────────────────────────────
                  _ActionButtons(levelId: widget.levelId, accent: accent),

                  const SizedBox(height: AppDimensions.spaceLG),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trophy icon
// ─────────────────────────────────────────────────────────────────────────────

class _TrophyIcon extends StatelessWidget {
  const _TrophyIcon({required this.stars, required this.isPerfect});

  final int stars;
  final bool isPerfect;

  @override
  Widget build(BuildContext context) {
    final emoji = isPerfect
        ? '🏆'
        : stars == 3
            ? '🌟'
            : stars == 2
                ? '⭐'
                : '✨';

    return Text(
      emoji,
      style: const TextStyle(fontSize: 88),
    )
        .animate()
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stars row
// ─────────────────────────────────────────────────────────────────────────────

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < stars;
        final delay = (400 + i * 150).ms;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXS),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: filled
                ? SemanticColors.coinsColor
                : Theme.of(context).colorScheme.outline.withAlpha(0x44),
            size: 52,
          )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                delay: delay,
                duration: 500.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(delay: delay, duration: 300.ms),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rewards card
// ─────────────────────────────────────────────────────────────────────────────

class _RewardsCard extends StatelessWidget {
  const _RewardsCard({
    required this.coins,
    required this.xp,
    required this.moves,
    required this.elapsed,
    required this.accent,
  });

  final int coins;
  final int xp;
  final int moves;
  final Duration elapsed;
  final Color accent;

  String _formatTime(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: cs.surface.withAlpha(0xDD),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: cs.outline.withAlpha(0x22)),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(0x11),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Earned row
          Row(
            children: [
              Expanded(
                child: _RewardTile(
                  icon: Icons.monetization_on_rounded,
                  iconColor: SemanticColors.coinsColor,
                  label: AppStrings.winCoinsEarned,
                  value: '+$coins',
                  delay: 700.ms,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: cs.outline.withAlpha(0x22),
              ),
              Expanded(
                child: _RewardTile(
                  icon: Icons.bolt_rounded,
                  iconColor: SemanticColors.xpGradientStart,
                  label: AppStrings.winXpEarned,
                  value: '+$xp',
                  delay: 850.ms,
                ),
              ),
            ],
          ),

          Divider(
            height: AppDimensions.spaceLG * 2,
            color: cs.outline.withAlpha(0x22),
          ),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _RewardTile(
                  icon: Icons.touch_app_rounded,
                  iconColor: cs.primary,
                  label: 'Moves',
                  value: moves.toString(),
                  delay: 1000.ms,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: cs.outline.withAlpha(0x22),
              ),
              Expanded(
                child: _RewardTile(
                  icon: Icons.timer_outlined,
                  iconColor: cs.secondary,
                  label: 'Time',
                  value: _formatTime(elapsed),
                  delay: 1100.ms,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.15, end: 0, delay: 650.ms);
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.delay,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: AppDimensions.spaceXS),
        Text(
          value,
          style: AppTypography.headlineLarge.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: cs.onSurface.withAlpha(0x88),
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action buttons
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({required this.levelId, required this.accent});

  final int levelId;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── Next Level ─────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeight,
          child: AnimatedButton(
            onTap: () {
              ref.read(winProvider.notifier).clear();
              context.go('/game/${levelId + 1}');
            },
            backgroundColor: accent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.winNextLevel,
                  style: AppTypography.titleMedium.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Icon(Icons.arrow_forward_rounded, color: cs.onPrimary, size: 20),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2, end: 0, delay: 1200.ms),

        const SizedBox(height: AppDimensions.spaceMD),

        // ── Replay + Home row ──────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: AppDimensions.buttonHeight,
                child: AnimatedButton(
                  onTap: () {
                    ref.read(winProvider.notifier).clear();
                    context.go('/game/$levelId');
                  },
                  backgroundColor: cs.secondaryContainer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded,
                          color: cs.onSecondaryContainer, size: 20),
                      const SizedBox(width: AppDimensions.spaceXS),
                      Text(
                        AppStrings.winReplay,
                        style: AppTypography.titleMedium.copyWith(
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMD),
            Expanded(
              child: SizedBox(
                height: AppDimensions.buttonHeight,
                child: AnimatedButton(
                  onTap: () {
                    ref.read(winProvider.notifier).clear();
                    context.go('/home');
                  },
                  backgroundColor: cs.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_rounded,
                          color: cs.onSurface.withAlpha(0xCC), size: 20),
                      const SizedBox(width: AppDimensions.spaceXS),
                      Text(
                        'Home',
                        style: AppTypography.titleMedium.copyWith(
                          color: cs.onSurface.withAlpha(0xCC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 1350.ms).slideY(begin: 0.2, end: 0, delay: 1350.ms),
      ],
    );
  }
}
