import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:arrow_flow/game/models/maze_layout.dart';
import 'package:arrow_flow/game/models/maze_level_data.dart';
import 'package:arrow_flow/game/logic/path_checker.dart';

// ── MazeGamePhase ─────────────────────────────────────────────────────────────

enum MazeGamePhase { loading, playing, paused, complete }

// ── MazeGameState ─────────────────────────────────────────────────────────────

/// Immutable snapshot of the maze game at any point in time.
@immutable
class MazeGameState extends Equatable {
  const MazeGameState({
    this.phase          = MazeGamePhase.loading,
    this.layout,
    this.levelData,
    this.pathResult,
    this.moveCount      = 0,
    this.hintsUsed      = 0,
    this.elapsedSeconds = 0,
    this.hintNodeId,
    this.animatingNodeId,
  });

  final MazeGamePhase  phase;

  /// Current maze (updated each time the player rotates an arrow).
  final MazeLayout?    layout;

  /// Original level definition (used for reset).
  final MazeLevelData? levelData;

  /// Result of the last path-check (updated after every tap).
  final PathResult?    pathResult;

  final int moveCount;
  final int hintsUsed;
  final int elapsedSeconds;

  /// Node highlighted as the next hint arrow (cleared on any player tap).
  final int? hintNodeId;

  /// Node currently playing its rotate animation (cleared after animation).
  final int? animatingNodeId;

  // ── Derived ───────────────────────────────────────────────────────────────

  bool get isPlaying  => phase == MazeGamePhase.playing;
  bool get isPaused   => phase == MazeGamePhase.paused;
  bool get isComplete => phase == MazeGamePhase.complete;
  bool get isLoading  => phase == MazeGamePhase.loading;

  /// Stars earned on completion (requires [isComplete] == true).
  int get stars {
    if (!isComplete || levelData == null) return 0;
    final par = levelData!.par;
    if (moveCount <= par)       return 3;
    if (moveCount <= par + 2)   return 2;
    return 1;
  }

  MazeGameState copyWith({
    MazeGamePhase?  phase,
    MazeLayout?     layout,
    MazeLevelData?  levelData,
    PathResult?     pathResult,
    int?            moveCount,
    int?            hintsUsed,
    int?            elapsedSeconds,
    int?            hintNodeId,
    int?            animatingNodeId,
    bool            clearHint          = false,
    bool            clearAnimating     = false,
  }) {
    return MazeGameState(
      phase:           phase           ?? this.phase,
      layout:          layout          ?? this.layout,
      levelData:       levelData       ?? this.levelData,
      pathResult:      pathResult      ?? this.pathResult,
      moveCount:       moveCount       ?? this.moveCount,
      hintsUsed:       hintsUsed       ?? this.hintsUsed,
      elapsedSeconds:  elapsedSeconds  ?? this.elapsedSeconds,
      hintNodeId:      clearHint       ? null : (hintNodeId     ?? this.hintNodeId),
      animatingNodeId: clearAnimating  ? null : (animatingNodeId ?? this.animatingNodeId),
    );
  }

  @override
  List<Object?> get props => [
        phase, layout, levelData, pathResult,
        moveCount, hintsUsed, elapsedSeconds,
        hintNodeId, animatingNodeId,
      ];
}
