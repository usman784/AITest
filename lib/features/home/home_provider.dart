import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_flow/core/di/providers.dart';
import 'package:arrow_flow/features/onboarding/onboarding_provider.dart'
    show kPlayerName, kPlayerAvatar;

// ── Shared-Preferences keys ───────────────────────────────────────────────────

const String kPlayerCoins = 'player_coins';
const String kPlayerXP = 'player_xp';
const String kPlayerLives = 'player_lives';
const String kPlayerMaxLives = 'player_max_lives';
const String kLastLifeRefillMs = 'last_life_refill_ms';
const String kCurrentWorldId = 'current_world_id';
const String kCurrentLevelId = 'current_level_id';
const String kWorldProgressMap = 'world_progress_map';

// ── Game-play constants ───────────────────────────────────────────────────────

/// Default number of lives.
const int kDefaultMaxLives = 5;

/// Minutes between automatic life regeneration ticks.
const int kLifeRegenMinutes = 20;

/// XP required to advance one player level.
const int kXpPerLevel = 1000;

// ── WorldInfo ─────────────────────────────────────────────────────────────────

/// Immutable view of a single world's metadata and progress.
@immutable
class WorldInfo extends Equatable {
  const WorldInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gradientStart,
    required this.gradientEnd,
    required this.totalLevels,
    required this.completedLevels,
    required this.isUnlocked,
  });

  final int id;
  final String name;
  final String emoji;
  final Color gradientStart;
  final Color gradientEnd;

  /// Total levels in this world. `0` means the world is "Coming Soon".
  final int totalLevels;

  /// Levels the player has already completed.
  final int completedLevels;

  /// Whether the player can access this world.
  final bool isUnlocked;

  bool get isComingSoon => totalLevels == 0;
  double get progress =>
      totalLevels > 0 ? (completedLevels / totalLevels).clamp(0.0, 1.0) : 0.0;
  int get starCount => completedLevels; // 1 star per completed level (max 3 stars tracked in game screen)

  @override
  List<Object?> get props => [
        id,
        name,
        totalLevels,
        completedLevels,
        isUnlocked,
      ];
}

// ── Static world definitions ──────────────────────────────────────────────────

const _kTotalLevelsPerWorld = 20;

/// Minimum number of completed levels in world N-1 to unlock world N.
const _kUnlockThreshold = 10;

class _WorldDef {
  const _WorldDef({
    required this.id,
    required this.name,
    required this.emoji,
    required this.gradientStart,
    required this.gradientEnd,
    required this.totalLevels,
  });
  final int id;
  final String name;
  final String emoji;
  final Color gradientStart;
  final Color gradientEnd;
  final int totalLevels;
}

const List<_WorldDef> _kWorldDefs = [
  _WorldDef(
    id: 1,
    name: 'The Meadow',
    emoji: '🌿',
    gradientStart: Color(0xFF56AB2F),
    gradientEnd: Color(0xFF1A7431),
    totalLevels: _kTotalLevelsPerWorld,
  ),
  _WorldDef(
    id: 2,
    name: 'Neon City',
    emoji: '🌆',
    gradientStart: Color(0xFF00F5FF),
    gradientEnd: Color(0xFFFF006E),
    totalLevels: _kTotalLevelsPerWorld,
  ),
  _WorldDef(
    id: 3,
    name: 'The Forest',
    emoji: '🌲',
    gradientStart: Color(0xFF1A3A2A),
    gradientEnd: Color(0xFF2D6A4F),
    totalLevels: 0,
  ),
  _WorldDef(
    id: 4,
    name: 'The Sketch Pad',
    emoji: '✏️',
    gradientStart: Color(0xFF8B7355),
    gradientEnd: Color(0xFFF5DEB3),
    totalLevels: 0,
  ),
  _WorldDef(
    id: 5,
    name: 'Deep Space',
    emoji: '🚀',
    gradientStart: Color(0xFF0D0D2B),
    gradientEnd: Color(0xFF3A0CA3),
    totalLevels: 0,
  ),
  _WorldDef(
    id: 6,
    name: 'Frozen Tundra',
    emoji: '❄️',
    gradientStart: Color(0xFF74B9FF),
    gradientEnd: Color(0xFF0984E3),
    totalLevels: 0,
  ),
  _WorldDef(
    id: 7,
    name: 'Lava Caves',
    emoji: '🌋',
    gradientStart: Color(0xFFFF6B35),
    gradientEnd: Color(0xFF8B0000),
    totalLevels: 0,
  ),
  _WorldDef(
    id: 8,
    name: 'Cloud Kingdom',
    emoji: '☁️',
    gradientStart: Color(0xFFAFCBFF),
    gradientEnd: Color(0xFF636FA4),
    totalLevels: 0,
  ),
  _WorldDef(
    id: 9,
    name: 'Crystal Caves',
    emoji: '💎',
    gradientStart: Color(0xFF7B2FF7),
    gradientEnd: Color(0xFF00D4FF),
    totalLevels: 0,
  ),
  _WorldDef(
    id: 10,
    name: 'The Final Grid',
    emoji: '⚡',
    gradientStart: Color(0xFFFFD700),
    gradientEnd: Color(0xFFFF6B35),
    totalLevels: 0,
  ),
];

