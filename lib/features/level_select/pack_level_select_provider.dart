import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_flow/core/di/providers.dart';

// ── SharedPreferences key helper ──────────────────────────────────────────────

String _levelStarsKey(int packId, int levelId) =>
    'arrows_level_${packId}_$levelId';

// ── Pack metadata (mirrors home_provider.dart constants) ──────────────────────

const int kPackLevelCount = 20;

const List<String> kPackNames = [
  'First Steps', 'Getting Warm', 'Finding Rhythm', 'The Twist',
  'Crossroads',  'Deep Maze',    'The Gauntlet',   'Brain Knot',
  'Obsidian',    'Void',
];

const List<String> kPackDifficulties = [
  'Tutorial', 'Easy', 'Easy / Medium', 'Medium', 'Medium / Hard',
  'Hard', 'Hard / Expert', 'Expert', 'Expert', 'Nightmare',
];

// ── LevelState ────────────────────────────────────────────────────────────────

enum LevelState {
  /// Previous level not yet completed — cell is grey.
  locked,

  /// Unlocked but never played — white cell with ink border.
  open,

  /// Played and completed (1–2 stars).
  completed,

  /// Perfect run (3 stars) — ink-filled cell.
  perfect,
}

// ── LevelCellData ─────────────────────────────────────────────────────────────

@immutable
class LevelCellData extends Equatable {
  const LevelCellData({
    required this.levelId,
    required this.stars,
    required this.isUnlocked,
  });

  final int levelId;

  /// Stars earned: 0 = not played, 1–2 = completed, 3 = perfect.
  final int stars;

  final bool isUnlocked;

  LevelState get state {
    if (!isUnlocked)  return LevelState.locked;
    if (stars == 0)   return LevelState.open;
    if (stars >= 3)   return LevelState.perfect;
    return LevelState.completed;
  }

  @override
  List<Object?> get props => [levelId, stars, isUnlocked];
}

// ── PackLevelSelectState ──────────────────────────────────────────────────────

@immutable
class PackLevelSelectState extends Equatable {
  const PackLevelSelectState({
    required this.packId,
    this.packName   = '',
    this.difficulty = '',
    this.levels     = const [],
    this.isLoaded   = false,
  });

  final int packId;
  final String packName;
  final String difficulty;
  final List<LevelCellData> levels;
  final bool isLoaded;

  int get completedCount => levels.where((l) => l.stars > 0).length;

  PackLevelSelectState copyWith({
    String?              packName,
    String?              difficulty,
    List<LevelCellData>? levels,
    bool?                isLoaded,
  }) {
    return PackLevelSelectState(
      packId:     packId,
      packName:   packName    ?? this.packName,
      difficulty: difficulty  ?? this.difficulty,
      levels:     levels      ?? this.levels,
      isLoaded:   isLoaded    ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props =>
      [packId, packName, difficulty, levels, isLoaded];
}

// ── PackLevelSelectNotifier ───────────────────────────────────────────────────

class PackLevelSelectNotifier
    extends StateNotifier<PackLevelSelectState> {
  PackLevelSelectNotifier(this._prefs, int packId)
      : super(PackLevelSelectState(packId: packId)) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final packId = state.packId;
    final idx    = (packId - 1).clamp(0, kPackNames.length - 1);

    final levels = List.generate(kPackLevelCount, (i) {
      final levelId = i + 1;
      final stars   = _prefs.getInt(_levelStarsKey(packId, levelId)) ?? 0;

      final bool isUnlocked;
      if (levelId == 1) {
        isUnlocked = true;
      } else {
        final prevStars =
            _prefs.getInt(_levelStarsKey(packId, levelId - 1)) ?? 0;
        isUnlocked = prevStars > 0;
      }

      return LevelCellData(
        levelId:    levelId,
        stars:      stars,
        isUnlocked: isUnlocked,
      );
    });

    state = state.copyWith(
      packName:   kPackNames[idx],
      difficulty: kPackDifficulties[idx],
      levels:     levels,
      isLoaded:   true,
    );
  }

  /// Called by the game screen after completing a level.
  Future<void> recordStars(int levelId, int stars) async {
    await _prefs.setInt(_levelStarsKey(state.packId, levelId), stars);
    _load();
  }

  Future<void> refresh() async => _load();
}

// ── Provider ──────────────────────────────────────────────────────────────────

final packLevelSelectProvider = StateNotifierProvider.family<
    PackLevelSelectNotifier, PackLevelSelectState, int>(
  (ref, packId) => PackLevelSelectNotifier(
    ref.watch(sharedPreferencesProvider),
    packId,
  ),
);
