import 'package:flutter/material.dart';
import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/core/utils/haptic_helper.dart';

/// A button that animates to 95 % of its size on press and springs back.
///
/// Optionally displays a neon glow box-shadow via [enableGlow].
///
/// ```dart
/// AnimatedButton(
///   onTap: () => context.go('/home'),
///   enableGlow: true,
///   child: Text('Play'),
/// )
/// ```
class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    super.key,
    required this.child,
    required this.onTap,
    this.backgroundColor,
    this.borderRadius = AppDimensions.radiusMD,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.enableGlow = false,
    this.glowColor,
    this.hapticFeedback = true,
  });

  /// The widget to show inside the button.
  final Widget child;

  /// Called when the button is released.
  final VoidCallback onTap;

  /// Background fill colour. Defaults to the theme's primary colour.
  final Color? backgroundColor;

  /// Corner radius of the button.
  final double borderRadius;

  /// Internal padding around [child].
  final EdgeInsets padding;

  /// When `true`, a soft glow box-shadow is rendered around the button.
  final bool enableGlow;

  /// Colour of the glow. Falls back to [backgroundColor] when `null`.
  final Color? glowColor;

  /// Whether to trigger haptic feedback on press.
  final bool hapticFeedback;

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _controller.forward();
    if (widget.hapticFeedback) HapticHelper.onUiTap();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final baseColor =
        widget.backgroundColor ?? Theme.of(context).colorScheme.primary;
    final glow = widget.glowColor ?? baseColor;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.enableGlow
                ? [
                    BoxShadow(
                      color: glow.withAlpha(_isPressed ? 100 : 60),
                      blurRadius: _isPressed ? 16 : 12,
                      spreadRadius: _isPressed ? 2 : 0,
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
