import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/game/models/arrow_node.dart';
import 'package:arrow_flow/game/models/maze_layout.dart';
import 'package:arrow_flow/game/logic/path_checker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MazePainter
// ─────────────────────────────────────────────────────────────────────────────

/// [CustomPainter] that renders the maze.
///
/// Corridors are drawn as lines; nodes as circles with arrow glyphs.
/// The currently valid path is highlighted with ink colour.
class MazePainter extends CustomPainter {
  MazePainter({
    required this.layout,
    required this.pathResult,
    this.hintNodeId,
    this.animatingNodeId,
    this.animationValue = 1.0,
  });

  final MazeLayout   layout;
  final PathResult?  pathResult;
  final int?         hintNodeId;
  final int?         animatingNodeId;

  /// [0.0 … 1.0] driven by an [AnimationController] for the rotate spring.
  final double animationValue;

  static const double _padding   = 40.0;
  static const double _nodeRatio = 0.38; // node radius as fraction of cellSize

  // ── Geometry helpers ──────────────────────────────────────────────────────

  double _cellSize(Size size) {
    final availW = size.width  - 2 * _padding;
    final availH = size.height - 2 * _padding;
    final cellW  = availW / math.max(layout.gridCols, 1);
    final cellH  = availH / math.max(layout.gridRows, 1);
    return math.min(cellW, cellH);
  }

  Offset _nodeOffset(ArrowNode node, Size size) {
    final cs = _cellSize(size);
    final ox = (size.width  - cs * layout.gridCols) / 2;
    final oy = (size.height - cs * layout.gridRows) / 2;
    return Offset(ox + node.col * cs + cs / 2, oy + node.row * cs + cs / 2);
  }

  // ── Hit-testing (used by screen) ─────────────────────────────────────────

  /// Returns the node id under [tapOffset], or null if none.
  int? findNodeAt(Offset tapOffset, Size size) {
    final cs = _cellSize(size);
    final r  = cs * _nodeRatio;
    for (final node in layout.nodes) {
      if ((tapOffset - _nodeOffset(node, size)).distance <= r) return node.id;
    }
    return null;
  }

  // ── Paint ────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final cs          = _cellSize(size);
    final nodeR       = cs * _nodeRatio;
    final pathNodeSet = pathResult?.pathNodeIds.toSet() ?? {};

    // ── Corridors ──────────────────────────────────────────────────────────
    final corridorPaint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap   = StrokeCap.round
      ..style       = PaintingStyle.stroke;

    for (final corridor in layout.corridors) {
      final a = layout.nodeById(corridor.fromId);
      final b = layout.nodeById(corridor.toId);
      if (a == null || b == null) continue;

      final onPath = pathNodeSet.contains(a.id) && pathNodeSet.contains(b.id);
      corridorPaint.color = onPath ? AppColors.ink : AppColors.divider;
      corridorPaint.strokeWidth = onPath ? 2.5 : 1.5;

      canvas.drawLine(_nodeOffset(a, size), _nodeOffset(b, size), corridorPaint);
    }

    // ── Nodes ──────────────────────────────────────────────────────────────
    for (final node in layout.nodes) {
      _paintNode(canvas, node, size, nodeR, pathNodeSet);
    }
  }

  void _paintNode(
    Canvas canvas,
    ArrowNode node,
    Size size,
    double nodeR,
    Set<int> pathNodeSet,
  ) {
    final center    = _nodeOffset(node, size);
    final onPath    = pathNodeSet.contains(node.id);
    final isHint    = node.id == hintNodeId;
    final isAnimate = node.id == animatingNodeId;
    final isPerfect = onPath && (pathResult?.isSolved ?? false);
    final isDeadEnd = node.id == pathResult?.deadEndNodeId;

    // ── Scale for animate bounce ──────────────────────────────────────────
    double scale = 1.0;
    if (isAnimate) {
      // spring: scale up then settle
      scale = 1.0 + 0.25 * math.sin(animationValue * math.pi);
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    // ── Background circle ────────────────────────────────────────────────
    final bgPaint = Paint()..style = PaintingStyle.fill;
    if (node.isExit) {
      bgPaint.color = AppColors.background;
    } else if (isPerfect || (onPath && node.isStart)) {
      bgPaint.color = AppColors.ink;
    } else if (node.isFixed) {
      bgPaint.color = const Color(0xFFF5F5F5);
    } else {
      bgPaint.color = AppColors.background;
    }
    canvas.drawCircle(center, nodeR, bgPaint);

    // ── Border ───────────────────────────────────────────────────────────
    final borderPaint = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeWidth = isHint ? 2.5 : 1.5;

    if (isDeadEnd) {
      borderPaint.color = AppColors.errorArrow;
    } else if (isHint) {
      borderPaint.color = AppColors.hintGold;
    } else if (isPerfect || onPath) {
      borderPaint.color = AppColors.ink;
    } else {
      borderPaint.color = node.isFixed ? AppColors.divider : AppColors.ink;
    }
    canvas.drawCircle(center, nodeR, borderPaint);

    // ── Glyph ────────────────────────────────────────────────────────────
    if (node.isExit) {
      // Draw a checkmark inside the exit node.
      final chkPaint = Paint()
        ..color       = onPath ? AppColors.successGreen : AppColors.inkLight
        ..strokeWidth = 2.0
        ..strokeCap   = StrokeCap.round
        ..style       = PaintingStyle.stroke;
      final r = nodeR * 0.5;
      final p1 = center + Offset(-r * 0.6, 0);
      final p2 = center + Offset(-r * 0.1, r * 0.6);
      final p3 = center + Offset(r * 0.7, -r * 0.7);
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy);
      canvas.drawPath(path, chkPaint);
    } else {
      // Draw the arrow glyph as text.
      final glyphColor = (isPerfect || (onPath && node.isStart))
          ? Colors.white
          : isDeadEnd
              ? AppColors.errorArrow
              : AppColors.ink;

      final tp = TextPainter(
        text: TextSpan(
          text: node.direction.glyph,
          style: GoogleFonts.nunito(
            fontSize:   nodeR * 1.1,
            fontWeight: FontWeight.w800,
            color:      glyphColor,
            height:     1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        center - Offset(tp.width / 2, tp.height / 2),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(MazePainter old) =>
      old.layout         != layout         ||
      old.pathResult     != pathResult      ||
      old.hintNodeId     != hintNodeId      ||
      old.animatingNodeId != animatingNodeId ||
      old.animationValue != animationValue;
}
