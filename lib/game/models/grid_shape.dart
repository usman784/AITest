import 'package:flutter/material.dart';

/// The supported shapes for the Arrow Flow game grid.
enum GridShape {
  square,
  hexagonal,
  circular,
  diamond,
  star,
}

/// Convenience helpers on [GridShape].
extension GridShapeExtension on GridShape {
  /// Human-readable display name.
  String get displayName {
    switch (this) {
      case GridShape.square:
        return 'Square';
      case GridShape.hexagonal:
        return 'Hexagonal';
      case GridShape.circular:
        return 'Circular';
      case GridShape.diamond:
        return 'Diamond';
      case GridShape.star:
        return 'Star';
    }
  }

  /// Short description shown in the grid-shape picker.
  String get description {
    switch (this) {
      case GridShape.square:
        return 'Classic N×N grid.';
      case GridShape.hexagonal:
        return 'Honeycomb hex grid with 6-directional flow.';
      case GridShape.circular:
        return 'Radial rings — arrows flow outward from the centre.';
      case GridShape.diamond:
        return '45° rotated square grid.';
      case GridShape.star:
        return 'Star-shaped grid with pointed outer cells.';
    }
  }

  /// Minimum supported grid size for this shape.
  int get minGridSize {
    switch (this) {
      case GridShape.square:
        return 4;
      case GridShape.hexagonal:
        return 3;
      case GridShape.circular:
        return 3;
      case GridShape.diamond:
        return 3;
      case GridShape.star:
        return 5;
    }
  }

  /// Maximum supported grid size for this shape.
  int get maxGridSize {
    switch (this) {
      case GridShape.square:
        return 8;
      case GridShape.hexagonal:
        return 7;
      case GridShape.circular:
        return 6;
      case GridShape.diamond:
        return 7;
      case GridShape.star:
        return 7;
    }
  }

  /// Icon representing this shape.
  IconData get icon {
    switch (this) {
      case GridShape.square:
        return Icons.grid_view;
      case GridShape.hexagonal:
        return Icons.hexagon;
      case GridShape.circular:
        return Icons.circle_outlined;
      case GridShape.diamond:
        return Icons.diamond_outlined;
      case GridShape.star:
        return Icons.star_border;
    }
  }

  /// Parses the JSON-safe shape string used in level files.
  static GridShape fromString(String value) {
    switch (value.toLowerCase()) {
      case 'square':
        return GridShape.square;
      case 'hexagonal':
        return GridShape.hexagonal;
      case 'circular':
        return GridShape.circular;
      case 'diamond':
        return GridShape.diamond;
      case 'star':
        return GridShape.star;
      default:
        return GridShape.square;
    }
  }
}
