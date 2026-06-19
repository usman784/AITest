import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:arrow_flow/game/models/maze_level_data.dart';

/// Loads [MazeLevelData] from `assets/levels/pack_N.json`.
class MazeLevelRepository {
  MazeLevelRepository._();

  // In-memory cache keyed by pack ID.
  static final Map<int, List<MazeLevelData>> _cache = {};

  /// Returns all levels in [packId], loading and caching the JSON if needed.
  static Future<List<MazeLevelData>> loadPack(int packId) async {
    if (_cache.containsKey(packId)) return _cache[packId]!;

    final path = 'assets/levels/pack_$packId.json';
    try {
      final raw     = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final levels  = (decoded['levels'] as List<dynamic>)
          .map((e) => MazeLevelData.fromJson(e as Map<String, dynamic>))
          .toList();
      _cache[packId] = levels;
      return levels;
    } catch (_) {
      // Asset not found for this pack — return empty list.
      return [];
    }
  }

  /// Returns a single level by [packId] + [levelId], or `null` if not found.
  static Future<MazeLevelData?> loadLevel(int packId, int levelId) async {
    final levels = await loadPack(packId);
    for (final level in levels) {
      if (level.id == levelId) return level;
    }
    return null;
  }

  /// Clears the in-memory cache (useful for testing).
  static void clearCache() => _cache.clear();
}
