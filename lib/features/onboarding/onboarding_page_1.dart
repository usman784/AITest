import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';

/// Page 1 — Welcome.
///
/// Shows an animated circular arrow logo, the app name, and the tagline.
/// Navigation is handled by the parent [OnboardingScreen] container.
class OnboardingPage1 extends ConsumerStatefulWidget {
  const OnboardingPage1({super.key});

  @override
  ConsumerState<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends ConsumerState<OnboardingPage1>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final accent = ext?.accentColor ?? Theme.of(context).colorScheme.primary;
    final isNeon = ext?.isNeonTheme ?? false;

    return Scaffold(
      backgroundColor: ext?.backgroundGradientStart ??
          Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLG),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Animated circular arrow logo ───────────────────────────────
              SizedBox(
                width: 200,
                height: 200,
                child: AnimatedBuilder(
                  animation: _rotCtrl,
                  builder: (_, __) =>
                      CustomPaint(painter: _CircleArrowPainter(
                    progress: _rotCtrl.value,
                    accentColor: accent,
                    glowColor: ext?.glowColor ?? Colors.transparent,
                    isNeon: isNeon,
                  )),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── App name ───────────────────────────────────────────────────
              Text(
                'Welcome to',
                style: AppTypography.headlineMedium.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(0xCC),
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOut),

              Text(
                'Arrow Flow',
                style: AppTypography.displayMedium.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOut),

              const SizedBox(height: AppDimensions.spaceMD),

              // ── Tagline ────────────────────────────────────────────────────
              Text(
                'The puzzle game where\nevery move matters.',
                style: AppTypography.bodyLarge.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(0xAA),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms),

              const Spacer(flex: 3),

              // Bottom spacer matches the navigation bar height in the parent.
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular Arrow Logo Painter
// ─────────────────────────────────────────────────────────────────────────────

/// Draws four arrow symbols arranged evenly on a circle that rotates slowly.
class _CircleArrowPainter extends CustomPainter {
  const _CircleArrowPainter({
    required this.progress,
    required this.accentColor,
    required this.glowColor,
    required this.isNeon,
  });

  final double progress;
  final Color accentColor;
  final Color glowColor;
  final bool isNeon;

  static const List<String> _symbols = ['↑', '→', '↓', '←'];
  static const List<Color> _colors = [
    Color(0xFF4361EE),
    Color(0xFFFF006E),
    Color(0xFF00F5FF),
    Color(0xFF2DC653),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.35;
    final angle = progress * math.pi * 2;

    // Draw orbit circle.
    final orbitPaint = Paint()
      ..color = accentColor.withAlpha(0x22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), radius, orbitPaint);

    // Draw center logo text.
    final tp = TextPainter(
      text: TextSpan(
        text: '⬡',
        style: TextStyle(fontSize: 28, color: accentColor.withAlpha(0x44)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

    // Draw 4 arrow symbols at evenly-spaced angles, rotating with [angle].
    for (var i = 0; i < 4; i++) {
      final a = angle + (i * math.pi / 2);
      final x = cx + radius * math.cos(a);
      final y = cy + radius * math.sin(a);
      final color = _colors[i];

      if (isNeon) {
        final glowPaint = Paint()
          ..color = color.withAlpha(0x40)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(x, y), 18, glowPaint);
      }

      final tp2 = TextPainter(
        text: TextSpan(
          text: _symbols[i],
          style: TextStyle(
            fontSize: 24,
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp2.paint(canvas, Offset(x - tp2.width / 2, y - tp2.height / 2));
    }
  }

  @override
  bool shouldRepaint(_CircleArrowPainter old) => old.progress != progress;
}
