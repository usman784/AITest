import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_flow/core/di/providers.dart';
import 'package:arrow_flow/core/theme/theme_notifier.dart';
import 'package:arrow_flow/core/utils/audio_helper.dart';

// ── SharedPreferences keys ────────────────────────────────────────────────────

/// Set to `true` when the user finishes the onboarding flow.
/// Read by [SplashScreen] to decide the first-launch route.
const String kOnboardingComplete = 'onboarding_complete';

/// Set to `true` when a player profile (nickname + avatar) has been saved.
const String kUserProfileExists = 'user_profile_exists';

/// Stored player nickname (max 16 chars).
const String kPlayerName = 'player_name';

/// Selected avatar index (0–7).
const String kPlayerAvatar = 'player_avatar';

/// Colorblind accessibility mode flag.
const String kColorblindMode = 'colorblind_mode';

/// Selected [SoundPack] name.
const String kSoundPackPref = 'sound_pack';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable state for the five-page onboarding flow.
class OnboardingState extends Equatable {
  const OnboardingState({
    this.currentPage = 0,
    this.selectedStyle = VisualStyle.minimalist,
    this.selectedSoundPack = SoundPack.arcade,
    this.themeMode = ThemeMode.system,
    this.colorblindMode = false,
    this.playerName = '',
    this.selectedAvatar = 0,
    this.nameError = '',
  });

  /// Currently visible page index (0–4).
  final int currentPage;

  /// Visual theme the user has chosen on page 4.
  final VisualStyle selectedStyle;

  /// Sound pack selected on page 4.
  final SoundPack selectedSoundPack;

  /// Light / dark / system mode selected on page 4.
  final ThemeMode themeMode;

  /// Whether colorblind patterns are enabled (page 5 toggle).
  final bool colorblindMode;

  /// Player nickname entered on page 5.
  final String playerName;

  /// Avatar index chosen on page 5 (0–7).
  final int selectedAvatar;

  /// Validation error message for [playerName]; empty when valid.
  final String nameError;

  /// Returns a copy with any supplied fields replaced.
  OnboardingState copyWith({
    int? currentPage,
    VisualStyle? selectedStyle,
    SoundPack? selectedSoundPack,
    ThemeMode? themeMode,
    bool? colorblindMode,
    String? playerName,
    int? selectedAvatar,
    String? nameError,
  }) =>
      OnboardingState(
        currentPage: currentPage ?? this.currentPage,
        selectedStyle: selectedStyle ?? this.selectedStyle,
        selectedSoundPack: selectedSoundPack ?? this.selectedSoundPack,
        themeMode: themeMode ?? this.themeMode,
        colorblindMode: colorblindMode ?? this.colorblindMode,
        playerName: playerName ?? this.playerName,
        selectedAvatar: selectedAvatar ?? this.selectedAvatar,
        nameError: nameError ?? this.nameError,
      );

  @override
  List<Object?> get props => [
        currentPage,
        selectedStyle,
        selectedSoundPack,
        themeMode,
        colorblindMode,
        playerName,
        selectedAvatar,
        nameError,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

/// Manages onboarding selections and persists them when the flow completes.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._prefs, this._themeNotifier)
      : super(const OnboardingState());

  final SharedPreferences _prefs;
  final ThemeNotifier _themeNotifier;

  /// Updates the active page index.
  void setPage(int page) => state = state.copyWith(currentPage: page);

  /// Applies [style] to the live theme immediately (page 4 live preview).
  void setThemeStyle(VisualStyle style) {
    state = state.copyWith(selectedStyle: style);
    _themeNotifier.setVisualStyle(style);
  }

  /// Stores the selected sound pack.
  void setSoundPack(SoundPack pack) =>
      state = state.copyWith(selectedSoundPack: pack);

  /// Applies [mode] to the live theme immediately (page 4 toggle).
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _themeNotifier.setThemeMode(mode);
  }

  /// Toggles colorblind accessibility mode.
  void setColorblindMode(bool enabled) =>
      state = state.copyWith(colorblindMode: enabled);

  /// Validates and stores the player nickname.
  void setPlayerName(String name) {
    final trimmed = name.trim();
    final error = trimmed.isEmpty
        ? 'Nickname is required'
        : trimmed.length > 16
            ? 'Max 16 characters'
            : '';
    state = state.copyWith(playerName: trimmed, nameError: error);
  }

  /// Selects an avatar by index.
  void setAvatar(int index) => state = state.copyWith(selectedAvatar: index);

  /// Returns `true` when the form is valid and [finish] may be called.
  bool get canFinish =>
      state.playerName.trim().isNotEmpty && state.nameError.isEmpty;

  /// Persists all onboarding selections to [SharedPreferences].
  Future<void> finish() async {
    await Future.wait([
      _prefs.setString(kPlayerName, state.playerName),
      _prefs.setInt(kPlayerAvatar, state.selectedAvatar),
      _prefs.setBool(kColorblindMode, state.colorblindMode),
      _prefs.setString(kSoundPackPref, state.selectedSoundPack.name),
      _prefs.setBool(kOnboardingComplete, true),
      _prefs.setBool(kUserProfileExists, true),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides [OnboardingNotifier] scoped to the onboarding route.
final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final themeNotifier = ref.watch(themeProvider.notifier);
  return OnboardingNotifier(prefs, themeNotifier);
});
