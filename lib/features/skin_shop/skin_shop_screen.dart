import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';

/// Skin shop screen where players can purchase and equip arrow skins.
class SkinShopScreen extends StatelessWidget {
  const SkinShopScreen({super.key});

  static const List<_SkinItem> _skins = [
    _SkinItem(emoji: '➡️', name: AppStrings.skinDefault, price: 0),
    _SkinItem(emoji: '💡', name: AppStrings.skinNeon, price: 200),
    _SkinItem(emoji: '🪵', name: AppStrings.skinWooden, price: 150),
    _SkinItem(emoji: '🪞', name: AppStrings.skinMetallic, price: 300),
    _SkinItem(emoji: '🌌', name: AppStrings.skinGalaxy, price: 500),
    _SkinItem(emoji: '✏️', name: AppStrings.skinSketch, price: 100),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.skinShopTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _skins.length,
          itemBuilder: (_, i) {
            final skin = _skins[i];
            final isFree = skin.price == 0;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      skin.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      skin.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (isFree)
                      Chip(label: const Text(AppStrings.skinShopEquipped))
                    else
                      Chip(
                        label: Text(
                          '${skin.price} ${AppStrings.skinShopCoins}',
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SkinItem {
  const _SkinItem({
    required this.emoji,
    required this.name,
    required this.price,
  });

  final String emoji;
  final String name;
  final int price;
}
