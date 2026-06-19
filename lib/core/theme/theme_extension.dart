import 'package:flutter/material.dart';
import 'package:arrow_flow/core/constants/app_colors.dart';

/// Custom [ThemeExtension] that carries Arrow Flow–specific design tokens.
///
/// Access it from any [BuildContext] via:
/// ```dart
/// final ext = Theme.of(context).extension<ArrowFlowThemeExtension>()!;
/// ```
@immutable
class ArrowFlowThemeExtension
    extends ThemeExtension<ArrowFlowThemeExtension> {
  const ArrowFlowThemeExtension({
    required this.arrowColor,
    required this.gridLineColor,
    required this.glowColor,
    required this.backgroundGradientStart,
    required this.backgroundGradientEnd,
    required this.isNeonTheme,
    required this.isSpaceTheme,
    required this.isWoodenTheme,
    required this.isSketchTheme,
    required this.successColor,
    required this.errorColor,
    required this.accentColor,
  });

  /// Colour used to paint arrow symbols.
  final Color arrowColor;

  /// Colour of grid lines.
  final Color gridLineColor;

  /// Soft glow halo colour (used by Neon and Space themes).
  final Color glowColor;

  /// Top colour of the animated background gradient.
  final Color backgroundGradientStart;

  /// Bottom colour of the animated background gradient.
  final Color backgroundGradientEnd;

  /// Whether this theme uses neon-style effects.
  final bool isNeonTheme;

  /// Whether this theme uses space-style effects.
  final bool isSpaceTheme;

  /// Whether this theme uses wooden textures.
  final bool isWoodenTheme;

  /// Whether this theme uses sketch/doodle effects.
  final bool isSketchTheme;

  /// Success/completion colour.
  final Color successColor;

  /// Error/wrong-tap colour.
  final Color errorColor;

  /// Primary accent colour.
  final Color accentColor;

  @override
  ArrowFlowThemeExtension copyWith({
    Color? arrowColor,
    Color? gridLineColor,
    Color? glowColor,
    Color? backgroundGradientStart,
    Color? backgroundGradientEnd,
    bool? isNeonTheme,
    bool? isSpaceTheme,
    bool? isWoodenTheme,
    bool? isSketchTheme,
    Color? successColor,
    Color? errorColor,
    Color? accentColor,
  }) {
    return ArrowFlowThemeExtension(
      arrowColor: arrowColor ?? this.arrowColor,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      glowColor: glowColor ?? this.glowColor,
      backgroundGradientStart:
          backgroundGradientStart ?? this.backgroundGradientStart,
      backgroundGradientEnd:
          backgroundGradientEnd ?? this.backgroundGradientEnd,
      isNeonTheme: isNeonTheme ?? this.isNeonTheme,
      isSpaceTheme: isSpaceTheme ?? this.isSpaceTheme,
      isWoodenTheme: isWoodenTheme ?? this.isWoodenTheme,
      isSketchTheme: isSketchTheme ?? this.isSketchTheme,
      successColor: successColor ?? this.successColor,
      errorColor: errorColor ?? this.errorColor,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  ArrowFlowThemeExtension lerp(
    ThemeExtension<ArrowFlowThemeExtension>? other,
    double t,
  ) {
    if (other is! ArrowFlowThemeExtension) return this;
    return ArrowFlowThemeExtension(
      arrowColor: Color.lerp(arrowColor, other.arrowColor, t)!,
      gridLineColor: Color.lerp(gridLineColor, other.gridLineColor, t)!,
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
      backgroundGradientStart: Color.lerp(
          backgroundGradientStart, other.backgroundGradientStart, t)!,
      backgroundGradientEnd:
          Color.lerp(backgroundGradientEnd, other.backgroundGradientEnd, t)!,
      isNeonTheme: t < 0.5 ? isNeonTheme : other.isNeonTheme,
      isSpaceTheme: t < 0.5 ? isSpaceTheme : other.isSpaceTheme,
      isWoodenTheme: t < 0.5 ? isWoodenTheme : other.isWoodenTheme,
      isSketchTheme: t < 0.5 ? isSketchTheme : other.isSketchTheme,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
    );
  }

  // ── Static Factory Methods ────────────────────────────────────────────────────

  /// Extension values for the Minimalist visual style.
  static ArrowFlowThemeExtension minimalist() =>
      const ArrowFlowThemeExtension(
        arrowColor: MinimalistColors.arrowColor,
        gridLineColor: MinimalistColors.gridLine,
        glowColor: Color(0x334361EE),
        backgroundGradientStart: MinimalistColors.background,
        backgroundGradientEnd: Color(0xFFECEFF1),
        isNeonTheme: false,
        isSpaceTheme: false,
        isWoodenTheme: false,
        isSketchTheme: false,
        successColor: MinimalistColors.success,
        errorColor: MinimalistColors.error,
        accentColor: MinimalistColors.accent,
      );

  /// Extension values for the Neon visual style.
  static ArrowFlowThemeExtension neon() =>
      const ArrowFlowThemeExtension(
        arrowColor: NeonColors.arrowColor,
        gridLineColor: NeonColors.gridLine,
        glowColor: NeonColors.glowColor,
        backgroundGradientStart: NeonColors.background,
        backgroundGradientEnd: Color(0xFF0D0D1F),
        isNeonTheme: true,
        isSpaceTheme: false,
        isWoodenTheme: false,
        isSketchTheme: false,
        successColor: NeonColors.success,
        errorColor: NeonColors.error,
        accentColor: NeonColors.accent,
      );

  /// Extension values for the Wooden visual style.
  static ArrowFlowThemeExtension wooden() =>
      const ArrowFlowThemeExtension(
        arrowColor: WoodenColors.arrowColor,
        gridLineColor: WoodenColors.gridLine,
        glowColor: Color(0x338B4513),
        backgroundGradientStart: WoodenColors.background,
        backgroundGradientEnd: Color(0xFFC8A060),
        isNeonTheme: false,
        isSpaceTheme: false,
        isWoodenTheme: true,
        isSketchTheme: false,
        successColor: WoodenColors.success,
        errorColor: WoodenColors.error,
        accentColor: WoodenColors.accent,
      );

  /// Extension values for the Sketch visual style.
  static ArrowFlowThemeExtension sketch() =>
      const ArrowFlowThemeExtension(
        arrowColor: SketchColors.arrowColor,
        gridLineColor: SketchColors.gridLine,
        glowColor: Color(0x33FF6B35),
        backgroundGradientStart: SketchColors.background,
        backgroundGradientEnd: SketchColors.paperTexture,
        isNeonTheme: false,
        isSpaceTheme: false,
        isWoodenTheme: false,
        isSketchTheme: true,
        successColor: SketchColors.success,
        errorColor: SketchColors.error,
        accentColor: SketchColors.accent,
      );

  /// Extension values for the Space visual style.
  static ArrowFlowThemeExtension space() =>
      const ArrowFlowThemeExtension(
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
      );
}
