import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arrow_flow/core/constants/app_colors.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/constants/app_typography.dart';
import 'package:arrow_flow/core/di/providers.dart';

// ── SP keys ───────────────────────────────────────────────────────────────────

const String kArrowsSoundEnabled   = 'arrows_sound_enabled';
const String kArrowsHapticsEnabled = 'arrows_haptics_enabled';

// ── SettingsState ─────────────────────────────────────────────────────────────

class SettingsState {
  const SettingsState({
    this.soundEnabled   = true,
    this.hapticsEnabled = true,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;

  SettingsState copyWith({bool? soundEnabled, bool? hapticsEnabled}) {
    return SettingsState(
      soundEnabled:   soundEnabled   ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}

// ── SettingsNotifier ──────────────────────────────────────────────────────────

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._prefs) : super(const SettingsState()) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    state = SettingsState(
      soundEnabled:   _prefs.getBool(kArrowsSoundEnabled)   ?? true,
      hapticsEnabled: _prefs.getBool(kArrowsHapticsEnabled) ?? true,
    );
  }

  Future<void> toggleSound() async {
    final next = !state.soundEnabled;
    await _prefs.setBool(kArrowsSoundEnabled, next);
    state = state.copyWith(soundEnabled: next);
  }

  Future<void> toggleHaptics() async {
    final next = !state.hapticsEnabled;
    await _prefs.setBool(kArrowsHapticsEnabled, next);
    state = state.copyWith(hapticsEnabled: next);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(sharedPreferencesProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// SettingsScreen
// ─────────────────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.ink),
        ),
        title: Text(
          'Settings',
          style: AppTypography.levelLabel.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceLG,
          vertical: AppDimensions.spaceMD,
        ),
        children: [
          // ── Audio section ───────────────────────────────────────────────
          const _SectionHeader(title: 'Audio'),
          _SettingsTile(
            icon: settings.soundEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            title: 'Sound Effects',
            subtitle: settings.soundEnabled ? 'On' : 'Off',
            trailing: Switch(
              value: settings.soundEnabled,
              onChanged: (_) => notifier.toggleSound(),
              activeThumbColor: AppColors.ink,
              activeTrackColor: AppColors.inkLight.withValues(alpha: 0.4),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceSM),

          // ── Feedback section ────────────────────────────────────────────
          const _SectionHeader(title: 'Feedback'),
          _SettingsTile(
            icon: settings.hapticsEnabled
                ? Icons.vibration_rounded
                : Icons.phonelink_erase_rounded,
            title: 'Haptic Feedback',
            subtitle: settings.hapticsEnabled ? 'On' : 'Off',
            trailing: Switch(
              value: settings.hapticsEnabled,
              onChanged: (_) => notifier.toggleHaptics(),
              activeThumbColor: AppColors.ink,
              activeTrackColor: AppColors.inkLight.withValues(alpha: 0.4),
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLG),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppDimensions.spaceMD),

          // ── About section ───────────────────────────────────────────────
          const _SectionHeader(title: 'About'),
          const _SettingsTile(
            icon: Icons.apps_rounded,
            title: 'Arrows – Puzzle Escape',
            subtitle: 'Version 1.0.0',
          ),
          _SettingsTile(
            icon: Icons.policy_outlined,
            title: 'Privacy Policy',
            subtitle: 'View in browser',
            onTap: () {/* TODO: launch URL */},
          ),
          _SettingsTile(
            icon: Icons.star_outline_rounded,
            title: 'Rate the App',
            subtitle: 'Leave a review',
            onTap: () {/* TODO: launch store */},
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionHeader
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppDimensions.spaceSM,
        top: AppDimensions.spaceSM,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.difficultyLabel.copyWith(
          color: AppColors.inkLight,
          letterSpacing: 1.5,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SettingsTile
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.ink, size: 22),
        title: Text(
          title,
          style: AppTypography.levelLabel.copyWith(
            color: AppColors.ink,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.statLabel.copyWith(fontSize: 12),
        ),
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right_rounded,
                    color: AppColors.inkLight, size: 20)
                : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceXS,
        ),
      ),
    );
  }
}
