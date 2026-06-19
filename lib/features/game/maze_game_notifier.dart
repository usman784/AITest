import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/di/providers.dart';
import 'package:arrow_flow/core/utils/audio_helper.dart';
import 'package:arrow_flow/features/settings/settings_provider.dart';
import 'package:arrow_flow/game/data/maze_level_repository.dart';
import 'package:arrow_flow/game/logic/hint_engine.dart';
import 'package:arrow_flow/game/logic/path_checker.dart';
import 'package:arrow_flow/features/game/maze_game_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MazeGameNotifier
// ─────────────────────────────────────────────────────────────────────────────

class MazeGameNotifier extends StateNotifier<MazeGameState> {
  MazeGameNotifier(this._ref) : super(const MazeGameState());

  final Ref _ref;
  Timer? _ticker;

  // ── Convenience accessors ─────────────────────────────────────────────────

  AudioService get _audio       => _ref.read(audioServiceProvider);
  bool get _hapticsEnabled      => _ref.read(settingsProvider).hapticsEnabled;

  void _haptic(void Function() fn) {
    if (_hapticsEnabled) fn();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadLevel(int packId, int levelId) async {
    state = const MazeGameState(phase: MazeGamePhase.loading);

    // Stop any ambient already playing from a previous level.
    unawaited(_audio.stopAmbient());

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

    // Load arcade SFX pack and start ambient music.
    await _audio.loadSoundPack(SoundPack.arcade);
    unawaited(_audio.playAmbient(AmbientTrack.lofi));
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

      // Level complete: play win chime + strong haptic.
      unawaited(_audio.playSfx(SoundEffect.levelComplete));
      unawaited(_audio.stopAmbient());
      _haptic(HapticFeedback.heavyImpact);

      state = state.copyWith(
        layout:          newLayout,
        pathResult:      pathResult,
        moveCount:       newMoveCount,
        phase:           MazeGamePhase.complete,
        animatingNodeId: nodeId,
        clearHint:       true,
      );
    } else {
      // Regular tap: click sound + selection haptic.
      unawaited(_audio.playSfx(SoundEffect.tapSuccess));
      _haptic(HapticFeedback.selectionClick);

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

    // Hint chime + light haptic.
    unawaited(_audio.playSfx(SoundEffect.hintChime));
    _haptic(HapticFeedback.lightImpact);

    state = state.copyWith(
      hintsUsed:  state.hintsUsed + 1,
      hintNodeId: hintNodeId,
    );
  }

  void pause() {
    if (!state.isPlaying) return;
    _stopTicker();
    unawaited(_audio.pauseAmbient());
    state = state.copyWith(phase: MazeGamePhase.paused);
  }

  void resume() {
    if (!state.isPaused) return;
    state = state.copyWith(phase: MazeGamePhase.playing);
    unawaited(_audio.resumeAmbient());
    _startTicker();
  }

  void resetLevel() {
    final levelData = state.levelData;
    if (levelData == null) return;
    _stopTicker();
    unawaited(_audio.stopAmbient());

    final pathResult = PathChecker.check(levelData.layout);
    state = MazeGameState(
      phase:      MazeGamePhase.playing,
      layout:     levelData.layout,
      levelData:  levelData,
      pathResult: pathResult,
    );
    _startTicker();
    unawaited(_audio.playAmbient(AmbientTrack.lofi));
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
    unawaited(_audio.stopAmbient());
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final mazeGameProvider =
    StateNotifierProvider.autoDispose<MazeGameNotifier, MazeGameState>(
  (ref) => MazeGameNotifier(ref),
);
