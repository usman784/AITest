import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/utils/haptic_helper.dart';
import 'package:arrow_flow/features/home/home_provider.dart';

/// Horizontal scroll card representing a single world.
///
/// Shows the world's gradient, name, emoji, progress ring, and level count.
/// Locked / coming-soon worlds render a frosted overlay.
class WorldPreviewCard extends StatelessWidget {
  const WorldPreviewCard({
    super.key,
    required this.world,
    required this.index,
  });

  final WorldInfo world;

  /// Position in the horizontal list — used to stagger the entrance animation.
  final int index;

  static const double _kCardWidth = 180;
  static const double _kCardHeight = 220;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: SizedBox(
        width: _kCardWidth,
        height: _kCardHeight,
        child: _buildCard(context),
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 60 * index),
            duration: 350.ms,
          )
          .slideX(
            begin: 0.2,
            end: 0,
            delay: Duration(milliseconds: 60 * index),
            duration: 350.ms,
            curve: Curves.easeOut,
          ),
    );
  }

  void _onTap(BuildContext context) {
    if (!world.isUnlocked) return;
    HapticHelper.onUiTap();
    context.go('/level-select/${world.id}');
  }

  Widget _buildCard(BuildContext context) {
    return Stack(
      children: [
        // ── Gradient background ──────────────────────────────────────────
        _GradientBackground(
          gradientStart: world.gradientStart,
          gradientEnd: world.gradientEnd,
        ),

        // ── Content ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress ring
              Align(
                alignment: Alignment.centerRight,
                child: _ProgressRing(
                  progress: world.progress,
                  completed: world.completedLevels,
                  total: world.totalLevels,
                  isComingSoon: world.isComingSoon,
                ),
              ),

              const Spacer(),

              // Emoji
              Text(
                world.emoji,
                style: const TextStyle(fontSize: 32),
              ),

              const SizedBox(height: AppDimensions.spaceXS),

              // World name
              Text(
                world.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    const Shadow(
                      blurRadius: 4,
                      color: Colors.black38,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXS),

              // Level count / coming soon
              if (world.isComingSoon)
                _Badge(label: 'Coming Soon', color: Colors.white30)
              else
                Text(
                  '${world.completedLevels} / ${world.totalLevels} levels',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),

        // ── Locked overlay ────────────────────────────────────────────────
        if (!world.isUnlocked && !world.isComingSoon)
          _LockedOverlay(label: 'Locked'),

        // ── Coming soon overlay ───────────────────────────────────────────
        if (world.isComingSoon) _LockedOverlay(label: 'Coming Soon'),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GradientBackground extends StatelessWidget {
  const _GradientBackground({
    required this.gradientStart,
    required this.gradientEnd,
  });

  final Color gradientStart;
  final Color gradientEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: gradientEnd.withAlpha(0x55),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.completed,
    required this.total,
    required this.isComingSoon,
  });

  final double progress;
  final int completed;
  final int total;
  final bool isComingSoon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: CustomPaint(
        painter: _RingPainter(
          progress: isComingSoon ? 0.0 : progress,
          trackColor: Colors.white24,
          progressColor: Colors.white,
        ),
        child: Center(
          child: isComingSoon
              ? const Icon(Icons.lock_outline_rounded,
                  color: Colors.white54, size: 16)
              : Text(
                  '${(progress * 100).round()}%',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 3;
    const strokeWidth = 4.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Track (full circle).
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc.
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _LockedOverlay extends StatelessWidget {
  const _LockedOverlay({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, color: Colors.white70, size: 32),
              const SizedBox(height: AppDimensions.spaceXS),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
