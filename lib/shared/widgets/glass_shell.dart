import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme.dart';

class GlassShell extends StatelessWidget {
  const GlassShell({
    super.key,
    required this.child,
    this.opacity = 1.0,
  });

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final radius = BorderRadius.circular(tokens.radiusLg);

    return Padding(
      padding: EdgeInsets.all(tokens.shellInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: tokens.shadowSoft,
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: tokens.glassBlur,
              sigmaY: tokens.glassBlur,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: tokens.shellGradient(opacity),
                borderRadius: radius,
                border: Border.all(color: tokens.glassBorder),
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.35 * opacity),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Material(
                    type: MaterialType.transparency,
                    color: Colors.transparent,
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
