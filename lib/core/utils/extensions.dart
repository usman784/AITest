import 'package:flutter/material.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';

// ── Color extensions ──────────────────────────────────────────────────────────

/// Utility extensions on [Color].
extension ColorX on Color {
  /// Returns this colour with [value] as the alpha channel (0.0–1.0).
  Color withOpacityValue(double value) => withAlpha((value * 255).round());

  /// Returns the colour as a CSS hex string, e.g. `#FF4361EE`.
  String toHex({bool includeAlpha = true}) {
    final a = includeAlpha ? alpha.toRadixString(16).padLeft(2, '0') : '';
    final r = red.toRadixString(16).padLeft(2, '0');
    final g = green.toRadixString(16).padLeft(2, '0');
    final b = blue.toRadixString(16).padLeft(2, '0');
    return '#${includeAlpha ? a : ''}$r$g$b'.toUpperCase();
  }

  /// Returns a lighter version of this colour by [amount] (0.0–1.0).
  Color lighten(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Returns a darker version of this colour by [amount] (0.0–1.0).
  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

// ── String extensions ─────────────────────────────────────────────────────────

/// Utility extensions on [String].
extension StringX on String {
  /// Returns this string with its first character in upper case.
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Returns `true` if this string is a valid Arrow Flow player name.
  ///
  /// Rules: 2–20 characters, letters / numbers / spaces / underscores only.
  bool get isValidPlayerName {
    if (length < 2 || length > 20) return false;
    return RegExp(r'^[a-zA-Z0-9 _]+$').hasMatch(this);
  }
}

// ── Duration extensions ───────────────────────────────────────────────────────

/// Utility extensions on [Duration].
extension DurationX on Duration {
  /// Formats the duration as a game timer string, e.g. `"02:34"`.
  String toGameTimer() {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

// ── BuildContext extensions ───────────────────────────────────────────────────

/// Convenience extensions on [BuildContext] to reduce boilerplate.
extension BuildContextX on BuildContext {
  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// The Arrow Flow custom theme extension.
  ///
  /// Throws if the extension is not present (should never happen if
  /// [AppTheme] is used correctly).
  ArrowFlowThemeExtension get gameTheme =>
      Theme.of(this).extension<ArrowFlowThemeExtension>()!;

  /// The logical width of the device screen.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// The logical height of the device screen.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// `true` when the device is in landscape orientation.
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// `true` when the shortest side exceeds 600 dp (tablet breakpoint).
  bool get isTablet => MediaQuery.of(this).size.shortestSide >= 600;
}

// ── int extensions ────────────────────────────────────────────────────────────

/// Utility extensions on [int].
extension IntX on int {
  /// Returns the ordinal suffix string, e.g. `1` → `"1st"`, `2` → `"2nd"`.
  String toOrdinal() {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}
