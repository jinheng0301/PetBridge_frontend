import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/storage/prefs_store.dart';
import 'package:petbridge/core/storage/secure_store.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/auth/data/auth_repository.dart';
import 'package:petbridge/features/auth/data/google_auth.dart';

import '../../helpers/fakes.dart';

const _tokens = TokenPair(access: 'a1', refresh: 'r1');

void main() {
  late MockAuthRepository repo;
  late MockGoogleAuth google;
  late MemorySecureStore store;
  late MockPrefsStore prefs;

  setUp(() {
    repo = MockAuthRepository();
    google = MockGoogleAuth();
    store = MemorySecureStore();
    prefs = stubPrefs();
  });

  ProviderContainer makeContainer() => ProviderContainer.test(
    overrides: [
      authRepositoryProvider.overrideWithValue(repo),
      googleAuthProvider.overrideWithValue(google),
      secureStoreProvider.overrideWithValue(store),
      prefsStoreProvider.overrideWithValue(prefs),
    ],
  );

  /// Reads the controller and waits for its startup restore to finish.
  Future<ProviderContainer> started() async {
    final c = makeContainer()..listen(sessionControllerProvider, (_, _) {});
    await c.read(sessionControllerProvider.notifier).restored;
    return c;
  }

  test('no token -> Unauthenticated', () async {
    final c = await started();
    expect(c.read(sessionControllerProvider), isA<SessionUnauthenticated>());
    verifyNever(repo.me);
  });

  test('token + onboarded=false -> NeedsOnboarding', () async {
    store.tokens = _tokens;
    when(repo.me).thenAnswer((_) async => const Me(id: 'u1', onboarded: false));
    final c = await started();
    expect(c.read(sessionControllerProvider), isA<SessionNeedsOnboarding>());
  });

  test('token + onboarded=true -> Ready', () async {
    store.tokens = _tokens;
    when(repo.me).thenAnswer((_) async => const Me(id: 'u1', onboarded: true));
    final c = await started();
    final s = c.read(sessionControllerProvider);
    expect(s, isA<SessionReady>());
    expect((s as SessionReady).me.id, 'u1');
  });

  test('me() 401 after failed refresh -> Unauthenticated', () async {
    store.tokens = _tokens;
    when(repo.me).thenThrow(const AppFailure('UNAUTHORIZED', status: 401));
    final c = await started();
    expect(c.read(sessionControllerProvider), isA<SessionUnauthenticated>());
    expect(store.tokens, isNull);
  });

  test('network failure at startup stays unknown with the failure', () async {
    store.tokens = _tokens;
    when(repo.me).thenThrow(const AppFailure(AppFailure.network));
    final c = await started();
    final s = c.read(sessionControllerProvider);
    expect(s, isA<SessionUnknown>());
    expect((s as SessionUnknown).failure?.code, AppFailure.network);
    expect(store.tokens, isNotNull);
  });

  test('google cancel stays on login without error', () async {
    when(google.signIn).thenAnswer((_) async => null);
    final c = await started();

    await c.read(sessionControllerProvider.notifier).loginGoogle();

    expect(c.read(sessionControllerProvider), isA<SessionUnauthenticated>());
    verifyNever(() => repo.loginGoogle(any()));
  });

  test('google login with a token loads me', () async {
    when(google.signIn).thenAnswer((_) async => 'id-token');
    when(() => repo.loginGoogle('id-token')).thenAnswer((_) async {});
    when(repo.me).thenAnswer((_) async => const Me(id: 'u1', onboarded: false));
    final c = await started();

    await c.read(sessionControllerProvider.notifier).loginGoogle();

    expect(c.read(sessionControllerProvider), isA<SessionNeedsOnboarding>());
  });

  test('dev login failure propagates and stays unauthenticated', () async {
    when(() => repo.loginDev(any()))
        .thenThrow(const AppFailure('PROVIDER_NOT_CONFIGURED', status: 501));
    final c = await started();

    await expectLater(
      c.read(sessionControllerProvider.notifier).loginDev('dev-a@local'),
      throwsA(isA<AppFailure>()),
    );
    expect(c.read(sessionControllerProvider), isA<SessionUnauthenticated>());
  });

  test('apple login unavailable when disabled', () async {
    final c = await started();
    await expectLater(
      c.read(sessionControllerProvider.notifier).loginApple(),
      throwsA(
        isA<AppFailure>().having(
          (f) => f.code,
          'code',
          'APPLE_LOGIN_UNAVAILABLE',
        ),
      ),
    );
  });

  test('logout clears store and signs out of Google', () async {
    store.tokens = _tokens;
    when(repo.me).thenAnswer((_) async => const Me(id: 'u1', onboarded: true));
    when(repo.logout).thenAnswer((_) async => store.tokens = null);
    when(google.signOut).thenAnswer((_) async {});
    final c = await started();

    await c.read(sessionControllerProvider.notifier).logout();

    expect(c.read(sessionControllerProvider), isA<SessionUnauthenticated>());
    verify(repo.logout).called(1);
    verify(google.signOut).called(1);
    verify(prefs.clear).called(1);
  });

  test('logout still finishes when Google sign-out fails', () async {
    when(repo.logout).thenAnswer((_) async {});
    when(google.signOut).thenThrow(Exception('boom'));
    final c = await started();

    await c.read(sessionControllerProvider.notifier).logout();

    expect(c.read(sessionControllerProvider), isA<SessionUnauthenticated>());
  });

  test('expire moves to Unauthenticated', () async {
    store.tokens = _tokens;
    when(repo.me).thenAnswer((_) async => const Me(id: 'u1', onboarded: true));
    final c = await started();

    c.read(sessionControllerProvider.notifier).expire();

    expect(c.read(sessionControllerProvider), isA<SessionUnauthenticated>());
  });
}
