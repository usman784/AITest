import 'package:equatable/equatable.dart';

/// An immutable edge in the maze graph connecting two [ArrowNode]s.
///
/// Corridors are bidirectional — a corridor from A to B allows travel in
/// both directions.
class CorridorSegment extends Equatable {
  const CorridorSegment({
    required this.fromId,
    required this.toId,
  });

  final int fromId;
  final int toId;

  /// Returns `true` if this corridor connects node [a] to node [b]
  /// (in either direction).
  bool connects(int a, int b) =>
      (fromId == a && toId == b) || (fromId == b && toId == a);

  factory CorridorSegment.fromJson(Map<String, dynamic> json) {
    return CorridorSegment(
      fromId: json['from'] as int,
      toId:   json['to']   as int,
    );
  }

  @override
  List<Object?> get props => [fromId, toId];
}
