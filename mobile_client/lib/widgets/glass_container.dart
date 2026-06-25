import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isFake;
  final double opacity;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.isFake = false,
    this.opacity = 0.1,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? Colors.white.withAlpha((opacity * 255).toInt()), width: 1.0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );

    final shape = LiquidRoundedSuperellipse(borderRadius: borderRadius);

    Widget glassWidget;
    if (isFake) {
      glassWidget = FakeGlass(
        shape: shape,
        settings: const LiquidGlassSettings(
          blur: 40,
          glassColor: Color.fromRGBO(28, 30, 35, 0.6),
        ),
        child: content,
      );
    } else {
      glassWidget = LiquidGlass(
        shape: shape,
        child: content,
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: glassWidget);
    }
    return glassWidget;
  }
}
