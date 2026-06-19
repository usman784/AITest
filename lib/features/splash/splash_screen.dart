// ── REDESIGNED: Arrows – Puzzle Escape Splash Screen ─────────────────────────
// Rich dark-gradient background with animated floating arrows and glowing logo.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_flow/features/onboarding/onboarding_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Splash palette (self-contained — does not use AppColors to allow full theme)
// ─────────────────────────────────────────────────────────────────────────────

const Color _bg0 = Color(0xFF0D0B1E);
const Color _bg1 = Color(0xFF1A1040);
const Color _bg2 = Color(0xFF0F0C29);
const Color _accent = Color(0xFF6C63FF);
const Color _accentBright = Color(0xFF9D8FFF);
const Color _gold = Color(0xFFFFC300);
const Color _white = Colors.white;

// ─────────────────────────────────────────────────────────────────────────────
// SplashScreen
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loadingCtrl;

  int _arrowsVisible = 0;

  @override
  void initState() {
    super.initState();

    // Light icons on dark background.
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );

    _loadingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 700));
    for (int i = 0; i < 4; i++) {
      if (!mounted) return;
      setState(() => _arrowsVisible = i + 1);
      if (i < 3) await Future.delayed(const Duration(milliseconds: 180));
    }
    if (!mounted) return;
    await _loadingCtrl.forward();
    if (!mounted) return;
    // Route to onboarding on first launch, home on subsequent launches.
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(kOnboardingComplete) ?? false;
    if (mounted) context.go(onboardingDone ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _loadingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bg0, _bg1, _bg2],
          ),
        ),
        child: Stack(
          children: [
            // ── Scattered ambient arrows ──────────────────────────────────
            ..._ambientArrows(size),

            // ── Glow orb behind logo ──────────────────────────────────────
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accent.withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Central logo ──────────────────────────────────────────────
            Center(
              child: _LogoDiamond(arrowsVisible: _arrowsVisible),
            ),

            // ── Bottom gradient progress bar ──────────────────────────────
            Positioned(
              left: 40,
              right: 40,
              bottom: 52,
              child: Column(
                children: [
                  Text(
                    'loading…',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: _white.withValues(alpha: 0.35),
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _loadingCtrl,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [_accent, _gold],
                        ).createShader(bounds),
                        child: LinearProgressIndicator(
                          value: _loadingCtrl.value,
                          backgroundColor:
                              _white.withValues(alpha: 0.08),
                          color: _white,
                          minHeight: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 14 fixed ambient arrow symbols scattered across the screen
  List<Widget> _ambientArrows(Size size) {
    final items = [
      // (glyph, left%, top%, size, opacity, rotation)
      ('↑', 0.08, 0.10, 22.0, 0.12, 0.2),
      ('→', 0.85, 0.08, 18.0, 0.10, -0.1),
      ('↓', 0.12, 0.75, 26.0, 0.14, 0.3),
      ('←', 0.80, 0.80, 20.0, 0.11, -0.2),
      ('↑', 0.50, 0.06, 16.0, 0.09, 0.0),
      ('→', 0.05, 0.45, 20.0, 0.10, 0.1),
      ('↓', 0.90, 0.50, 18.0, 0.08, -0.15),
      ('←', 0.45, 0.88, 24.0, 0.13, 0.25),
      ('↑', 0.68, 0.18, 14.0, 0.07, -0.05),
      ('→', 0.28, 0.20, 16.0, 0.08, 0.15),
      ('↓', 0.70, 0.70, 22.0, 0.10, 0.0),
      ('←', 0.18, 0.60, 14.0, 0.07, -0.1),
      ('↑', 0.92, 0.30, 18.0, 0.09, 0.3),
      ('→', 0.38, 0.92, 16.0, 0.08, -0.2),
    ];

    return items.indexed.map((entry) {
      final i   = entry.$1;
      final item = entry.$2;
      final (glyph, lPct, tPct, sz, op, rot) = item;
      return Positioned(
        left: size.width  * lPct,
        top:  size.height * tPct,
        child: Transform.rotate(
          angle: rot,
          child: Text(
            glyph,
            style: GoogleFonts.nunito(
              fontSize: sz,
              fontWeight: FontWeight.w900,
              color: _white.withValues(alpha: op),
            ),
          ),
        )
            .animate(delay: Duration(milliseconds: 300 + i * 80))
            .fadeIn(duration: 600.ms),
      );
    }).toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LogoDiamond
// ─────────────────────────────────────────────────────────────────────────────

class _LogoDiamond extends StatelessWidget {
  const _LogoDiamond({required this.arrowsVisible});

  final int arrowsVisible;

  static const double _dist = 80.0;
  static const double _size = 260.0;
  static const double _half = _size / 2.0;

  static const List<(String, double, double)> _arrows = [
    ('↑',  0.0,   -_dist),
    ('→',  _dist,  0.0),
    ('↓',  0.0,    _dist),
    ('←', -_dist,  0.0),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Wordmark ───────────────────────────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ARROWS',
                style: GoogleFonts.nunito(
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  color: _white,
                  letterSpacing: 6.0,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: _accentBright.withValues(alpha: 0.9),
                      blurRadius: 24,
                    ),
                    Shadow(
                      color: _accent.withValues(alpha: 0.5),
                      blurRadius: 48,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),
              const SizedBox(height: 6),
              Text(
                'PUZZLE ESCAPE',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _gold,
                  letterSpacing: 4.0,
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            ],
          ),

          // ── Directional arrows ─────────────────────────────────────────
          for (int i = 0; i < _arrows.length; i++)
            if (i < arrowsVisible)
              Positioned(
                left: _half + _arrows[i].$2 - 16,
                top:  _half + _arrows[i].$3 - 16,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _accentBright.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _accentBright.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _arrows[i].$1,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _white,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: _accentBright,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.0, 0.0),
                      end: const Offset(1.0, 1.0),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 200.ms),
              ),
        ],
      ),
    );
  }
}
