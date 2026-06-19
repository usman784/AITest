import 'package:flutter/material.dart';
import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';

/// Full [ThemeData] definitions for the **Space** visual style.
///
/// Space is always dark — both [light] and [dark] return the same deep-space
/// palette so the cosmic atmosphere is preserved regardless of system mode.
class SpaceTheme {
  const SpaceTheme._();

  /// Light-mode Space theme (still uses the dark space palette).
  static ThemeData light() => _build();

  /// Dark-mode Space theme.
  static ThemeData dark() => _build();

  static ThemeData _build() {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: SpaceColors.primary,
      onPrimary: SpaceColors.background,
      primaryContainer: Color(0xFF2D3060),
      onPrimaryContainer: SpaceColors.primary,
      secondary: SpaceColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF3B1A70),
      onSecondaryContainer: Color(0xFFD9BBFF),
      tertiary: SpaceColors.success,
      onTertiary: SpaceColors.background,
      tertiaryContainer: Color(0xFF003823),
      onTertiaryContainer: SpaceColors.success,
      error: SpaceColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFF5C1010),
      onErrorContainer: Color(0xFFFFB4AB),
      surface: SpaceColors.surface,
      onSurface: SpaceColors.textPrimary,
      surfaceContainerHighest: Color(0xFF1C1E38),
      onSurfaceVariant: SpaceColors.textSecondary,
      outline: SpaceColors.gridLine,
      shadow: Colors.black,
      inverseSurface: SpaceColors.primary,
      onInverseSurface: SpaceColors.background,
      inversePrimary: Color(0xFF4A5080),
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: SpaceColors.background,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: SpaceColors.textPrimary,
        displayColor: SpaceColors.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: SpaceColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: SpaceColors.primary,
          letterSpacing: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SpaceColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          elevation: 0,
          shadowColor: SpaceColors.nebula1.withAlpha(0x80),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SpaceColors.accent,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SpaceColors.accent,
          side: const BorderSide(color: SpaceColors.accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: SpaceColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: const BorderSide(color: SpaceColors.gridLine),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SpaceColors.surface,
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
          borderSide: const BorderSide(color: SpaceColors.gridLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: SpaceColors.accent, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium
            .copyWith(color: SpaceColors.textSecondary),
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: SpaceColors.textSecondary.withAlpha(0xAA)),
      ),
      iconTheme: const IconThemeData(
        color: SpaceColors.textPrimary,
        size: AppDimensions.iconMD,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? SpaceColors.accent
              : const Color(0xFF555570);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? SpaceColors.nebula1.withAlpha(0x80)
              : SpaceColors.gridLine;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? SpaceColors.accent
              : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM / 2),
        ),
        side: const BorderSide(color: SpaceColors.accent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: SpaceColors.accent,
        inactiveTrackColor: SpaceColors.gridLine,
        thumbColor: SpaceColors.accent,
        overlayColor: SpaceColors.nebula1.withAlpha(0x40),
        trackHeight: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: SpaceColors.surface,
        labelStyle: AppTypography.labelMedium
            .copyWith(color: SpaceColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          side: const BorderSide(color: SpaceColors.gridLine),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: const DividerThemeData(
        color: SpaceColors.gridLine,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SpaceColors.surface,
        indicatorColor: SpaceColors.nebula1.withAlpha(0x40),
        labelTextStyle:
            WidgetStateProperty.all(AppTypography.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active
                ? SpaceColors.accent
                : SpaceColors.textSecondary,
            size: AppDimensions.iconMD,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: SpaceColors.accent,
        foregroundColor: Colors.white,
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
      extensions: const [
        ArrowFlowThemeExtension(
          arrowColor: SpaceColors.arrowColor,
          gridLineColor: SpaceColors.gridLine,
          glowColor: Color(0x667C3AED),
          backgroundGradientStart: SpaceColors.background,
          backgroundGradientEnd: SpaceColors.surface,
          isNeonTheme: false,
          isSpaceTheme: true,
          isWoodenTheme: false,
          isSketchTheme: false,
          successColor: SpaceColors.success,
          errorColor: SpaceColors.error,
          accentColor: SpaceColors.accent,
          sketchStrokeColor: SpaceColors.gridLine,
          meteorColor: SpaceColors.meteorColor,
          starFieldColor: SpaceColors.starField,
        ),
      ],
    );
  }
}
