import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenPair {
  const new({required this.access, required this.refresh});

  final String access;
  final String refresh;
}

/// Where the access and refresh tokens live.
abstract interface class SecureStore {
  Future<TokenPair?> read();
  Future<void> write(TokenPair t);
  Future<void> clear();
}

class FlutterSecureStore implements SecureStore {
  new([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<TokenPair?> read() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) return null;
    return TokenPair(access: access, refresh: refresh);
  }

  @override
  Future<void> write(TokenPair t) async {
    await _storage.write(key: _accessKey, value: t.access);
    await _storage.write(key: _refreshKey, value: t.refresh);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

final secureStoreProvider = Provider<SecureStore>(
  (ref) => FlutterSecureStore(),
);
