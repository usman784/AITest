import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/di/providers.dart';
import 'package:arrow_flow/core/utils/audio_helper.dart';
import 'package:arrow_flow/core/utils/haptic_helper.dart';
import 'package:arrow_flow/game/data/level_repository.dart';
import 'package:arrow_flow/game/models/arrow.dart';
import 'package:arrow_flow/game/models/game_state.dart';
import 'package:arrow_flow/game/models/level_data.dart';

// ── Notifier ──────────────────────────────────────────────────────────────────

class GameNotifier extends StateNotifier<GameStatus> {
  GameNotifier(this._repo, this._audio) : super(const GameInitial());

  final LevelRepository _repo;
  final AudioService _audio;

  LevelData? _currentLevel;
  Timer? _ticker;
  int _nextSolutionIdx = 0;
  List<int> _solution = [];

  // ── Public accessors ──────────────────────────────────────────────────────

  LevelData? get currentLevel => _currentLevel;

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadLevel(int levelId) async {
    state = const GameLoading();
    try {
      LevelData? found;
      for (final worldId in [1, 2]) {
        try {
          found = await _repo.getLevel(worldId, levelId);
          break;
        } catch (_) {}
      }
      if (found == null) throw StateError('Level $levelId not found.');
      _startGame(found);
    } catch (_) {
      state = const GameInitial();
    }
  }

  Future<void> loadDailyChallenge() async {
    state = const GameLoading();
    try {
      final level = await _repo.getDailyChallenge();
      if (level == null) throw StateError('No daily challenge available.');
      _startGame(level);
    } catch (_) {
      state = const GameInitial();
    }
  }

  void _startGame(LevelData levelData) {
    _currentLevel = levelData;
    _solution = List.unmodifiable(levelData.solution);
    _nextSolutionIdx = 0;

    final arrows = levelData.arrows.map(_arrowFromData).toList();
    final grid = _buildGrid(levelData.gridSize, arrows);

    state = GamePlaying(
      grid: grid,
      arrows: arrows,
      livesRemaining: 3,
      moveCount: 0,
      hintCount: 3,
    );
    _startTicker();
  }

  // ── Player actions ────────────────────────────────────────────────────────

  void tapArrow(int arrowId) {
    if (state is! GamePlaying) return;
    final playing = state as GamePlaying;
    if (playing.isPaused || playing.isComplete) return;

    final isCorrect = _nextSolutionIdx < _solution.length &&
        _solution[_nextSolutionIdx] == arrowId;

    if (isCorrect) {
      _onCorrectTap(playing, arrowId);
    } else {
      _onWrongTap(playing, arrowId);
    }
  }

  void _onCorrectTap(GamePlaying playing, int arrowId) {
    HapticHelper.onArrowSelect();

    final tapped = playing.arrows.firstWhere((a) => a.id == arrowId);
    _playDirectionalSfx(tapped.direction);

    _nextSolutionIdx++;

    final newArrows =
        playing.arrows.where((a) => a.id != arrowId).toList();
    final newGrid = _buildGrid(_currentLevel!.gridSize, newArrows);
    final newMoves = playing.moveCount + 1;

    if (newArrows.isEmpty) {
      // ── Level complete ─────────────────────────────────────────────────
      _stopTicker();
      HapticHelper.onLevelComplete();
      _audio.playSfx(SoundEffect.levelComplete);

      final stars = _calcStars(newMoves, _currentLevel!.par);
      state = GameComplete(
        finalState: playing.copyWith(
          arrows: newArrows,
          grid: newGrid,
          moveCount: newMoves,
          isComplete: true,
          clearHintArrow: true,
        ),
        stars: stars,
        coinsEarned: _currentLevel!.coinReward,
        xpEarned: _currentLevel!.xpReward,
      );
    } else {
      state = playing.copyWith(
        arrows: newArrows,
        grid: newGrid,
        moveCount: newMoves,
        clearErrorArrow: true,
        clearHintArrow: true,
      );
    }
  }

