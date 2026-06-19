import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/di/providers.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
// kOnboardingComplete and kUserProfileExists are the source of truth here:
import 'package:arrow_flow/features/onboarding/onboarding_provider.dart'
    show kOnboardingComplete, kUserProfileExists;

// ── Arrow symbols displayed in the logo ──────────────────────────────────────

const List<String> _arrowSymbols = ['↑', '→', '↓', '←', '↑'];

/// Accent colours for each letter of "Arrow" — one per [_arrowSymbols] entry.
const List<Color> _arrowAccents = [
  Color(0xFF4361EE), // ↑ blue
  Color(0xFFFF006E), // → magenta
  Color(0xFF00F5FF), // ↓ cyan
  Color(0xFF2DC653), // ← green
  Color(0xFF7C3AED), // ↑ purple
];

// ─────────────────────────────────────────────────────────────────────────────
// SplashScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Full-screen animated splash shown for 2.8 s on every cold start.
///
/// Animation timeline:
///  0.0–0.6 s  Arrow letters drop in from above with spring physics.
///  0.6–1.2 s  Letters settle; Neon theme adds a glow pulse.
///  1.2–2.0 s  "Flow" subtitle appears with a typewriter effect.
///  2.0–2.8 s  Entire logo scales up 5 % then fades to white → next screen.
///
/// Navigation:
///  • `onboarding_complete` == false  → /onboarding
///  • `user_profile_exists` == false  → /onboarding
///  • otherwise                        → /home
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────────────────

  /// Drives the animated particle background.
  late final AnimationController _particleCtrl;

  /// Drives the loading bar sweep animation.
  late final AnimationController _loadingCtrl;

  /// Drives the full-screen exit fade (white-out).
  late final AnimationController _exitCtrl;

  // ── State ────────────────────────────────────────────────────────────────────

  bool _showFlow = false;
  bool _glowActive = false;
  String _typewriterText = '';
  static const String _flowWord = 'Flow';

  @override
  void initState() {
    super.initState();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _loadingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Step 1 + 2: arrow letters animate in (handled by flutter_animate)
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Trigger glow pulse for Neon / Space themes.
    setState(() => _glowActive = true);

    // Step 3: typewriter for "Flow"
    await _typewriterEffect();
    if (!mounted) return;

    // Step 4: exit + navigate
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    await _exitCtrl.forward();
    if (!mounted) return;

    await _navigateNext();
  }

  Future<void> _typewriterEffect() async {
    for (var i = 1; i <= _flowWord.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      if (!mounted) return;
      setState(() {
        _typewriterText = _flowWord.substring(0, i);
        if (i == 1) _showFlow = true;
      });
    }
    // Small pause at full word before cursor blinks off.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  Future<void> _navigateNext() async {
    final prefs = ref.read(sharedPreferencesProvider);

    // Pre-load world 1 levels while the splash plays.
    try {
      final repo = ref.read(levelRepositoryProvider);
      await repo.getWorld(1);
    } catch (_) {
      // Non-fatal — level data will be loaded lazily on the game screen.
    }

    if (!mounted) return;

    final onboardingDone = prefs.getBool(kOnboardingComplete) ?? false;
    final profileExists = prefs.getBool(kUserProfileExists) ?? false;

    if (!onboardingDone || !profileExists) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    _loadingCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final isNeon = ext?.isNeonTheme ?? false;
    final isSpace = ext?.isSpaceTheme ?? false;
    final gradStart = ext?.backgroundGradientStart ??
        MinimalistColors.background;
    final gradEnd = ext?.backgroundGradientEnd ?? const Color(0xFFECEFF1);
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: _exitCtrl,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _exitCtrl.value,
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: gradStart,
        body: Stack(
          children: [
            // ── Animated background ──────────────────────────────────────────
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _ParticlePainter(
                  progress: _particleCtrl.value,
                  gradientStart: gradStart,
                  gradientEnd: gradEnd,
                  isSpace: isSpace,
                  isNeon: isNeon,
                ),
              ),
            ),

            // ── Main content ──────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo
                  _Logo(
                    glowActive: _glowActive,
                    isNeon: isNeon,
                    isSpace: isSpace,
                    typewriterText: _typewriterText,
                    showFlow: _showFlow,
                  ),

                  const Spacer(flex: 3),

                  // Loading bar
                  _LoadingBar(controller: _loadingCtrl),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── Version number ────────────────────────────────────────────────
            Positioned(
              right: 16,
              bottom: 24,
              child: Text(
                'v1.0.0',
                style: AppTypography.bodySmall.copyWith(
                  color: (ext?.gridLineColor ?? Colors.grey)
                      .withAlpha(0xAA),
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
// Logo widget
// ─────────────────────────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  const _Logo({
    required this.glowActive,
    required this.isNeon,
    required this.isSpace,
    required this.typewriterText,
    required this.showFlow,
  });

  final bool glowActive;
  final bool isNeon;
  final bool isSpace;
  final String typewriterText;
  final bool showFlow;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Arrow" — five coloured arrow symbols drop in
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_arrowSymbols.length, (i) {
            final letter = _arrowSymbols[i];
            final color = _arrowAccents[i];
            return _ArrowLetter(
              symbol: letter,
              color: color,
              index: i,
              glow: glowActive && (isNeon || isSpace),
            );
          }),
        ),

        const SizedBox(height: 4),

        // "Flow" — typewriter reveal
        SizedBox(
          height: 52,
          child: AnimatedOpacity(
            opacity: showFlow ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  typewriterText,
                  style: AppTypography.displayMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Blinking cursor
                _BlinkingCursor(
                    color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    )
        .animate()
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          delay: const Duration(milliseconds: 2000),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        )
        .then()
        .fadeOut(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 200),
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual arrow letter with drop-in spring animation
// ─────────────────────────────────────────────────────────────────────────────

class _ArrowLetter extends StatelessWidget {
  const _ArrowLetter({
    required this.symbol,
    required this.color,
    required this.index,
    required this.glow,
  });

  final String symbol;
  final Color color;
  final int index;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: index * 100);

    Widget letter = Text(
      symbol,
      style: AppTypography.displayLarge.copyWith(
        color: color,
        fontSize: 52,
        shadows: glow
            ? [
                Shadow(color: color.withAlpha(0xCC), blurRadius: 16),
                Shadow(color: color.withAlpha(0x66), blurRadius: 32),
              ]
            : null,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: letter
          .animate(delay: delay)
          .slideY(
            begin: -1.5,
            end: 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
          )
          .fadeIn(
            duration: const Duration(milliseconds: 200),
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Blinking cursor
// ─────────────────────────────────────────────────────────────────────────────

class _BlinkingCursor extends StatelessWidget {
  const _BlinkingCursor({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 32,
      margin: const EdgeInsets.only(left: 2, top: 4),
      color: color,
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeOut(duration: const Duration(milliseconds: 500));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated loading bar
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final accent = ext?.accentColor ?? MinimalistColors.accent;
    final bg = ext?.gridLineColor ?? MinimalistColors.gridLine;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    // Track
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: bg.withAlpha(0x55),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Fill
                    FractionallySizedBox(
                      widthFactor: controller.value,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accent.withAlpha(0xCC),
                              accent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withAlpha(0x66),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Particle / star-field background painter
// ─────────────────────────────────────────────────────────────────────────────

/// A [CustomPainter] that renders 20 slowly drifting particles.
///
/// On the **Space** theme particles are rendered as tiny stars (white dots).
/// On the **Neon** theme they are soft-glowing cyan dots.
/// On other themes they are semi-transparent accent-coloured specks.
class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.progress,
    required this.gradientStart,
    required this.gradientEnd,
    required this.isSpace,
    required this.isNeon,
  }) : _rand = math.Random(42);

  final double progress;
  final Color gradientStart;
  final Color gradientEnd;
  final bool isSpace;
  final bool isNeon;
  final math.Random _rand;

  static const int _particleCount = 20;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw animated gradient background.
    final gradPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientEnd],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), gradPaint);

    // Draw particles.
    final particleColor = isSpace
        ? Colors.white
        : isNeon
            ? NeonColors.primary
            : MinimalistColors.accent;

    for (var i = 0; i < _particleCount; i++) {
      // Each particle has a pseudo-random stable base position derived
      // from its index, then drifts slowly based on [progress].
      final baseX = _rand.nextDouble() * size.width;
      final baseY = _rand.nextDouble() * size.height;
      final speed = 0.3 + _rand.nextDouble() * 0.4;
      final radius = 1.5 + _rand.nextDouble() * 3.0;
      final phase = _rand.nextDouble() * math.pi * 2;

      final dx = math.sin(progress * math.pi * 2 * speed + phase) * 12;
      final dy = math.cos(progress * math.pi * 2 * speed + phase * 0.7) * 8;

      final alpha = (0.25 + 0.45 * math.sin(progress * math.pi * 2 + phase))
          .clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particleColor.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      if (isSpace) {
        // Cross / plus shape for stars.
        final cx = baseX + dx;
        final cy = baseY + dy;
        canvas.drawCircle(Offset(cx, cy), radius * 0.6, paint);
      } else if (isNeon) {
        // Glowing dot with soft shadow.
        final glowPaint = Paint()
          ..color = particleColor.withValues(alpha: alpha * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(baseX + dx, baseY + dy), radius * 2, glowPaint);
        canvas.drawCircle(Offset(baseX + dx, baseY + dy), radius, paint);
      } else {
        canvas.drawCircle(Offset(baseX + dx, baseY + dy), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
