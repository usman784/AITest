import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/game/models/arrow.dart';

/// A single cell in the game grid.
///
/// Renders the arrow tile with:
/// - Direction colour + icon
/// - Slide-off animation when [arrow.isSliding]
/// - Pulsing hint glow when [isHinted]
/// - Red shake when [isError] (blocked tap)
/// - Blue path-preview tint when [isPathPreview]
/// - Dimmed look when [canSlide] is false (arrow is currently blocked)
/// Empty cells show a subtle ghost border.
class ArrowCell extends StatelessWidget {
  const ArrowCell({
    super.key,
    required this.arrow,
    required this.isError,
    required this.isHinted,
    required this.isPathPreview,
    required this.canSlide,
    required this.cellSize,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  /// `null` → empty cell.
  final Arrow? arrow;

  final bool isError;
  final bool isHinted;

  /// Cell is on the slide-path of the currently hovered arrow.
  final bool isPathPreview;

  /// Whether the arrow can currently slide off the grid.
  final bool canSlide;

  final double cellSize;

  final VoidCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final VoidCallback? onTapCancel;

  // ── Direction colours ──────────────────────────────────────────────────────

  static const _dirColors = {
    ArrowDirection.up: Color(0xFF4FC3F7),
    ArrowDirection.down: Color(0xFFFFB74D),
    ArrowDirection.left: Color(0xFF81C784),
    ArrowDirection.right: Color(0xFFEF9A9A),
  };

  static const _dirIcons = {
    ArrowDirection.up: Icons.arrow_upward_rounded,
    ArrowDirection.down: Icons.arrow_downward_rounded,
    ArrowDirection.left: Icons.arrow_back_rounded,
    ArrowDirection.right: Icons.arrow_forward_rounded,
  };

  // ── Slide offsets in logical pixels (large enough to exit screen) ─────────

  static Offset _slideEnd(ArrowDirection dir, double cellSize) {
    // Slides ~10 cell-widths in its direction — plenty to clear any grid.
    final d = cellSize * 10;
    switch (dir) {
      case ArrowDirection.up:
        return Offset(0, -d);
      case ArrowDirection.down:
        return Offset(0, d);
      case ArrowDirection.left:
        return Offset(-d, 0);
      case ArrowDirection.right:
        return Offset(d, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Empty cell ─────────────────────────────────────────────────────────
    if (arrow == null) {
      return _EmptyCell(
        cellSize: cellSize,
        isPathPreview: isPathPreview,
      );
    }

    final dir = arrow!.direction;
    final baseColor = _dirColors[dir]!;
    final icon = _dirIcons[dir]!;
    final iconSize = (cellSize * 0.42).clamp(14.0, 36.0);

    // Dim arrow that cannot currently slide.
    final effectiveColor = canSlide ? baseColor : baseColor.withAlpha(0x55);
    final bgAlpha = canSlide ? (isHinted ? 0x66 : 0x44) : 0x1A;

    // ── Base cell widget ───────────────────────────────────────────────────
    Widget cell = GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              effectiveColor.withAlpha(bgAlpha),
              effectiveColor.withAlpha((bgAlpha * 0.6).round()),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isError
                ? const Color(0xFFEF233C)
                : isHinted
                    ? effectiveColor
                    : effectiveColor.withAlpha(canSlide ? 0x99 : 0x33),
            width: (isError || isHinted) ? 2.5 : 1.5,
          ),
          boxShadow: isHinted
              ? [
                  BoxShadow(
                    color: effectiveColor.withAlpha(0x66),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: effectiveColor, size: iconSize),
            // Lock icon overlay for blocked arrows.
            if (!canSlide && !arrow!.isSliding)
              Positioned(
                right: 2,
                bottom: 2,
                child: Icon(
                  Icons.lock_outline_rounded,
                  color: effectiveColor.withAlpha(0x88),
                  size: (cellSize * 0.22).clamp(8.0, 14.0),
                ),
              ),
          ],
        ),
      ),
    );

    // ── Slide animation ────────────────────────────────────────────────────
    if (arrow!.isSliding) {
      final end = _slideEnd(dir, cellSize);
      cell = cell
          .animate()
          .custom(
            duration: 380.ms,
            curve: Curves.easeIn,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(end.dx * value, end.dy * value),
                child: Opacity(
                  opacity: (1.0 - value * 1.8).clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
          );
    }

    // ── Error shake ────────────────────────────────────────────────────────
    if (isError) {
      cell = cell
          .animate()
          .shakeX(amount: 6, duration: 400.ms, curve: Curves.elasticOut);
    }

    // ── Hint pulse ─────────────────────────────────────────────────────────
    if (isHinted) {
      cell = cell
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.06,
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
  const _EmptyCell({required this.cellSize, required this.isPathPreview});

  final double cellSize;
  final bool isPathPreview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: isPathPreview
            ? const Color(0xFF4FC3F7).withAlpha(0x22)
            : cs.surface.withAlpha(0x33),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: isPathPreview
              ? const Color(0xFF4FC3F7).withAlpha(0x88)
              : cs.outline.withAlpha(0x22),
          width: isPathPreview ? 2 : 1,
        ),
        boxShadow: isPathPreview
            ? [
                BoxShadow(
                  color: const Color(0xFF4FC3F7).withAlpha(0x33),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }
}


/// A single cell in the game grid.
///
/// Renders the arrow's direction icon with colour coding, selection glow,
/// hint pulse, and shake animation on a wrong tap. Empty cells show a
