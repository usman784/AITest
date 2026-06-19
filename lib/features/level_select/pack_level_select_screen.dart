import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/features/level_select/pack_level_select_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PackLevelSelectScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Displays all 20 levels for a single pack in a 5-column grid.
///
/// Routes: `/levels/:packId`
class PackLevelSelectScreen extends ConsumerWidget {
  const PackLevelSelectScreen({super.key, required this.packId});

  final int packId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(packLevelSelectProvider(packId));

    if (!state.isLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.ink),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.ink,
            size: 20,
          ),
          tooltip: 'Back',
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pack $packId · ${state.packName}',
              style: AppTypography.levelLabel.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              state.difficulty,
              style: AppTypography.difficultyLabel.copyWith(
                color: AppColors.inkLight,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _ProgressRow(
              completed: state.completedCount,
              total: state.levels.length,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMD),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceLG),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: AppDimensions.spaceSM,
            crossAxisSpacing: AppDimensions.spaceSM,
          ),
          itemCount: state.levels.length,
          itemBuilder: (context, i) {
            final cell = state.levels[i];
            return _LevelCell(
              data: cell,
              onTap: cell.state != LevelState.locked
                  ? () => _showLevelDetail(
                        context,
                        cell,
                        packId,
                        state.packName,
                      )
                  : null,
            )
                .animate(delay: Duration(milliseconds: i * 28))
                .fadeIn(duration: 220.ms)
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 280.ms,
                  curve: Curves.easeOutBack,
                );
          },
        ),
      ),
    );
  }

  void _showLevelDetail(
    BuildContext context,
    LevelCellData data,
    int packId,
    String packName,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      builder: (_) => _LevelDetailSheet(
        data: data,
        packId: packId,
        packName: packName,
        onPlay: () {
          Navigator.of(context).pop();
          context.go('/game/$packId/${data.levelId}');
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProgressRow
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: total > 0 ? completed / total : 0,
            backgroundColor: AppColors.divider,
            color: AppColors.ink,
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSM),
        Text(
          '$completed / $total',
          style: AppTypography.statLabel.copyWith(
            color: AppColors.inkLight,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LevelCell
// ─────────────────────────────────────────────────────────────────────────────

class _LevelCell extends StatelessWidget {
  const _LevelCell({required this.data, this.onTap});

  final LevelCellData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lvlState  = data.state;
    final isPerfect = lvlState == LevelState.perfect;
    final isLocked  = lvlState == LevelState.locked;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isPerfect
              ? AppColors.ink
              : isLocked
                  ? AppColors.divider
                  : AppColors.background,
          border: Border.all(
            color: isLocked ? Colors.transparent : AppColors.ink,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocked)
              const Icon(
                Icons.lock_outline,
                size: 18,
                color: AppColors.inkLight,
              )
            else ...[
              Text(
                '${data.levelId}',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isPerfect ? Colors.white : AppColors.ink,
                  height: 1,
                ),
              ),
              if (data.stars > 0) ...[
                const SizedBox(height: 2),
                _StarsRow(stars: data.stars, isPerfect: isPerfect),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StarsRow
// ─────────────────────────────────────────────────────────────────────────────

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.stars, required this.isPerfect});

  final int stars;
  final bool isPerfect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => Icon(
          i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 8,
          color: i < stars
              ? AppColors.hintGold
              : isPerfect
                  ? Colors.white30
                  : AppColors.divider,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LevelDetailSheet
// ─────────────────────────────────────────────────────────────────────────────

class _LevelDetailSheet extends StatelessWidget {
  const _LevelDetailSheet({
    required this.data,
    required this.packId,
    required this.packName,
    required this.onPlay,
  });

  final LevelCellData data;
  final int packId;
  final String packName;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spaceLG,
          AppDimensions.spaceLG,
          AppDimensions.spaceLG,
          AppDimensions.spaceLG,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ─────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppDimensions.spaceLG),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Level number + pack label ────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Level ${data.levelId}', style: AppTypography.heroTitle),
                const Spacer(),
                Text(
                  packName,
                  style: AppTypography.difficultyLabel.copyWith(
                    color: AppColors.inkLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceMD),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppDimensions.spaceMD),

            // ── Stars / play status ──────────────────────────────────────
            Row(
              children: [
                Text(
                  data.stars > 0 ? 'Best: ' : 'Not played yet',
                  style: AppTypography.statLabel.copyWith(
                    color: AppColors.inkLight,
                  ),
                ),
                if (data.stars > 0)
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        i < data.stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 22,
                        color: i < data.stars
                            ? AppColors.hintGold
                            : AppColors.divider,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            // ── Play button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onPlay,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spaceMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                ),
                child: Text(
                  data.stars > 0 ? 'Play Again' : 'Play',
                  style: AppTypography.buttonLabel.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
