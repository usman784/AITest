import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_flow/core/di/providers.dart';
import 'package:arrow_flow/game/data/level_repository.dart';
import 'package:arrow_flow/game/models/level_data.dart';

// ── SharedPreferences key ─────────────────────────────────────────────────────

/// JSON map: `"worldId_levelId"` → stars earned (0–3).
const String kLevelStarsMap = 'level_stars_map';

// ── Static world display info ─────────────────────────────────────────────────

@immutable
class LevelWorldInfo {
  const LevelWorldInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.hasLevels,
  });

  final int id;
  final String name;
  final String emoji;

  /// `true` when a JSON asset exists for this world.
  final bool hasLevels;
}

/// Full list of worlds shown in the tab bar.
const List<LevelWorldInfo> kWorldInfoList = [
  LevelWorldInfo(id: 1, name: 'The Meadow', emoji: '🌿', hasLevels: true),
  LevelWorldInfo(id: 2, name: 'Neon City', emoji: '🌆', hasLevels: true),
  LevelWorldInfo(id: 3, name: 'The Forest', emoji: '🌲', hasLevels: false),
  LevelWorldInfo(id: 4, name: 'The Sketch Pad', emoji: '✏️', hasLevels: false),
  LevelWorldInfo(id: 5, name: 'Deep Space', emoji: '🚀', hasLevels: false),
  LevelWorldInfo(id: 6, name: 'Frozen Tundra', emoji: '❄️', hasLevels: false),
  LevelWorldInfo(id: 7, name: 'Lava Caves', emoji: '🌋', hasLevels: false),
  LevelWorldInfo(id: 8, name: 'Cloud Kingdom', emoji: '☁️', hasLevels: false),
  LevelWorldInfo(id: 9, name: 'Crystal Caves', emoji: '💎', hasLevels: false),
  LevelWorldInfo(id: 10, name: 'The Final Grid', emoji: '⚡', hasLevels: false),
];

// ── State ─────────────────────────────────────────────────────────────────────

class LevelSelectState extends Equatable {
  const LevelSelectState({
    this.selectedWorldId = 1,
    this.levels = const [],
    this.starsMap = const {},
    this.isLoading = false,
  });

  /// Currently displayed world.
  final int selectedWorldId;

  /// Levels belonging to [selectedWorldId] (empty for "coming soon" worlds).
  final List<LevelData> levels;

  /// Maps `"worldId_levelId"` → stars earned (0 = not completed, 1–3).
  final Map<String, int> starsMap;

  /// `true` while level data is being fetched.
  final bool isLoading;

  // ── Derived ─────────────────────────────────────────────────────────────────

  bool get isComingSoon => !isLoading && levels.isEmpty;

  /// Stars earned for a specific level (0 if never played).
  int starsFor(int worldId, int levelId) =>
      starsMap['${worldId}_$levelId'] ?? 0;

  /// A level is unlocked when the previous level has at least 1 star.
  bool isLevelUnlocked(int index) {
    if (index == 0) return true;
    if (index >= levels.length) return false;
    return starsFor(selectedWorldId, levels[index - 1].id) > 0;
  }

  LevelSelectState copyWith({
    int? selectedWorldId,
    List<LevelData>? levels,
    Map<String, int>? starsMap,
    bool? isLoading,
  }) {
    return LevelSelectState(
      selectedWorldId: selectedWorldId ?? this.selectedWorldId,
      levels: levels ?? this.levels,
      starsMap: starsMap ?? this.starsMap,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [selectedWorldId, levels, starsMap, isLoading];
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class LevelSelectNotifier extends StateNotifier<LevelSelectState> {
  LevelSelectNotifier(this._prefs, this._repo)
      : super(const LevelSelectState()) {
    _loadStars();
    loadWorld(1);
  }

  final SharedPreferences _prefs;
  final LevelRepository _repo;

  // ── Stars persistence ────────────────────────────────────────────────────────

  void _loadStars() {
    final raw = _prefs.getString(kLevelStarsMap);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      state = state.copyWith(
        starsMap: decoded.map((k, v) => MapEntry(k, v as int)),
      );
    } catch (_) {}
  }

  Future<void> saveLevelStars(int levelId, int stars) async {
    final key = '${state.selectedWorldId}_$levelId';
    final newMap = Map<String, int>.from(state.starsMap)..[key] = stars;
    await _prefs.setString(kLevelStarsMap, jsonEncode(newMap));
    state = state.copyWith(starsMap: newMap);
  }

  // ── World loading ────────────────────────────────────────────────────────────

  Future<void> loadWorld(int worldId) async {
    state = state.copyWith(
      selectedWorldId: worldId,
      isLoading: true,
      levels: [],
    );
    try {
      final levels = await _repo.getLevelsForWorld(worldId);
      state = state.copyWith(levels: levels, isLoading: false);
    } catch (_) {
      // No JSON asset for this world — treat as "coming soon".
      state = state.copyWith(levels: [], isLoading: false);
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final levelSelectProvider =
    StateNotifierProvider<LevelSelectNotifier, LevelSelectState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final repo = ref.watch(levelRepositoryProvider);
  return LevelSelectNotifier(prefs, repo);
});
