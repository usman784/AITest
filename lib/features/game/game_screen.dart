import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';
import 'package:arrow_flow/features/game/game_provider.dart';
import 'package:arrow_flow/features/game/widgets/game_grid.dart';
import 'package:arrow_flow/features/game/widgets/game_hud.dart';
import 'package:arrow_flow/features/game/widgets/pause_overlay.dart';
import 'package:arrow_flow/features/home/home_provider.dart';
import 'package:arrow_flow/features/level_select/level_select_provider.dart';
import 'package:arrow_flow/game/models/game_state.dart';

/// Main game screen.
///
/// Accepts either a [levelId] (for regular levels) or [isDaily] flag
/// (for the daily challenge).
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({
    super.key,
    this.levelId,
    this.isDaily = false,
  }) : assert(
          isDaily || levelId != null,
          'Either levelId or isDaily must be provided.',
        );

  /// The level to load from the repository.
  final int? levelId;

  /// Whether to load the daily challenge level.
  final bool isDaily;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _completionHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(gameProvider.notifier);
      if (widget.isDaily) {
        notifier.loadDailyChallenge();
      } else {
        notifier.loadLevel(widget.levelId!);
      }
    });
  }

  // ── Pop scope: pause on Android back ─────────────────────────────────────

  Future<bool> _onWillPop() async {
    final s = ref.read(gameProvider);
    if (s is GamePlaying && !s.isPaused) {
      ref.read(gameProvider.notifier).pause();
      return false;
    }
    return true;
  }

  // ── Handle game complete side-effects ─────────────────────────────────────

  Future<void> _onComplete(GameComplete complete) async {
    if (_completionHandled) return;
    _completionHandled = true;

    final level = ref.read(gameProvider.notifier).currentLevel;
    if (level != null) {
      // Persist stars
      await ref
          .read(levelSelectProvider.notifier)
          .saveLevelStars(level.id, complete.stars);

      // Credit coins + XP to player profile
      await Future.wait([
        ref.read(homeProvider.notifier).addCoins(complete.coinsEarned),
        ref.read(homeProvider.notifier).addXP(complete.xpEarned),
        ref
            .read(homeProvider.notifier)
            .setCurrentLevel(level.worldId, level.id),
      ]);

      if (!mounted) return;
      context.go('/win/${level.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for completion / game-over transitions.
    ref.listen<GameStatus>(gameProvider, (previous, next) {
      if (next is GameComplete) {
        _onComplete(next);
      }
      if (next is GameOver) {
        ref.read(homeProvider.notifier).clearCurrentLevel();
      }
    });

    final gameState = ref.watch(gameProvider);

    // Derive appBar title.
    final title = widget.isDaily
        ? AppStrings.homeDaily
        : '${AppStrings.gameLevel} ${widget.levelId ?? ''}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final allowed = await _onWillPop();
          if (allowed && mounted) context.go('/home');
        }
      },
      child: GradientScaffold(
        body: SafeArea(
          child: _buildBody(context, gameState, title),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GameStatus state, String title) {
    // ── Loading / initial ────────────────────────────────────────────────────
    if (state is GameInitial || state is GameLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ── Playing ──────────────────────────────────────────────────────────────
    if (state is GamePlaying) {
      return Stack(
        children: [
          Column(
            children: [
              GameHud(playing: state),
              Expanded(child: GameGrid(playing: state)),
            ],
          ),
          if (state.isPaused) const PauseOverlay(),
        ],
      );
    }

    // ── Game Over ────────────────────────────────────────────────────────────
    if (state is GameOver) {
      final frozen = state.finalState;
      return Stack(
        children: [
          Column(
            children: [
              GameHud(playing: frozen),
              Expanded(child: GameGrid(playing: frozen)),
            ],
          ),
          const GameOverOverlay(),
        ],
      );
    }

    // ── Complete (transition handled in listener) ─────────────────────────
    if (state is GameComplete) {
      final frozen = state.finalState;
      return Column(
        children: [
          GameHud(playing: frozen),
          Expanded(child: GameGrid(playing: frozen)),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    // Fallback
    return const Center(child: CircularProgressIndicator());
  }
}
