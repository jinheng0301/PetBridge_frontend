import 'dart:convert';

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

/// Keeps both tokens under one key, so a write is all or nothing: an app
/// killed mid-write can never be left with a new access token next to an
/// already-rotated refresh token, which the server would treat as reuse
/// and answer by revoking the whole session.
class FlutterSecureStore implements SecureStore {
  new([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokensKey = 'auth_tokens';

  /// Where tokens lived before v1.8; read once and migrated.
  static const _legacyAccessKey = 'access_token';
  static const _legacyRefreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<TokenPair?> read() async {
    final raw = await _storage.read(key: _tokensKey);
    if (raw != null) return _decode(raw);
    return await _migrateLegacy();
  }

  @override
  Future<void> write(TokenPair t) => _storage.write(
    key: _tokensKey,
    value: jsonEncode({'access': t.access, 'refresh': t.refresh}),
  );

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokensKey);
    await _deleteLegacy();
  }

  static TokenPair? _decode(String raw) {
    try {
      if (jsonDecode(raw) case {
        'access': final String access,
        'refresh': final String refresh,
      }) {
        return TokenPair(access: access, refresh: refresh);
      }
    } on FormatException {
      // Corrupt value: treat as signed out.
    }
    return null;
  }

  Future<TokenPair?> _migrateLegacy() async {
    final access = await _storage.read(key: _legacyAccessKey);
    final refresh = await _storage.read(key: _legacyRefreshKey);
    if (access == null || refresh == null) return null;
    final t = TokenPair(access: access, refresh: refresh);
    await write(t);
    await _deleteLegacy();
    return t;
  }

  Future<void> _deleteLegacy() async {
    await _storage.delete(key: _legacyAccessKey);
    await _storage.delete(key: _legacyRefreshKey);
  }
}

final secureStoreProvider = Provider<SecureStore>(
  (ref) => FlutterSecureStore(),
);
