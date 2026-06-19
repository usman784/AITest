import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/features/home/home_provider.dart';

/// Pinned top bar showing avatar, player name, XP level, coins and lives.
///
/// Reads from [homeProvider] and renders a glass-style surface that sits
/// above the main scroll content.
class PlayerStatsBar extends ConsumerWidget {
  const PlayerStatsBar({super.key});

  // Avatar icons mirror onboarding_page_5.dart's avatar list.
  static const List<IconData> _avatarIcons = [
    Icons.arrow_upward_rounded,
    Icons.arrow_forward_rounded,
    Icons.star_rounded,
    Icons.bolt_rounded,
    Icons.auto_awesome_rounded,
    Icons.sports_esports_rounded,
    Icons.psychology_rounded,
    Icons.emoji_events_rounded,
  ];

  static const List<Color> _avatarColors = [
    Color(0xFF4361EE),
    Color(0xFFFF006E),
    Color(0xFF2DC653),
    Color(0xFFFFD60A),
    Color(0xFF00F5FF),
    Color(0xFFFF9500),
    Color(0xFF7C3AED),
    Color(0xFFEF233C),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final avatarIdx = state.playerAvatar.clamp(0, _avatarIcons.length - 1);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spaceMD,
        AppDimensions.spaceSM,
        AppDimensions.spaceMD,
        AppDimensions.spaceSM,
      ),
      decoration: BoxDecoration(
        color: cs.surface.withAlpha(0xEE),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(0x22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ───────────────────────────────────────────────────────
          _Avatar(
            icon: _avatarIcons[avatarIdx],
            color: _avatarColors[avatarIdx],
            name: state.playerName,
          ),

          const SizedBox(width: AppDimensions.spaceSM),

          // ── Name + XP bar ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                _XpBar(
                  level: state.playerLevel,
                  progress: state.levelProgress,
                  xp: state.xp,
                  ext: ext,
                ),
              ],
            ),
          ),

          const SizedBox(width: AppDimensions.spaceMD),

          // ── Coins ────────────────────────────────────────────────────────
          _StatChip(
            icon: Icons.monetization_on_rounded,
            color: SemanticColors.coinsColor,
            value: _formatCount(state.coins),
          ),

          const SizedBox(width: AppDimensions.spaceSM),

          // ── Lives ────────────────────────────────────────────────────────
          _LivesRow(lives: state.lives, maxLives: state.maxLives),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.icon,
    required this.color,
    required this.name,
  });

  final IconData icon;
  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(0x22),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _XpBar extends StatelessWidget {
  const _XpBar({
    required this.level,
    required this.progress,
    required this.xp,
    required this.ext,
  });

  final int level;
  final double progress;
  final int xp;
  final ArrowFlowThemeExtension? ext;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          'Lv.$level',
          style: AppTypography.bodySmall.copyWith(
            color: ext?.accentColor ?? cs.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceXS),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.outline.withAlpha(0x33),
              valueColor: const AlwaysStoppedAnimation<Color>(
                SemanticColors.xpGradientStart,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceSM,
        vertical: AppDimensions.spaceXS,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(0x1A),
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        border: Border.all(color: color.withAlpha(0x55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LivesRow extends StatelessWidget {
  const _LivesRow({required this.lives, required this.maxLives});

  final int lives;
  final int maxLives;

  @override
  Widget build(BuildContext context) {
    // Show up to 5 heart icons regardless of maxLives for compact layout.
    final displayMax = maxLives.clamp(1, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(displayMax, (i) {
        final filled = i < lives;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: filled
                ? SemanticColors.livesColor
                : SemanticColors.livesColor.withAlpha(0x44),
            size: 16,
          ),
        );
      }),
    );
  }
}
