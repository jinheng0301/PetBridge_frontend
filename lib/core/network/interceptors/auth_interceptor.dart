import 'package:dio/dio.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/token_refresher.dart';
import 'package:petbridge/core/storage/secure_store.dart';

/// Adds the bearer token and, on 401, refreshes once and replays.
///
/// Concurrent 401s share one refresh (single flight, see [TokenRefresher]).
/// If the server rejects the refresh (400/401/403: invalid, reused, account
/// disabled) the tokens are cleared and `onSessionExpired` runs once; the
/// original request then fails with its 401. Any other refresh failure (no
/// network, timeout, 5xx) keeps the tokens and fails the request with that
/// failure (e.g. `NETWORK`), so the next request or a retry refreshes again.
class AuthInterceptor extends Interceptor {
  new({
    required this._refresher,
    required this._retryDio,
    required this._store,
  });

  static const _retriedKey = 'auth_retried';
  static const _header = 'Authorization';

  final TokenRefresher _refresher;
  final Dio _retryDio;
  final SecureStore _store;

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
      fresh = await _refresher.fresh(
        sentWithAccess: o.headers[_header]?.toString(),
      );
    } on Object catch (e) {
      handler.next(
        TokenRefresher.endsSession(e)
            ? err
            : err.copyWith(error: AppFailure.from(e)),
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
}
