import 'package:flutter/material.dart';

import '../theme.dart';

class GlassListRow extends StatelessWidget {
  const GlassListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return DecoratedBox(
      decoration: tokens.surfaceDecoration(),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.04),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spaceMd,
              vertical: tokens.spaceSm + 2,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: tokens.spaceSm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodyMedium!,
                        child: title,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        DefaultTextStyle(
                          style: Theme.of(context).textTheme.labelSmall!,
                          child: subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: tokens.spaceSm),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryStatusChip extends StatelessWidget {
  const HistoryStatusChip({super.key, required this.status});

  final String status;

  Color _colorForStatus() {
    final lower = status.toLowerCase();
    if (lower.contains('fail') || lower.contains('error')) {
      return AppColors.historyFailed;
    }
    if (lower.contains('run') || lower.contains('progress')) {
      return AppColors.historyRunning;
    }
    if (lower.contains('complete') || lower.contains('done') || lower == 'ok') {
      return AppColors.historyCompleted;
    }
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus();
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
