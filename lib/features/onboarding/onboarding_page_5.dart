import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';
import 'package:arrow_flow/features/onboarding/onboarding_provider.dart';

/// Page 5 — Choose Your Style.
///
/// Collects the player's nickname, avatar selection, confirms the theme and
/// sound-pack choices from page 4, and offers a colorblind toggle.
/// The parent's "Start Playing! 🎮" CTA button calls [OnboardingNotifier.finish].
class OnboardingPage5 extends ConsumerStatefulWidget {
  const OnboardingPage5({super.key});

  @override
  ConsumerState<OnboardingPage5> createState() => _OnboardingPage5State();
}

class _OnboardingPage5State extends ConsumerState<OnboardingPage5> {
  late final TextEditingController _nameCtrl;

  // ── Avatar definitions ────────────────────────────────────────────────────

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
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: ref.read(onboardingNotifierProvider).playerName,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final bgColor =
        ext?.backgroundGradientStart ?? Theme.of(context).scaffoldBackgroundColor;
    final accent =
        ext?.accentColor ?? Theme.of(context).colorScheme.primary;

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
              const SizedBox(height: 48), // back button clearance

              Text(
                'Set Up Your Profile',
                style: AppTypography.headlineLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── Nickname ────────────────────────────────────────────────
              Text(
                'Your nickname',
                style: AppTypography.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceSM),
              TextField(
                controller: _nameCtrl,
                maxLength: 16,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_\- ]')),
                ],
                style: AppTypography.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. ArrowMaster',
                  counterText: '${_nameCtrl.text.length}/16',
                  errorText:
                      state.nameError.isNotEmpty ? state.nameError : null,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                onChanged: (v) {
                  notifier.setPlayerName(v);
                  setState(() {}); // refresh counter
                },
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── Avatar ──────────────────────────────────────────────────
              Text(
                'Choose your avatar',
                style: AppTypography.titleLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              _AvatarGrid(
                icons: _avatarIcons,
                colors: _avatarColors,
                selected: state.selectedAvatar,
                onSelect: notifier.setAvatar,
                accent: accent,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── Summary of page 4 choices ────────────────────────────────
              _SelectionSummary(state: state),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── Colorblind toggle ────────────────────────────────────────
              _ColorblindToggle(
                enabled: state.colorblindMode,
                onChanged: notifier.setColorblindMode,
                accent: accent,
              ).animate().fadeIn(delay: 300.ms),

              // Bottom clearance for the nav bar CTA.
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar grid
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarGrid extends StatelessWidget {
  const _AvatarGrid({
    required this.icons,
    required this.colors,
    required this.selected,
    required this.onSelect,
    required this.accent,
  });

  final List<IconData> icons;
  final List<Color> colors;
  final int selected;
  final ValueChanged<int> onSelect;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppDimensions.spaceSM,
        crossAxisSpacing: AppDimensions.spaceSM,
        childAspectRatio: 1,
      ),
      itemCount: icons.length,
      itemBuilder: (_, i) {
        final isSelected = selected == i;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors[i].withAlpha(0x33)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(
                color: isSelected
                    ? colors[i]
                    : Theme.of(context).colorScheme.outline.withAlpha(0x44),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              icons[i],
              color: isSelected
                  ? colors[i]
                  : Theme.of(context).colorScheme.onSurface.withAlpha(0x88),
              size: 32,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selection summary (theme + sound from page 4)
// ─────────────────────────────────────────────────────────────────────────────

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeName = _styleName(state.selectedStyle);
    final soundName = _soundName(state.selectedSoundPack);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: cs.outline.withAlpha(0x33)),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.palette_rounded,
            label: 'Theme',
            value: themeName,
            cs: cs,
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          _SummaryRow(
            icon: Icons.music_note_rounded,
            label: 'Sound',
            value: soundName,
            cs: cs,
          ),
        ],
      ),
    );
  }

  static String _styleName(dynamic style) {
    const names = {
      'minimalist': 'Minimalist',
      'neon': 'Neon',
      'wooden': 'Wooden',
      'sketch': 'Sketch',
      'space': 'Space',
    };
    final key = style.toString().split('.').last;
    return names[key] ?? key;
  }

  static String _soundName(dynamic pack) {
    const names = {
      'arcade': 'Arcade 🕹️',
      'nature': 'Nature 🌿',
      'asmr': 'ASMR 😌',
      'scifi': 'Sci-Fi 🚀',
      'silent': 'Silent 🔇',
    };
    final key = pack.toString().split('.').last;
    return names[key] ?? key;
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: AppDimensions.spaceSM),
        Text(
          '$label:',
          style: AppTypography.bodyMedium.copyWith(
            color: cs.onSurface.withAlpha(0xAA),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSM),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Colorblind toggle
// ─────────────────────────────────────────────────────────────────────────────

class _ColorblindToggle extends StatelessWidget {
  const _ColorblindToggle({
    required this.enabled,
    required this.onChanged,
    required this.accent,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMD,
        vertical: AppDimensions.spaceSM,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: cs.outline.withAlpha(0x33)),
      ),
      child: Row(
        children: [
          const Icon(Icons.accessibility_new_rounded, size: 24),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Colorblind Mode',
                  style: AppTypography.titleMedium.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  'Uses shapes & patterns alongside colour',
                  style: AppTypography.bodySmall.copyWith(
                    color: cs.onSurface.withAlpha(0x88),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeColor: accent,
          ),
        ],
      ),
    );
  }
}
