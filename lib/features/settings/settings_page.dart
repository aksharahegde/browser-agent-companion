import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import '../../data/models/app_settings.dart';
import '../../services/agent/agent_host_validator.dart';
import '../../shared/app_messenger.dart';
import '../../shared/providers.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/glass_list_row.dart';
import '../../shared/widgets/overlay_subnav.dart';
import '../../shared/widgets/toggle_row.dart';
import '../../core/overlay_window_service.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late final TextEditingController _hostController;
  late final TextEditingController _tokenController;
  bool _screenPermission = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _hostController = TextEditingController(text: settings.agentHost);
    _tokenController = TextEditingController(text: settings.authToken);
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final granted =
        await ref.read(permissionsServiceProvider).hasScreenRecording();
    if (mounted) setState(() => _screenPermission = granted);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OverlaySubnav(
          title: 'Settings',
          onBack: widget.onBack,
          onMinimize: () => hideOverlayWindow(ref),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(tokens.spaceMd),
            children: [
              _SectionHeading(title: 'Connection'),
              TextField(
                controller: _hostController,
                decoration: const InputDecoration(labelText: 'Agent host URL'),
              ),
              SizedBox(height: tokens.spaceSm + 4),
              TextField(
                controller: _tokenController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Auth token (Keychain)'),
              ),
              SizedBox(height: tokens.spaceLg),
              _SectionHeading(title: 'Session'),
              activeSession.when(
                data: (session) => GlassListRow(
                  title: Text(session?.title ?? 'Active session'),
                  subtitle: Text(
                    settings.activeSessionId.isEmpty
                        ? 'None'
                        : settings.activeSessionId,
                    style: const TextStyle(
                      fontFamily: 'Menlo',
                      fontSize: 11,
                    ),
                  ),
                  trailing: settings.activeSessionId.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Copy session ID',
                          icon: Icon(Icons.copy, color: tokens.textMuted),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: settings.activeSessionId),
                            );
                            showAppSnackBar('Session ID copied');
                          },
                        ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              SizedBox(height: tokens.spaceLg),
              _SectionHeading(title: 'Defaults'),
              ToggleRow(
                title: 'Default attach clipboard',
                value: settings.defaultAttachClipboard,
                onChanged: (v) =>
                    _save(settings.copyWith(defaultAttachClipboard: v)),
              ),
              ToggleRow(
                title: 'Default attach screenshot',
                value: settings.defaultAttachScreenshot,
                onChanged: (v) =>
                    _save(settings.copyWith(defaultAttachScreenshot: v)),
              ),
              ToggleRow(
                title: 'Launch at login',
                value: settings.launchAtLogin,
                onChanged: (v) async {
                  await _save(settings.copyWith(launchAtLogin: v));
                  launchAtStartup.setup(
                    appName: 'CUA Companion',
                    appPath: '',
                    packageName: 'cua_companion',
                  );
                  if (v) {
                    launchAtStartup.enable();
                  } else {
                    launchAtStartup.disable();
                  }
                },
              ),
              SizedBox(height: tokens.spaceLg),
              _SectionHeading(title: 'Permissions'),
              DecoratedBox(
                decoration: tokens.surfaceDecoration(),
                child: Padding(
                  padding: EdgeInsets.all(tokens.spaceMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    Text(
                      'Screen recording permission',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    SizedBox(height: tokens.spaceSm / 2),
                    Text(
                      _screenPermission ? 'Granted' : 'Not granted',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.textMuted,
                          ),
                    ),
                    SizedBox(height: tokens.spaceSm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () async {
                          final service = ref.read(permissionsServiceProvider);
                          if (!_screenPermission) {
                            await service.requestScreenRecording();
                          } else {
                            await service.openSystemSettings();
                          }
                          await _loadPermissions();
                        },
                        child: Text(
                          _screenPermission ? 'Open Settings' : 'Request',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
              SizedBox(height: tokens.spaceLg),
              FilledButton(
                onPressed: _applyAndReconnect,
                child: const Text('Save & reconnect'),
              ),
              SizedBox(height: tokens.spaceMd),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                onPressed: () => ref.read(appLifecycleServiceProvider).quitApp(),
                child: const Text('Quit App'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _save(AppSettings settings) async {
    await ref.read(settingsProvider.notifier).update(settings);
  }

  Future<void> _applyAndReconnect() async {
    final current = ref.read(settingsProvider);
    final rawHost = _hostController.text.trim();
    final token = _tokenController.text.trim();

    try {
      final host = parseAgentHost(rawHost);
      final updated = current.copyWith(
        agentHost: host,
        authToken: token,
      );
      await _save(updated);
      await ref.read(agentSessionServiceProvider).configure(updated);
      if (mounted) {
        showAppSnackBar('Settings saved');
      }
    } on AgentHostValidationException catch (error) {
      if (mounted) {
        showAppSnackBar(error.message);
      }
    }
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spaceSm),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tokens.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
