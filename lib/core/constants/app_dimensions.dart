/// All dimension constants used throughout the Arrow Flow UI.
///
/// Use these values instead of hard-coded numbers to ensure consistent
/// spacing, sizing, and layout across every screen.
class AppDimensions {
  const AppDimensions._();

  // ── Spacing ─────────────────────────────────────────────────────────────────

  /// 4 dp — micro gap between tightly packed elements.
  static const double spaceXS = 4.0;

  /// 8 dp — small gap between related elements.
  static const double spaceSM = 8.0;

  /// 16 dp — standard gap, e.g. between list items.
  static const double spaceMD = 16.0;

  /// 24 dp — large gap, e.g. between card sections.
  static const double spaceLG = 24.0;

  /// 32 dp — extra-large gap, e.g. between major layout regions.
  static const double spaceXL = 32.0;

  /// 48 dp — hero/headline spacing.
  static const double spaceXXL = 48.0;

  // ── Border Radius ────────────────────────────────────────────────────────────

  /// 8 dp — small corner radius, e.g. chips and badges.
  static const double radiusSM = 8.0;

  /// 12 dp — medium corner radius, e.g. input fields.
  static const double radiusMD = 12.0;

  /// 16 dp — large corner radius, e.g. cards.
  static const double radiusLG = 16.0;

  /// 24 dp — extra-large corner radius, e.g. bottom sheets.
  static const double radiusXL = 24.0;

  /// 100 dp — pill / fully rounded shape.
  static const double radiusRound = 100.0;

  // ── Icon Sizes ───────────────────────────────────────────────────────────────

  /// 16 dp — small icon, e.g. inline with text.
  static const double iconSM = 16.0;

  /// 24 dp — standard icon size.
  static const double iconMD = 24.0;

  /// 32 dp — large icon, e.g. feature highlights.
  static const double iconLG = 32.0;

  /// 48 dp — extra-large icon, e.g. empty-state illustrations.
  static const double iconXL = 48.0;

  // ── Game Grid ────────────────────────────────────────────────────────────────

  /// Minimum cell size used on small phones in landscape mode.
  static const double cellSizeMin = 40.0;

  /// Default cell size.
  static const double cellSizeMD = 52.0;

  /// Maximum cell size used on tablets in portrait mode.
  static const double cellSizeMax = 64.0;

  /// Outer padding around the game grid.
  static const double gridPadding = 16.0;

  // ── Arrow Node ───────────────────────────────────────────────────────────────

  /// Default arrow node hit-area / visual size.
  static const double arrowNodeSize = 44.0;

  /// Enlarged node used for boss / key arrows.
  static const double arrowNodeBossSize = 60.0;

  // ── Button ───────────────────────────────────────────────────────────────────

  /// Standard button height.
  static const double buttonHeight = 52.0;

  /// Minimum tap-target size for accessibility.
  static const double minTapTarget = 44.0;

  // ── App Bar ──────────────────────────────────────────────────────────────────

  /// Standard app-bar height.
  static const double appBarHeight = 56.0;

  // ── Bottom Navigation ────────────────────────────────────────────────────────

  /// Height of the bottom navigation bar.
  static const double bottomNavHeight = 64.0;
}
