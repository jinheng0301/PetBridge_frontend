import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/dio_client.dart';
import 'package:petbridge/core/storage/secure_store.dart';

typedef RefreshFn = Future<TokenPair> Function(String refreshToken);

/// When [token] (a JWT) expires, from its payload `exp` (seconds since the
/// epoch), or `null` if it is not a JWT or carries no usable `exp`.
DateTime? jwtExpiry(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map<String, dynamic>) return null;
    final exp = payload['exp'];
    if (exp is! num) return null;
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
  } on FormatException {
    return null;
  }
}

/// Refreshes the token pair, shared by REST (`AuthInterceptor`) and the
/// realtime socket so both go through one single-flight refresh.
///
/// Concurrent callers share one refresh. If the server rejects the refresh
/// (400/401/403: invalid, reused, account disabled) the tokens are cleared
/// and `onSessionExpired` runs once. Any other refresh failure (no network,
/// timeout, 5xx) keeps the tokens and is rethrown, so a retry refreshes again.
class TokenRefresher {
  new({
    required this._store,
    required this._refresh,
    required this._onSessionExpired,
  });

  /// Refresh when less than this is left on the access token.
  static const _refreshMargin = Duration(seconds: 60);

  final SecureStore _store;
  final RefreshFn _refresh;
  final void Function() _onSessionExpired;

  Future<TokenPair>? _inflight;

  /// Tokens to use after a rejected access token. Joins a refresh already in
  /// flight; skips the refresh if another one already finished after the
  /// request was sent with [sentWithAccess] (an `Authorization` header value).
  Future<TokenPair> fresh({String? sentWithAccess}) async {
    final inflight = _inflight;
    if (inflight != null) return await inflight;

    final current = await _store.read();
    if (current == null) {
      throw const AppFailure(AppFailure.unauthorized, status: 401);
    }
    if (sentWithAccess != null &&
        sentWithAccess != 'Bearer ${current.access}') {
      return current;
    }
    return await (_inflight ??= _runRefresh(current.refresh));
  }

  /// An access token good for at least a minute past [now], refreshing first
  /// if needed. `null` when there are no tokens. A token whose expiry cannot
  /// be read is used as is.
  Future<String?> validAccess(DateTime now) async {
    final current = await _store.read();
    if (current == null) return null;
    final exp = jwtExpiry(current.access);
    if (exp == null || exp.difference(now) >= _refreshMargin) {
      return current.access;
    }
    return (await fresh()).access;
  }

  Future<TokenPair> _runRefresh(String refreshToken) async {
    try {
      final tokens = await _refresh(refreshToken);
      await _store.write(tokens);
      return tokens;
    } on Object catch (e) {
      if (endsSession(e)) {
        await _store.clear();
        _onSessionExpired();
      }
      rethrow;
    } finally {
      _inflight = null;
    }
  }

  /// Codes the refresh endpoint answers when the session cannot continue.
  static const Set<String> _sessionEndingCodes = {
    AppFailure.unauthorized,
    'REFRESH_INVALID',
    'REFRESH_REUSED',
    'ACCOUNT_DISABLED',
    'VALIDATION_FAILED',
  };

  /// Whether a refresh failure means the server rejected the session, as
  /// opposed to it not being reachable right now.
  static bool endsSession(Object e) {
    final f = AppFailure.from(e);
    return _sessionEndingCodes.contains(f.code) ||
        const {400, 401, 403}.contains(f.status);
  }
}

final tokenRefresherProvider = Provider<TokenRefresher>(
  (ref) => TokenRefresher(
    store: ref.watch(secureStoreProvider),
    refresh: (rt) => ref.read(refreshFnProvider)(rt),
    onSessionExpired: () => ref.read(onSessionExpiredProvider)(),
  ),
);
