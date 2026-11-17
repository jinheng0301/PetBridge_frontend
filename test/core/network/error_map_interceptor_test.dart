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

void main() {
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
