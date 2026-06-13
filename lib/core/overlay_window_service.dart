import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../shared/providers.dart';

Future<void> _ensureTransparentWindow() async {
  await windowManager.setTitleBarStyle(
    TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  await windowManager.setBackgroundColor(Colors.transparent);
  await windowManager.setHasShadow(false);
}

Future<void> showOverlayWindow(WidgetRef ref) async {
  ref.read(overlayVisibleProvider.notifier).show();
  await _ensureTransparentWindow();
  await windowManager.show();
  await windowManager.focus();
  await windowManager.setAlwaysOnTop(true);
}

Future<void> hideOverlayWindow(WidgetRef ref) async {
  ref.read(overlayVisibleProvider.notifier).hide();
  ref.read(settingsVisibleProvider.notifier).hide();
  ref.read(workflowsVisibleProvider.notifier).hide();
  ref.read(sessionsVisibleProvider.notifier).hide();
  await windowManager.hide();
}
