import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/dio_client.dart';
import 'package:petbridge/core/storage/prefs_store.dart';
import 'package:petbridge/core/storage/secure_store.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/data/auth_repository.dart';
import 'package:petbridge/features/auth/data/google_auth.dart';

/// Owns the [Session]. Starts in [SessionUnknown] and restores from the
/// stored tokens; the login methods throw [AppFailure] for the UI to show.
class SessionController extends Notifier<Session> {
  static const appleUnavailable = 'APPLE_LOGIN_UNAVAILABLE';

  late Future<void> _restored;

  /// Completes when the startup restore (or the last [retry]) has finished.
  Future<void> get restored => _restored;

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Session build() {
    _restored = _restore();
    return const SessionUnknown();
  }

  /// Runs the startup restore again after it failed (e.g. no network).
  Future<void> retry() {
    state = const SessionUnknown();
    return _restored = _restore();
  }

  Future<void> _restore() async {
    // Let build() return before the state is replaced.
    await Future<void>.value();
    final tokens = await ref.read(secureStoreProvider).read();
    if (tokens == null) {
      state = const SessionUnauthenticated();
      return;
    }
    try {
      await _loadMe();
    } on AppFailure catch (f) {
      if (_isTransient(f)) {
        state = SessionUnknown(failure: f);
      } else {
        await ref.read(secureStoreProvider).clear();
        state = const SessionUnauthenticated();
      }
    }
  }

  /// Failures worth a retry rather than a trip back to the login page.
  static bool _isTransient(AppFailure f) =>
      f.code == AppFailure.network ||
      f.code == AppFailure.unknown ||
      (f.status ?? 0) >= 500;

  Future<void> _loadMe() async {
    final me = await _repo.me();
    state = me.onboarded ? SessionReady(me) : SessionNeedsOnboarding(me);
  }

  Future<void> loginDev(String email) async {
    await _repo.loginDev(email);
    await _loadMe();
  }

  /// Does nothing when the user cancels the Google sheet.
  Future<void> loginGoogle() async {
    final idToken = await ref.read(googleAuthProvider).signIn();
    if (idToken == null) return;
    await _repo.loginGoogle(idToken);
    await _loadMe();
  }

  /// Apple sign-in is deferred in phase 1 (Android only), so this always
  /// reports it as unavailable.
  Future<void> loginApple() async {
    throw const AppFailure(appleUnavailable);
  }

  /// Reloads `/me`, e.g. after onboarding completes. Throws [AppFailure].
  Future<void> refreshMe() => _loadMe();

  /// Ends the session: server logout (best effort), local tokens and
  /// preferences cleared, Google signed out.
  Future<void> logout() async {
    await _repo.logout();
    try {
      await ref.read(googleAuthProvider).signOut();
    } on Object {
      // Not signed in with Google, or the plugin failed; nothing to undo.
    }
    await ref.read(prefsStoreProvider).clear();
    state = const SessionUnauthenticated();
  }

  /// Called when a token refresh fails; tokens are already cleared.
  void expire() => state = const SessionUnauthenticated();
}

final sessionControllerProvider = NotifierProvider<SessionController, Session>(
  SessionController.new,
);

/// Connects the network layer to the auth feature. Pass to the root
/// `ProviderScope`.
final List<Override> authNetworkOverrides = [
  refreshFnProvider.overrideWith(
    (ref) =>
        (rt) => ref.read(authRepositoryProvider).refresh(rt),
  ),
  onSessionExpiredProvider.overrideWith(
    (ref) =>
        () => ref.read(sessionControllerProvider.notifier).expire(),
  ),
];
