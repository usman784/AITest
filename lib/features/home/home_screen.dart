import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/features/home/home_provider.dart';

// ── Design tokens (dark premium palette) ─────────────────────────────────────

const _c0 = Color(0xFF0D0B1E);
const _c1 = Color(0xFF1E1560);
const _cAccent = Color(0xFF6C63FF);
const _cAccentBright = Color(0xFF9D8FFF);
const _cGold = Color(0xFFFFC300);
const _cSuccess = Color(0xFF2DC653);

const List<List<Color>> _packGrad = [
  [Color(0xFF4361EE), Color(0xFF7209B7)],
  [Color(0xFF7209B7), Color(0xFFE63946)],
  [Color(0xFFE63946), Color(0xFFF77F00)],
  [Color(0xFFF77F00), Color(0xFFFFC300)],
  [Color(0xFF2DC653), Color(0xFF0077B6)],
  [Color(0xFF00B4D8), Color(0xFF4361EE)],
  [Color(0xFF9B5DE5), Color(0xFFE040FB)],
  [Color(0xFF2EC4B6), Color(0xFF0077B6)],
  [Color(0xFFFF6B6B), Color(0xFFFFC300)],
  [Color(0xFF1A1040), Color(0xFF4361EE)],
];

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  void _onNavTap(int index) {
    if (index == _navIndex) return;
    setState(() => _navIndex = index);
    switch (index) {
      case 1:
        context.go('/level-select');
      case 2:
        context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final packState = ref.watch(homePackProvider);

    if (!packState.isLoaded) {
      return const Scaffold(
        backgroundColor: _c0,
        body: Center(
          child: CircularProgressIndicator(color: _cAccent, strokeWidth: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      extendBody: true,
      bottomNavigationBar: _BottomNav(currentIndex: _navIndex, onTap: _onNavTap),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _HeroBanner(packState: packState)),
          if (packState.hasSavedGame)
            SliverToBoxAdapter(
              child: _ContinueCard(packState: packState),
            ),
          SliverToBoxAdapter(child: _PacksSection(packs: packState.packs)),
          const SliverToBoxAdapter(child: _DailyCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeroBanner
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.packState});
  final HomePackState packState;

  @override
  Widget build(BuildContext context) {
    final packIdx = (packState.currentPack - 1).clamp(0, 9);
    final pack = packState.packs.isNotEmpty ? packState.packs[packIdx] : null;
    final top = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_c0, _c1],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Glow blob
          Positioned(
            top: -20,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _cAccent.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Decorative dim arrows
          Positioned(right: 24, top: top + 80,
            child: _dimArrow('→', 48, 0.07)),
          Positioned(right: 72, top: top + 140,
            child: _dimArrow('↑', 32, 0.05)),
          Positioned(right: 110, top: top + 60,
            child: _dimArrow('↓', 24, 0.04)),

          // Main content
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spaceLG,
              top + AppDimensions.spaceLG,
              AppDimensions.spaceLG,
              AppDimensions.spaceXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ARROWS',
                            style: GoogleFonts.nunito(
                              fontSize: 36, fontWeight: FontWeight.w900,
                              color: Colors.white, letterSpacing: 5, height: 1,
                              shadows: [
                                Shadow(color: _cAccentBright.withValues(alpha: 0.8), blurRadius: 20),
                              ],
                            )),
                        Text('PUZZLE ESCAPE',
                            style: GoogleFonts.nunito(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: _cGold, letterSpacing: 3.5,
                            )),
                      ],
                    ),
                    const Spacer(),
                    _GlassIcon(
                      icon: Icons.settings_rounded,
                      onTap: () => context.go('/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                // Stats row
                Row(
                  children: [
                    _StatPill(
                      icon: Icons.star_rounded,
                      iconColor: _cGold,
                      value: '${packState.totalStars}',
                      label: 'Stars',
                    ),
                    const SizedBox(width: 16),
                    _StatPill(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: _cSuccess,
                      value: '${pack?.completedLevels ?? 0}',
                      label: 'Solved',
                    ),
                    const SizedBox(width: 16),
                    _StatPill(
                      icon: Icons.layers_rounded,
                      iconColor: _cAccentBright,
                      value: 'P${packState.currentPack}',
                      label: pack?.name ?? 'Tutorial',
                    ),
                  ],
                ),
                if (pack != null) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pack.progress,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            color: _cAccentBright,
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(pack.progress * 100).round()}%',
                        style: GoogleFonts.nunito(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.06, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _dimArrow(String g, double sz, double op) => Text(g,
      style: GoogleFonts.nunito(
        fontSize: sz, fontWeight: FontWeight.w900,
        color: Colors.white.withValues(alpha: op),
      ));
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatPill
// ─────────────────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: GoogleFonts.nunito(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: Colors.white, height: 1,
                )),
            Text(label,
                style: GoogleFonts.nunito(
                  fontSize: 10, fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.5),
                )),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GlassIcon
// ─────────────────────────────────────────────────────────────────────────────

class _GlassIcon extends StatelessWidget {
  const _GlassIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ContinueCard
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.packState});
  final HomePackState packState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4361EE), Color(0xFF7209B7)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4361EE).withValues(alpha: 0.45),
                blurRadius: 20, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => context.go(
              '/game/${packState.savedPack}/${packState.savedLevel}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Continue Playing',
                            style: GoogleFonts.nunito(
                              fontSize: 16, fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )),
                        Text(
                          'Pack ${packState.savedPack} · Level ${packState.savedLevel}',
                          style: GoogleFonts.nunito(
                            fontSize: 12, fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 80.ms)
        .slideY(begin: 0.1, end: 0, duration: 350.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PacksSection
// ─────────────────────────────────────────────────────────────────────────────

class _PacksSection extends StatelessWidget {
  const _PacksSection({required this.packs});
  final List<PackProgress> packs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
          child: Row(
            children: [
              Text('Packs',
                  style: GoogleFonts.nunito(
                    fontSize: 22, fontWeight: FontWeight.w900,
                    color: Colors.white, letterSpacing: -0.5,
                  )),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _cAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${packs.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: _cAccentBright,
                    )),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: packs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _PackCard(pack: packs[i], index: i),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PackCard
// ─────────────────────────────────────────────────────────────────────────────

class _PackCard extends StatelessWidget {
  const _PackCard({required this.pack, required this.index});
  final PackProgress pack;
  final int index;

  @override
  Widget build(BuildContext context) {
    final locked = !pack.isUnlocked;
    final gi = (pack.packId - 1).clamp(0, _packGrad.length - 1);
    final grad = _packGrad[gi];

    return SizedBox(
      width: 164,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: locked
                  ? [const Color(0xFF2A2A3E), const Color(0xFF1A1A2E)]
                  : grad,
            ),
            boxShadow: locked
                ? null
                : [
                    BoxShadow(
                      color: grad.last.withValues(alpha: 0.4),
                      blurRadius: 16, offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: InkWell(
            onTap: locked ? null : () => context.go('/levels/${pack.packId}'),
            child: Stack(
              children: [
                // Big decorative arrow
                Positioned(
                  top: -8, right: -6,
                  child: Text('→',
                      style: GoogleFonts.nunito(
                        fontSize: 64, fontWeight: FontWeight.w900,
                        color: Colors.white.withValues(alpha: 0.07),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: locked
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              locked
                                  ? Icons.lock_outline_rounded
                                  : Icons.layers_rounded,
                              size: 11,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 3),
                            Text('Pack ${pack.packId}',
                                style: GoogleFonts.nunito(
                                  fontSize: 11, fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.85),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(pack.name,
                          style: GoogleFonts.nunito(
                            fontSize: 16, fontWeight: FontWeight.w800,
                            color: Colors.white, height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text(pack.difficulty.toUpperCase(),
                          style: GoogleFonts.nunito(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 1.5,
                          )),
                      if (!locked) ...[
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: pack.progress,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.18),
                            color: Colors.white,
                            minHeight: 3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text('${pack.completedLevels}/${pack.totalLevels}',
                            style: GoogleFonts.nunito(
                              fontSize: 10, fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.55),
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 80 + index * 70))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.16, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DailyCard
// ─────────────────────────────────────────────────────────────────────────────

class _DailyCard extends StatefulWidget {
  const _DailyCard();

  @override
  State<_DailyCard> createState() => _DailyCardState();
}

class _DailyCardState extends State<_DailyCard> {
  late Timer _timer;
  late Duration _left;

  @override
  void initState() {
    super.initState();
    _left = _calc();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _left = _calc());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Duration _calc() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day + 1).difference(n);
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1040), Color(0xFF3A0CA3)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3A0CA3).withValues(alpha: 0.5),
                blurRadius: 24, offset: const Offset(0, 8),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => context.go('/game/daily'),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: _cGold, size: 18),
                          const SizedBox(width: 4),
                          Text('Daily Puzzle',
                              style: GoogleFonts.nunito(
                                fontSize: 18, fontWeight: FontWeight.w900,
                                color: Colors.white,
                              )),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 13),
                          const SizedBox(width: 4),
                          Text('Resets in ${_fmt(_left)}',
                              style: GoogleFonts.nunito(
                                fontSize: 12, fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.5),
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_cGold, Color(0xFFFF9F1C)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _cGold.withValues(alpha: 0.4),
                          blurRadius: 12, offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.go('/game/daily'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text('Play',
                              style: GoogleFonts.nunito(
                                fontSize: 15, fontWeight: FontWeight.w800,
                                color: Colors.white,
                              )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 350.ms)
        .slideY(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomNav
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: const Color(0xFF1A1A2E),
      indicatorColor: _cAccent.withValues(alpha: 0.25),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined,
              color: Colors.white.withValues(alpha: 0.55)),
          selectedIcon: const Icon(Icons.home_rounded, color: _cAccentBright),
          label: 'Play',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined,
              color: Colors.white.withValues(alpha: 0.55)),
          selectedIcon:
              const Icon(Icons.grid_view_rounded, color: _cAccentBright),
          label: 'Levels',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined,
              color: Colors.white.withValues(alpha: 0.55)),
          selectedIcon:
              const Icon(Icons.settings_rounded, color: _cAccentBright),
          label: 'Settings',
        ),
      ],
    );
  }
}
