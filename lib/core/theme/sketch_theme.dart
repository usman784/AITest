import 'package:flutter/material.dart';
import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';

/// Full [ThemeData] definitions for the **Sketch / Doodle** visual style.
class SketchTheme {
  const SketchTheme._();

  /// Light-mode Sketch theme (paper white with ink strokes).
  static ThemeData light() => _build(Brightness.light);

  /// Dark-mode Sketch theme (dark paper with chalk strokes).
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A14) : SketchColors.background;
    final surface = isDark ? const Color(0xFF252520) : SketchColors.surface;
    final onSurface =
        isDark ? const Color(0xFFF0EDD8) : SketchColors.textPrimary;
    final accentColor =
        isDark ? const Color(0xFFFF8C60) : SketchColors.accent;

    final cs = ColorScheme(
      brightness: brightness,
      primary: SketchColors.primary,
      onPrimary: isDark ? const Color(0xFF1A1A14) : Colors.white,
      primaryContainer: isDark
          ? const Color(0xFF333325)
          : const Color(0xFFF5F0D8),
      onPrimaryContainer: isDark ? const Color(0xFFF0EDD8) : SketchColors.primary,
      secondary: accentColor,
      onSecondary: Colors.white,
      secondaryContainer: isDark
          ? const Color(0xFF4A2515)
          : const Color(0xFFFFE8DA),
      onSecondaryContainer:
          isDark ? const Color(0xFFFFCCB0) : const Color(0xFF3D1500),
      tertiary: SketchColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFBBF0D0),
      onTertiaryContainer: const Color(0xFF002112),
      error: SketchColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest:
          isDark ? const Color(0xFF303028) : const Color(0xFFF0EDD5),
      onSurfaceVariant: isDark
          ? const Color(0xFFB0AD98)
          : SketchColors.textSecondary,
      outline: isDark
          ? const Color(0xFF6A6A58)
          : SketchColors.gridLine,
      shadow: Colors.black,
      inverseSurface:
          isDark ? SketchColors.background : SketchColors.primary,
      onInverseSurface:
          isDark ? SketchColors.primary : SketchColors.background,
      inversePrimary: isDark ? const Color(0xFFF0EDD8) : SketchColors.primary,
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: onSurface,
        displayColor: isDark ? const Color(0xFFF0EDD8) : SketchColors.primary,
        fontFamily: 'Nunito',
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            side: BorderSide(
              color: isDark ? SketchColors.inkColor : SketchColors.sketchStroke,
              width: 2,
            ),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          side: BorderSide(
            color: isDark
                ? const Color(0xFF6A6A58)
                : SketchColors.sketchStroke.withAlpha(0xAA),
            width: 2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C22) : SketchColors.paperTexture,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceSM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFF6A6A58)
                : SketchColors.sketchStroke.withAlpha(0xAA),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium
            .copyWith(color: isDark ? const Color(0xFFB0AD98) : SketchColors.textSecondary),
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: SketchColors.textSecondary.withAlpha(0xAA)),
      ),
      iconTheme: IconThemeData(
        color: onSurface,
        size: AppDimensions.iconMD,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? accentColor
              : isDark
                  ? const Color(0xFF808070)
                  : const Color(0xFFBBBBAA);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? accentColor.withAlpha(0x66)
              : isDark
                  ? const Color(0xFF444438)
                  : SketchColors.gridLine;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? accentColor
              : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM / 2),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accentColor,
        inactiveTrackColor: isDark
            ? const Color(0xFF4A4A3A)
            : SketchColors.gridLine,
        thumbColor: accentColor,
        overlayColor: accentColor.withAlpha(0x29),
        trackHeight: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? const Color(0xFF303028)
            : const Color(0xFFF5F0D8),
        labelStyle: AppTypography.labelMedium.copyWith(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          side: BorderSide(
            color: isDark
                ? const Color(0xFF6A6A58)
                : SketchColors.sketchStroke.withAlpha(0x66),
          ),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(
        color: isDark
            ? const Color(0xFF4A4A38)
            : SketchColors.gridLine.withAlpha(0xCC),
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accentColor.withAlpha(0x29),
        labelTextStyle:
            WidgetStateProperty.all(AppTypography.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active
                ? accentColor
                : isDark
                    ? const Color(0xFFB0AD98)
                    : SketchColors.textSecondary,
            size: AppDimensions.iconMD,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: const BorderSide(color: SketchColors.sketchStroke, width: 2),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: [
        ArrowFlowThemeExtension(
          arrowColor: SketchColors.arrowColor,
          gridLineColor: isDark ? const Color(0xFF6A6A58) : SketchColors.gridLine,
          glowColor: accentColor.withAlpha(0x33),
          backgroundGradientStart: bg,
          backgroundGradientEnd: isDark
              ? const Color(0xFF101010)
              : SketchColors.paperTexture,
          isNeonTheme: false,
          isSpaceTheme: false,
          isWoodenTheme: false,
          isSketchTheme: true,
          successColor: SketchColors.success,
          errorColor: SketchColors.error,
          accentColor: accentColor,
          sketchStrokeColor: isDark ? SketchColors.inkColor : SketchColors.sketchStroke,
          meteorColor: Colors.transparent,
          starFieldColor: Colors.transparent,
        ),
      ],
    );
  }
}
