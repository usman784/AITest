import 'package:flutter/material.dart';
import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';

/// Full [ThemeData] definitions for the **Neon** visual style.
///
/// Neon is always dark — both [light] and [dark] return the same dark-first
/// palette so the game always looks correct when this style is active.
class NeonTheme {
  const NeonTheme._();

  /// Light-mode Neon theme (still uses the dark neon palette).
  static ThemeData light() => _build();

  /// Dark-mode Neon theme.
  static ThemeData dark() => _build();

  static ThemeData _build() {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: NeonColors.primary,
      onPrimary: NeonColors.background,
      primaryContainer: Color(0xFF003D40),
      onPrimaryContainer: NeonColors.primary,
      secondary: NeonColors.accent,
      onSecondary: NeonColors.background,
      secondaryContainer: Color(0xFF5A0029),
      onSecondaryContainer: NeonColors.accent,
      tertiary: NeonColors.success,
      onTertiary: NeonColors.background,
      tertiaryContainer: Color(0xFF003823),
      onTertiaryContainer: NeonColors.success,
      error: NeonColors.error,
      onError: NeonColors.background,
      errorContainer: Color(0xFF5A0000),
      onErrorContainer: NeonColors.error,
      surface: NeonColors.surface,
      onSurface: NeonColors.textPrimary,
      surfaceContainerHighest: Color(0xFF1C1C28),
      onSurfaceVariant: NeonColors.textSecondary,
      outline: NeonColors.gridLine,
      shadow: Colors.black,
      inverseSurface: NeonColors.textPrimary,
      onInverseSurface: NeonColors.background,
      inversePrimary: Color(0xFF005F63),
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: NeonColors.background,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: NeonColors.textPrimary,
        displayColor: NeonColors.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: NeonColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: NeonColors.primary,
          shadows: [
            Shadow(
              color: NeonColors.glowColor,
              blurRadius: 8,
            ),
          ],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeonColors.primary,
          foregroundColor: NeonColors.background,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          elevation: 0,
          shadowColor: NeonColors.glowColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: NeonColors.primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NeonColors.primary,
          side: const BorderSide(color: NeonColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: NeonColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: const BorderSide(color: NeonColors.gridLine),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeonColors.surface,
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
          borderSide: const BorderSide(color: NeonColors.gridLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: NeonColors.primary, width: 2),
        ),
        labelStyle:
            AppTypography.bodyMedium.copyWith(color: NeonColors.textSecondary),
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: NeonColors.textSecondary.withAlpha(0xAA)),
      ),
      iconTheme: const IconThemeData(
        color: NeonColors.textPrimary,
        size: AppDimensions.iconMD,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? NeonColors.primary
              : const Color(0xFF555555);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? NeonColors.glowColor
              : NeonColors.gridLine;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? NeonColors.primary
              : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(NeonColors.background),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM / 2),
        ),
        side: const BorderSide(color: NeonColors.primary),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: NeonColors.primary,
        inactiveTrackColor: NeonColors.gridLine,
        thumbColor: NeonColors.primary,
        overlayColor: NeonColors.glowColor,
        trackHeight: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: NeonColors.surface,
        labelStyle:
            AppTypography.labelMedium.copyWith(color: NeonColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          side: const BorderSide(color: NeonColors.gridLine),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: NeonColors.gridLine,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: NeonColors.surface,
        indicatorColor: NeonColors.glowColor,
        labelTextStyle:
            WidgetStateProperty.all(AppTypography.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? NeonColors.primary : NeonColors.textSecondary,
            size: AppDimensions.iconMD,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: NeonColors.primary,
        foregroundColor: NeonColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
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
          arrowColor: NeonColors.arrowColor,
          gridLineColor: NeonColors.gridLine,
          glowColor: NeonColors.glowColor,
          backgroundGradientStart: NeonColors.background,
          backgroundGradientEnd: const Color(0xFF0D0D1F),
          isNeonTheme: true,
          isSpaceTheme: false,
          isWoodenTheme: false,
          isSketchTheme: false,
          successColor: NeonColors.success,
          errorColor: NeonColors.error,
          accentColor: NeonColors.accent,
          sketchStrokeColor: NeonColors.gridLine,
          meteorColor: Colors.transparent,
          starFieldColor: Colors.transparent,
        ),
      ],
    );
  }
}
