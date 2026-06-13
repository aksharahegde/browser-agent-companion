import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storageKey = 'agent_auth_token';

abstract class AuthTokenStore {
  Future<String> read();

  Future<void> write(String token);

  Future<void> delete();
}

class SecureAuthTokenStore implements AuthTokenStore {
  SecureAuthTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String> read() async {
    return await _storage.read(key: _storageKey) ?? '';
  }

  @override
  Future<void> write(String token) async {
    if (token.isEmpty) {
      await delete();
      return;
    }
    await _storage.write(key: _storageKey, value: token);
  }

  @override
  Future<void> delete() async {
    await _storage.delete(key: _storageKey);
  }
}

class InMemoryAuthTokenStore implements AuthTokenStore {
  String _value = '';

  @override
  Future<String> read() async => _value;

  @override
  Future<void> write(String token) async {
    _value = token;
  }

  @override
  Future<void> delete() async {
    _value = '';
  }
}

Future<String> migrateLegacyAuthToken({
  required String legacyToken,
  required AuthTokenStore store,
}) async {
  final existing = await store.read();
  if (existing.isNotEmpty) return existing;
  if (legacyToken.isEmpty) return '';
  await store.write(legacyToken);
  return legacyToken;
}
