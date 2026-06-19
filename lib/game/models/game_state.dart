import 'package:equatable/equatable.dart';
import 'package:arrow_flow/game/models/arrow.dart';

/// All possible game status variants.
enum GameStatusType { initial, loading, playing, complete, gameOver }

/// Base class for all game states.
sealed class GameStatus extends Equatable {
  const GameStatus();
}

/// The game has not yet been initialised.
final class GameInitial extends GameStatus {
  const GameInitial();

  @override
  List<Object?> get props => [];
}

/// Level data is being loaded.
final class GameLoading extends GameStatus {
  const GameLoading();

  @override
  List<Object?> get props => [];
}

/// The player is actively playing the level.
final class GamePlaying extends GameStatus {
  const GamePlaying({
    required this.grid,
    required this.arrows,
    this.livesRemaining = 3,
    this.moveCount = 0,
    this.hintCount = 3,
    this.isComplete = false,
    this.selectedArrow,
    this.errorArrow,
    this.elapsedTime = Duration.zero,
    this.replayMoves = const [],
    this.isPaused = false,
  });

  /// The 2-D grid, row-major order. Cells can be `null` (empty).
  final List<List<Arrow?>> grid;

  /// Flat list of all arrows currently on the board (not yet cleared).
  final List<Arrow> arrows;

  /// Number of lives remaining. Game over when this reaches 0.
  final int livesRemaining;

  /// Total number of arrow taps made so far.
  final int moveCount;

  /// Remaining hints the player can use.
  final int hintCount;

  /// Whether all arrows have been cleared.
  final bool isComplete;

  /// The currently selected arrow, if any.
  final Arrow? selectedArrow;

  /// The arrow that caused the most recent error (used for shake animation).
  final Arrow? errorArrow;

  /// How long the player has been playing this level.
  final Duration elapsedTime;

  /// Sequence of move IDs recorded so far (used for replay mode).
  final List<int> replayMoves;

  /// Whether the game is paused.
  final bool isPaused;

  /// Returns a copy with the given fields replaced.
  GamePlaying copyWith({
    List<List<Arrow?>>? grid,
    List<Arrow>? arrows,
    int? livesRemaining,
    int? moveCount,
    int? hintCount,
    bool? isComplete,
    Arrow? selectedArrow,
    bool clearSelectedArrow = false,
    Arrow? errorArrow,
    bool clearErrorArrow = false,
    Duration? elapsedTime,
    List<int>? replayMoves,
    bool? isPaused,
  }) {
    return GamePlaying(
      grid: grid ?? this.grid,
      arrows: arrows ?? this.arrows,
      livesRemaining: livesRemaining ?? this.livesRemaining,
      moveCount: moveCount ?? this.moveCount,
      hintCount: hintCount ?? this.hintCount,
      isComplete: isComplete ?? this.isComplete,
      selectedArrow:
          clearSelectedArrow ? null : (selectedArrow ?? this.selectedArrow),
      errorArrow:
          clearErrorArrow ? null : (errorArrow ?? this.errorArrow),
      elapsedTime: elapsedTime ?? this.elapsedTime,
      replayMoves: replayMoves ?? this.replayMoves,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  List<Object?> get props => [
        arrows,
        livesRemaining,
        moveCount,
        hintCount,
        isComplete,
        selectedArrow,
        errorArrow,
        elapsedTime,
        replayMoves,
        isPaused,
      ];
}

/// The player successfully cleared all arrows.
final class GameComplete extends GameStatus {
  const GameComplete({
    required this.finalState,
    required this.stars,
    required this.coinsEarned,
    required this.xpEarned,
  });

  /// The final playing state at the moment of completion.
  final GamePlaying finalState;

  /// Stars awarded: 3 = at/under par, 2 = up to 2× par, 1 = otherwise.
  final int stars;

  /// Coins awarded for this level.
  final int coinsEarned;

  /// XP awarded for this level.
  final int xpEarned;

  @override
  List<Object?> get props => [finalState, stars, coinsEarned, xpEarned];
}

/// The player ran out of lives.
final class GameOver extends GameStatus {
  const GameOver({required this.finalState});

  /// The final playing state at the moment of game over.
  final GamePlaying finalState;

  @override
  List<Object?> get props => [finalState];
}
