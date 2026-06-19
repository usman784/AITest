import 'package:equatable/equatable.dart';

import 'package:arrow_flow/game/models/maze_layout.dart';

/// A single level in pack-based play.
class MazeLevelData extends Equatable {
  const MazeLevelData({
    required this.id,
    required this.packId,
    required this.layout,
    required this.par,
  });

  /// Level number within the pack (1-based).
  final int id;

  /// Pack this level belongs to (1–10).
  final int packId;

  /// The maze topology and initial arrow directions.
  final MazeLayout layout;

  /// Par move count — achieving this awards 3 stars.
  final int par;

  factory MazeLevelData.fromJson(Map<String, dynamic> json) {
    return MazeLevelData(
      id:     json['id']     as int,
      packId: json['packId'] as int,
      layout: MazeLayout.fromJson(json),
      par:    json['par']    as int,
    );
  }

  @override
  List<Object?> get props => [id, packId, layout, par];
}