List<WorldInfo> _buildWorldList(Map<int, int> progress) {
  return List.generate(_kWorldDefs.length, (i) {
    final def = _kWorldDefs[i];
    final completed = progress[def.id] ?? 0;
    final bool isUnlocked;
    if (def.totalLevels == 0) {
      isUnlocked = false; // coming soon
    } else if (def.id == 1) {
      isUnlocked = true; // world 1 always unlocked
    } else {
      final prevDef = _kWorldDefs[i - 1];
      final prevCompleted = progress[prevDef.id] ?? 0;
      isUnlocked = prevCompleted >= _kUnlockThreshold;
    }
    return WorldInfo(
      id: def.id,
      name: def.name,
      emoji: def.emoji,
      gradientStart: def.gradientStart,
      gradientEnd: def.gradientEnd,
      totalLevels: def.totalLevels,
      completedLevels: completed,
      isUnlocked: isUnlocked,
    );
  });
}

// ── HomeState ─────────────────────────────────────────────────────────────────

class HomeState extends Equatable {
  const HomeState({
    this.playerName = 'Player',
    this.playerAvatar = 0,
    this.xp = 0,
    this.coins = 0,
    this.lives = kDefaultMaxLives,
    this.maxLives = kDefaultMaxLives,
    this.currentWorldId = 0,
    this.currentLevelId = 0,
    this.worlds = const [],
    this.isLoaded = false,
  });

  final String playerName;

  /// Index into the avatar icon list (0-7, same as onboarding page 5).
  final int playerAvatar;

  final int xp;
  final int coins;
  final int lives;
  final int maxLives;

  /// World and level of the most-recently started game. Both `0` = none.
  final int currentWorldId;
  final int currentLevelId;

  final List<WorldInfo> worlds;

  /// False until [HomeNotifier.load] completes.
  final bool isLoaded;

  // ── Derived ─────────────────────────────────────────────────────────────────

  bool get hasContinue => currentWorldId > 0 && currentLevelId > 0;

  /// Player level (1-based).
  int get playerLevel => xp ~/ kXpPerLevel + 1;

  /// Progress within the current player level [0.0, 1.0].
  double get levelProgress => (xp % kXpPerLevel) / kXpPerLevel;

  HomeState copyWith({
    String? playerName,
    int? playerAvatar,
    int? xp,
    int? coins,
    int? lives,
    int? maxLives,
    int? currentWorldId,
    int? currentLevelId,
    List<WorldInfo>? worlds,
    bool? isLoaded,
  }) {
    return HomeState(
      playerName: playerName ?? this.playerName,
      playerAvatar: playerAvatar ?? this.playerAvatar,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      currentWorldId: currentWorldId ?? this.currentWorldId,
      currentLevelId: currentLevelId ?? this.currentLevelId,
      worlds: worlds ?? this.worlds,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  List<Object?> get props => [
        playerName,
        playerAvatar,
        xp,
        coins,
        lives,
        maxLives,
        currentWorldId,
        currentLevelId,
        worlds,
        isLoaded,
      ];
}

// ── HomeNotifier ──────────────────────────────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier(this._prefs) : super(const HomeState()) {
    load();
  }

