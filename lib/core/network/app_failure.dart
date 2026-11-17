import 'package:dio/dio.dart';

/// The single error type the app's UI sees. The UI localises by [code] only
/// and never shows the server's `message`.
class AppFailure implements Exception {
  const new(this.code, {this.status, this.requestId, this.details = const {}});

  /// Turns anything thrown by a request into an [AppFailure].
  ///
  /// `ErrorMapInterceptor` puts the mapped failure in
  /// [DioException.error]; anything else becomes `UNKNOWN`.
  factory from(Object error) => switch (error) {
    final AppFailure f => f,
    DioException(error: final AppFailure f) => f,
    DioException(:final response) => AppFailure(
      unknown,
      status: response?.statusCode,
    ),
    _ => const AppFailure(unknown),
  };

  /// The server could not be reached (no connection, DNS, timeout).
  static const network = 'NETWORK';

  /// The error could not be understood.
  static const unknown = 'UNKNOWN';

  final String code;
  final int? status;
  final String? requestId;
  final Map<String, Object?> details;

  @override
  String toString() =>
      'AppFailure($code, status: $status, requestId: $requestId)';
}
