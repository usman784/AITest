import 'package:arrow_flow/game/models/arrow_node.dart';
import 'package:arrow_flow/game/models/maze_layout.dart';
import 'package:arrow_flow/game/logic/path_checker.dart';

// ── MazeValidationResult ──────────────────────────────────────────────────────

class MazeValidationResult {
  const MazeValidationResult({required this.isValid, this.error});

  final bool isValid;
  final String? error;

  const MazeValidationResult.ok() : isValid = true, error = null;
}

// ── MazeValidator ─────────────────────────────────────────────────────────────

/// Validates that a [MazeLayout] is structurally consistent and solvable.
class MazeValidator {
  MazeValidator._();

  static MazeValidationResult validate(MazeLayout layout) {
    // Required nodes must exist.
    if (layout.nodeById(layout.startNodeId) == null) {
      return const MazeValidationResult(isValid: false, error: 'Missing start node');
    }
    if (layout.nodeById(layout.exitNodeId) == null) {
      return const MazeValidationResult(isValid: false, error: 'Missing exit node');
    }

    // All corridor endpoints must reference existing nodes.
    for (final corridor in layout.corridors) {
      if (layout.nodeById(corridor.fromId) == null) {
        return MazeValidationResult(
          isValid: false,
          error:   'Corridor references missing node ${corridor.fromId}',
        );
      }
      if (layout.nodeById(corridor.toId) == null) {
        return MazeValidationResult(
          isValid: false,
          error:   'Corridor references missing node ${corridor.toId}',
        );
      }
    }

    // At least one arrangement of free arrows must solve the maze.
    if (!_hasSolution(layout)) {
      return const MazeValidationResult(
        isValid: false,
        error:   'No valid solution exists for this layout',
      );
    }

    return const MazeValidationResult.ok();
  }

  /// DFS over every possible direction assignment for free nodes.
  static bool _hasSolution(MazeLayout layout) {
    final freeIds = layout.nodes
        .where((n) => n.isFree)
        .map((n) => n.id)
        .toList();
    return _dfs(layout, freeIds, 0);
  }

  static bool _dfs(MazeLayout layout, List<int> freeIds, int idx) {
    if (idx == freeIds.length) {
      return PathChecker.check(layout).isSolved;
    }
    for (final dir in MazeDirection.values) {
      final next = layout.withNodeDirection(freeIds[idx], dir);
      if (_dfs(next, freeIds, idx + 1)) return true;
    }
    return false;
  }
}
