import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';
import 'package:arrow_flow/features/level_select/level_select_provider.dart';
import 'package:arrow_flow/features/level_select/widgets/level_grid.dart';
import 'package:arrow_flow/features/level_select/widgets/world_tab_bar.dart';

/// Level-select screen — shows a world tab bar and a grid of level cells.
///
/// Accepts an optional [worldId] from the router to jump directly to that
/// world tab on first load.
class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key, this.worldId});

  /// The world to display immediately, or `null` to default to world 1.
  final int? worldId;

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.worldId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(levelSelectProvider.notifier)
            .loadWorld(widget.worldId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(levelSelectProvider);
    final cs = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();

    // Find current world display name from the static list.
    final worldInfo = kWorldInfoList.firstWhere(
      (w) => w.id == state.selectedWorldId,
      orElse: () => kWorldInfoList.first,
    );

    return GradientScaffold(
      body: Column(
        children: [
          // ── Custom app bar ─────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: _AppBar(
              worldName: worldInfo.name,
              worldEmoji: worldInfo.emoji,
              accent: ext?.accentColor ?? cs.primary,
              onBack: () => context.go('/home'),
            ),
          ),

          // ── World tab bar ──────────────────────────────────────────────
          const WorldTabBar(),

          // ── Level grid ─────────────────────────────────────────────────
          const Expanded(child: LevelGrid()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom app bar
// ─────────────────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar({
    required this.worldName,
    required this.worldEmoji,
    required this.accent,
    required this.onBack,
  });

  final String worldName;
  final String worldEmoji;
  final Color accent;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: AppDimensions.appBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceSM),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onBack,
            color: cs.onSurface,
          ),
          const SizedBox(width: AppDimensions.spaceXS),
          Text(worldEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: Text(
              worldName,
              style: AppTypography.titleLarge.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // World count badge
          Text(
            AppStrings.levelSelectTitle,
            style: AppTypography.bodySmall.copyWith(
              color: cs.onSurface.withAlpha(0x88),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
        ],
      ),
    );
  }
}
