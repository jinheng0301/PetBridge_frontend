import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/config/env.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/interceptors/auth_interceptor.dart';
import 'package:petbridge/core/network/interceptors/error_map_interceptor.dart';
import 'package:petbridge/core/storage/secure_store.dart';

/// Generated clients already put `/api/v1` in every path, so Dio's base
/// URL is only the scheme, host and port of [Env.apiBaseUrl].
String apiOrigin(String apiBaseUrl) => Uri.parse(apiBaseUrl).origin;

Dio buildDio({
  required SecureStore store,
  required RefreshFn refresh,
  required void Function() onSessionExpired,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiOrigin(Env.apiBaseUrl),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.addAll([
    AuthInterceptor(
      store: store,
      refresh: refresh,
      onSessionExpired: onSessionExpired,
      retryDio: dio,
    ),
    ErrorMapInterceptor(),
    // Bodies stay out of logs (requestBody/responseBody default to false).
    if (kDebugMode) LogInterceptor(),
  ]);
  return dio;
}

/// How tokens get refreshed. The auth feature overrides this (Task 6);
/// until then a 401 simply expires the session.
final refreshFnProvider = Provider<RefreshFn>(
  (ref) =>
      (_) async => throw const AppFailure('UNAUTHORIZED', status: 401),
);

/// Called once when a refresh fails. The auth feature overrides this.
final onSessionExpiredProvider = Provider<void Function()>((ref) => () {});

final dioProvider = Provider<Dio>((ref) {
  final dio = buildDio(
    store: ref.watch(secureStoreProvider),
    refresh: (rt) => ref.read(refreshFnProvider)(rt),
    onSessionExpired: () => ref.read(onSessionExpiredProvider)(),
  );
  ref.onDispose(dio.close);
  return dio;
});
