/// The only place that reads compile-time configuration
/// (`--dart-define-from-file=env/dev_android.json`).
abstract final class Env {
  static const String env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8090/api/v1',
  );

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static const bool devLogin = bool.fromEnvironment('DEV_LOGIN');

  static const bool appleLoginEnabled = bool.fromEnvironment(
    'APPLE_LOGIN_ENABLED',
  );
}
