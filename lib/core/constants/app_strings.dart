/// All string constants for the Arrow Flow app.
///
/// No widget file should contain a hard-coded string — every piece of user-
/// visible text must come from this class.
class AppStrings {
  const AppStrings._();

  // ── App ──────────────────────────────────────────────────────────────────────

  static const String appName = 'Arrow Flow';
  static const String appTagline = 'Guide every arrow off the board.';

  // ── Splash ───────────────────────────────────────────────────────────────────

  static const String splashLoading = 'Loading…';

  // ── Onboarding ───────────────────────────────────────────────────────────────

  static const String onboardingTitle1 = 'Welcome to Arrow Flow';
  static const String onboardingBody1 =
      'Tap arrows in the right order to guide them off the board.';
  static const String onboardingTitle2 = 'No Collisions!';
  static const String onboardingBody2 =
      'A wrong tap costs you a life. Think before you tap!';
  static const String onboardingTitle3 = 'Clear the Grid';
  static const String onboardingBody3 =
      'Remove every arrow without any crashes to complete the level.';
  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingGetStarted = 'Get Started';

  // ── Home ─────────────────────────────────────────────────────────────────────

  static const String homePlay = 'Play';
  static const String homeDaily = 'Daily Challenge';
  static const String homeLevels = 'Levels';
  static const String homeSettings = 'Settings';
  static const String homeSkinShop = 'Skin Shop';
  static const String homeAchievements = 'Achievements';
  static const String homeLeaderboard = 'Leaderboard';
  static const String homeContinue = 'Continue';

  // ── Level Select ─────────────────────────────────────────────────────────────

  static const String levelSelectTitle = 'Select Level';
  static const String levelSelectWorld = 'World';
  static const String levelSelectLocked = 'Locked';
  static const String levelSelectCompleted = 'Completed';
  static const String levelSelectPar = 'Par';
  static const String levelSelectBestTime = 'Best';

  // ── World Names ──────────────────────────────────────────────────────────────

  static const String world1Name = 'The Meadow';
  static const String world2Name = 'Neon City';
  static const String world3Name = 'The Forest';
  static const String world4Name = 'The Sketch Pad';
  static const String world5Name = 'Deep Space';

  // ── Game ─────────────────────────────────────────────────────────────────────

  static const String gamePause = 'Pause';
  static const String gameResume = 'Resume';
  static const String gameRestart = 'Restart';
  static const String gameQuit = 'Quit';
  static const String gameHint = 'Hint';
  static const String gameLives = 'Lives';
  static const String gameMoves = 'Moves';
  static const String gameTimer = 'Time';
  static const String gameLevel = 'Level';
  static const String gamePaused = 'Paused';
  static const String gameOver = 'Game Over';
  static const String gameTryAgain = 'Try Again';

  // ── Win Dialog ───────────────────────────────────────────────────────────────

  static const String winTitle = 'Level Complete!';
  static const String winStars = 'Stars';
  static const String winNextLevel = 'Next Level';
  static const String winReplay = 'Replay';
  static const String winShare = 'Share';
  static const String winCoinsEarned = 'Coins Earned';
  static const String winXpEarned = 'XP Earned';

  // ── Settings ─────────────────────────────────────────────────────────────────

  static const String settingsTitle = 'Settings';
  static const String settingsSound = 'Sound Effects';
  static const String settingsMusic = 'Background Music';
  static const String settingsSoundPack = 'Sound Pack';
  static const String settingsHaptics = 'Haptic Feedback';
  static const String settingsTheme = 'Visual Style';
  static const String settingsDarkMode = 'Dark Mode';
  static const String settingsColorblindMode = 'Colorblind Mode';
  static const String settingsLanguage = 'Language';
  static const String settingsPrivacy = 'Privacy Policy';
  static const String settingsTerms = 'Terms of Service';
  static const String settingsRateApp = 'Rate Arrow Flow';
  static const String settingsShareApp = 'Share with Friends';
  static const String settingsRestorePurchases = 'Restore Purchases';
  static const String settingsVersion = 'Version';

