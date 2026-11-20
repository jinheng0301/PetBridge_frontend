import 'package:dio/dio.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/storage/secure_store.dart';

typedef RefreshFn = Future<TokenPair> Function(String refreshToken);

/// Adds the bearer token and, on 401, refreshes once and replays.
///
/// Concurrent 401s share one refresh (single flight). If the server rejects
/// the refresh (400/401/403: invalid, reused, account disabled) the tokens
/// are cleared and `onSessionExpired` runs once; the original request then
/// fails with its 401. Any other refresh failure (no network, timeout, 5xx)
/// keeps the tokens and fails the request with that failure (e.g.
/// `NETWORK`), so the next request or a retry refreshes again.
class AuthInterceptor extends Interceptor {
  new({
    required this._store,
    required this._refresh,
    required this._onSessionExpired,
    required this._retryDio,
  });

  static const _retriedKey = 'auth_retried';
  static const _header = 'Authorization';

  final SecureStore _store;
  final RefreshFn _refresh;
  final void Function() _onSessionExpired;
  final Dio _retryDio;

  Future<TokenPair>? _inflight;

  /// Login, refresh and logout neither carry nor refresh the access token.
  static bool _isAuthPath(RequestOptions o) => o.uri.path.contains('/auth/');

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthPath(options)) {
      final tokens = await _store.read();
      if (tokens != null) options.headers[_header] = 'Bearer ${tokens.access}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final o = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        _isAuthPath(o) ||
        o.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }

    final TokenPair fresh;
    try {
      fresh = await _freshTokens(sentWith: o.headers[_header]);
    } on Object catch (e) {
      handler.next(
        _endsSession(e) ? err : err.copyWith(error: AppFailure.from(e)),
      );
      return;
    }

    try {
      final response = await _retryDio.fetch<dynamic>(
        o.copyWith(
          headers: {...o.headers, _header: 'Bearer ${fresh.access}'},
          extra: {...o.extra, _retriedKey: true},
        ),
      );
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Tokens to replay with. Joins a refresh already in flight; skips the
  /// refresh if another one already finished after this request was sent.
  Future<TokenPair> _freshTokens({required Object? sentWith}) async {
    final inflight = _inflight;
    if (inflight != null) return await inflight;

    final current = await _store.read();
    if (current == null) {
      throw const AppFailure(AppFailure.unauthorized, status: 401);
    }
    if (sentWith != null && sentWith != 'Bearer ${current.access}') {
      return current;
    }
    return await (_inflight ??= _runRefresh(current.refresh));
  }

  Future<TokenPair> _runRefresh(String refreshToken) async {
    try {
      final tokens = await _refresh(refreshToken);
      await _store.write(tokens);
      return tokens;
    } on Object catch (e) {
      if (_endsSession(e)) {
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
  static bool _endsSession(Object e) {
    final f = AppFailure.from(e);
    return _sessionEndingCodes.contains(f.code) ||
        const {400, 401, 403}.contains(f.status);
  }
}
