import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';

class GlassShell extends StatelessWidget {
  const GlassShell({
    super.key,
    required this.child,
    this.opacity = 1.0,
    this.padding,
  });

  final Widget child;
  final double opacity;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: tokens.glassBlur,
          sigmaY: tokens.glassBlur,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tokens.glassFill(opacity),
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border: Border.all(color: tokens.glassBorder),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowSoft,
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }
}