  // ── Sound Pack names ─────────────────────────────────────────────────────────

  static const String soundPackArcade = 'Arcade';
  static const String soundPackNature = 'Nature';
  static const String soundPackAsmr = 'ASMR';
  static const String soundPackScifi = 'Sci-Fi';
  static const String soundPackSilent = 'Silent';

  // ── Visual Styles ────────────────────────────────────────────────────────────

  static const String styleMinimalist = 'Minimalist';
  static const String styleNeon = 'Neon';
  static const String styleWooden = 'Wooden';
  static const String styleSketch = 'Sketch';
  static const String styleSpace = 'Space';

  // ── Skin Shop ────────────────────────────────────────────────────────────────

  static const String skinShopTitle = 'Skin Shop';
  static const String skinShopBuy = 'Buy';
  static const String skinShopEquip = 'Equip';
  static const String skinShopEquipped = 'Equipped';
  static const String skinShopUnlock = 'Unlock';
  static const String skinShopCoins = 'Coins';

  // ── Skin names ───────────────────────────────────────────────────────────────

  static const String skinDefault = 'Classic';
  static const String skinNeon = 'Neon Glow';
  static const String skinWooden = 'Oak Wood';
  static const String skinMetallic = 'Chrome';
  static const String skinGalaxy = 'Galaxy';
  static const String skinSketch = 'Sketched';

  // ── Achievements ─────────────────────────────────────────────────────────────

  static const String achievementsTitle = 'Achievements';
  static const String achievementUnlocked = 'Unlocked';
  static const String achievementLocked = 'Locked';

  static const String achievementFirstClear = 'First Clear';
  static const String achievementFirstClearDesc =
      'Complete your first level.';
  static const String achievementSpeedrun = 'Speedrunner';
  static const String achievementSpeedrunDesc =
      'Complete a level in under 10 seconds.';
  static const String achievementPerfect = 'Flawless';
  static const String achievementPerfectDesc =
      'Complete 10 levels without losing a life.';
  static const String achievementWorld1 = 'Meadow Master';
  static const String achievementWorld1Desc =
      'Complete all levels in The Meadow.';
  static const String achievementWorld2 = 'Neon Knight';
  static const String achievementWorld2Desc =
      'Complete all levels in Neon City.';
  static const String achievementCentury = 'Centurion';
  static const String achievementCenturyDesc =
      'Complete 100 levels.';
  static const String achievementDailyStreak = 'On a Roll';
  static const String achievementDailyStreakDesc =
      'Complete 7 daily challenges in a row.';
  static const String achievementNoHints = 'Self-Reliant';
  static const String achievementNoHintsDesc =
      'Complete a world without using any hints.';

  // ── Leaderboard ──────────────────────────────────────────────────────────────

  static const String leaderboardTitle = 'Leaderboard';
  static const String leaderboardGlobal = 'Global';
  static const String leaderboardFriends = 'Friends';
  static const String leaderboardWeekly = 'This Week';
  static const String leaderboardAllTime = 'All Time';
  static const String leaderboardRank = 'Rank';
  static const String leaderboardPlayer = 'Player';
  static const String leaderboardScore = 'Score';

  // ── IAP ──────────────────────────────────────────────────────────────────────

  static const String iapNoAdsTitle = 'Remove Ads';
  static const String iapNoAdsDescription =
      'Enjoy Arrow Flow without any interruptions — forever.';
  static const String iapNoAdsPrice = '\$1.99';
  static const String iapPurchase = 'Purchase';
  static const String iapRestore = 'Restore';
  static const String iapThankYou = 'Thank you for supporting Arrow Flow!';

  // ── Errors & Misc ────────────────────────────────────────────────────────────

  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection.';
  static const String errorLevelLoad = 'Failed to load level data.';
  static const String errorAdNotReady = 'Ad is not ready yet. Try again shortly.';
  static const String hintNotAvailable = 'No more hints available.';
  static const String confirmQuit = 'Are you sure you want to quit?';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String loading = 'Loading…';
  static const String comingSoon = 'Coming Soon';
}
