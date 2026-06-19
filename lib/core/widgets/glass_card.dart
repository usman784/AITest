import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';

/// A frosted-glass card that blurs the content behind it.
///
/// Uses [BackdropFilter] with [ImageFilter.blur] to create the glass effect.
/// The [opacity] parameter controls how opaque the card background is
/// (lower = more transparent / glassy).
///
/// ```dart
/// GlassCard(
///   child: Text('Hello'),
///   opacity: 0.2,
/// )
/// ```
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.opacity = 0.15,
    this.borderRadius = AppDimensions.radiusLG,
    this.padding = const EdgeInsets.all(AppDimensions.spaceMD),
    this.borderColor,
    this.blurSigma = 10.0,
  });

  /// The widget rendered inside the glass card.
  final Widget child;

  /// Background opacity in the range [0.0, 1.0].
  final double opacity;

  /// Corner radius of the card.
  final double borderRadius;

  /// Internal padding.
  final EdgeInsets padding;

  /// Border colour. Defaults to white at 30 % opacity.
  final Color? borderColor;

  /// Blur sigma applied by [ImageFilter.blur].
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final border = borderColor ??
        Theme.of(context).colorScheme.onSurface.withAlpha(77);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surface
                .withAlpha((opacity * 255).round()),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: border, width: 1.0),
          ),
          child: child,
        ),
      ),
    );
  }
}
