import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/di/providers.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/core/theme/theme_notifier.dart';
import 'package:arrow_flow/core/utils/audio_helper.dart';
import 'package:arrow_flow/features/onboarding/onboarding_provider.dart';

/// Page 4 — Themes & Sound.
///
/// Lets the user pick a visual theme (previewed live), choose a sound pack
/// (1.5 s audio preview), and set Light / Dark / Auto app mode.
class OnboardingPage4 extends ConsumerWidget {
  const OnboardingPage4({super.key});

  // ── Theme swatches ──────────────────────────────────────────────────────────

  static const _themes = [
    (style: VisualStyle.minimalist, color: Color(0xFF4361EE), label: 'Clean'),
    (style: VisualStyle.neon,       color: Color(0xFF00F5FF), label: 'Neon'),
    (style: VisualStyle.wooden,     color: Color(0xFF8B4513), label: 'Wood'),
    (style: VisualStyle.sketch,     color: Color(0xFFFF6B35), label: 'Sketch'),
    (style: VisualStyle.space,      color: Color(0xFF7C3AED), label: 'Space'),
  ];

  // ── Sound packs ─────────────────────────────────────────────────────────────

  static const _packs = [
    (pack: SoundPack.arcade,  icon: Icons.sports_esports_rounded,  label: 'Arcade 🕹️'),
    (pack: SoundPack.nature,  icon: Icons.forest_rounded,          label: 'Nature 🌿'),
    (pack: SoundPack.asmr,    icon: Icons.spa_rounded,             label: 'ASMR 😌'),
    (pack: SoundPack.scifi,   icon: Icons.rocket_launch_rounded,   label: 'Sci-Fi 🚀'),
    (pack: SoundPack.silent,  icon: Icons.volume_off_rounded,      label: 'Silent 🔇'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final bgColor =
        ext?.backgroundGradientStart ?? Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLG,
            vertical: AppDimensions.spaceMD,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48), // back/skip clearance

              Text(
                'Your Style',
                style: AppTypography.headlineLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── Visual theme ──────────────────────────────────────────────
              Text(
                'Visual Theme',
                style: AppTypography.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _themes.map((t) {
                  final isSelected = state.selectedStyle == t.style;
                  return GestureDetector(
                    onTap: () => notifier.setThemeStyle(t.style),
                    child: _ThemeSwatch(
                      color: t.color,
                      label: t.label,
                      isSelected: isSelected,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── Sound pack ────────────────────────────────────────────────
              Text(
                'Sound Pack',
                style: AppTypography.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Wrap(
                spacing: AppDimensions.spaceSM,
                runSpacing: AppDimensions.spaceSM,
                children: _packs.map((p) {
                  final isSelected = state.selectedSoundPack == p.pack;
                  return GestureDetector(
                    onTap: () {
                      notifier.setSoundPack(p.pack);
                      // Play 1.5 s audio preview.
                      _previewSound(ref, p.pack);
                    },
                    child: _SoundPackChip(
                      icon: p.icon,
                      label: p.label,
                      isSelected: isSelected,
                      selectedColor:
                          ext?.accentColor ??
                          Theme.of(context).colorScheme.primary,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── App mode ──────────────────────────────────────────────────
              Text(
                'Appearance',
                style: AppTypography.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              _AppearanceToggle(
                current: state.themeMode,
                onChanged: notifier.setThemeMode,
              ),

              const SizedBox(height: 110), // nav bar clearance
            ],
          ),
        ),
      ),
    );
  }

  /// Triggers a 1.5 s audio preview for [pack] using the AudioService.
  void _previewSound(WidgetRef ref, SoundPack pack) {
    final audio = ref.read(audioServiceProvider);
    audio.loadSoundPack(pack);
    audio.playSfx(SoundEffect.tapSuccess);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme swatch
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.color,
    required this.label,
    required this.isSelected,
  });

  final Color color;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withAlpha(0x66),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(0xCC),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sound pack chip
// ─────────────────────────────────────────────────────────────────────────────

class _SoundPackChip extends StatelessWidget {
  const _SoundPackChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? selectedColor.withAlpha(0x22)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        border: Border.all(
          color: isSelected
              ? selectedColor
              : Theme.of(context).colorScheme.outline.withAlpha(0x55),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 18,
              color: isSelected
                  ? selectedColor
                  : Theme.of(context).colorScheme.onSurface.withAlpha(0xAA)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected
                  ? selectedColor
                  : Theme.of(context).colorScheme.onSurface.withAlpha(0xCC),
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Appearance toggle (Light / Dark / Auto)
// ─────────────────────────────────────────────────────────────────────────────

class _AppearanceToggle extends StatelessWidget {
  const _AppearanceToggle({
    required this.current,
    required this.onChanged,
  });

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  static const _modes = [
    (mode: ThemeMode.light,  icon: Icons.light_mode_rounded,  label: 'Light'),
    (mode: ThemeMode.system, icon: Icons.brightness_auto_rounded, label: 'Auto'),
    (mode: ThemeMode.dark,   icon: Icons.dark_mode_rounded,   label: 'Dark'),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(0x44),
        ),
      ),
      child: Row(
        children: _modes.map((m) {
          final isActive = current == m.mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(m.mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isActive ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      m.icon,
                      size: 16,
                      color: isActive
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(0x88),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      m.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: isActive
                            ? Colors.white
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(0x88),
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
