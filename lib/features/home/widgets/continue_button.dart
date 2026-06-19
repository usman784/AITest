import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/core/utils/haptic_helper.dart';
import 'package:arrow_flow/features/home/home_provider.dart';

/// Prominent "Continue" CTA shown on the home screen when the player has an
/// in-progress level.
///
/// Tapping navigates to `/game/{levelId}` and plays a UI haptic.
class ContinueButton extends ConsumerWidget {
  const ContinueButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    if (!state.hasContinue) return const SizedBox.shrink();

    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final accent = ext?.accentColor ?? Theme.of(context).colorScheme.primary;

    // Find the world name for the continue label.
    final world = state.worlds.isEmpty
        ? null
        : state.worlds.where((w) => w.id == state.currentWorldId).firstOrNull;

    final label = world != null
        ? 'Continue — ${world.name} · Level ${state.currentLevelId}'
        : 'Continue — Level ${state.currentLevelId}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spaceLG,
        AppDimensions.spaceSM,
        AppDimensions.spaceLG,
        0,
      ),
      child: _GradientButton(
        label: label,
        accent: accent,
        onTap: () {
          HapticHelper.onUiTap();
          context.go('/game/${state.currentLevelId}');
        },
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 350.ms)
        .slideY(begin: 0.15, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient button with pulse animation
// ─────────────────────────────────────────────────────────────────────────────

class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: GestureDetector(
        onTapDown: (_) => _pulse.stop(),
        onTapUp: (_) {
          _pulse.repeat(reverse: true);
          widget.onTap();
        },
        onTapCancel: () => _pulse.repeat(reverse: true),
        child: Container(
          height: AppDimensions.buttonHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.accent, _darken(widget.accent, 0.15)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusRound),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withAlpha(0x55),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
