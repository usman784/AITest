import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/features/game/maze_game_notifier.dart';
import 'package:arrow_flow/features/game/maze_game_state.dart';
import 'package:arrow_flow/features/game/maze_painter.dart';
import 'package:arrow_flow/features/level_select/pack_level_select_provider.dart';
import 'package:arrow_flow/features/home/home_provider.dart';
import 'package:arrow_flow/features/win/maze_win_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MazeGameScreen
// ─────────────────────────────────────────────────────────────────────────────

/// The main game screen for pack-based maze levels.
///
/// Route: `/game/:packId/:levelId`
class MazeGameScreen extends ConsumerStatefulWidget {
  const MazeGameScreen({
    super.key,
    required this.packId,
    required this.levelId,
  });

  final int packId;
  final int levelId;

  @override
  ConsumerState<MazeGameScreen> createState() => _MazeGameScreenState();
}

class _MazeGameScreenState extends ConsumerState<MazeGameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  bool _completionHandled = false;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mazeGameProvider.notifier).loadLevel(widget.packId, widget.levelId);
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  // ── Tap on maze canvas ────────────────────────────────────────────────────

  void _onTapCanvas(TapDownDetails details, MazeGameState state, Size canvasSize) {
    if (!state.isPlaying || state.layout == null) return;
    final painter = MazePainter(
      layout:     state.layout!,
      pathResult: state.pathResult,
    );
    final nodeId = painter.findNodeAt(details.localPosition, canvasSize);
    if (nodeId == null) return;
    ref.read(mazeGameProvider.notifier).tapNode(nodeId);
    _bounceCtrl
      ..reset()
      ..forward();
  }

  // ── Completion side-effects ───────────────────────────────────────────────

  Future<void> _handleCompletion(MazeGameState state) async {
    if (_completionHandled) return;
    _completionHandled = true;

    // Persist stars to pack level select provider.
    await ref
        .read(packLevelSelectProvider(widget.packId).notifier)
        .recordStars(widget.levelId, state.stars);

    // Update home pack state.
    await ref
        .read(homePackProvider.notifier)
        .markLevelComplete(widget.packId, widget.levelId);

    if (!mounted) return;
    // Brief delay so the completion animation plays.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    context.go(
      '/win-maze/${widget.packId}/${widget.levelId}',
      extra: MazeWinData(
        packId:         widget.packId,
        levelId:        widget.levelId,
        stars:          state.stars,
        moveCount:      state.moveCount,
        par:            state.levelData?.par ?? 1,
        elapsedSeconds: state.elapsedSeconds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mazeGameProvider);

    // Handle completion.
    if (state.isComplete && !_completionHandled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleCompletion(state));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (state.isPaused) {
            ref.read(mazeGameProvider.notifier).resume();
          } else {
            ref.read(mazeGameProvider.notifier).pause();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: _buildBody(context, state)),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MazeGameState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.ink),
      );
    }

    return Column(
      children: [
        // ── HUD ────────────────────────────────────────────────────────────
        _Hud(
          packId:   widget.packId,
          levelId:  widget.levelId,
          state:    state,
          onBack:   () => context.go('/levels/${widget.packId}'),
          onPause:  () => ref.read(mazeGameProvider.notifier).pause(),
          onResume: () => ref.read(mazeGameProvider.notifier).resume(),
          onHint:   () => ref.read(mazeGameProvider.notifier).useHint(),
          onReset:  () {
            _completionHandled = false;
            ref.read(mazeGameProvider.notifier).resetLevel();
          },
        ),

        // ── Maze canvas ────────────────────────────────────────────────────
        Expanded(
          child: state.layout == null
              ? const SizedBox.shrink()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                    return GestureDetector(
                      onTapDown: (d) => _onTapCanvas(d, state, canvasSize),
                      child: AnimatedBuilder(
                        animation: _bounceCtrl,
                        builder: (_, __) => CustomPaint(
                          size: canvasSize,
                          painter: MazePainter(
                            layout:          state.layout!,
                            pathResult:      state.pathResult,
                            hintNodeId:      state.hintNodeId,
                            animatingNodeId: state.animatingNodeId,
                            animationValue:  _bounceCtrl.value,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // ── Pause overlay ──────────────────────────────────────────────────
        if (state.isPaused) _PauseOverlay(onResume: () => ref.read(mazeGameProvider.notifier).resume()),

        // ── Complete overlay ───────────────────────────────────────────────
        if (state.isComplete) _CompleteOverlay(state: state),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Hud
// ─────────────────────────────────────────────────────────────────────────────

class _Hud extends StatelessWidget {
  const _Hud({
    required this.packId,
    required this.levelId,
    required this.state,
    required this.onBack,
    required this.onPause,
    required this.onResume,
    required this.onHint,
    required this.onReset,
  });

  final int packId;
  final int levelId;
  final MazeGameState state;
  final VoidCallback onBack;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onHint;
  final VoidCallback onReset;

  String _fmtTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceSM,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          // Back
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.ink),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const SizedBox(width: AppDimensions.spaceSM),

          // Level label
          Text(
            'Pack $packId  ·  $levelId',
            style: AppTypography.levelLabel.copyWith(color: AppColors.ink, fontSize: 14),
          ),

          const Spacer(),

          // Timer
          Text(
            _fmtTime(state.elapsedSeconds),
            style: GoogleFonts.spaceMono(
              fontSize: 13,
              color: AppColors.inkLight,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: AppDimensions.spaceMD),

          // Moves
          Text(
            '${state.moveCount}',
            style: AppTypography.statLabel.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          Text(
            ' moves',
            style: AppTypography.statLabel.copyWith(color: AppColors.inkLight, fontSize: 12),
          ),

          const SizedBox(width: AppDimensions.spaceMD),

          // Hint
          IconButton(
            onPressed: onHint,
            icon: const Icon(Icons.lightbulb_outline_rounded, size: 20, color: AppColors.hintGold),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Hint',
          ),

          // Pause / resume
          IconButton(
            onPressed: state.isPaused ? onResume : onPause,
            icon: Icon(
              state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              size: 20,
              color: AppColors.ink,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PauseOverlay
// ─────────────────────────────────────────────────────────────────────────────

class _PauseOverlay extends StatelessWidget {
  const _PauseOverlay({required this.onResume});
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.white.withAlpha(0xEE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Paused', style: AppTypography.heroTitle),
            const SizedBox(height: AppDimensions.spaceLG),
            FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Resume'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CompleteOverlay
// ─────────────────────────────────────────────────────────────────────────────

class _CompleteOverlay extends StatelessWidget {
  const _CompleteOverlay({required this.state});
  final MazeGameState state;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.white.withAlpha(0xF5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Solved!',
              style: AppTypography.heroTitle.copyWith(color: AppColors.successGreen),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  i < state.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 36,
                  color: i < state.stars ? AppColors.hintGold : AppColors.divider,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              '${state.moveCount} moves',
              style: AppTypography.statLabel,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}
