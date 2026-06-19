/// All asset path constants for Arrow Flow.
///
/// Using constants prevents typos in asset paths and makes refactoring easy.
class AppAssets {
  const AppAssets._();

  // ── Lottie Animations ────────────────────────────────────────────────────────

  /// Arrow animation shown on the splash screen.
  static const String splashArrows = 'assets/lottie/splash_arrows.json';

  /// Stars burst on level complete.
  static const String winStars = 'assets/lottie/win_stars.json';

  /// Confetti shower on level complete.
  static const String confetti = 'assets/lottie/confetti.json';

  /// Achievement badge pop-in.
  static const String achievementUnlock = 'assets/lottie/achievement_unlock.json';

  /// Generic loading spinner.
  static const String loadingSpinner = 'assets/lottie/loading_spinner.json';

  // ── Audio — Arcade Pack ───────────────────────────────────────────────────────

  static const String arcadeTapPop = 'assets/audio/arcade/tap_pop.mp3';
  static const String arcadeBuzzError = 'assets/audio/arcade/buzz_error.mp3';
  static const String arcadeWinChime = 'assets/audio/arcade/win_chime.mp3';
  static const String arcadeWhooshUp = 'assets/audio/arcade/whoosh_up.mp3';
  static const String arcadeWhooshDown = 'assets/audio/arcade/whoosh_down.mp3';
  static const String arcadeWhooshLeft = 'assets/audio/arcade/whoosh_left.mp3';
  static const String arcadeWhooshRight = 'assets/audio/arcade/whoosh_right.mp3';
  static const String arcadeLifeLost = 'assets/audio/arcade/life_lost.mp3';

  // ── Audio — Nature Pack ───────────────────────────────────────────────────────

  static const String natureTapLeaf = 'assets/audio/nature/tap_leaf.mp3';
  static const String natureBuzzError = 'assets/audio/nature/buzz_error.mp3';
  static const String natureWinChime = 'assets/audio/nature/win_chime.mp3';
  static const String natureWhooshUp = 'assets/audio/nature/whoosh_up.mp3';
  static const String natureWhooshDown = 'assets/audio/nature/whoosh_down.mp3';
  static const String natureWhooshLeft = 'assets/audio/nature/whoosh_left.mp3';
  static const String natureWhooshRight = 'assets/audio/nature/whoosh_right.mp3';

  // ── Audio — ASMR Pack ────────────────────────────────────────────────────────

  static const String asmrTapPop = 'assets/audio/asmr/tap_pop.mp3';
  static const String asmrBuzzError = 'assets/audio/asmr/buzz_error.mp3';
  static const String asmrWinChime = 'assets/audio/asmr/win_chime.mp3';

  // ── Audio — Sci-Fi Pack ───────────────────────────────────────────────────────

  static const String scifiTapPop = 'assets/audio/scifi/tap_pop.mp3';
  static const String scifiBuzzError = 'assets/audio/scifi/buzz_error.mp3';
  static const String scifiWinChime = 'assets/audio/scifi/win_chime.mp3';
  static const String scifiWhooshUp = 'assets/audio/scifi/whoosh_up.mp3';
  static const String scifiWhooshDown = 'assets/audio/scifi/whoosh_down.mp3';
  static const String scifiWhooshLeft = 'assets/audio/scifi/whoosh_left.mp3';
  static const String scifiWhooshRight = 'assets/audio/scifi/whoosh_right.mp3';

  // ── Audio — Ambient Tracks ────────────────────────────────────────────────────

  /// Lo-fi background loop (default ambient).
  static const String ambientLofi = 'assets/audio/ambient/lofi_beat.mp3';

  /// Forest sounds ambient loop.
  static const String ambientForest = 'assets/audio/ambient/forest_ambient.mp3';

  /// Soft rain ambient loop (ASMR).
  static const String ambientRain = 'assets/audio/ambient/soft_rain.mp3';

  /// Deep space drone ambient loop (Sci-Fi).
  static const String ambientSpaceDrone = 'assets/audio/ambient/space_drone.mp3';

  // ── Images ────────────────────────────────────────────────────────────────────

  /// Wood-grain repeating texture used in the Wooden theme.
  static const String woodGrain = 'assets/images/wood_grain.png';

  /// Paper texture used in the Sketch theme.
  static const String paperTexture = 'assets/images/paper_texture.png';

  // ── Level Data ────────────────────────────────────────────────────────────────

  /// JSON data file for World 1 — The Meadow (minimalist theme).
  static const String world1Levels = 'assets/levels/world_1.json';

  /// JSON data file for World 2 — Neon City (neon theme).
  static const String world2Levels = 'assets/levels/world_2.json';

  /// JSON data file for daily challenge levels.
  static const String dailyChallenges = 'assets/levels/daily_challenges.json';
}
