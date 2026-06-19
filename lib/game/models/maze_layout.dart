import 'package:equatable/equatable.dart';

import 'package:arrow_flow/game/models/arrow_node.dart';
import 'package:arrow_flow/game/models/corridor_segment.dart';

/// The complete topology of a single maze puzzle: nodes + corridors.
///
/// [MazeLayout] is immutable. To apply a player move (rotate an arrow),
/// call [withNodeRotated] which returns a new layout.
class MazeLayout extends Equatable {
  const MazeLayout({
    required this.nodes,
    required this.corridors,
    required this.gridRows,
    required this.gridCols,
    required this.startNodeId,
    required this.exitNodeId,
  });

  final List<ArrowNode> nodes;
  final List<CorridorSegment> corridors;
  final int gridRows;
  final int gridCols;
  final int startNodeId;
  final int exitNodeId;

  // ── Lookups ──────────────────────────────────────────────────────────────

  ArrowNode? nodeById(int id) {
    for (final n in nodes) {
      if (n.id == id) return n;
    }
    return null;
  }

  ArrowNode? nodeAt(int row, int col) {
    for (final n in nodes) {
      if (n.row == row && n.col == col) return n;
    }
    return null;
  }

  /// Returns `true` when a corridor exists between node [a] and node [b].
  bool hasCorridor(int a, int b) {
    for (final c in corridors) {
      if (c.connects(a, b)) return true;
    }
    return false;
  }

  // ── Mutation helpers ─────────────────────────────────────────────────────

  /// Returns a new layout with [nodeId]'s arrow rotated 90° clockwise.
  MazeLayout withNodeRotated(int nodeId) {
    return _withNodes(
      nodes.map((n) => n.id == nodeId ? n.rotated() : n).toList(),
    );
  }

  /// Returns a new layout with [nodeId]'s direction set to [direction].
  MazeLayout withNodeDirection(int nodeId, MazeDirection direction) {
    return _withNodes(
      nodes.map((n) => n.id == nodeId ? n.withDirection(direction) : n).toList(),
    );
  }

  MazeLayout _withNodes(List<ArrowNode> newNodes) {
    return MazeLayout(
      nodes:       newNodes,
      corridors:   corridors,
      gridRows:    gridRows,
      gridCols:    gridCols,
      startNodeId: startNodeId,
      exitNodeId:  exitNodeId,
    );
  }

  // ── JSON ─────────────────────────────────────────────────────────────────

  factory MazeLayout.fromJson(Map<String, dynamic> json) {
    final nodes = (json['nodes'] as List<dynamic>)
        .map((e) => ArrowNode.fromJson(e as Map<String, dynamic>))
        .toList();
    final corridors = (json['corridors'] as List<dynamic>)
        .map((e) => CorridorSegment.fromJson(e as Map<String, dynamic>))
        .toList();
    return MazeLayout(
      nodes:       nodes,
      corridors:   corridors,
      gridRows:    json['gridRows'] as int,
      gridCols:    json['gridCols'] as int,
      startNodeId: json['startNodeId'] as int,
      exitNodeId:  json['exitNodeId']  as int,
    );
  }

  @override
  List<Object?> get props => [nodes, corridors, gridRows, gridCols, startNodeId, exitNodeId];
}
