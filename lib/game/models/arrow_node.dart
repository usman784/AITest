import 'package:equatable/equatable.dart';

// ── MazeDirection ─────────────────────────────────────────────────────────────

/// Cardinal directions used in the maze game (clockwise order for rotation).
enum MazeDirection { up, right, down, left }

extension MazeDirectionX on MazeDirection {
  /// Next direction when rotating 90° clockwise.
  MazeDirection get rotated => MazeDirection.values[(index + 1) % 4];

  /// Unicode arrow glyph for display.
  String get glyph => const ['↑', '→', '↓', '←'][index];

  /// Row/col delta when following this direction in the maze grid.
  (int dr, int dc) get offset {
    switch (this) {
      case MazeDirection.up:    return (-1,  0);
      case MazeDirection.right: return ( 0,  1);
      case MazeDirection.down:  return ( 1,  0);
      case MazeDirection.left:  return ( 0, -1);
    }
  }

  static MazeDirection fromString(String s) {
    switch (s) {
      case 'up':    return MazeDirection.up;
      case 'right': return MazeDirection.right;
      case 'down':  return MazeDirection.down;
      case 'left':  return MazeDirection.left;
      default:      return MazeDirection.right;
    }
  }
}

// ── ArrowNodeType ─────────────────────────────────────────────────────────────

enum ArrowNodeType {
  /// Entry point — always fixed.
  start,

  /// Exit point — reaching this solves the level.
  exit,

  /// Player can rotate this arrow.
  free,

  /// Pre-set arrow the player cannot change.
  fixed,
}

// ── ArrowNode ─────────────────────────────────────────────────────────────────

/// An immutable node in the maze graph. Each node occupies one grid cell and
/// (if it isn't the EXIT) has a directional arrow.
class ArrowNode extends Equatable {
  const ArrowNode({
    required this.id,
    required this.row,
    required this.col,
    required this.type,
    required this.direction,
  });

  final int id;
  final int row;
  final int col;
  final ArrowNodeType type;
  final MazeDirection direction;

  bool get isFixed => type == ArrowNodeType.fixed || type == ArrowNodeType.start;
  bool get isExit  => type == ArrowNodeType.exit;
  bool get isStart => type == ArrowNodeType.start;
  bool get isFree  => type == ArrowNodeType.free;

  /// Returns a copy with the direction rotated 90° clockwise.
  ArrowNode rotated() => copyWith(direction: direction.rotated);

  /// Returns a copy with the given [direction].
  ArrowNode withDirection(MazeDirection d) => copyWith(direction: d);

  ArrowNode copyWith({
    MazeDirection? direction,
    ArrowNodeType? type,
  }) {
    return ArrowNode(
      id:        id,
      row:       row,
      col:       col,
      type:      type      ?? this.type,
      direction: direction ?? this.direction,
    );
  }

  factory ArrowNode.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'free';
    final ArrowNodeType nodeType;
    switch (typeStr) {
      case 'start': nodeType = ArrowNodeType.start;
      case 'exit':  nodeType = ArrowNodeType.exit;
      case 'fixed': nodeType = ArrowNodeType.fixed;
      default:      nodeType = ArrowNodeType.free;
    }
    return ArrowNode(
      id:        json['id']  as int,
      row:       json['row'] as int,
      col:       json['col'] as int,
      type:      nodeType,
      direction: MazeDirectionX.fromString(json['direction'] as String? ?? 'right'),
    );
  }

  @override
  List<Object?> get props => [id, row, col, type, direction];
}
