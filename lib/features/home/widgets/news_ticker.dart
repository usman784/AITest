import 'package:flutter/material.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';

/// A horizontally scrolling announcement ticker.
///
/// Renders a single row of [_kItems] separated by bullet dividers, then
/// seamlessly loops by animating a [Transform.translate] over two side-by-side
/// copies of the row.  The animation starts after the first frame so the
/// content width can be measured with a [GlobalKey].
class NewsTicker extends StatefulWidget {
  const NewsTicker({super.key});

  /// Static announcement strings shown in the ticker.
  static const List<String> _kItems = [
    '🎉  New worlds coming soon — stay tuned!',
    '🏆  Weekly leaderboard resets every Sunday',
    '💡  Hint: plan your path before your first tap',
    '⭐  Earn 3 stars to unlock bonus skins',
    '📅  Don\'t forget your daily challenge!',
    '🔥  Streak bonuses double your XP',
  ];

  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _contentKey = GlobalKey();
  double _contentWidth = 0;

  // Duration per full cycle — adjusted once the true content width is known.
  static const Duration _kBaseDuration = Duration(seconds: 22);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _kBaseDuration);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() => _contentWidth = box.size.width);
        // Scale duration proportionally so speed stays constant.
        final seconds = (_contentWidth / 60).clamp(12, 60).toInt();
        _ctrl.duration = Duration(seconds: seconds);
        _ctrl.repeat();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final accent = ext?.accentColor ?? cs.primary;

    final row = _TickerRow(items: NewsTicker._kItems);

    return Container(
      height: 36,
      color: accent.withAlpha(0x18),
      child: Row(
        children: [
          // Left label
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceSM,
            ),
            color: accent,
            height: 36,
            child: Center(
              child: Text(
                'NEWS',
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          // Scrolling content
          Expanded(
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, child) {
                  final offset = _contentWidth > 0
                      ? -_ctrl.value * _contentWidth
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Row(
                  children: [
                    // First copy — measured with a GlobalKey.
                    _TickerRowKeyed(key: _contentKey, items: NewsTicker._kItems),
                    // Second copy — enables seamless loop.
                    row,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Row helpers
// ─────────────────────────────────────────────────────────────────────────────

class _TickerRow extends StatelessWidget {
  const _TickerRow({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final widgets = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMD,
          ),
          child: Text(
            items[i],
            style: AppTypography.bodySmall.copyWith(
              color: cs.onSurface.withAlpha(0xCC),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
        ),
      );
      if (i < items.length - 1) {
        widgets.add(
          Text(
            '•',
            style: TextStyle(
              color: cs.outline.withAlpha(0x88),
              fontSize: 12,
            ),
          ),
        );
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: widgets);
  }
}

/// Identical to [_TickerRow] but accepts a [Key] for width measurement.
class _TickerRowKeyed extends StatelessWidget {
  const _TickerRowKeyed({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) => _TickerRow(items: items);
}
