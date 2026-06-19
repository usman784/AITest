import 'package:flutter/material.dart';
import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/core/theme/theme_notifier.dart';

/// Builds [ThemeData] objects for every combination of [VisualStyle] and
/// [Brightness].
class AppTheme {
  const AppTheme._();

  /// Returns the correct [ThemeData] for [style] at [brightness].
  static ThemeData getTheme(VisualStyle style, Brightness brightness) {
    switch (style) {
      case VisualStyle.minimalist:
        return _minimalistTheme(brightness);
      case VisualStyle.neon:
        return _neonTheme(brightness);
      case VisualStyle.wooden:
        return _woodenTheme(brightness);
      case VisualStyle.sketch:
        return _sketchTheme(brightness);
      case VisualStyle.space:
        return _spaceTheme(brightness);
    }
  }

  // ── Shared helpers ────────────────────────────────────────────────────────────

  static ElevatedButtonThemeData _elevatedButtonTheme(Color foreground) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: foreground,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
      );

  static CardTheme _cardTheme({Color? color}) => CardTheme(
        elevation: 0,
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      );

  static const AppBarTheme _transparentAppBar = AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
  );

  static const PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  // ── Minimalist ────────────────────────────────────────────────────────────────

  static ThemeData _minimalistTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: MinimalistColors.accent,
          brightness: brightness,
        ),
        scaffoldBackgroundColor: brightness == Brightness.light
            ? MinimalistColors.background
            : const Color(0xFF121212),
        textTheme: AppTypography.textTheme,
        extensions: const [
          // Using factory constructor via static method
        ],
        appBarTheme: _transparentAppBar,
        elevatedButtonTheme:
            _elevatedButtonTheme(MinimalistColors.surface),
        cardTheme: _cardTheme(),
        pageTransitionsTheme: _pageTransitions,
      ).copyWith(
        extensions: {ArrowFlowThemeExtension.minimalist()},
      );

  // ── Neon ──────────────────────────────────────────────────────────────────────

  static ThemeData _neonTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: NeonColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: NeonColors.background,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: NeonColors.textPrimary,
          displayColor: NeonColors.textPrimary,
        ),
        appBarTheme: _transparentAppBar,
        elevatedButtonTheme:
            _elevatedButtonTheme(NeonColors.background),
        cardTheme: _cardTheme(color: NeonColors.surface),
        pageTransitionsTheme: _pageTransitions,
      ).copyWith(
        extensions: {ArrowFlowThemeExtension.neon()},
      );

  // ── Wooden ────────────────────────────────────────────────────────────────────

  static ThemeData _woodenTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: WoodenColors.accent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: WoodenColors.background,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: WoodenColors.textPrimary,
          displayColor: WoodenColors.textPrimary,
        ),
        appBarTheme: _transparentAppBar,
        elevatedButtonTheme:
            _elevatedButtonTheme(WoodenColors.surface),
        cardTheme: _cardTheme(color: WoodenColors.surface),
        pageTransitionsTheme: _pageTransitions,
      ).copyWith(
        extensions: {ArrowFlowThemeExtension.wooden()},
      );

  // ── Sketch ────────────────────────────────────────────────────────────────────

  static ThemeData _sketchTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SketchColors.accent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: SketchColors.background,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: SketchColors.textPrimary,
          displayColor: SketchColors.textPrimary,
        ),
        appBarTheme: _transparentAppBar,
        elevatedButtonTheme:
            _elevatedButtonTheme(SketchColors.surface),
        cardTheme: _cardTheme(color: SketchColors.surface),
        pageTransitionsTheme: _pageTransitions,
      ).copyWith(
        extensions: {ArrowFlowThemeExtension.sketch()},
      );

  // ── Space ─────────────────────────────────────────────────────────────────────

  static ThemeData _spaceTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SpaceColors.accent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: SpaceColors.background,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: SpaceColors.textPrimary,
          displayColor: SpaceColors.textPrimary,
        ),
        appBarTheme: _transparentAppBar,
        elevatedButtonTheme:
            _elevatedButtonTheme(SpaceColors.background),
        cardTheme: _cardTheme(color: SpaceColors.surface),
        pageTransitionsTheme: _pageTransitions,
      ).copyWith(
        extensions: {ArrowFlowThemeExtension.space()},
      );
}
