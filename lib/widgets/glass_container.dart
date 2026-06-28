import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final bool isFake;
  final double opacity;
  final Color? borderColor;
  final double blur;
  final Color? glassColor;
  final BoxBorder? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isFake = false,
    this.opacity = 0.6,
    this.borderColor,
    this.blur = 40.0,
    this.glassColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBorderRadius = borderRadius ?? BorderRadius.circular(24.0);
    
    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: glassColor ?? AppTheme.surface.withValues(alpha: opacity),
        border: border ?? Border.all(color: borderColor ?? AppTheme.outline.withValues(alpha: 0.2), width: 1.0),
        borderRadius: resolvedBorderRadius,
      ),
      child: child,
    );

    Widget glassWidget = ClipRRect(
      borderRadius: resolvedBorderRadius.resolve(Directionality.of(context)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );

    if (margin != null) {
      return Padding(padding: margin!, child: glassWidget);
    }
    return glassWidget;
  }
}
