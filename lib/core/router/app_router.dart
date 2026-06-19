import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arrow_flow/features/splash/splash_screen.dart';
import 'package:arrow_flow/features/onboarding/onboarding_screen.dart';
import 'package:arrow_flow/features/home/home_screen.dart';
import 'package:arrow_flow/features/level_select/level_select_screen.dart';
import 'package:arrow_flow/features/level_select/pack_level_select_screen.dart';
import 'package:arrow_flow/features/game/maze_game_screen.dart';
import 'package:arrow_flow/features/game/game_screen.dart';
import 'package:arrow_flow/features/win_dialog/win_dialog.dart';
import 'package:arrow_flow/features/settings/settings_screen.dart';
import 'package:arrow_flow/features/skin_shop/skin_shop_screen.dart';
import 'package:arrow_flow/features/achievements/achievements_screen.dart';
import 'package:arrow_flow/features/leaderboard/leaderboard_screen.dart';
import 'package:arrow_flow/features/win/maze_win_screen.dart';

/// Riverpod [Provider] that exposes the application-level [GoRouter].
///
/// All named routes are defined here. Use [context.go] / [context.push] in
/// widgets instead of navigating via [Navigator] directly.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/level-select',
        builder: (_, __) => const LevelSelectScreen(),
      ),
      GoRoute(
        path: '/level-select/:worldId',
        builder: (_, state) => LevelSelectScreen(
          worldId: int.tryParse(
                state.pathParameters['worldId'] ?? '',
              ) ??
              1,
        ),
      ),
      GoRoute(
        path: '/game/:levelId',
        builder: (_, state) => GameScreen(
          levelId: int.tryParse(
                state.pathParameters['levelId'] ?? '',
              ) ??
              1,
        ),
      ),
      GoRoute(
        path: '/game/daily',
        builder: (_, __) => const GameScreen(isDaily: true),
      ),
      GoRoute(
        path: '/win/:levelId',
        pageBuilder: (_, state) => CustomTransitionPage<void>(
          child: WinDialog(
            levelId: int.tryParse(
                  state.pathParameters['levelId'] ?? '',
                ) ??
                1,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/skin-shop',
        builder: (_, __) => const SkinShopScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (_, __) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (_, __) => const LeaderboardScreen(),
      ),

      // ── Pack-based routes (new minimalist redesign) ─────────────────────
      GoRoute(
        path: '/levels/:packId',
        builder: (_, state) => PackLevelSelectScreen(
          packId: int.tryParse(
                state.pathParameters['packId'] ?? '',
              ) ??
              1,
        ),
      ),
      GoRoute(
        path: '/game/:packId/:levelId',
        builder: (_, state) => MazeGameScreen(
          packId:  int.tryParse(state.pathParameters['packId']  ?? '') ?? 1,
          levelId: int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1,
        ),
      ),
      GoRoute(
        path: '/win-maze/:packId/:levelId',
        pageBuilder: (_, state) => CustomTransitionPage<void>(
          child: MazeWinScreen(
            data: state.extra is MazeWinData
                ? state.extra as MazeWinData
                : MazeWinData(
                    packId:         int.tryParse(state.pathParameters['packId']  ?? '') ?? 1,
                    levelId:        int.tryParse(state.pathParameters['levelId'] ?? '') ?? 1,
                    stars:          1,
                    moveCount:      0,
                    par:            1,
                    elapsedSeconds: 0,
                  ),
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
    ],
  );
});
