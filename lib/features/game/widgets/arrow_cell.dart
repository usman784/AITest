import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/game/models/arrow.dart';

/// A single cell in the game grid.
///
/// Renders the arrow's direction icon with colour coding, selection glow,
/// hint pulse, and shake animation on a wrong tap. Empty cells show a
/// subtle ghost border.
class ArrowCell extends StatelessWidget {
  const ArrowCell({
    super.key,
    required this.arrow,
    required this.isError,
    required this.isHinted,
    required this.cellSize,
    this.onTap,
  });

  /// `null` → empty cell.
  final Arrow? arrow;

  /// Shows a red shake animation when true.
  final bool isError;

  /// Shows a pulsing hint glow when true.
  final bool isHinted;

  /// Width/height of this cell in logical pixels.
  final double cellSize;

  final VoidCallback? onTap;

  // ── Direction colours ──────────────────────────────────────────────────────

  static const _dirColors = {
    ArrowDirection.up: Color(0xFF4FC3F7),    // sky blue
    ArrowDirection.down: Color(0xFFFFB74D),  // amber
    ArrowDirection.left: Color(0xFF81C784),  // green
    ArrowDirection.right: Color(0xFFEF9A9A), // salmon
  };

  static const _dirIcons = {
    ArrowDirection.up: Icons.arrow_upward_rounded,
    ArrowDirection.down: Icons.arrow_downward_rounded,
    ArrowDirection.left: Icons.arrow_back_rounded,
    ArrowDirection.right: Icons.arrow_forward_rounded,
  };

  @override
  Widget build(BuildContext context) {
    if (arrow == null) return _EmptyCell(cellSize: cellSize);

    final dir = arrow!.direction;
    final color = _dirColors[dir]!;
    final icon = _dirIcons[dir]!;
    final iconSize = (cellSize * 0.42).clamp(14.0, 36.0);
    final fontSize = (cellSize * 0.22).clamp(8.0, 16.0);

    Widget cell = GestureDetector(
      onTap: onTap,
      child: Container(
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withAlpha(isHinted ? 0x66 : 0x44),
              color.withAlpha(isHinted ? 0x44 : 0x22),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isError
                ? const Color(0xFFEF233C)
                : isHinted
                    ? color
                    : color.withAlpha(0x88),
            width: (isError || isHinted) ? 2.5 : 1.5,
          ),
          boxShadow: isHinted
              ? [
                  BoxShadow(
                    color: color.withAlpha(0x66),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            Text(
              arrow!.id.toString(),
              style: TextStyle(
                color: color.withAlpha(0xCC),
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );

    // ── Error shake ──────────────────────────────────────────────────────────
    if (isError) {
      cell = cell
          .animate()
          .shakeX(
            amount: 6,
            duration: 350.ms,
            curve: Curves.elasticOut,
          );
    }

    // ── Hint pulse ───────────────────────────────────────────────────────────
    if (isHinted) {
      cell = cell
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.05,
            duration: 600.ms,
            curve: Curves.easeInOut,
          );
    }

    return cell;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty cell
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyCell extends StatelessWidget {
  const _EmptyCell({required this.cellSize});

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: cs.surface.withAlpha(0x33),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: cs.outline.withAlpha(0x22),
          width: 1,
        ),
      ),
    );
  }
}
