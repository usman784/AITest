import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All typographic styles used in Arrow Flow.
///
/// Styles are defined as static [TextStyle] constants and assembled into a
/// [TextTheme] via [AppTypography.textTheme].
class AppTypography {
  const AppTypography._();

  // ── Display ──────────────────────────────────────────────────────────────────

  /// Hero text — splash screen, large level numbers.
  static final TextStyle displayLarge = GoogleFonts.nunito(
    fontWeight: FontWeight.w900,
    fontSize: 48,
    letterSpacing: -1.5,
  );

  /// Section headings on marketing / onboarding pages.
  static final TextStyle displayMedium = GoogleFonts.nunito(
    fontWeight: FontWeight.w700,
    fontSize: 36,
  );

  // ── Headline ─────────────────────────────────────────────────────────────────

  /// Screen titles.
  static final TextStyle headlineLarge = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 28,
  );

  /// Card headings, dialog titles.
  static final TextStyle headlineMedium = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 22,
  );

  // ── Title ────────────────────────────────────────────────────────────────────

  /// App bar titles, section headings.
  static final TextStyle titleLarge = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );

  /// Sub-section headings, list item titles.
  static final TextStyle titleMedium = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  // ── Body ─────────────────────────────────────────────────────────────────────

  /// Primary body copy — onboarding, settings descriptions.
  static final TextStyle bodyLarge = GoogleFonts.nunito(
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
  );

  /// Secondary body copy — card descriptions, hints.
  static final TextStyle bodyMedium = GoogleFonts.nunito(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  /// Smallest body copy — captions, footnotes.
  static final TextStyle bodySmall = GoogleFonts.nunito(
    fontWeight: FontWeight.w400,
    fontSize: 12,
  );

  // ── Label ────────────────────────────────────────────────────────────────────

  /// Button labels, tab bar labels.
  static final TextStyle labelLarge = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 0.5,
  );

  /// Chip labels, badge text.
  static final TextStyle labelMedium = GoogleFonts.poppins(
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );

  // ── Game-specific ────────────────────────────────────────────────────────────

  /// Monospaced score / timer display.
  static final TextStyle monoScore = GoogleFonts.spaceMono(
    fontWeight: FontWeight.w400,
    fontSize: 24,
  );

  /// Bold label rendered inside each arrow node.
  static final TextStyle gameArrow = GoogleFonts.nunito(
    fontWeight: FontWeight.w900,
    fontSize: 32,
  );

  /// Coin and XP counter text.
  static final TextStyle currencyCounter = GoogleFonts.spaceMono(
    fontWeight: FontWeight.w700,
    fontSize: 18,
  );

  // ── TextTheme factory ────────────────────────────────────────────────────────

  /// Returns a [TextTheme] built from the typographic styles above.
  ///
  /// Pass this to [ThemeData.textTheme] when constructing a theme.
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
      );
}
