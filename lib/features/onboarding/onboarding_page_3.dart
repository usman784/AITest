import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';

/// Page 3 — Game Modes & Grid Shapes.
///
/// Shows a horizontally scrollable row of five grid-shape preview cards
/// and six colour-coded difficulty badges.
class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  // ── Shape data ─────────────────────────────────────────────────────────────

  static const _shapes = [
    (label: 'Square',      desc: 'Classic grid — great for beginners'),
    (label: 'Hexagonal',   desc: 'Six-sided cells add extra paths'),
    (label: 'Circular',    desc: 'Radial rings, exit from the outside'),
    (label: 'Diamond',     desc: '45° rotated challenge'),
    (label: 'Star',        desc: 'Pointed arms make it tricky'),
  ];

  // ── Difficulty data ────────────────────────────────────────────────────────

  static const _difficulties = [
    (label: 'Tutorial 🟢', color: Color(0xFF2DC653)),
    (label: 'Easy 🔵',     color: Color(0xFF4361EE)),
    (label: 'Medium 🟡',   color: Color(0xFFFFD60A)),
    (label: 'Hard 🟠',     color: Color(0xFFFF9500)),
    (label: 'Expert 🔴',   color: Color(0xFFEF233C)),
    (label: 'Nightmare 💀', color: Color(0xFF6A0DAD)),
  ];

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final bgColor =
        ext?.backgroundGradientStart ?? Theme.of(context).scaffoldBackgroundColor;
    final accent = ext?.accentColor ?? Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 56), // back/skip clearance

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceLG),
              child: Text(
                'Grid Shapes & Modes',
                style: AppTypography.headlineLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            const SizedBox(height: AppDimensions.spaceSM),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceLG),
              child: Text(
                'Five unique grid shapes to master:',
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(0xAA),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spaceMD),

            // ── Shape cards (horizontal scroll) ────────────────────────────
            SizedBox(
              height: 148,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceLG),
                itemCount: _shapes.length,
                itemBuilder: (context, i) {
                  final shape = _shapes[i];
                  return _ShapeCard(
                    index: i,
                    label: shape.label,
                    desc: shape.desc,
                    accent: accent,
                    ext: ext,
                  )
                      .animate(
                          delay: Duration(milliseconds: 100 + i * 60))
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.2, curve: Curves.easeOut);
                },
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLG),

            // ── Difficulty badges ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceLG),
              child: Text(
                'Six difficulty levels:',
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(0xAA),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spaceSM),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceLG),
              child: Wrap(
                spacing: AppDimensions.spaceSM,
                runSpacing: AppDimensions.spaceSM,
                children: List.generate(_difficulties.length, (i) {
                  final d = _difficulties[i];
                  return _DifficultyBadge(label: d.label, color: d.color)
                      .animate(
                          delay: Duration(milliseconds: 200 + i * 80))
                      .fadeIn(duration: 300.ms)
                      .scale(
                          begin: const Offset(0.8, 0.8),
                          curve: Curves.easeOut);
                }),
              ),
            ),

            const Spacer(),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shape card
// ─────────────────────────────────────────────────────────────────────────────

class _ShapeCard extends StatelessWidget {
  const _ShapeCard({
    required this.index,
    required this.label,
    required this.desc,
    required this.accent,
    required this.ext,
  });

