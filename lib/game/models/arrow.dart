import 'package:equatable/equatable.dart';

/// The four cardinal directions an arrow can point.
enum ArrowDirection { up, down, left, right }

/// The visual style applied to an arrow node.
enum ArrowSkinStyle {
  defaultStyle,
  neon,
  wooden,
  metallic,
  galaxy,
  sketch,
}

/// Overlay pattern used in colorblind mode to distinguish arrows by shape.
enum ColorblindPattern {
  none,
  dots,
  stripes,
  crosshatch,
  zigzag,
}

/// An immutable data class representing a single arrow on the game grid.
class Arrow extends Equatable {
  const Arrow({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
    this.isSelected = false,
    this.isMoving = false,
    this.isCleared = false,
    this.isSliding = false,
    this.skinStyle = ArrowSkinStyle.defaultStyle,
    this.colorblindPattern = ColorblindPattern.none,
  });

  /// Unique identifier for this arrow within a level.
  final int id;

  /// Zero-based row index on the grid.
  final int row;

  /// Zero-based column index on the grid.
  final int col;

  /// The direction this arrow is pointing.
  final ArrowDirection direction;

  /// Whether this arrow is currently selected by the player.
  final bool isSelected;

  /// Whether this arrow is currently animating its exit from the grid.
  final bool isMoving;

  /// Whether this arrow has exited the grid and been cleared.
  final bool isCleared;

  /// Whether this arrow is currently sliding off the grid (animation in progress).
  final bool isSliding;

  /// The visual skin applied to this arrow.
  final ArrowSkinStyle skinStyle;

  /// The colorblind-mode pattern overlay.
  final ColorblindPattern colorblindPattern;

  /// Returns a copy of this arrow with the given fields replaced.
  Arrow copyWith({
    int? id,
    int? row,
    int? col,
    ArrowDirection? direction,
    bool? isSelected,
    bool? isMoving,
    bool? isCleared,
    bool? isSliding,
    ArrowSkinStyle? skinStyle,
    ColorblindPattern? colorblindPattern,
  }) {
    return Arrow(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      direction: direction ?? this.direction,
      isSelected: isSelected ?? this.isSelected,
      isMoving: isMoving ?? this.isMoving,
      isCleared: isCleared ?? this.isCleared,
      isSliding: isSliding ?? this.isSliding,
      skinStyle: skinStyle ?? this.skinStyle,
      colorblindPattern: colorblindPattern ?? this.colorblindPattern,
    );
  }

  @override
  List<Object?> get props => [
        id,
        row,
        col,
        direction,
        isSelected,
        isMoving,
        isCleared,
        isSliding,
        skinStyle,
        colorblindPattern,
      ];

  @override
  String toString() =>
      'Arrow(id: $id, row: $row, col: $col, direction: $direction)';
}

// ── ArrowDirection extensions ─────────────────────────────────────────────────

/// Convenience helpers on [ArrowDirection].
extension ArrowDirectionExtension on ArrowDirection {
  /// Unicode arrow symbol for this direction.
  String get symbol {
    switch (this) {
      case ArrowDirection.up:
        return '↑';
      case ArrowDirection.down:
        return '↓';
      case ArrowDirection.left:
        return '←';
      case ArrowDirection.right:
        return '→';
    }
  }

  /// Human-readable label.
  String get label {
    switch (this) {
      case ArrowDirection.up:
        return 'up';
      case ArrowDirection.down:
        return 'down';
      case ArrowDirection.left:
        return 'left';
      case ArrowDirection.right:
        return 'right';
    }
  }

  /// The row delta when moving one step in this direction (−1 = up, +1 = down).
  int get rowDelta {
    switch (this) {
      case ArrowDirection.up:
        return -1;
      case ArrowDirection.down:
        return 1;
      case ArrowDirection.left:
      case ArrowDirection.right:
        return 0;
    }
  }

  /// The column delta when moving one step in this direction (−1 = left, +1 = right).
  int get colDelta {
    switch (this) {
      case ArrowDirection.left:
        return -1;
      case ArrowDirection.right:
        return 1;
      case ArrowDirection.up:
      case ArrowDirection.down:
        return 0;
    }
  }

  /// Converts a JSON-safe direction string (e.g. `"right"`) to [ArrowDirection].
  static ArrowDirection fromString(String value) {
    switch (value.toLowerCase()) {
      case 'up':
        return ArrowDirection.up;
      case 'down':
        return ArrowDirection.down;
      case 'left':
        return ArrowDirection.left;
      case 'right':
        return ArrowDirection.right;
      default:
        throw ArgumentError('Unknown ArrowDirection: $value');
    }
  }
}
