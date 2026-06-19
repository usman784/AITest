import 'package:flutter/material.dart';

/// Colour palette for the Minimalist visual style.
class MinimalistColors {
  const MinimalistColors._();

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF212529);
  static const Color accent = Color(0xFF4361EE);
  static const Color success = Color(0xFF2DC653);
  static const Color error = Color(0xFFEF233C);
  static const Color arrowColor = Color(0xFF343A40);
  static const Color gridLine = Color(0xFFDEE2E6);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
}

/// Colour palette for the Neon visual style.
class NeonColors {
  const NeonColors._();

  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color primary = Color(0xFF00F5FF);
  static const Color accent = Color(0xFFFF006E);
  static const Color success = Color(0xFF00FF94);
  static const Color error = Color(0xFFFF3A3A);
  static const Color arrowColor = Color(0xFF00F5FF);
  static const Color glowColor = Color(0x6600F5FF);
  static const Color gridLine = Color(0xFF1A1A2E);
  static const Color textPrimary = Color(0xFFE0E0FF);
  static const Color textSecondary = Color(0xFF9090B0);
}

/// Colour palette for the Wooden / Natural visual style.
class WoodenColors {
  const WoodenColors._();

  static const Color background = Color(0xFFDEB887);
  static const Color surface = Color(0xFFF5DEB3);
  static const Color primary = Color(0xFF5C3D1E);
  static const Color accent = Color(0xFF8B4513);
  static const Color success = Color(0xFF228B22);
  static const Color error = Color(0xFF8B0000);
  static const Color arrowColor = Color(0xFF3E1C00);
  static const Color textPrimary = Color(0xFF3E1C00);
  static const Color textSecondary = Color(0xFF7A5230);
  static const Color gridLine = Color(0xFFC8A060);
  /// Semi-transparent overlay that simulates a wood-grain texture.
  static const Color grainOverlay = Color(0x0D000000);
}

/// Colour palette for the Sketch / Doodle visual style.
class SketchColors {
  const SketchColors._();

  static const Color background = Color(0xFFFFFDF5);
  static const Color surface = Color(0xFFFEFCE8);
  static const Color primary = Color(0xFF1A1A1A);
  static const Color accent = Color(0xFFFF6B35);
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color arrowColor = Color(0xFF1A1A1A);
  static const Color paperTexture = Color(0xFFFAF9F0);
  /// Ink colour used for sketch-style stroke rendering.
  static const Color inkColor = Color(0xFF2C2C2C);
  /// Stroke colour for the outer sketch outline.
  static const Color sketchStroke = Color(0xFF333333);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF555555);
  static const Color gridLine = Color(0xFFCCCCAA);
}

/// Colour palette for the Space visual style.
class SpaceColors {
  const SpaceColors._();

  static const Color background = Color(0xFF0B0C1E);
  static const Color surface = Color(0xFF131428);
  static const Color primary = Color(0xFFE2E8F0);
  static const Color accent = Color(0xFF7C3AED);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color nebula1 = Color(0xFF7C3AED);
  static const Color nebula2 = Color(0xFF1D4ED8);
  static const Color starField = Color(0xFFFFFFFF);
  /// Colour of the animated meteor / shooting-star effect.
  static const Color meteorColor = Color(0xFFFCD34D);
  static const Color arrowColor = Color(0xFFE2E8F0);
  static const Color gridLine = Color(0xFF1E2040);
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
}

/// Colours chosen to be distinguishable under common colour-vision deficiencies.
class ColorblindSafeColors {
  const ColorblindSafeColors._();

  static const Color safeBlue = Color(0xFF0072B2);
  static const Color safeOrange = Color(0xFFE69F00);
  static const Color safeGreen = Color(0xFF009E73);
  static const Color safeRed = Color(0xFFD55E00);
  static const Color safePurple = Color(0xFFCC79A7);
  static const Color safeYellow = Color(0xFFF0E442);
  static const Color safeSkyBlue = Color(0xFF56B4E9);
  static const Color safeBlack = Color(0xFF000000);
}

/// Semantic colours used for game-specific UI elements.
class SemanticColors {
  const SemanticColors._();

  /// Colour used for the lives / hearts counter.
  static const Color livesColor = Color(0xFFEF233C);

  /// Colour used for the coins counter.
  static const Color coinsColor = Color(0xFFFFD60A);

  /// XP bar gradient — start colour.
  static const Color xpGradientStart = Color(0xFF4361EE);

  /// XP bar gradient — end colour.
  static const Color xpGradientEnd = Color(0xFF7C3AED);

  /// Convenience getter for the XP gradient.
  static const LinearGradient xpGradient = LinearGradient(
    colors: [xpGradientStart, xpGradientEnd],
  );
}
