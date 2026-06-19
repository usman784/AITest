import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';
import 'package:arrow_flow/features/home/home_provider.dart';
import 'package:arrow_flow/features/home/widgets/continue_button.dart';
import 'package:arrow_flow/features/home/widgets/daily_challenge_card.dart';
import 'package:arrow_flow/features/home/widgets/news_ticker.dart';
import 'package:arrow_flow/features/home/widgets/player_stats_bar.dart';
import 'package:arrow_flow/features/home/widgets/world_preview_card.dart';

/// Home screen — shown after onboarding completes.
///
/// Layout (top → bottom):
/// 1. [PlayerStatsBar]  — pinned above the scroll area
/// 2. [NewsTicker]      — scrolling announcements strip
/// 3. Scrollable body:
///    a. [ContinueButton] (if an in-progress level exists)
///    b. [DailyChallengeCard]
///    c. "Adventures" section header
///    d. Horizontal world-card list ([WorldPreviewCard] × 10)
/// 4. [NavigationBar]   — bottom nav: Play / Levels / Shop / Achievements
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Bottom-nav index: 0 = Play (home), others navigate away.
  int _navIndex = 0;

  void _onNavTap(int index) {
    if (index == _navIndex) return;
    switch (index) {
      case 1:
        context.go('/level-select');
        break;
      case 2:
        context.go('/skin-shop');
        break;
      case 3:
        context.go('/achievements');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();

    if (!state.isLoaded) {
      return const GradientScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return GradientScaffold(
      body: Column(
        children: [
          // ── Pinned stats bar (below system status bar) ─────────────────
          SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PlayerStatsBar(),
                const NewsTicker(),
              ],
            ),
          ),

          // ── Scrollable main content ────────────────────────────────────
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Continue button
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppDimensions.spaceMD),
                      const ContinueButton(),
                    ],
                  ),
                ),

                // Daily challenge
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppDimensions.spaceMD),
                    child: DailyChallengeCard(),
                  ),
                ),

                // "Adventures" section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.spaceLG,
                      AppDimensions.spaceLG,
                      AppDimensions.spaceLG,
                      AppDimensions.spaceSM,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Adventures',
                          style: AppTypography.headlineMedium.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideX(begin: -0.1, end: 0, delay: 200.ms),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.go('/level-select'),
                          child: Text(
                            'See all',
                            style: AppTypography.bodyMedium.copyWith(
                              color: ext?.accentColor ?? cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Horizontal world cards
                SliverToBoxAdapter(
                  child: _WorldCarousel(worlds: state.worlds),
                ),

                // Bottom padding for nav bar clearance
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.spaceLG),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// World carousel
// ─────────────────────────────────────────────────────────────────────────────

class _WorldCarousel extends StatelessWidget {
  const _WorldCarousel({required this.worlds});

  final List<WorldInfo> worlds;

  @override
  Widget build(BuildContext context) {
    if (worlds.isEmpty) {
      return const SizedBox(height: 220);
    }
    return SizedBox(
      height: 228,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceLG,
          vertical: AppDimensions.spaceXS,
        ),
        itemCount: worlds.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppDimensions.spaceMD),
        itemBuilder: (_, i) => WorldPreviewCard(
          world: worlds[i],
          index: i,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: cs.surface.withAlpha(0xEE),
      indicatorColor: cs.primaryContainer,
      height: AppDimensions.bottomNavHeight,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: AppStrings.homePlay,
        ),
        NavigationDestination(
          icon: const Icon(Icons.grid_view_outlined),
          selectedIcon: const Icon(Icons.grid_view_rounded),
          label: AppStrings.homeLevels,
        ),
        NavigationDestination(
          icon: const Icon(Icons.storefront_outlined),
          selectedIcon: const Icon(Icons.storefront_rounded),
          label: AppStrings.homeSkinShop,
        ),
        NavigationDestination(
          icon: const Icon(Icons.emoji_events_outlined),
          selectedIcon: const Icon(Icons.emoji_events_rounded),
          label: AppStrings.homeAchievements,
        ),
      ],
    );
  }
}
