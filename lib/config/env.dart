/// The only place that reads compile-time configuration
/// (`--dart-define-from-file=env/dev_android.json`).
abstract final class Env {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8090/api/v1',
  );

  /// Realtime room socket.
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://10.0.2.2:8090/api/v1/ws',
  );

  /// Sent in the socket handshake.
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static const bool devLogin = bool.fromEnvironment('DEV_LOGIN');

  static const bool appleLoginEnabled = bool.fromEnvironment(
    'APPLE_LOGIN_ENABLED',
  );

  /// Base of share links and poster QR codes (`{base}/j/{code}`). A
  /// placeholder until the real domain exists.
  static const String shareBaseUrl = String.fromEnvironment(
    'SHARE_BASE_URL',
    defaultValue: 'https://petbridge.example.com',
  );
}
