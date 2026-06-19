import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:arrow_flow/core/constants/app_assets.dart';
import 'package:arrow_flow/game/models/level_data.dart';

/// Loads and caches [WorldData] from bundled JSON asset files.
///
/// Level files live in `assets/levels/`. Each file contains one [WorldData]
/// object with an array of [LevelData] objects.
///
/// Access via the Riverpod `levelRepositoryProvider` defined in
/// `lib/core/di/providers.dart`.
class LevelRepository {
  LevelRepository();

  final Map<int, WorldData> _cache = {};

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Returns the [WorldData] for [worldId], loading from disk if necessary.
  Future<WorldData> getWorld(int worldId) async {
    if (_cache.containsKey(worldId)) return _cache[worldId]!;
    final world = await _loadWorld(worldId);
    _cache[worldId] = world;
    return world;
  }

  /// Returns the [LevelData] for the given [levelId] within [worldId].
  ///
  /// Throws [StateError] when the level is not found.
  Future<LevelData> getLevel(int worldId, int levelId) async {
    final world = await getWorld(worldId);
    return world.levels.firstWhere(
      (l) => l.id == levelId,
      orElse: () => throw StateError(
        'Level $levelId not found in world $worldId.',
      ),
    );
  }

  /// Returns all [LevelData] objects for [worldId], ordered by `id`.
  Future<List<LevelData>> getLevelsForWorld(int worldId) async {
    final world = await getWorld(worldId);
    return List.unmodifiable(world.levels);
  }

  /// Returns today's daily challenge, or `null` when no data is available.
  Future<LevelData?> getDailyChallenge() async {
    try {
      final json = await rootBundle.loadString(AppAssets.dailyChallenges);
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final world = WorldData.fromJson(decoded);
      if (world.levels.isEmpty) return null;
      // Select today's level by day-of-year modulo level count.
      final today = DateTime.now();
      final dayIndex = today.difference(DateTime(today.year)).inDays;
      return world.levels[dayIndex % world.levels.length];
    } catch (_) {
      return null;
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────────

  Future<WorldData> _loadWorld(int worldId) async {
    final assetPath = _assetPath(worldId);
    final json = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return WorldData.fromJson(decoded);
  }

  String _assetPath(int worldId) {
    switch (worldId) {
      case 1:
        return AppAssets.world1Levels;
      case 2:
        return AppAssets.world2Levels;
      default:
        throw ArgumentError('Unknown worldId: $worldId');
    }
  }
}
