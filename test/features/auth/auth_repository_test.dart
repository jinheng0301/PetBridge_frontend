import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/interceptors/error_map_interceptor.dart';
import 'package:petbridge/core/storage/secure_store.dart';
import 'package:petbridge/features/auth/data/auth_repository.dart';
import 'package:petbridge/gen/pet_bridge_api.dart';

import '../../core/network/fake_adapter.dart';
import '../../helpers/fakes.dart';

Map<String, Object?> _login(String access, String refresh) => {
  'data': {
    'access_token': access,
    'refresh_token': refresh,
    'expires_in': 900,
    'user': {'id': 'u1', 'onboarded': false},
  },
};

void main() {
  late MemorySecureStore store;

  ApiAuthRepository repo(FakeAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(ErrorMapInterceptor());
    return ApiAuthRepository(PetBridgeApi(dio), store);
  }

  setUp(() => store = MemorySecureStore());

  test('dev login stores the token pair', () async {
    final adapter = FakeAdapter((_) async => jsonBody(200, _login('a', 'r')));

    await repo(adapter).loginDev('dev-a@local');

    expect(store.tokens?.access, 'a');
    expect(store.tokens?.refresh, 'r');
    expect(adapter.seen.single.uri.path, '/api/v1/auth/login/dev');
  });

  test('me maps the profile', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody(200, {
        'data': {
          'id': 'u1',
          'onboarded': true,
          'nickname': 'Aki',
          'mbti': 'ENFP',
          'pet_type': 'happy_shiba',
          'native_lang': 'zh-Hant',
          'age_band': '13_17',
          'tz': 'Asia/Taipei',
        },
      }),
    );

    final me = await repo(adapter).me();

    expect(me.onboarded, isTrue);
    expect(me.nativeLang, 'zh-Hant');
    expect(me.ageBand, '13_17');
    expect(me.petType, 'happy_shiba');
  });

  test('server errors become AppFailure', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody(403, {
        'error': {'code': 'ACCOUNT_DISABLED', 'message': 'x'},
      }),
    );

    await expectLater(
      repo(adapter).loginDev('x@local'),
      throwsA(
        isA<AppFailure>().having((f) => f.code, 'code', 'ACCOUNT_DISABLED'),
      ),
    );
    expect(store.tokens, isNull);
  });

  test('logout clears tokens even when the server call fails', () async {
    store.tokens = const TokenPair(access: 'a', refresh: 'r');
    final adapter = FakeAdapter((_) async => jsonBody(500, {}));

    await repo(adapter).logout();

    expect(store.tokens, isNull);
    expect(adapter.seen.single.uri.path, '/api/v1/auth/logout');
  });
}
