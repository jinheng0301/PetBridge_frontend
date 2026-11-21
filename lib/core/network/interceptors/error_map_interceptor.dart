import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:petbridge/core/network/app_failure.dart';

/// Puts an [AppFailure] in [DioException.error] for every failed request.
///
/// Backend errors look like
/// `{"error":{"code","message","request_id","details"?}}`.
class ErrorMapInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is AppFailure) {
      handler.next(err);
      return;
    }
    handler.next(err.copyWith(error: _map(err)));
  }

  static AppFailure _map(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const AppFailure(AppFailure.network);
      case DioExceptionType.unknown when err.error is SocketException:
        return const AppFailure(AppFailure.network);
      case DioExceptionType.badResponse:
        return _fromBody(err.response!);
      case DioExceptionType.unknown:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return AppFailure(AppFailure.unknown, status: err.response?.statusCode);
    }
  }

  static AppFailure _fromBody(Response<dynamic> response) {
    final status = response.statusCode;
    var data = response.data;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        data = null;
      }
    }
    if (data case {
      'error': {'code': final String code} && final Map<String, Object?> e,
    }) {
      final raw = e['details'];
      final details = <String, Object?>{
        if (raw is Map) ...raw.map((k, v) => MapEntry(k.toString(), v)),
      };
      // RATE_LIMITED carries its wait in the Retry-After header only; put it
      // under the same key CODE_COOLDOWN uses so the UI reads one place.
      final retryAfter = int.tryParse(
        response.headers.value('retry-after') ?? '',
      );
      if (status == 429 && retryAfter != null) {
        details.putIfAbsent('retry_after_seconds', () => retryAfter);
      }
      return AppFailure(
        code,
        status: status,
        requestId: e['request_id'] as String?,
        details: details,
      );
    }
    return AppFailure(AppFailure.unknown, status: status);
  }
}
