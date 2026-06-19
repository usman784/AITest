import 'package:flutter/material.dart';
import 'package:arrow_flow/core/theme/minimalist_theme.dart';
import 'package:arrow_flow/core/theme/neon_theme.dart';
import 'package:arrow_flow/core/theme/wooden_theme.dart';
import 'package:arrow_flow/core/theme/sketch_theme.dart';
import 'package:arrow_flow/core/theme/space_theme.dart';
import 'package:arrow_flow/core/theme/theme_notifier.dart';

// Re-export per-theme builders so callers only need this one import.
export 'package:arrow_flow/core/theme/minimalist_theme.dart';
export 'package:arrow_flow/core/theme/neon_theme.dart';
export 'package:arrow_flow/core/theme/wooden_theme.dart';
export 'package:arrow_flow/core/theme/sketch_theme.dart';
export 'package:arrow_flow/core/theme/space_theme.dart';
export 'package:arrow_flow/core/theme/theme_extension.dart';

/// Dispatches to the correct per-[VisualStyle] [ThemeData] factory.
///
/// Neon and Space themes always use their dark palette regardless of
/// [brightness] — intentional to preserve the atmosphere of those styles.
///
/// Usage:
/// ```dart
/// final theme = AppTheme.getTheme(VisualStyle.neon, Brightness.dark);
/// ```
class AppTheme {
  const AppTheme._();

  /// Returns the [ThemeData] for [style] at the given [brightness].
  static ThemeData getTheme(VisualStyle style, Brightness brightness) {
    switch (style) {
      case VisualStyle.minimalist:
        return brightness == Brightness.dark
            ? MinimalistTheme.dark()
            : MinimalistTheme.light();
      case VisualStyle.neon:
        return brightness == Brightness.dark
            ? NeonTheme.dark()
            : NeonTheme.light();
      case VisualStyle.wooden:
        return brightness == Brightness.dark
            ? WoodenTheme.dark()
            : WoodenTheme.light();
      case VisualStyle.sketch:
        return brightness == Brightness.dark
            ? SketchTheme.dark()
            : SketchTheme.light();
      case VisualStyle.space:
        return brightness == Brightness.dark
            ? SpaceTheme.dark()
            : SpaceTheme.light();
    }
  }
}
