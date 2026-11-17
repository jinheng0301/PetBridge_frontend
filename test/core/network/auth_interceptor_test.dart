import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/interceptors/auth_interceptor.dart';
import 'package:petbridge/core/network/interceptors/error_map_interceptor.dart';
import 'package:petbridge/core/storage/secure_store.dart';

import 'fake_adapter.dart';

class FakeSecureStore implements SecureStore {
  new(this.tokens);

  TokenPair? tokens;
  int clears = 0;

  @override
  Future<TokenPair?> read() async => tokens;

  @override
  Future<void> write(TokenPair t) async => tokens = t;

  @override
  Future<void> clear() async {
    clears++;
    tokens = null;
  }
}

/// 200 only for the fresh access token, 401 otherwise.
Future<ResponseBody> _server(RequestOptions o) async {
  if (o.headers['Authorization'] == 'Bearer new') {
    return jsonBody(200, {'data': 'ok'});
  }
  return jsonBody(401, {
    'error': {'code': 'UNAUTHORIZED', 'message': 'x', 'request_id': 'r'},
  });
}

void main() {
  late FakeSecureStore store;
  late FakeAdapter adapter;
  late Dio dio;
  late int refreshCalls;
  late int expired;

  void build(RefreshFn refresh) {
    adapter = FakeAdapter(_server);
    final retryDio = Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = adapter;
    dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = adapter
      ..interceptors.addAll([
        AuthInterceptor(
          store: store,
          refresh: refresh,
          onSessionExpired: () => expired++,
          retryDio: retryDio,
        ),
        ErrorMapInterceptor(),
      ]);
  }

  setUp(() {
    store = FakeSecureStore(const TokenPair(access: 'old', refresh: 'r-old'));
    refreshCalls = 0;
    expired = 0;
  });

  test('attaches bearer token', () async {
    store.tokens = const TokenPair(access: 'new', refresh: 'r');
    build((_) async => throw StateError('no refresh expected'));

    final res = await dio.get<Object?>('/api/v1/me');

    expect(res.statusCode, 200);
    expect(adapter.seen.single.headers['Authorization'], 'Bearer new');
  });

  test('two concurrent 401s refresh once and both replay', () async {
    build((rt) async {
      refreshCalls++;
      expect(rt, 'r-old');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return const TokenPair(access: 'new', refresh: 'r-new');
    });

    final results = await Future.wait([
      dio.get<Object?>('/api/v1/me'),
      dio.post<Object?>('/api/v1/me/onboarding', data: {'x': 1}),
    ]);

    expect(refreshCalls, 1);
    expect(results.map((r) => r.statusCode), [200, 200]);
    final replays = adapter.seen.where(
      (o) => o.headers['Authorization'] == 'Bearer new',
    );
    expect(replays, hasLength(2));
    expect(store.tokens?.refresh, 'r-new');
    expect(expired, 0);
  });

  test('refresh failure clears tokens and expires session', () async {
    build((_) async {
      refreshCalls++;
      throw const AppFailure('REFRESH_REUSED');
    });

    await expectLater(
      dio.get<Object?>('/api/v1/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(store.clears, 1);
    expect(store.tokens, isNull);
    expect(expired, 1);
  });

  test('does not refresh for /auth/refresh itself', () async {
    build((_) async {
      refreshCalls++;
      return const TokenPair(access: 'new', refresh: 'r-new');
    });

    await expectLater(
      dio.post<Object?>('/api/v1/auth/refresh', data: {'refresh_token': 'x'}),
      throwsA(isA<DioException>()),
    );
    expect(refreshCalls, 0);
    expect(adapter.seen.single.headers.containsKey('Authorization'), isFalse);
    expect(expired, 0);
  });
}
