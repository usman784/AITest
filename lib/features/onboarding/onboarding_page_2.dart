import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/core/utils/haptic_helper.dart';
import 'package:arrow_flow/core/widgets/glass_card.dart';

/// Page 2 — How to Play.
///
/// Shows a 3×3 demo grid with animated arrows that auto-play the correct tap
/// sequence every 3 seconds. The user can also tap the grid interactively.
/// Three glassmorphism rule cards slide in from the right.
class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({super.key});

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2> {
  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final bgColor =
        ext?.backgroundGradientStart ?? Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLG,
            vertical: AppDimensions.spaceMD,
          ),
          child: Column(
            children: [
              const SizedBox(height: 48), // back/skip button clearance

              Text(
                'How to Play',
                style: AppTypography.headlineLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── Demo grid ────────────────────────────────────────────────
              Center(child: _DemoGrid()),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── Rule cards ───────────────────────────────────────────────
              ..._ruleCards(context),

              // Bottom padding for the navigation bar.
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _ruleCards(BuildContext context) {
    const rules = [
      (icon: Icons.touch_app_rounded, text: 'Tap arrows in the right order'),
      (icon: Icons.route_rounded, text: 'Guide them off the grid without collision'),
      (icon: Icons.favorite_rounded, text: 'Wrong tap = lose a life ❤️'),
    ];

    return List.generate(rules.length, (i) {
      final rule = rules[i];
      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
        child: GlassCard(
          opacity: 0.12,
          child: Row(
            children: [
              Icon(rule.icon,
                  color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: Text(
                  rule.text,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 200 + i * 150))
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.3, curve: Curves.easeOut),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Demo Grid
// ─────────────────────────────────────────────────────────────────────────────

/// 3×3 interactive demo grid.
///
/// Auto-plays the correct tap sequence every 3 s and loops indefinitely.
/// The user can also tap arrows manually.
class _DemoGrid extends StatefulWidget {
  @override
  State<_DemoGrid> createState() => _DemoGridState();
}

class _DemoGridState extends State<_DemoGrid> {
  // Initial arrows: id → (row, col, direction)
  static const _initialArrows = [
    _Arrow(id: 0, row: 0, col: 0, direction: '←'),
    _Arrow(id: 1, row: 0, col: 2, direction: '↑'),
    _Arrow(id: 2, row: 1, col: 1, direction: '↓'),
    _Arrow(id: 3, row: 2, col: 2, direction: '→'),
  ];

  // Correct tap order.
  static const _solution = [1, 3, 0, 2];

  List<_Arrow> _arrows = List.of(_initialArrows);
  final Set<int> _cleared = {};
  int _step = 0;
  int? _highlighted; // positive = correct hint, negative id = error flash
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scheduleNext(delay: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleNext({Duration delay = const Duration(milliseconds: 900)}) {
    _timer?.cancel();
    _timer = Timer(delay, _autoStep);
  }

  void _autoStep() {
    if (!mounted) return;

    if (_step >= _solution.length) {
      // All cleared — reset after a pause.
      _timer = Timer(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _arrows = List.of(_initialArrows);
          _cleared.clear();
          _step = 0;
          _highlighted = null;
        });
        _scheduleNext(delay: const Duration(seconds: 1));
      });
      return;
    }

    final id = _solution[_step];

    // Highlight the arrow to tap.
    setState(() => _highlighted = id);

    // After 600 ms, clear it.
    _timer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _cleared.add(id);
        _highlighted = null;
        _step++;
      });
      _scheduleNext();
    });
  }

  void _onUserTap(int id) {
    if (_cleared.contains(id)) return;
    _timer?.cancel();

    if (_step < _solution.length && _solution[_step] == id) {
      // Correct.
      HapticHelper.onArrowSelect();
      setState(() {
        _cleared.add(id);
        _step++;
        _highlighted = null;
      });
      _scheduleNext();
    } else {
      // Wrong — brief error flash.
      HapticHelper.onWrongTap();
      setState(() => _highlighted = -(id + 1));
      _timer = Timer(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        setState(() => _highlighted = null);
        _scheduleNext();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final accent = ext?.accentColor ?? Theme.of(context).colorScheme.primary;
    const cellSize = 64.0;
    const gridSize = 3;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(0x55),
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: SizedBox(
        width: cellSize * gridSize,
        height: cellSize * gridSize,
        child: Stack(
          children: [
            // Grid lines.
            CustomPaint(
              size: const Size(cellSize * gridSize, cellSize * gridSize),
              painter: _GridLinePainter(
                cellSize: cellSize,
                size: gridSize,
                lineColor: Theme.of(context).colorScheme.outline.withAlpha(0x33),
              ),
            ),

            // Arrow cells.
            for (final arrow in _arrows)
              Positioned(
                left: arrow.col * cellSize,
                top: arrow.row * cellSize,
                width: cellSize,
                height: cellSize,
                child: _highlighted == -(arrow.id + 1)
                    // Error flash.
                    ? _ArrowCell(
                        arrow: arrow,
                        cleared: false,
                        isError: true,
                        accent: accent,
                        onTap: () => _onUserTap(arrow.id),
                      )
                    : AnimatedOpacity(
                        opacity: _cleared.contains(arrow.id) ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: _ArrowCell(
                          arrow: arrow,
                          cleared: _cleared.contains(arrow.id),
                          isHinted: _highlighted == arrow.id,
                          accent: accent,
                          onTap: () => _onUserTap(arrow.id),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Arrow {
  const _Arrow({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
  });

  final int id;
  final int row;
  final int col;
  final String direction;
}

// ─────────────────────────────────────────────────────────────────────────────

class _ArrowCell extends StatelessWidget {
  const _ArrowCell({
    required this.arrow,
    required this.cleared,
    required this.accent,
    required this.onTap,
    this.isHinted = false,
    this.isError = false,
  });

  final _Arrow arrow;
  final bool cleared;
  final bool isHinted;
  final bool isError;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (cleared) return const SizedBox.shrink();

    final bg = isError
        ? Colors.red.withAlpha(0x33)
        : isHinted
            ? accent.withAlpha(0x33)
            : Colors.transparent;

    final border = isHinted
        ? Border.all(color: accent, width: 2)
        : isError
            ? Border.all(color: Colors.red, width: 2)
            : null;

    Widget cell = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          border: border,
        ),
        child: Center(
          child: Text(
            arrow.direction,
            style: AppTypography.gameArrow.copyWith(
              color: isError
                  ? Colors.red
                  : isHinted
                      ? accent
                      : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );

    if (isHinted) {
      cell = cell
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.08, 1.08),
            duration: 500.ms,
          );
    }

    if (isError) {
      cell = cell
          .animate()
          .shakeX(amount: 4, duration: 300.ms);
    }

    return cell;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GridLinePainter extends CustomPainter {
  const _GridLinePainter({
    required this.cellSize,
    required this.size,
    required this.lineColor,
  });

  final double cellSize;
  final int size;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (var i = 1; i < size; i++) {
      final pos = i * cellSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, canvasSize.height), paint);
      canvas.drawLine(Offset(0, pos), Offset(canvasSize.width, pos), paint);
    }
  }

  @override
  bool shouldRepaint(_GridLinePainter old) => false;
}
