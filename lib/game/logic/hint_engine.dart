import 'package:arrow_flow/game/models/arrow_node.dart';
import 'package:arrow_flow/game/models/maze_layout.dart';
import 'package:arrow_flow/game/logic/path_checker.dart';

/// Suggests the next arrow node the player should rotate to make progress
/// toward solving the maze.
class HintEngine {
  HintEngine._();

  /// Returns the [ArrowNode.id] of the free arrow the player should rotate
  /// next, or `null` if the maze is already solved or no hint is available.
  ///
  /// Strategy:
  /// 1. If already solved, return null.
  /// 2. For each free node, try setting it to each of the 4 directions.
  ///    Return the first node that, when correctly rotated, leads to a longer
  ///    path or a full solution.
  static int? suggest(MazeLayout layout) {
    final current = PathChecker.check(layout);
    if (current.isSolved) return null;

    final freeNodes = layout.nodes
        .where((n) => n.isFree)
        .toList();
    if (freeNodes.isEmpty) return null;

    // First pass: look for a rotation that immediately solves the level.
    for (final node in freeNodes) {
      for (final dir in MazeDirection.values) {
        if (dir == node.direction) continue;
        final testLayout = layout.withNodeDirection(node.id, dir);
        if (PathChecker.check(testLayout).isSolved) return node.id;
      }
    }

    // Second pass: look for a rotation that extends the path.
    for (final node in freeNodes) {
      for (final dir in MazeDirection.values) {
        if (dir == node.direction) continue;
        final testLayout = layout.withNodeDirection(node.id, dir);
        final result     = PathChecker.check(testLayout);
        if (result.pathNodeIds.length > current.pathNodeIds.length) {
          return node.id;
        }
      }
    }

    // Fallback: return the first free node.
    return freeNodes.first.id;
  }
}
