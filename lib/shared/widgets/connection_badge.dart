import 'package:flutter/material.dart';

import '../../data/models/trace_event.dart';
import 'status_pill.dart';

@Deprecated('Use StatusPill.connection instead')
class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key, required this.status, required this.host});

  final ConnectionStatus status;
  final String host;

  @override
  Widget build(BuildContext context) {
    return StatusPill.connection(status: status, host: host);
  }
}
