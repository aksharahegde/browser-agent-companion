import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import '../../data/models/app_settings.dart';
import '../../shared/providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

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

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _hostController,
            decoration: const InputDecoration(labelText: 'Agent host URL'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tokenController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Auth token (optional)'),
          ),
          const SizedBox(height: 16),
          activeSession.when(
            data: (session) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(session?.title ?? 'Active session ID'),
              subtitle: Text(
                settings.activeSessionId.isEmpty
                    ? 'None'
                    : settings.activeSessionId,
                style: const TextStyle(fontFamily: 'Menlo', fontSize: 11),
              ),
              trailing: settings.activeSessionId.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Copy session ID',
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: settings.activeSessionId),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session ID copied')),
                        );
                      },
                    ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Default attach clipboard'),
            value: settings.defaultAttachClipboard,
            onChanged: (v) => _save(settings.copyWith(defaultAttachClipboard: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Default attach screenshot'),
            value: settings.defaultAttachScreenshot,
            onChanged: (v) =>
                _save(settings.copyWith(defaultAttachScreenshot: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Launch at login'),
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
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Screen recording permission',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(_screenPermission ? 'Granted' : 'Not granted'),
                  const SizedBox(height: 8),
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
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _applyAndReconnect,
            child: const Text('Save & reconnect'),
          ),
          const SizedBox(height: 32),
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
    );
  }

  Future<void> _save(AppSettings settings) async {
    await ref.read(settingsProvider.notifier).update(settings);
  }

  Future<void> _applyAndReconnect() async {
    final current = ref.read(settingsProvider);
    final updated = current.copyWith(
      agentHost: _hostController.text.trim(),
      authToken: _tokenController.text.trim(),
    );
    await _save(updated);
    await ref.read(agentSessionServiceProvider).configure(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }
}
