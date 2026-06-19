/// JSON-serialisable representation of a single arrow as stored in level files.
class ArrowData {
  const ArrowData({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
  });

  /// Unique arrow identifier within its level.
  final int id;

  /// Zero-based row on the grid.
  final int row;

  /// Zero-based column on the grid.
  final int col;

  /// Direction string, e.g. `"right"`. Parsed to [ArrowDirection] at runtime.
  final String direction;

  factory ArrowData.fromJson(Map<String, dynamic> json) => ArrowData(
        id: json['id'] as int,
        row: json['row'] as int,
        col: json['col'] as int,
        direction: json['direction'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'row': row,
        'col': col,
        'direction': direction,
      };

  @override
  String toString() =>
      'ArrowData(id: $id, row: $row, col: $col, direction: $direction)';
}

/// JSON-serialisable representation of a single level.
class LevelData {
  const LevelData({
    required this.id,
    required this.worldId,
    required this.difficulty,
    required this.gridShape,
    required this.gridSize,
    required this.arrows,
    required this.solution,
    required this.par,
    required this.coinReward,
    required this.xpReward,
  });

  /// Unique level identifier.
  final int id;

  /// The world this level belongs to.
  final int worldId;

  /// Human-readable difficulty label, e.g. `"tutorial"`, `"medium"`.
  final String difficulty;

  /// Grid shape, e.g. `"square"`, `"hexagonal"`.
  final String gridShape;

  /// Number of rows/columns (for square grids) or equivalent measure.
  final int gridSize;

  /// All arrows placed on the grid at the start of the level.
  final List<ArrowData> arrows;

  /// The optimal sequence of arrow IDs for a perfect solve.
  final List<int> solution;

  /// Par move count — achieving this awards 3 stars.
  final int par;

  /// Coins awarded on completion.
  final int coinReward;

  /// XP awarded on completion.
  final int xpReward;

  factory LevelData.fromJson(Map<String, dynamic> json) => LevelData(
        id: json['id'] as int,
        worldId: json['worldId'] as int,
        difficulty: json['difficulty'] as String,
        gridShape: json['gridShape'] as String,
        gridSize: json['gridSize'] as int,
        arrows: (json['arrows'] as List<dynamic>)
            .map((e) => ArrowData.fromJson(e as Map<String, dynamic>))
            .toList(),
        solution: (json['solution'] as List<dynamic>)
            .map((e) => e as int)
            .toList(),
        par: json['par'] as int,
        coinReward: json['coinReward'] as int,
        xpReward: json['xpReward'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'worldId': worldId,
        'difficulty': difficulty,
        'gridShape': gridShape,
        'gridSize': gridSize,
        'arrows': arrows.map((a) => a.toJson()).toList(),
        'solution': solution,
        'par': par,
        'coinReward': coinReward,
        'xpReward': xpReward,
      };

  @override
  String toString() => 'LevelData(id: $id, worldId: $worldId)';
}

/// JSON-serialisable representation of a world (collection of levels).
class WorldData {
  const WorldData({
    required this.world,
    required this.name,
    required this.theme,
    required this.levels,
  });

  /// World number.
  final int world;

  /// Display name, e.g. `"The Meadow"`.
  final String name;

  /// Visual theme name, e.g. `"minimalist"`.
  final String theme;

  /// All levels belonging to this world.
  final List<LevelData> levels;

  factory WorldData.fromJson(Map<String, dynamic> json) => WorldData(
        world: json['world'] as int,
        name: json['name'] as String,
        theme: json['theme'] as String,
        levels: (json['levels'] as List<dynamic>)
            .map((e) => LevelData.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'world': world,
        'name': name,
        'theme': theme,
        'levels': levels.map((l) => l.toJson()).toList(),
      };

  @override
  String toString() => 'WorldData(world: $world, name: $name)';
}