  final int index;
  final String label;
  final String desc;
  final Color accent;
  final ArrowFlowThemeExtension? ext;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final outlineColor =
        Theme.of(context).colorScheme.outline.withAlpha(0x55);

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: AppDimensions.spaceSM),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: outlineColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shape preview.
          SizedBox(
            width: 64,
            height: 64,
            child: CustomPaint(
              painter: _ShapePreviewPainter(
                shapeIndex: index,
                color: accent,
                lineColor: ext?.gridLineColor ??
                    Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Difficulty badge
// ─────────────────────────────────────────────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(0x22),
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        border: Border.all(color: color.withAlpha(0x88)),
      ),
      child: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shape Preview Painter — draws a compact 64×64 preview for each grid shape
// ─────────────────────────────────────────────────────────────────────────────

class _ShapePreviewPainter extends CustomPainter {
  const _ShapePreviewPainter({
    required this.shapeIndex,
    required this.color,
    required this.lineColor,
  });

  final int shapeIndex;
  final Color color;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    switch (shapeIndex) {
      case 0:
        _drawSquare(canvas, size);
      case 1:
        _drawHexagonal(canvas, size);
      case 2:
        _drawCircular(canvas, size);
      case 3:
        _drawDiamond(canvas, size);
      case 4:
        _drawStar(canvas, size);
    }
  }

  Paint get _linePaint => Paint()
    ..color = lineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  Paint get _fillPaint => Paint()
    ..color = color.withAlpha(0x33)
    ..style = PaintingStyle.fill;

  // 4×4 square grid.
  void _drawSquare(Canvas canvas, Size size) {
    const cols = 4;
    const rows = 4;
    final cw = size.width / cols;
    final ch = size.height / rows;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(c * cw + 1, r * ch + 1, cw - 2, ch - 2);
        canvas.drawRect(rect, _fillPaint);
        canvas.drawRect(rect, _linePaint);
      }
    }
  }

  // 7 hexagons in a flower (1+6) arrangement.
  void _drawHexagonal(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.14;
    final centers = [
      Offset(cx, cy),
      for (var i = 0; i < 6; i++)
        Offset(
          cx + r * 2.1 * math.cos(i * math.pi / 3),
          cy + r * 2.1 * math.sin(i * math.pi / 3),
        ),
    ];
    for (final c in centers) {
      _drawHex(canvas, c, r);
    }
  }

  void _drawHex(Canvas canvas, Offset center, double r) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 - math.pi / 6;
      final p = Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, _fillPaint);
    canvas.drawPath(path, _linePaint);
  }

  // 3 concentric rings of circles.
  void _drawCircular(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radii = [size.width * 0.12, size.width * 0.28, size.width * 0.44];
    final counts = [1, 6, 12];

    for (var ring = 0; ring < 3; ring++) {
      final n = counts[ring];
      final rr = radii[ring];
      for (var i = 0; i < n; i++) {
        final a = i * (2 * math.pi / n);
        final ox = cx + rr * math.cos(a);
        final oy = cy + rr * math.sin(a);
        final cr = size.width * 0.07;
        canvas.drawCircle(Offset(ox, oy), cr, _fillPaint);
        canvas.drawCircle(Offset(ox, oy), cr, _linePaint);
      }
    }
  }

  // 3×3 grid rotated 45°.
  void _drawDiamond(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final step = size.width * 0.22;
    final cellR = step * 0.38;

    for (var r = -1; r <= 1; r++) {
      for (var c = -1; c <= 1; c++) {
        final ox = cx + (c - r) * step;
        final oy = cy + (c + r) * (step * 0.7);
        final path = Path()
          ..moveTo(ox, oy - cellR)
          ..lineTo(ox + cellR, oy)
          ..lineTo(ox, oy + cellR)
          ..lineTo(ox - cellR, oy)
          ..close();
        canvas.drawPath(path, _fillPaint);
        canvas.drawPath(path, _linePaint);
      }
    }
  }

  // Star with center + 4 arm cells.
  void _drawStar(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.16;
    final armLen = size.width * 0.35;

    // Center cell.
    canvas.drawCircle(Offset(cx, cy), r, _fillPaint);
    canvas.drawCircle(Offset(cx, cy), r, _linePaint);

    // Arms (up, right, down, left).
    const offsets = [
      Offset(0, -1),
      Offset(1, 0),
      Offset(0, 1),
      Offset(-1, 0),
    ];
    for (final dir in offsets) {
      final ox = cx + dir.dx * armLen;
      final oy = cy + dir.dy * armLen;
      canvas.drawCircle(Offset(ox, oy), r, _fillPaint);
      canvas.drawCircle(Offset(ox, oy), r, _linePaint);
      // Connector.
      canvas.drawLine(
        Offset(cx + dir.dx * r, cy + dir.dy * r),
        Offset(ox - dir.dx * r, oy - dir.dy * r),
        _linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ShapePreviewPainter old) => false;
}
