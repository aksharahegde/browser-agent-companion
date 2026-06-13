import 'package:flutter/material.dart';

import '../theme.dart';

class PanelSection extends StatelessWidget {
  const PanelSection({
    super.key,
    this.title,
    required this.child,
    this.flex,
  });

  final String? title;
  final Widget child;
  final int? flex;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    final content = Padding(
      padding: EdgeInsets.all(tokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tokens.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
            ),
            SizedBox(height: tokens.spaceSm),
          ],
          Expanded(child: child),
        ],
      ),
    );

    if (flex != null) {
      return Expanded(flex: flex!, child: content);
    }
    return content;
  }
}
