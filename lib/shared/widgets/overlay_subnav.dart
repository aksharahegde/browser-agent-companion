import 'package:flutter/material.dart';

import '../theme.dart';

class OverlaySubnav extends StatelessWidget {
  const OverlaySubnav({
    super.key,
    required this.title,
    required this.onBack,
    required this.onMinimize,
    this.actions = const [],
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onMinimize;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceMd,
        tokens.spaceSm,
        tokens.spaceMd,
        tokens.spaceSm,
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Back'),
          ),
          SizedBox(width: tokens.spaceSm),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...actions,
          TextButton(
            onPressed: onMinimize,
            child: const Text('Minimize'),
          ),
        ],
      ),
    );
  }
}
