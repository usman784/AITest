import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The five visual styles available in Arrow Flow.
enum VisualStyle {
  minimalist,
  neon,
  wooden,
  sketch,
  space,
}

/// Immutable state held by [ThemeNotifier].
class ThemeState extends Equatable {
  const ThemeState({
    required this.visualStyle,
    required this.themeMode,
  });

  /// Which visual theme is currently active.
  final VisualStyle visualStyle;

  /// Light / Dark / System theme mode.
  final ThemeMode themeMode;

  /// Returns a new [ThemeState] with any supplied fields replaced.
  ThemeState copyWith({
    VisualStyle? visualStyle,
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      visualStyle: visualStyle ?? this.visualStyle,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [visualStyle, themeMode];
}

// ── SharedPreferences keys ────────────────────────────────────────────────────

const String _kVisualStyleKey = 'visual_style';
const String _kThemeModeKey = 'theme_mode';

/// Manages theme persistence and live updates.
///
/// Reads the previously saved [VisualStyle] and [ThemeMode] from
/// [SharedPreferences] on construction and exposes methods to update them.
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier(this._prefs)
      : super(const ThemeState(
          visualStyle: VisualStyle.minimalist,
          themeMode: ThemeMode.system,
        )) {
    _loadFromPrefs();
  }

  final SharedPreferences _prefs;

  /// Updates the active visual style and persists the change.
  void setVisualStyle(VisualStyle style) {
    state = state.copyWith(visualStyle: style);
    _prefs.setString(_kVisualStyleKey, style.name);
  }

  /// Updates the theme mode (light / dark / system) and persists the change.
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setString(_kThemeModeKey, _themeModeToString(mode));
  }

  /// Restores theme settings from [SharedPreferences].
  void _loadFromPrefs() {
    final styleString = _prefs.getString(_kVisualStyleKey);
    final modeString = _prefs.getString(_kThemeModeKey);

    final visualStyle = styleString != null
        ? VisualStyle.values.firstWhere(
            (v) => v.name == styleString,
            orElse: () => VisualStyle.minimalist,
          )
        : VisualStyle.minimalist;

    final themeMode = _themeModeFromString(modeString);

    state = ThemeState(visualStyle: visualStyle, themeMode: themeMode);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

/// Riverpod provider for [ThemeNotifier].
///
/// Depends on [sharedPreferencesProvider] which must be overridden in
/// [ProviderScope] before the app starts (done in [main]).
final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  // SharedPreferences is provided via override in main.dart / ProviderScope.
  // If you call this before the override is set up, it will throw — which is
  // the correct behaviour (fail fast).
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden before themeNotifierProvider '
    'can be used. See lib/core/di/providers.dart.',
  );
});
