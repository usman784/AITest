import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

/// Snapshot of a completed level's result, passed from the game screen to the
/// win dialog via [winProvider].
class WinResult extends Equatable {
  const WinResult({
    required this.levelId,
    required this.stars,
    required this.coinsEarned,
    required this.xpEarned,
    required this.moveCount,
    required this.elapsedTime,
    this.isPerfect = false,
  });

  final int levelId;

  /// 1-3 stars awarded for this run.
  final int stars;

  final int coinsEarned;
  final int xpEarned;
  final int moveCount;
  final Duration elapsedTime;

  /// True when the player solved it in exactly par moves (3-star with no hints).
  final bool isPerfect;

  @override
  List<Object?> get props => [
        levelId,
        stars,
        coinsEarned,
        xpEarned,
        moveCount,
        elapsedTime,
        isPerfect,
      ];
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class WinNotifier extends StateNotifier<WinResult?> {
  WinNotifier() : super(null);

  /// Called by [GameScreen] just before navigating to `/win/:levelId`.
  void setResult(WinResult result) => state = result;

  void clear() => state = null;
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Holds the last [WinResult]. **Not** auto-disposed so the win screen can read
/// it after the game screen is removed from the navigation stack.
final winProvider = StateNotifierProvider<WinNotifier, WinResult?>((ref) {
  return WinNotifier();
});
