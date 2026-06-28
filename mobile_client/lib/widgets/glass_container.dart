import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

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
    this.opacity = 0.6,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.glassSurface,
        border: Border.all(color: borderColor ?? AppTheme.outlineGlow, width: 1.0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );

    Widget glassWidget = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: content,
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: glassWidget);
    }
    return glassWidget;
  }
}
