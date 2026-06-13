import 'package:cua_companion/services/security/auth_token_store.dart';
import 'package:cua_companion/services/security/run_history_redaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redactStoredRunPrompt', () {
    test('redacts when sensitive attachments were included', () {
      expect(
        redactStoredRunPrompt(
          prompt: 'secret clipboard contents',
          includesSensitiveAttachments: true,
        ),
        sensitiveRunPromptPlaceholder,
      );
    });

    test('truncates long prompts without sensitive attachments', () {
      final prompt = 'a' * 300;
      final redacted = redactStoredRunPrompt(
        prompt: prompt,
        includesSensitiveAttachments: false,
        maxLength: 280,
      );

      expect(redacted.length, 281);
      expect(redacted.endsWith('…'), isTrue);
    });
  });

  group('runIncludesSensitiveAttachments', () {
    test('detects clipboard template usage', () {
      expect(
        runIncludesSensitiveAttachments(
          flags: const AgentRunContextFlags(
            attachedClipboard: false,
            attachedScreenshot: false,
            promptUsedClipboardTemplate: true,
          ),
        ),
        isTrue,
      );
    });
  });

  group('migrateLegacyAuthToken', () {
    test('migrates legacy sqlite token into store once', () async {
      final store = InMemoryAuthTokenStore();

      final migrated = await migrateLegacyAuthToken(
        legacyToken: 'legacy-token',
        store: store,
      );

      expect(migrated, 'legacy-token');
      expect(await store.read(), 'legacy-token');
    });

    test('does not overwrite existing secure token', () async {
      final store = InMemoryAuthTokenStore();
      await store.write('secure-token');

      final migrated = await migrateLegacyAuthToken(
        legacyToken: 'legacy-token',
        store: store,
      );

      expect(migrated, 'secure-token');
    });
  });
}