  void _onWrongTap(GamePlaying playing, int arrowId) {
    HapticHelper.onWrongTap();
    _audio.playSfx(SoundEffect.tapError);

    final errorArrow = playing.arrows.firstWhere(
      (a) => a.id == arrowId,
      orElse: () => playing.arrows.first,
    );

    final newLives = playing.livesRemaining - 1;

    if (newLives <= 0) {
      _stopTicker();
      HapticHelper.onLifeLost();
      _audio.playSfx(SoundEffect.lifeLost);
      state = GameOver(finalState: playing.copyWith(livesRemaining: 0));
    } else {
      HapticHelper.onLifeLost();
      _audio.playSfx(SoundEffect.lifeLost);
      state = playing.copyWith(livesRemaining: newLives, errorArrow: errorArrow);

      // Auto-clear error indicator after the shake animation finishes.
      Future.delayed(const Duration(milliseconds: 700), () {
        if (state is GamePlaying) {
          state = (state as GamePlaying).copyWith(clearErrorArrow: true);
        }
      });
    }
  }

  void useHint() {
    if (state is! GamePlaying) return;
    final playing = state as GamePlaying;
    if (playing.hintCount <= 0 || _nextSolutionIdx >= _solution.length) return;

    HapticHelper.onHintUsed();
    _audio.playSfx(SoundEffect.hintChime);

    final hintId = _solution[_nextSolutionIdx];
    state = playing.copyWith(
      hintCount: playing.hintCount - 1,
      hintArrowId: hintId,
    );
  }

  void pause() {
    if (state is! GamePlaying) return;
    _stopTicker();
    state = (state as GamePlaying).copyWith(isPaused: true);
  }

  void resume() {
    if (state is! GamePlaying) return;
    state = (state as GamePlaying).copyWith(isPaused: false);
    _startTicker();
  }

  Future<void> restart() async {
    _stopTicker();
    if (_currentLevel != null) _startGame(_currentLevel!);
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state is GamePlaying) {
        final p = state as GamePlaying;
        if (!p.isPaused && !p.isComplete) {
          state = p.copyWith(elapsedTime: p.elapsedTime + const Duration(seconds: 1));
        }
      }
    });
  }

  void _stopTicker() => _ticker?.cancel();

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Arrow _arrowFromData(ArrowData data) => Arrow(
        id: data.id,
        row: data.row,
        col: data.col,
        direction: _directionOf(data.direction),
      );

  static ArrowDirection _directionOf(String s) {
    switch (s) {
      case 'up':
        return ArrowDirection.up;
      case 'down':
        return ArrowDirection.down;
      case 'left':
        return ArrowDirection.left;
      default:
        return ArrowDirection.right;
    }
  }

  static List<List<Arrow?>> _buildGrid(int size, List<Arrow> arrows) {
    final grid = List.generate(
      size,
      (_) => List<Arrow?>.filled(size, null, growable: false),
      growable: false,
    );
    for (final a in arrows) {
      if (a.row < size && a.col < size) grid[a.row][a.col] = a;
    }
    return grid;
  }

  static int _calcStars(int moves, int par) {
    if (moves <= par) return 3;
    if (moves <= par * 2) return 2;
    return 1;
  }

  void _playDirectionalSfx(ArrowDirection dir) {
    switch (dir) {
      case ArrowDirection.up:
        _audio.playSfx(SoundEffect.arrowExitUp);
      case ArrowDirection.down:
        _audio.playSfx(SoundEffect.arrowExitDown);
      case ArrowDirection.left:
        _audio.playSfx(SoundEffect.arrowExitLeft);
      case ArrowDirection.right:
        _audio.playSfx(SoundEffect.arrowExitRight);
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final gameProvider =
    StateNotifierProvider.autoDispose<GameNotifier, GameStatus>((ref) {
  final repo = ref.watch(levelRepositoryProvider);
  final audio = ref.watch(audioServiceProvider);
  return GameNotifier(repo, audio);
});
