import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/utils/haptic_helper.dart';
import 'package:arrow_flow/features/onboarding/onboarding_page_1.dart';
import 'package:arrow_flow/features/onboarding/onboarding_page_2.dart';
import 'package:arrow_flow/features/onboarding/onboarding_page_3.dart';
import 'package:arrow_flow/features/onboarding/onboarding_page_4.dart';
import 'package:arrow_flow/features/onboarding/onboarding_page_5.dart';
import 'package:arrow_flow/features/onboarding/onboarding_provider.dart';

/// Five-page onboarding flow shown on first launch.
///
/// The container owns navigation controls (Skip, Back, page indicator, CTA
/// button) so individual page widgets remain purely presentational.
///
/// Flow:
///   Page 1 — Welcome
///   Page 2 — How to Play
///   Page 3 — Game Modes & Grid Shapes
///   Page 4 — Themes & Sound
///   Page 5 — Choose Your Style (saves profile → navigates to /home)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  static const int _totalPages = 5;

  // CTA labels indexed by page (0–4).
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

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _animateTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onNext(int currentPage) {
    HapticHelper.onUiTap();
    if (currentPage < _totalPages - 1) {
      _animateTo(currentPage + 1);
    }
  }

  void _onBack(int currentPage) {
    HapticHelper.onUiTap();
    if (currentPage > 0) _animateTo(currentPage - 1);
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final currentPage = state.currentPage;
    final isLast = currentPage == _totalPages - 1;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Page content ─────────────────────────────────────────────────
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (page) => notifier.setPage(page),
            children: const [
              OnboardingPage1(),
              OnboardingPage2(),
              OnboardingPage3(),
              OnboardingPage4(),
              OnboardingPage5(),
            ],
          ),

          // ── Skip button (top-right, pages 0–3) ───────────────────────────
          if (!isLast)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              right: AppDimensions.spaceMD,
              child: TextButton(
                onPressed: _onSkip,
                child: Text(
                  'Skip',
                  style: AppTypography.labelLarge.copyWith(
                    color: cs.onSurface.withAlpha(0x88),
                  ),
                ),
              ),
            ),

          // ── Back button (top-left, pages 1–4) ────────────────────────────
          if (currentPage > 0)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: AppDimensions.spaceSM,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: cs.onSurface.withAlpha(0x88),
                onPressed: () => _onBack(currentPage),
              ),
            ),

          // ── Bottom navigation bar ─────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom +
                AppDimensions.spaceMD,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Page dots
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _totalPages,
                  effect: WormEffect(
                    dotWidth: 8,
                    dotHeight: 8,
                    spacing: 6,
                    activeDotColor: cs.primary,
                    dotColor: cs.onSurface.withAlpha(0x33),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceMD),

                // CTA button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceXL,
                  ),
                  child: _CtaButton(
                    label: _ctaLabels[currentPage],
                    isLast: isLast,
                    enabled: !isLast ||
                        ref
                            .read(onboardingNotifierProvider.notifier)
                            .canFinish,
                    onTap: isLast
                        ? _onFinish
                        : () => _onNext(currentPage),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA button
// ─────────────────────────────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.isLast,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool isLast;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: AppDimensions.buttonHeight,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: isLast ? cs.onPrimary : cs.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
