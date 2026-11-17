import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/dio_client.dart';
import 'package:petbridge/core/storage/secure_store.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/gen/pet_bridge_api.dart';

/// Login, token refresh, logout and `/me`. Every method throws
/// [AppFailure] only.
abstract interface class AuthRepository {
  /// Logs in and stores the tokens.
  Future<void> loginDev(String email);

  /// Logs in with a Google ID token and stores the tokens.
  Future<void> loginGoogle(String idToken);

  /// Logs in with an Apple ID token and stores the tokens.
  Future<void> loginApple(String idToken);

  Future<Me> me();

  /// Exchanges [refreshToken] for a new pair. Does not store it; the
  /// `AuthInterceptor` does.
  Future<TokenPair> refresh(String refreshToken);

  /// Revokes the refresh token on the server (best effort) and always
  /// clears the local tokens. Never throws.
  Future<void> logout();
}

class ApiAuthRepository implements AuthRepository {
  new(this._api, this._store);

  final PetBridgeApi _api;
  final SecureStore _store;

  @override
  Future<void> loginDev(String email) =>
      _login(() => _api.auth.loginDev(body: LoginDevRequest(email: email)));

  @override
  Future<void> loginGoogle(String idToken) => _login(
    () => _api.auth.loginGoogle(body: IDTokenRequest(idToken: idToken)),
  );

  @override
  Future<void> loginApple(String idToken) => _login(
    () => _api.auth.loginApple(body: IDTokenRequest(idToken: idToken)),
  );

  Future<void> _login(Future<LoginDevResponse200> Function() call) async {
    final res = await _guard(call);
    await _store.write(_pair(res.data));
  }

  @override
  Future<Me> me() async {
    final p = (await _guard(_api.me.getMe)).data;
    return Me(
      id: p.id,
      onboarded: p.onboarded,
      nickname: p.nickname,
      mbti: p.mbti,
      petType: p.petType,
      nativeLang: p.nativeLang?.value as String?,
      ageBand: p.ageBand?.value as String?,
    );
  }

  @override
  Future<TokenPair> refresh(String refreshToken) async {
    final res = await _guard(
      () => _api.auth.refreshToken(
        body: RefreshRequest(refreshToken: refreshToken),
      ),
    );
    return _pair(res.data);
  }

  @override
  Future<void> logout() async {
    try {
      final tokens = await _store.read();
      if (tokens != null) {
        await _api.auth.logout(
          body: RefreshRequest(refreshToken: tokens.refresh),
        );
      }
    } on Object {
      // Best effort: the local session ends either way.
    } finally {
      await _store.clear();
    }
  }

  static TokenPair _pair(LoginData d) =>
      TokenPair(access: d.accessToken, refresh: d.refreshToken);
}

/// Runs [call] and rethrows anything as an [AppFailure].
Future<T> _guard<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on Object catch (e) {
    throw AppFailure.from(e);
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(
    PetBridgeApi(ref.watch(dioProvider)),
    ref.watch(secureStoreProvider),
  ),
);
