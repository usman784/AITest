import 'package:arrow_flow/game/models/arrow_node.dart';
import 'package:arrow_flow/game/models/maze_layout.dart';

// ── PathResult ────────────────────────────────────────────────────────────────

/// The result of tracing the arrow-path through a [MazeLayout].
class PathResult {
  const PathResult({
    required this.isSolved,
    required this.pathNodeIds,
    this.deadEndNodeId,
  });

  /// `true` when the path starting at [MazeLayout.startNodeId] reaches
  /// [MazeLayout.exitNodeId] without dead-ends or loops.
  final bool isSolved;

  /// Ordered list of node IDs visited along the path (including start and,
  /// when solved, exit).
  final List<int> pathNodeIds;

  /// The last node visited before the path terminated (not EXIT). `null` when
  /// the level is solved.
  final int? deadEndNodeId;

  const PathResult.empty()
      : isSolved = false,
        pathNodeIds = const [],
        deadEndNodeId = null;
}

// ── PathChecker ───────────────────────────────────────────────────────────────

/// Traces the arrow-path through [layout] and returns a [PathResult].
///
/// Traversal rules:
/// 1. Start at [MazeLayout.startNodeId].
/// 2. Read the current node's [ArrowNode.direction].
/// 3. Compute the target cell = current (row, col) + direction.offset.
/// 4. A corridor must exist between the current node and the target node.
/// 5. Repeat until EXIT is reached (solved) or the path terminates (dead-end
///    or loop).
class PathChecker {
  PathChecker._();

  static PathResult check(MazeLayout layout) {
    final start = layout.nodeById(layout.startNodeId);
    if (start == null) return const PathResult.empty();

    final visited  = <int>{start.id};
    final pathIds  = <int>[start.id];
    var   current  = start;

    while (!current.isExit) {
      final (dr, dc) = current.direction.offset;
      final nextRow  = current.row + dr;
      final nextCol  = current.col + dc;
      final next     = layout.nodeAt(nextRow, nextCol);

      if (next == null) {
        // Arrow points into empty space — dead end.
        return PathResult(
          isSolved:      false,
          pathNodeIds:   pathIds,
          deadEndNodeId: current.id,
        );
      }

      if (!layout.hasCorridor(current.id, next.id)) {
        // No corridor in that direction — dead end (wall).
        return PathResult(
          isSolved:      false,
          pathNodeIds:   pathIds,
          deadEndNodeId: current.id,
        );
      }

      if (visited.contains(next.id)) {
        // Loop detected.
        return PathResult(
          isSolved:      false,
          pathNodeIds:   pathIds,
          deadEndNodeId: current.id,
        );
      }

      visited.add(next.id);
      pathIds.add(next.id);
      current = next;
    }

    return PathResult(
      isSolved:    true,
      pathNodeIds: pathIds,
    );
  }
}
