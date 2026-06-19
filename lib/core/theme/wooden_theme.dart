import 'package:flutter/material.dart';
import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';

/// Full [ThemeData] definitions for the **Wooden / Natural** visual style.
class WoodenTheme {
  const WoodenTheme._();

  /// Light-mode Wooden theme.
  static ThemeData light() => _build(Brightness.light);

  /// Dark-mode Wooden theme (deepens warm browns).
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg =
        isDark ? const Color(0xFF2A1A0A) : WoodenColors.background;
    final surface =
        isDark ? const Color(0xFF3A2210) : WoodenColors.surface;
    final onSurface =
        isDark ? WoodenColors.surface : WoodenColors.textPrimary;

    final cs = ColorScheme(
      brightness: brightness,
      primary: WoodenColors.accent,
      onPrimary: Colors.white,
      primaryContainer: isDark
          ? const Color(0xFF5C3D1E)
          : const Color(0xFFFFDEB3),
      onPrimaryContainer:
          isDark ? WoodenColors.surface : WoodenColors.primary,
      secondary: WoodenColors.primary,
      onSecondary: Colors.white,
      secondaryContainer:
          isDark ? const Color(0xFF3E1C00) : const Color(0xFFF5DEB3),
      onSecondaryContainer:
          isDark ? WoodenColors.surface : WoodenColors.primary,
      tertiary: WoodenColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFB8E6B8),
      onTertiaryContainer: const Color(0xFF002200),
      error: WoodenColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFCDD2),
      onErrorContainer: const Color(0xFF4A0000),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest:
          isDark ? const Color(0xFF4A2C10) : const Color(0xFFEED5A8),
      onSurfaceVariant: WoodenColors.textSecondary,
      outline: WoodenColors.gridLine,
      shadow: Colors.black,
      inverseSurface:
          isDark ? WoodenColors.background : WoodenColors.primary,
      onInverseSurface:
          isDark ? WoodenColors.primary : WoodenColors.background,
      inversePrimary: const Color(0xFFFFB870),
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: onSurface,
        displayColor: WoodenColors.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? WoodenColors.surface : WoodenColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: isDark ? WoodenColors.surface : WoodenColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WoodenColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          elevation: 3,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: WoodenColors.accent,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: WoodenColors.accent,
          side: const BorderSide(color: WoodenColors.accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: WoodenColors.primary.withAlpha(0x33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: BorderSide(color: WoodenColors.gridLine.withAlpha(0xAA)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF3E2210) : const Color(0xFFFAEED8),
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
          borderSide: const BorderSide(color: WoodenColors.gridLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: WoodenColors.accent, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium
            .copyWith(color: WoodenColors.textSecondary),
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: WoodenColors.textSecondary.withAlpha(0xAA)),
      ),
      iconTheme: IconThemeData(
        color: isDark ? WoodenColors.surface : WoodenColors.primary,
        size: AppDimensions.iconMD,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? WoodenColors.accent
              : isDark
                  ? const Color(0xFF6A4020)
                  : WoodenColors.gridLine;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? WoodenColors.accent.withAlpha(0x66)
              : isDark
                  ? const Color(0xFF3A2010)
                  : const Color(0xFFDDB880);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? WoodenColors.accent
              : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM / 2),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: WoodenColors.accent,
        inactiveTrackColor: WoodenColors.gridLine,
        thumbColor: WoodenColors.accent,
        overlayColor: WoodenColors.accent.withAlpha(0x29),
        trackHeight: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? const Color(0xFF3A2210)
            : const Color(0xFFEED5A8),
        labelStyle: AppTypography.labelMedium.copyWith(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(
        color: WoodenColors.gridLine.withAlpha(isDark ? 0x60 : 0xFF),
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: WoodenColors.accent.withAlpha(0x29),
        labelTextStyle:
            WidgetStateProperty.all(AppTypography.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? WoodenColors.accent : WoodenColors.textSecondary,
            size: AppDimensions.iconMD,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: WoodenColors.accent,
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
      extensions: [
        ArrowFlowThemeExtension(
          arrowColor: WoodenColors.arrowColor,
          gridLineColor: WoodenColors.gridLine,
          glowColor: const Color(0x338B4513),
          backgroundGradientStart: isDark
              ? const Color(0xFF2A1A0A)
              : WoodenColors.background,
          backgroundGradientEnd: isDark
              ? const Color(0xFF1A0A00)
              : const Color(0xFFC8A060),
          isNeonTheme: false,
          isSpaceTheme: false,
          isWoodenTheme: true,
          isSketchTheme: false,
          successColor: WoodenColors.success,
          errorColor: WoodenColors.error,
          accentColor: WoodenColors.accent,
          sketchStrokeColor: WoodenColors.gridLine,
          meteorColor: Colors.transparent,
          starFieldColor: Colors.transparent,
        ),
      ],
    );
  }
}
