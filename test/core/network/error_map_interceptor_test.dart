import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/interceptors/error_map_interceptor.dart';

import 'fake_adapter.dart';

Dio _dio(Future<ResponseBody> Function(RequestOptions o) handler) =>
    Dio(BaseOptions(baseUrl: 'http://api.test'))
      ..httpClientAdapter = FakeAdapter(handler)
      ..interceptors.add(ErrorMapInterceptor());

Future<AppFailure> _failureOf(Dio dio) async {
  try {
    await dio.get<Object?>('/api/v1/me');
  } on DioException catch (e) {
    return AppFailure.from(e);
  }
  fail('expected the request to fail');
}

ResponseBody _withHeaders(int status, Object body, Map<String, String> h) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        for (final e in h.entries) e.key: [e.value],
      },
    );

Map<String, Object> _err(String code, [Map<String, Object>? details]) => {
  'error': {
    'code': code,
    'message': 'x',
    'request_id': 'r',
    'details': ?details,
  },
};

void main() {
  test('RATE_LIMITED copies Retry-After into details', () async {
    final dio = _dio(
      (_) async =>
          _withHeaders(429, _err('RATE_LIMITED'), {'retry-after': '42'}),
    );

    final f = await _failureOf(dio);

    expect(f.code, 'RATE_LIMITED');
    expect(f.details['retry_after_seconds'], 42);
  });

  test('non-integer Retry-After is ignored', () async {
    final dio = _dio(
      (_) async =>
          _withHeaders(429, _err('RATE_LIMITED'), {'retry-after': 'soon'}),
    );

    final f = await _failureOf(dio);

    expect(f.details.containsKey('retry_after_seconds'), isFalse);
  });

  test('CODE_COOLDOWN keeps body retry_after_seconds', () async {
    final dio = _dio(
      (_) async => jsonBody(
        429,
        _err('CODE_COOLDOWN', {'retry_after_seconds': 1800}),
      ),
    );

    final f = await _failureOf(dio);

    expect(f.details['retry_after_seconds'], 1800);
  });

  test('maps backend error body to AppFailure', () async {
    final dio = _dio(
      (_) async => jsonBody(409, {
        'error': {'code': 'ROOM_LIMIT', 'message': 'x', 'request_id': 'r1'},
      }),
    );

    final f = await _failureOf(dio);

    expect(f.code, 'ROOM_LIMIT');
    expect(f.requestId, 'r1');
    expect(f.status, 409);
  });

  test('keeps details', () async {
    final dio = _dio(
      (_) async => jsonBody(400, {
        'error': {
          'code': 'VALIDATION_FAILED',
          'message': 'x',
          'request_id': 'r2',
          'details': {
            'fields': ['nickname'],
          },
        },
      }),
    );

    final f = await _failureOf(dio);

    expect(f.code, 'VALIDATION_FAILED');
    expect(f.details['fields'], ['nickname']);
  });

  test('connection error becomes NETWORK', () async {
    final dio = _dio((_) async => throw const SocketException('refused'));

    final f = await _failureOf(dio);

    expect(f.code, 'NETWORK');
    expect(f.status, isNull);
  });

  test('timeout becomes NETWORK', () async {
    final dio = _dio(
      (o) async => throw DioException.connectionTimeout(
        timeout: const Duration(seconds: 5),
        requestOptions: o,
      ),
    );

    expect((await _failureOf(dio)).code, 'NETWORK');
  });

  test('non-json 500 becomes UNKNOWN', () async {
    final dio = _dio(
      (_) async => ResponseBody.fromString(
        '<html>oops</html>',
        500,
        headers: {
          Headers.contentTypeHeader: ['text/html'],
        },
      ),
    );

    final f = await _failureOf(dio);

    expect(f.code, 'UNKNOWN');
    expect(f.status, 500);
  });
}
