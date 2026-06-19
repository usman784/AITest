import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/game/data/maze_level_repository.dart';
import 'package:arrow_flow/game/logic/hint_engine.dart';
import 'package:arrow_flow/game/logic/path_checker.dart';
import 'package:arrow_flow/features/game/maze_game_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MazeGameNotifier
// ─────────────────────────────────────────────────────────────────────────────

class MazeGameNotifier extends StateNotifier<MazeGameState> {
  MazeGameNotifier() : super(const MazeGameState());

  Timer? _ticker;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadLevel(int packId, int levelId) async {
    state = const MazeGameState(phase: MazeGamePhase.loading);
    final levelData = await MazeLevelRepository.loadLevel(packId, levelId);
    if (levelData == null) {
      // No JSON for this pack/level yet — remain on loading screen.
      return;
    }
    final pathResult = PathChecker.check(levelData.layout);
    state = MazeGameState(
      phase:      MazeGamePhase.playing,
      layout:     levelData.layout,
      levelData:  levelData,
      pathResult: pathResult,
    );
    _startTicker();
  }

  // ── Player actions ────────────────────────────────────────────────────────

  void tapNode(int nodeId) {
    if (!state.isPlaying) return;
    final layout = state.layout;
    if (layout == null) return;

    final node = layout.nodeById(nodeId);
    if (node == null || node.isFixed) return;

    final newLayout    = layout.withNodeRotated(nodeId);
    final pathResult   = PathChecker.check(newLayout);
    final newMoveCount = state.moveCount + 1;

    if (pathResult.isSolved) {
      _stopTicker();
      state = state.copyWith(
        layout:          newLayout,
        pathResult:      pathResult,
        moveCount:       newMoveCount,
        phase:           MazeGamePhase.complete,
        animatingNodeId: nodeId,
        clearHint:       true,
      );
    } else {
      state = state.copyWith(
        layout:          newLayout,
        pathResult:      pathResult,
        moveCount:       newMoveCount,
        animatingNodeId: nodeId,
        clearHint:       true,
      );
    }
  }

  void clearAnimating() {
    if (state.animatingNodeId != null) {
      state = state.copyWith(clearAnimating: true);
    }
  }

  void useHint() {
    final layout = state.layout;
    if (layout == null || !state.isPlaying) return;
    final hintNodeId = HintEngine.suggest(layout);
    state = state.copyWith(
      hintsUsed: state.hintsUsed + 1,
      hintNodeId: hintNodeId,
    );
  }

  void pause() {
    if (!state.isPlaying) return;
    _stopTicker();
    state = state.copyWith(phase: MazeGamePhase.paused);
  }

  void resume() {
    if (!state.isPaused) return;
    state = state.copyWith(phase: MazeGamePhase.playing);
    _startTicker();
  }

  void resetLevel() {
    final levelData = state.levelData;
    if (levelData == null) return;
    _stopTicker();
    final pathResult = PathChecker.check(levelData.layout);
    state = MazeGameState(
      phase:      MazeGamePhase.playing,
      layout:     levelData.layout,
      levelData:  levelData,
      pathResult: pathResult,
    );
    _startTicker();
  }

  // ── Timer ────────────────────────────────────────────────────────────────

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPlaying) return;
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final mazeGameProvider =
    StateNotifierProvider.autoDispose<MazeGameNotifier, MazeGameState>(
  (ref) => MazeGameNotifier(),
);
