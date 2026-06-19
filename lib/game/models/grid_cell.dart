import 'package:equatable/equatable.dart';
import 'package:arrow_flow/game/models/arrow.dart';

/// An immutable data class representing a single cell on the game grid.
///
/// Each cell knows its position, whether it is highlighted (e.g. as a valid
/// move hint), and which [Arrow] — if any — currently occupies it.
class GridCell extends Equatable {
  const GridCell({
    required this.row,
    required this.col,
    this.occupant,
    this.isHighlighted = false,
    this.isExitCell = false,
  });

  /// Zero-based row index.
  final int row;

  /// Zero-based column index.
  final int col;

  /// The arrow that currently occupies this cell, or `null` if empty.
  final Arrow? occupant;

  /// Whether this cell is highlighted, e.g. as part of a hint overlay.
  final bool isHighlighted;

  /// Whether this cell is an exit cell — arrows that reach here are cleared.
  final bool isExitCell;

  /// Returns a copy of this cell with the given fields replaced.
  GridCell copyWith({
    int? row,
    int? col,
    Arrow? occupant,
    bool clearOccupant = false,
    bool? isHighlighted,
    bool? isExitCell,
  }) {
    return GridCell(
      row: row ?? this.row,
      col: col ?? this.col,
      occupant: clearOccupant ? null : (occupant ?? this.occupant),
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isExitCell: isExitCell ?? this.isExitCell,
    );
  }

  @override
  List<Object?> get props =>
      [row, col, occupant, isHighlighted, isExitCell];

  @override
  String toString() =>
      'GridCell(row: $row, col: $col, occupant: $occupant)';
}
