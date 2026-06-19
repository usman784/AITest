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
          themeMode: ThemeMode.dark,
        )) {
    _loadFromPrefs();
  }

  final SharedPreferences _prefs;

  /// Updates the active visual style and persists the change.
  void setVisualStyle(VisualStyle style) {
    state = state.copyWith(visualStyle: style);
    _prefs.setString(_kVisualStyleKey, style.toString().split('.').last);
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
            (v) => v.toString().split('.').last == styleString,
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
        return ThemeMode.dark;
    }
  }
}

/// Riverpod provider for [ThemeNotifier].
///
/// **Do not use this directly.** Use [themeProvider] from
/// `lib/core/di/providers.dart`, which correctly wires up the
/// [SharedPreferences] dependency via a ProviderScope override.
///
/// This stub is kept for completeness but will throw if called without the
/// override — see `lib/core/di/providers.dart` for the real provider.
// ignore: unused_element
final _themeNotifierStubProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  throw UnimplementedError(
    'Use themeProvider from lib/core/di/providers.dart instead.',
  );
});
