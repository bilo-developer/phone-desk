import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep background
        Container(
          color: AppTheme.background,
        ),
        // Atmospheric blobs
        Positioned(
          top: -100,
          left: -100,
          child: _buildBlob(AppTheme.primary.withAlpha(51), 400), // bg-primary/20
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _buildBlob(AppTheme.secondaryContainer.withAlpha(76), 400), // bg-secondary-container/30
        ),
        Positioned(
          top: 150,
          right: 50,
          child: _buildBlob(AppTheme.tertiaryContainer.withAlpha(25), 300), // bg-tertiary-container/10
        ),
        // Content layer
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }

  Widget _buildBlob(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
