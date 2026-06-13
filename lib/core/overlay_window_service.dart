import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../shared/providers.dart';

Future<void> showOverlayWindow(WidgetRef ref) async {
  ref.read(overlayVisibleProvider.notifier).state = true;
  await windowManager.setAsFrameless();
  await windowManager.show();
  await windowManager.focus();
  await windowManager.setAlwaysOnTop(true);
}

Future<void> hideOverlayWindow(WidgetRef ref) async {
  ref.read(overlayVisibleProvider.notifier).state = false;
  ref.read(settingsVisibleProvider.notifier).state = false;
  ref.read(workflowsVisibleProvider.notifier).state = false;
  await windowManager.hide();
}
