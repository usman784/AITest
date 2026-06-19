import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/di/providers.dart';
import 'package:arrow_flow/core/theme/theme_notifier.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';

/// Settings screen.
///
/// Lets the player switch the visual style, theme mode, and other preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return GradientScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settingsTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Visual Style ──────────────────────────────────────────────────
            Text(
              AppStrings.settingsTheme,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: VisualStyle.values.map((style) {
                final isSelected = themeState.visualStyle == style;
                return ChoiceChip(
                  label: Text(_styleLabel(style)),
                  selected: isSelected,
                  onSelected: (_) => themeNotifier.setVisualStyle(style),
                );
              }).toList(),
            ),
            const Divider(height: 32),

            // ── Theme Mode ────────────────────────────────────────────────────
            Text(
              AppStrings.settingsDarkMode,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ThemeMode.values.map((mode) {
                final isSelected = themeState.themeMode == mode;
                return ChoiceChip(
                  label: Text(_themeModeLabel(mode)),
                  selected: isSelected,
                  onSelected: (_) => themeNotifier.setThemeMode(mode),
                );
              }).toList(),
            ),
            const Divider(height: 32),

            // ── App info ──────────────────────────────────────────────────────
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text(AppStrings.settingsVersion),
              trailing: const Text('1.0.0'),
            ),
          ],
        ),
      ),
    );
  }

  String _styleLabel(VisualStyle style) {
    switch (style) {
      case VisualStyle.minimalist:
        return AppStrings.styleMinimalist;
      case VisualStyle.neon:
        return AppStrings.styleNeon;
      case VisualStyle.wooden:
        return AppStrings.styleWooden;
      case VisualStyle.sketch:
        return AppStrings.styleSketch;
      case VisualStyle.space:
        return AppStrings.styleSpace;
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
