import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/menu_bar/menu_bar_controller.dart';
import 'shared/app_messenger.dart';
import 'shared/app_navigator.dart';
import 'shared/theme.dart';

class CuaCompanionApp extends ConsumerWidget {
  const CuaCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'CUA Companion',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      theme: AppTheme.dark(),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: child,
        );
      },
      home: const MenuBarController(),
    );
  }
}
