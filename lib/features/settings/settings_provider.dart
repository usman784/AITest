import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_flow/core/di/providers.dart';
import 'package:arrow_flow/core/utils/audio_helper.dart';

// ── SharedPreferences keys ────────────────────────────────────────────────────

const String kArrowsSoundEnabled   = 'arrows_sound_enabled';
const String kArrowsHapticsEnabled = 'arrows_haptics_enabled';

// ── SettingsState ─────────────────────────────────────────────────────────────

class SettingsState {
  const SettingsState({
    this.soundEnabled   = true,
    this.hapticsEnabled = true,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;

  SettingsState copyWith({bool? soundEnabled, bool? hapticsEnabled}) =>
      SettingsState(
        soundEnabled:   soundEnabled   ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      );
}

// ── SettingsNotifier ──────────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._prefs, this._audio) : super(const SettingsState()) {
    _load();
  }

  final SharedPreferences _prefs;
  final AudioService _audio;

  void _load() {
    final sound   = _prefs.getBool(kArrowsSoundEnabled)   ?? true;
    final haptics = _prefs.getBool(kArrowsHapticsEnabled) ?? true;
    state = SettingsState(soundEnabled: sound, hapticsEnabled: haptics);
    // Sync AudioService to persisted values on startup.
    _audio.setSfxEnabled(sound);
    _audio.setMusicEnabled(sound);
  }

  /// Toggles SFX + ambient music together and persists the choice.
  Future<void> toggleSound() async {
    final next = !state.soundEnabled;
    await _prefs.setBool(kArrowsSoundEnabled, next);
    _audio.setSfxEnabled(next);
    _audio.setMusicEnabled(next);
    state = state.copyWith(soundEnabled: next);
  }

  /// Toggles haptic feedback and persists the choice.
  Future<void> toggleHaptics() async {
    final next = !state.hapticsEnabled;
    await _prefs.setBool(kArrowsHapticsEnabled, next);
    state = state.copyWith(hapticsEnabled: next);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Global settings provider.  Watches [sharedPreferencesProvider] and
/// [audioServiceProvider] so that toggling sound immediately propagates to
/// the AudioService singleton.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(
    ref.watch(sharedPreferencesProvider),
    ref.watch(audioServiceProvider),
  );
});
