import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/utils/haptic_helper.dart';
import 'package:arrow_flow/features/onboarding/onboarding_page_1.dart';
import 'package:arrow_flow/features/onboarding/onboarding_page_2.dart';
import 'package:arrow_flow/features/onboarding/onboarding_page_3.dart';
import 'package:arrow_flow/features/onboarding/onboarding_page_4.dart';
import 'package:arrow_flow/features/onboarding/onboarding_page_5.dart';
import 'package:arrow_flow/features/onboarding/onboarding_provider.dart';

// ── Dark premium palette (same as splash/home) ────────────────────────────────

const _oBg0    = Color(0xFF0D0B1E);
const _oBg1    = Color(0xFF1E1560);
const _oAccent = Color(0xFF6C63FF);
const _oAccentB = Color(0xFF9D8FFF);
const _oGold   = Color(0xFFFFC300);

// Per-page accent gradient pairs for the CTA button
const List<List<Color>> _pageGrad = [
  [Color(0xFF6C63FF), Color(0xFF7209B7)],
  [Color(0xFF4361EE), Color(0xFF6C63FF)],
  [Color(0xFF7209B7), Color(0xFFE63946)],
  [Color(0xFF00B4D8), Color(0xFF4361EE)],
  [Color(0xFFFFC300), Color(0xFFFF9F1C)],
];

// ─────────────────────────────────────────────────────────────────────────────
// OnboardingScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Five-page onboarding shown on first launch.
/// Container owns navigation controls; page widgets remain purely presentational.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  static const int _totalPages = 5;

  static const List<String> _ctaLabels = [
    "Let's Go  →",
    'Next  →',
    'Next  →',
    'Next  →',
    'Start Playing! 🎮',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateTo(int page) => _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

  void _onNext(int page) {
    HapticHelper.onUiTap();
    if (page < _totalPages - 1) _animateTo(page + 1);
  }

  void _onBack(int page) {
    HapticHelper.onUiTap();
    if (page > 0) _animateTo(page - 1);
  }

  void _onSkip() {
    HapticHelper.onUiTap();
    _animateTo(_totalPages - 1);
  }

  Future<void> _onFinish() async {
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    if (!notifier.canFinish) return;
    await notifier.finish();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final page   = state.currentPage;
    final isLast = page == _totalPages - 1;
    final pad    = MediaQuery.paddingOf(context);
    final grad   = _pageGrad[page.clamp(0, _pageGrad.length - 1)];

    return Scaffold(
      backgroundColor: _oBg0,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_oBg0, _oBg1],
          ),
        ),
        child: Stack(
          children: [
            // ── Ambient decorative arrows ─────────────────────────────────
            Positioned(
              left: 12, bottom: 160,
              child: Text('↑',
                  style: GoogleFonts.nunito(
                    fontSize: 40, fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.04),
                  )),
            ),
            Positioned(
              right: 16, top: pad.top + 80,
              child: Text('→',
                  style: GoogleFonts.nunito(
                    fontSize: 32, fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.04),
                  )),
            ),

            // ── Animated page glow blob (shifts per page) ─────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              top: page.isEven ? -60 : 100,
              left: page < 2 ? -80 : null,
              right: page >= 2 ? -80 : null,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      grad.first.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Page content ───────────────────────────────────────────────
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (p) => notifier.setPage(p),
              children: const [
                OnboardingPage1(),
                OnboardingPage2(),
                OnboardingPage3(),
                OnboardingPage4(),
                OnboardingPage5(),
              ],
            ),

            // ── Skip button ────────────────────────────────────────────────
            if (!isLast)
              Positioned(
                top: pad.top + 10,
                right: AppDimensions.spaceMD,
                child: TextButton(
                  onPressed: _onSkip,
                  child: Text('Skip',
                      style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.55),
                      )),
                ),
              ),

            // ── Back button ────────────────────────────────────────────────
            if (page > 0)
              Positioned(
                top: pad.top + 6,
                left: 4,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  color: Colors.white.withValues(alpha: 0.55),
                  onPressed: () => _onBack(page),
                ),
              ),

            // ── Bottom bar ────────────────────────────────────────────────
            Positioned(
              left: 0, right: 0,
              bottom: pad.bottom + AppDimensions.spaceMD,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated page dots
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _totalPages,
                    effect: WormEffect(
                      dotWidth: 8, dotHeight: 8, spacing: 6,
                      activeDotColor: _oAccentB,
                      dotColor: Colors.white.withValues(alpha: 0.2),
                      paintStyle: PaintingStyle.fill,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceMD),

                  // Gradient CTA button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceXL),
                    child: _GradientCtaButton(
                      label: _ctaLabels[page],
                      gradient: grad,
                      enabled: !isLast || notifier.canFinish,
                      onTap: isLast ? _onFinish : () => _onNext(page),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// _GradientCtaButton
// ─────────────────────────────────────────────────────────────────────────────

class _GradientCtaButton extends StatelessWidget {
  const _GradientCtaButton({
    required this.label,
    required this.gradient,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final List<Color> gradient;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: Material(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          height: AppDimensions.buttonHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withValues(alpha: 0.45),
                blurRadius: 16, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(key: ValueKey(label))
        .fadeIn(duration: 200.ms)
        .scaleXY(begin: 0.97, end: 1.0, duration: 200.ms, curve: Curves.easeOut);
  }
}
