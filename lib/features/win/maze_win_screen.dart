import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MazeWinData  (passed via GoRouter extra)
// ─────────────────────────────────────────────────────────────────────────────

class MazeWinData {
  const MazeWinData({
    required this.packId,
    required this.levelId,
    required this.stars,
    required this.moveCount,
    required this.par,
    required this.elapsedSeconds,
  });

  final int packId;
  final int levelId;
  final int stars;
  final int moveCount;
  final int par;
  final int elapsedSeconds;

  bool get isPerfect => stars == 3 && moveCount <= par;
}

// ─────────────────────────────────────────────────────────────────────────────
// MazeWinScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Full-screen win display shown after a maze level is solved.
///
/// Route: `/win-maze/:packId/:levelId`  extra: [MazeWinData]
class MazeWinScreen extends StatelessWidget {
  const MazeWinScreen({super.key, required this.data});

  final MazeWinData data;

  String _fmtTime(int s) {
    final m   = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppDimensions.spaceXXL),

              // ── Badge ──────────────────────────────────────────────────────
              if (data.isPerfect) ...[
                _PerfectBadge(),
                const SizedBox(height: AppDimensions.spaceMD),
              ],

              // ── Title ──────────────────────────────────────────────────────
              Text(
                'Level Complete!',
                style: AppTypography.heroTitle,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),

              const SizedBox(height: AppDimensions.spaceSM),

              Text(
                'Pack ${data.packId}  ·  Level ${data.levelId}',
                style: AppTypography.statLabel,
                textAlign: TextAlign.center,
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: AppDimensions.spaceXL),

              // ── Stars ───────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      i < data.stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 52,
                      color: i < data.stars ? AppColors.hintGold : AppColors.divider,
                    )
                        .animate(delay: Duration(milliseconds: 200 + i * 120))
                        .scale(
                          begin: const Offset(0.0, 0.0),
                          end: const Offset(1.0, 1.0),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 200.ms),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // ── Stats card ─────────────────────────────────────────────────
              _StatsCard(data: data, fmtTime: _fmtTime)
                  .animate(delay: 600.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0, duration: 300.ms),

              const Spacer(),

              // ── Buttons ────────────────────────────────────────────────────
              _ButtonColumn(data: data)
                  .animate(delay: 800.ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.15, end: 0, duration: 300.ms),

              const SizedBox(height: AppDimensions.spaceLG),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PerfectBadge
// ─────────────────────────────────────────────────────────────────────────────

class _PerfectBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.hintGold,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Text(
        'PERFECT',
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatsCard
// ─────────────────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.data, required this.fmtTime});

  final MazeWinData data;
  final String Function(int) fmtTime;

  @override
  Widget build(BuildContext context) {
    final movesColor = data.moveCount <= data.par
        ? AppColors.successGreen
        : AppColors.ink;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(
            label: 'Moves',
            value: '${data.moveCount}',
            sub:    '/ par ${data.par}',
            valueColor: movesColor,
          ),
          Container(width: 1, height: 48, color: AppColors.divider),
          _Stat(
            label: 'Time',
            value: fmtTime(data.elapsedSeconds),
            sub:   '',
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.sub,
    this.valueColor,
  });

  final String label;
  final String value;
  final String sub;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.bigNumber.copyWith(
            fontSize: 32,
            color: valueColor ?? AppColors.ink,
          ),
        ),
        Text(label, style: AppTypography.statLabel),
        if (sub.isNotEmpty)
          Text(
            sub,
            style: AppTypography.statLabel.copyWith(fontSize: 11),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ButtonColumn
// ─────────────────────────────────────────────────────────────────────────────

class _ButtonColumn extends StatelessWidget {
  const _ButtonColumn({required this.data});

  final MazeWinData data;

  @override
  Widget build(BuildContext context) {
    final isLastLevel = data.levelId >= 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Next Level (primary)
        if (!isLastLevel)
          FilledButton.icon(
            onPressed: () => context.go(
              '/game/${data.packId}/${data.levelId + 1}',
              extra: null,
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Next Level'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          )
        else
          FilledButton.icon(
            onPressed: () => context.go('/levels/${data.packId}'),
            icon: const Icon(Icons.grid_view_rounded),
            label: const Text('Pack Complete!'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          ),

        const SizedBox(height: AppDimensions.spaceSM),

        // Play Again (outlined)
        OutlinedButton.icon(
          onPressed: () => context.go(
            '/game/${data.packId}/${data.levelId}',
            extra: null,
          ),
          icon: const Icon(Icons.replay_rounded, color: AppColors.ink),
          label: Text(
            'Play Again',
            style: AppTypography.buttonLabel,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.ink, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceMD),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spaceXS),

        // Back to levels (text)
        TextButton(
          onPressed: () => context.go('/levels/${data.packId}'),
          child: Text(
            'Back to Levels',
            style: AppTypography.buttonLabel.copyWith(
              color: AppColors.inkLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
