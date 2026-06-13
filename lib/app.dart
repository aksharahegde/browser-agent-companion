import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/menu_bar/menu_bar_controller.dart';
import 'shared/theme.dart';

class CuaCompanionApp extends ConsumerWidget {
  const CuaCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'CUA Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const MenuBarController(),
    );
  }
}
