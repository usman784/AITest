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

  /// Prevents simultaneous slide animations.
  bool _isAnimating = false;

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
    _isAnimating = false;
    _stopTicker();

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

  // ── Tap mechanic: slide arrow off grid ───────────────────────────────────

  void tapArrow(int arrowId) {
    if (state is! GamePlaying) return;
    if (_isAnimating) return;
    final playing = state as GamePlaying;
    if (playing.isPaused || playing.isComplete) return;

    // Find the tapped arrow (skip already-sliding ones).
    Arrow? tapped;
    for (final a in playing.arrows) {
      if (a.id == arrowId && !a.isSliding) {
        tapped = a;
        break;
      }
    }
    if (tapped == null) return;

    if (canSlide(tapped, playing.grid)) {
      _slideArrow(playing, tapped);
    } else {
      _showBlocked(playing, tapped);
    }
  }

  /// Returns `true` when the path from [arrow] to the grid edge is fully clear.
  ///
  /// Ignores cells whose arrow is already sliding (treated as vacated).
  static bool canSlide(Arrow arrow, List<List<Arrow?>> grid) {
    final size = grid.length;
    switch (arrow.direction) {
      case ArrowDirection.up:
        for (int r = arrow.row - 1; r >= 0; r--) {
          final cell = grid[r][arrow.col];
          if (cell != null && !cell.isSliding) return false;
        }
        return true;
      case ArrowDirection.down:
        for (int r = arrow.row + 1; r < size; r++) {
          final cell = grid[r][arrow.col];
          if (cell != null && !cell.isSliding) return false;
        }
        return true;
      case ArrowDirection.left:
        for (int c = arrow.col - 1; c >= 0; c--) {
          final cell = grid[arrow.row][c];
          if (cell != null && !cell.isSliding) return false;
        }
        return true;
      case ArrowDirection.right:
        for (int c = arrow.col + 1; c < size; c++) {
          final cell = grid[arrow.row][c];
          if (cell != null && !cell.isSliding) return false;
        }
        return true;
    }
  }

  /// Returns the list of cell coords the arrow passes through on its way out,
  /// not including its own cell. Used for path-preview rendering.
  static List<(int row, int col)> pathCells(Arrow arrow, List<List<Arrow?>> grid) {
    final size = grid.length;
    final cells = <(int, int)>[];
    switch (arrow.direction) {
      case ArrowDirection.up:
        for (int r = arrow.row - 1; r >= 0; r--) {
          cells.add((r, arrow.col));
        }
      case ArrowDirection.down:
        for (int r = arrow.row + 1; r < size; r++) {
          cells.add((r, arrow.col));
        }
      case ArrowDirection.left:
        for (int c = arrow.col - 1; c >= 0; c--) {
          cells.add((arrow.row, c));
        }
      case ArrowDirection.right:
        for (int c = arrow.col + 1; c < size; c++) {
          cells.add((arrow.row, c));
        }
    }
    return cells;
  }

  /// Animate the arrow sliding off the grid, then remove it from state.
  Future<void> _slideArrow(GamePlaying playing, Arrow arrow) async {
    _isAnimating = true;
    HapticHelper.onArrowSelect();
    _playDirectionalSfx(arrow.direction);

    // 1. Mark as sliding + remove from grid immediately (it has vacated).
    final slidingArrow = arrow.copyWith(isSliding: true);
    final withSliding = playing.arrows
        .map((a) => a.id == arrow.id ? slidingArrow : a)
        .toList();
    // Grid is rebuilt WITHOUT the sliding arrow so subsequent canSlide checks
    // see this cell as empty.
    final gridWithout = _buildGrid(
      playing.grid.length,
      playing.arrows.where((a) => a.id != arrow.id).toList(),
    );
    state = playing.copyWith(
      arrows: withSliding,
      grid: gridWithout,
      clearHintArrow: true,
      clearHoveredArrow: true,
    );

    // 2. Wait for the slide animation to finish.
    await Future.delayed(const Duration(milliseconds: 380));

    _isAnimating = false;
    if (state is! GamePlaying) return;
    final current = state as GamePlaying;

    // 3. Fully remove the arrow.
    final remaining = current.arrows.where((a) => a.id != arrow.id).toList();
    final newGrid = _buildGrid(current.grid.length, remaining);
    final newMoves = current.moveCount + 1;

    if (remaining.isEmpty) {
      // ── Level complete ──────────────────────────────────────────────────
      _stopTicker();
      HapticHelper.onLevelComplete();
      _audio.playSfx(SoundEffect.levelComplete);

      final stars = _calcStars(newMoves, _currentLevel!.par);
      state = GameComplete(
        finalState: current.copyWith(
          arrows: remaining,
          grid: newGrid,
          moveCount: newMoves,
          isComplete: true,
        ),
        stars: stars,
        coinsEarned: _currentLevel!.coinReward,
        xpEarned: _currentLevel!.xpReward,
      );
    } else {
      state = current.copyWith(
        arrows: remaining,
        grid: newGrid,
        moveCount: newMoves,
      );
    }
  }

  /// Shows a blocked shake animation — the arrow cannot slide yet.
  void _showBlocked(GamePlaying playing, Arrow arrow) {
    HapticHelper.onWrongTap();
    _audio.playSfx(SoundEffect.tapError);

    state = playing.copyWith(errorArrow: arrow);
    Future.delayed(const Duration(milliseconds: 650), () {
      if (state is GamePlaying) {
        state = (state as GamePlaying).copyWith(clearErrorArrow: true);
      }
    });
  }

  // ── Hover / path preview ─────────────────────────────────────────────────

  void startHover(int arrowId) {
    if (state is! GamePlaying || _isAnimating) return;
    state = (state as GamePlaying).copyWith(hoveredArrowId: arrowId);
  }

  void endHover() {
    if (state is GamePlaying) {
      state = (state as GamePlaying).copyWith(clearHoveredArrow: true);
    }
  }

  // ── Hint ─────────────────────────────────────────────────────────────────

  void useHint() {
    if (state is! GamePlaying) return;
    final playing = state as GamePlaying;
    if (playing.hintCount <= 0 || _isAnimating) return;

    // Find any arrow that can currently slide.
    Arrow? slideable;
    for (final a in playing.arrows) {
      if (!a.isSliding && canSlide(a, playing.grid)) {
        slideable = a;
        break;
      }
    }
    if (slideable == null) return;

    HapticHelper.onHintUsed();
    _audio.playSfx(SoundEffect.hintChime);

    state = playing.copyWith(
      hintCount: playing.hintCount - 1,
      hintArrowId: slideable.id,
    );
  }

  // ── Pause / Resume / Restart ─────────────────────────────────────────────

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
    _isAnimating = false;
    if (_currentLevel != null) _startGame(_currentLevel!);
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state is GamePlaying) {
        final p = state as GamePlaying;
        if (!p.isPaused && !p.isComplete) {
          state = p.copyWith(
            elapsedTime: p.elapsedTime + const Duration(seconds: 1),
          );
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

  // ── Static helpers ────────────────────────────────────────────────────────

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

  /// Builds a row-major grid from a flat arrow list.
  /// Sliding arrows are NOT placed in the grid (their cell is treated as empty).
  static List<List<Arrow?>> _buildGrid(int size, List<Arrow> arrows) {
    final grid = List.generate(
      size,
      (_) => List<Arrow?>.filled(size, null, growable: false),
      growable: false,
    );
    for (final a in arrows) {
      if (!a.isSliding && a.row < size && a.col < size) {
        grid[a.row][a.col] = a;
      }
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


// ── Notifier ──────────────────────────────────────────────────────────────────
