import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arrow_flow/core/router/app_router.dart';
import 'package:arrow_flow/core/theme/theme_notifier.dart';
import 'package:arrow_flow/core/utils/audio_helper.dart';
import 'package:arrow_flow/game/data/level_repository.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

/// Provides the singleton [SharedPreferences] instance.
///
/// **Must** be overridden in [ProviderScope] before the app starts:
/// ```dart
/// ProviderScope(
///   overrides: [
///     sharedPreferencesProvider.overrideWithValue(prefs),
///   ],
///   child: ArrowFlowApp(),
/// )
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with a real '
    'SharedPreferences instance.',
  ),
);

// ── Theme ─────────────────────────────────────────────────────────────────────

/// Provides the [ThemeNotifier] and its [ThemeState].
///
/// Reads from [sharedPreferencesProvider] so that theme selections survive
/// app restarts.
final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

// ── Audio ─────────────────────────────────────────────────────────────────────

/// Provides the [AudioService] singleton.
///
/// Disposed when the provider is no longer used.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(
    sfxPlayer: AudioPlayer(),
    ambientPlayer: AudioPlayer(),
  );
  ref.onDispose(service.dispose);
  return service;
});

// ── Data ──────────────────────────────────────────────────────────────────────

/// Provides the [LevelRepository] singleton.
final levelRepositoryProvider = Provider<LevelRepository>(
  (_) => LevelRepository(),
);

// ── Navigation ────────────────────────────────────────────────────────────────

/// Re-exports [appRouterProvider] from the router module so that the rest of
/// the app only needs to import this one file.
final routerProvider = appRouterProvider;

/// Convenience type alias so widgets can write `ref.watch(routerProvider)`.
typedef AppRouter = GoRouter;
