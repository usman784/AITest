import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/core/utils/haptic_helper.dart';
import 'package:arrow_flow/core/widgets/glass_card.dart';
import 'package:arrow_flow/game/models/level_data.dart';
import 'package:arrow_flow/core/di/providers.dart';

/// Full-width glass card that shows today's daily challenge and a live
/// countdown to when it resets at midnight.
class DailyChallengeCard extends ConsumerWidget {
  const DailyChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<LevelData?>(
      future: ref.read(levelRepositoryProvider).getDailyChallenge(),
      builder: (context, snapshot) {
        final level = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLG,
          ),
          child: _CardContent(
            level: level,
            isLoading: isLoading,
          ),
        )
            .animate()
            .fadeIn(delay: 150.ms, duration: 350.ms)
            .slideY(
              begin: 0.1,
              end: 0,
              delay: 150.ms,
              duration: 350.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card content (StatefulWidget for countdown timer)
// ─────────────────────────────────────────────────────────────────────────────

class _CardContent extends StatefulWidget {
  const _CardContent({required this.level, required this.isLoading});

  final LevelData? level;
  final bool isLoading;

  @override
  State<_CardContent> createState() => _CardContentState();
}

class _CardContentState extends State<_CardContent> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = _timeToMidnight();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _remaining = _timeToMidnight());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _timeToMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final accent = ext?.accentColor ?? cs.primary;
    final level = widget.level;

    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      child: Row(
        children: [
          // ── Left: labels ──────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "DAILY CHALLENGE" tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceSM,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusRound),
                  ),
                  child: Text(
                    'DAILY CHALLENGE',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceXS),

                // Challenge name / loading state
                if (widget.isLoading)
                  Container(
                    height: 20,
                    width: 120,
                    decoration: BoxDecoration(
                      color: cs.outline.withAlpha(0x33),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                  )
                else
                  Text(
                    level != null
                        ? 'Today\'s Puzzle'
                        : 'No Challenge Today',
                    style: AppTypography.titleLarge.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                const SizedBox(height: AppDimensions.spaceXS),

                // Difficulty badge + grid info
                if (level != null)
                  Row(
                    children: [
                      _DifficultyBadge(difficulty: level.difficulty),
                      const SizedBox(width: AppDimensions.spaceXS),
                      Text(
                        '${level.gridSize}×${level.gridSize}',
                        style: AppTypography.bodySmall.copyWith(
                          color: cs.onSurface.withAlpha(0xAA),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: AppDimensions.spaceSM),

                // Countdown
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: cs.onSurface.withAlpha(0x88),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Resets in ${_formatDuration(_remaining)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: cs.onSurface.withAlpha(0x88),
                        fontFeatures: const [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimensions.spaceMD),

          // ── Right: play button ────────────────────────────────────────
          _PlayButton(
            enabled: level != null,
            accent: accent,
            onTap: () {
              HapticHelper.onUiTap();
              context.go('/game/daily');
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final String difficulty;

  Color _color(String d) {
    switch (d.toLowerCase()) {
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
    final color = _color(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(0x22),
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        border: Border.all(color: color.withAlpha(0x88)),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.enabled,
    required this.accent,
    required this.onTap,
  });

  final bool enabled;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: enabled ? accent : Colors.grey.withAlpha(0x44),
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: accent.withAlpha(0x55),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: enabled ? Colors.white : Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}
