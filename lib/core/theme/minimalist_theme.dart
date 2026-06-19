import 'package:flutter/material.dart';
import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';

/// Full [ThemeData] definitions for the **Minimalist** visual style.
///
/// Exported as two static factories — [light] and [dark] — so that
/// [AppTheme.getTheme] can dispatch to them by [Brightness].
class MinimalistTheme {
  const MinimalistTheme._();

  /// Light-mode Minimalist theme.
  static ThemeData light() => _build(Brightness.light);

  /// Dark-mode Minimalist theme.
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg =
        isDark ? const Color(0xFF121212) : MinimalistColors.background;
    final surface = isDark ? const Color(0xFF1E1E1E) : MinimalistColors.surface;
    final onSurface =
        isDark ? MinimalistColors.background : MinimalistColors.primary;

    final cs = ColorScheme(
      brightness: brightness,
      primary: MinimalistColors.accent,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD8E0FF),
      onPrimaryContainer: const Color(0xFF001258),
      secondary: MinimalistColors.accent.withAlpha(0xCC),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFDDE1FF),
      onSecondaryContainer: const Color(0xFF001259),
      tertiary: MinimalistColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFB3F0C8),
      onTertiaryContainer: const Color(0xFF00210F),
      error: MinimalistColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest:
          isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE8EAED),
      onSurfaceVariant:
          isDark ? const Color(0xFFB0B0B0) : MinimalistColors.textSecondary,
      outline: isDark ? const Color(0xFF555555) : MinimalistColors.gridLine,
      shadow: Colors.black,
      inverseSurface:
          isDark ? MinimalistColors.background : MinimalistColors.primary,
      onInverseSurface:
          isDark ? MinimalistColors.primary : MinimalistColors.background,
      inversePrimary: const Color(0xFFB6C4FF),
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
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
          backgroundColor: MinimalistColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MinimalistColors.accent,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MinimalistColors.accent,
          side: const BorderSide(color: MinimalistColors.accent),
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: BorderSide(
            color: MinimalistColors.gridLine.withAlpha(isDark ? 0x40 : 0xFF),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F2F5),
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
            color: MinimalistColors.gridLine.withAlpha(isDark ? 0x60 : 0xFF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: MinimalistColors.accent, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium
            .copyWith(color: MinimalistColors.textSecondary),
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: MinimalistColors.textSecondary.withAlpha(0xAA)),
      ),
      iconTheme: IconThemeData(
        color: onSurface,
        size: AppDimensions.iconMD,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MinimalistColors.accent;
          }
          return isDark ? const Color(0xFF888888) : const Color(0xFFBBBBBB);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MinimalistColors.accent.withAlpha(0x66);
          }
          return isDark ? const Color(0xFF444444) : const Color(0xFFDDDDDD);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MinimalistColors.accent;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM / 2),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: MinimalistColors.accent,
        inactiveTrackColor: MinimalistColors.accent.withAlpha(0x33),
        thumbColor: MinimalistColors.accent,
        overlayColor: MinimalistColors.accent.withAlpha(0x29),
        trackHeight: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEEEFF2),
        labelStyle: AppTypography.labelMedium.copyWith(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        ),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(
        color: MinimalistColors.gridLine.withAlpha(isDark ? 0x40 : 0xFF),
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: MinimalistColors.accent.withAlpha(0x29),
        labelTextStyle: WidgetStateProperty.all(AppTypography.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? MinimalistColors.accent : MinimalistColors.textSecondary,
            size: AppDimensions.iconMD,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: MinimalistColors.accent,
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
          arrowColor: isDark ? const Color(0xFFB0B8C8) : MinimalistColors.arrowColor,
          gridLineColor: isDark ? const Color(0xFF3A3A3A) : MinimalistColors.gridLine,
          glowColor: const Color(0x334361EE),
          backgroundGradientStart:
              isDark ? const Color(0xFF0F0F12) : MinimalistColors.background,
          backgroundGradientEnd:
              isDark ? const Color(0xFF1A1A2E) : const Color(0xFFECEFF1),
          isNeonTheme: false,
          isSpaceTheme: false,
          isWoodenTheme: false,
          isSketchTheme: false,
          successColor: MinimalistColors.success,
          errorColor: MinimalistColors.error,
          accentColor: MinimalistColors.accent,
          sketchStrokeColor: isDark ? const Color(0xFF3A3A3A) : MinimalistColors.gridLine,
          meteorColor: Colors.transparent,
          starFieldColor: Colors.transparent,
        ),
      ],
    );
  }
}
