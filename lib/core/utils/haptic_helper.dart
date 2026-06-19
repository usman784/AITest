import 'package:flutter/services.dart';

/// Semantic wrapper around Flutter's [HapticFeedback] API.
///
/// Use these methods instead of calling [HapticFeedback] directly so that
/// the intent of each vibration is clear at the call site.
class HapticHelper {
  const HapticHelper._();

  /// Light tap — fired when the player selects an arrow.
  static Future<void> onArrowSelect() =>
      HapticFeedback.lightImpact();

  /// Medium impact — fired on a wrong tap.
  static Future<void> onWrongTap() =>
      HapticFeedback.mediumImpact();

  /// Heavy impact — fired when a level is completed.
  static Future<void> onLevelComplete() =>
      HapticFeedback.heavyImpact();

  /// Medium impact — fired when the player loses a life.
  static Future<void> onLifeLost() =>
      HapticFeedback.mediumImpact();

  /// Light tap — fired when a hint is revealed.
  static Future<void> onHintUsed() =>
      HapticFeedback.lightImpact();

  /// Selection click — fired for general UI navigation taps.
  static Future<void> onUiTap() =>
      HapticFeedback.selectionClick();
}
