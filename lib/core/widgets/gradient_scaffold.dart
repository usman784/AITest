import 'package:flutter/material.dart';
import 'package:arrow_flow/core/theme/theme_extension.dart';

/// A [Scaffold] whose background is an animated gradient that shifts slowly
/// to create an ambient living feel.
///
/// The gradient colours are taken from [ArrowFlowThemeExtension] so that they
/// automatically match the active visual style.
class GradientScaffold extends StatefulWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
  });

  /// The primary content of the scaffold.
  final Widget body;

  /// Optional app bar displayed at the top.
  final PreferredSizeWidget? appBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Whether the scaffold should resize when the on-screen keyboard appears.
  final bool resizeToAvoidBottomInset;

  @override
  State<GradientScaffold> createState() => _GradientScaffoldState();
}

class _GradientScaffoldState extends State<GradientScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<ArrowFlowThemeExtension>();
    final start = ext?.backgroundGradientStart ??
        Theme.of(context).colorScheme.surface;
    final end = ext?.backgroundGradientEnd ??
        Theme.of(context).colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: widget.appBar,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (_, child) {
          // Interpolate between start→end and end→start to create a slow
          // oscillating gradient shift.
          final t = _animation.value;
          final gradientStart = Color.lerp(start, end, t * 0.3)!;
          final gradientEnd = Color.lerp(end, start, t * 0.3)!;

          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gradientStart, gradientEnd],
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: widget.body,
      ),
    );
  }
}