  final SharedPreferences _prefs;

  // ── Load ─────────────────────────────────────────────────────────────────────

  void load() {
    _applyLifeRegen();

    final progressRaw = _prefs.getString(kWorldProgressMap);
    Map<int, int> progress = {};
    if (progressRaw != null) {
      try {
        final decoded = jsonDecode(progressRaw) as Map<String, dynamic>;
        progress = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
      } catch (_) {}
    }

    state = state.copyWith(
      playerName: _prefs.getString(kPlayerName) ?? 'Player',
      playerAvatar: _prefs.getInt(kPlayerAvatar) ?? 0,
      xp: _prefs.getInt(kPlayerXP) ?? 0,
      coins: _prefs.getInt(kPlayerCoins) ?? 0,
      lives: _prefs.getInt(kPlayerLives) ?? kDefaultMaxLives,
      maxLives: _prefs.getInt(kPlayerMaxLives) ?? kDefaultMaxLives,
      currentWorldId: _prefs.getInt(kCurrentWorldId) ?? 0,
      currentLevelId: _prefs.getInt(kCurrentLevelId) ?? 0,
      worlds: _buildWorldList(progress),
      isLoaded: true,
    );
  }

  // ── Life regen ────────────────────────────────────────────────────────────────

  void _applyLifeRegen() {
    final lives = _prefs.getInt(kPlayerLives) ?? kDefaultMaxLives;
    final maxLives = _prefs.getInt(kPlayerMaxLives) ?? kDefaultMaxLives;
    if (lives >= maxLives) return;

    final lastMs = _prefs.getInt(kLastLifeRefillMs) ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final minutesPassed = (nowMs - lastMs) ~/ 60000;
    final regained =
        (minutesPassed ~/ kLifeRegenMinutes).clamp(0, maxLives - lives);

    if (regained > 0) {
      final newLives = (lives + regained).clamp(0, maxLives);
      _prefs.setInt(kPlayerLives, newLives);
      _prefs.setInt(kLastLifeRefillMs, nowMs);
    }
  }

  // ── Public mutations ──────────────────────────────────────────────────────────

  Future<void> setCurrentLevel(int worldId, int levelId) async {
    await Future.wait([
      _prefs.setInt(kCurrentWorldId, worldId),
      _prefs.setInt(kCurrentLevelId, levelId),
    ]);
    state = state.copyWith(currentWorldId: worldId, currentLevelId: levelId);
  }

  Future<void> clearCurrentLevel() async {
    await Future.wait([
      _prefs.setInt(kCurrentWorldId, 0),
      _prefs.setInt(kCurrentLevelId, 0),
    ]);
    state = state.copyWith(currentWorldId: 0, currentLevelId: 0);
  }

  Future<void> addCoins(int amount) async {
    final newCoins = state.coins + amount;
    await _prefs.setInt(kPlayerCoins, newCoins);
    state = state.copyWith(coins: newCoins);
  }

  Future<void> addXP(int amount) async {
    final newXP = state.xp + amount;
    await _prefs.setInt(kPlayerXP, newXP);
    state = state.copyWith(xp: newXP);
  }

  Future<void> loseLife() async {
    if (state.lives <= 0) return;
    final newLives = state.lives - 1;
    await _prefs.setInt(kPlayerLives, newLives);
    // Start the regen clock when the first life is lost.
    if (state.lives == state.maxLives) {
      await _prefs.setInt(
          kLastLifeRefillMs, DateTime.now().millisecondsSinceEpoch);
    }
    state = state.copyWith(lives: newLives);
  }

  Future<void> recordWorldProgress(int worldId, int completedCount) async {
    final rawProgress = <int, int>{...?_currentProgress()};
    rawProgress[worldId] = completedCount;
    final encoded =
        jsonEncode(rawProgress.map((k, v) => MapEntry(k.toString(), v)));
    await _prefs.setString(kWorldProgressMap, encoded);
    state = state.copyWith(worlds: _buildWorldList(rawProgress));
  }

  Map<int, int>? _currentProgress() {
    final raw = _prefs.getString(kWorldProgressMap);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return null;
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HomeNotifier(prefs);
});
