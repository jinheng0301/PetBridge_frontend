import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/features/auth/application/session.dart';

void main() {
  const fresh = Me(id: 'u1', onboarded: false);
  const done = Me(id: 'u1', onboarded: true, nickname: 'Aki');

  test('unknown -> /splash', () {
    expect(redirectFor(const SessionUnknown(), Routes.home), Routes.splash);
    expect(redirectFor(const SessionUnknown(), Routes.splash), isNull);
  });

  test('unauthenticated on /home -> /login', () {
    expect(
      redirectFor(const SessionUnauthenticated(), Routes.home),
      Routes.login,
    );
  });

  test('unauthenticated on /login -> null', () {
    expect(redirectFor(const SessionUnauthenticated(), Routes.login), isNull);
  });

  test('needsOnboarding on /home -> /onboarding/lang', () {
    expect(
      redirectFor(const SessionNeedsOnboarding(fresh), Routes.home),
      Routes.onbLang,
    );
    expect(
      redirectFor(const SessionNeedsOnboarding(fresh), Routes.login),
      Routes.onbLang,
    );
  });

  test('needsOnboarding on /onboarding/profile -> null', () {
    for (final loc in [
      Routes.onbLang,
      Routes.onbMbti,
      Routes.onbQuiz,
      Routes.onbQuizResult,
      Routes.onbReveal,
      Routes.onbProfile,
      Routes.onbTooYoung,
    ]) {
      expect(
        redirectFor(const SessionNeedsOnboarding(fresh), loc),
        isNull,
        reason: loc,
      );
    }
  });

  test('ready on /login or /onboarding/* -> /home', () {
    expect(redirectFor(const SessionReady(done), Routes.login), Routes.home);
    expect(redirectFor(const SessionReady(done), Routes.onbLang), Routes.home);
    expect(redirectFor(const SessionReady(done), Routes.splash), Routes.home);
  });

  test('ready on /home -> null', () {
    expect(redirectFor(const SessionReady(done), Routes.home), isNull);
    expect(redirectFor(const SessionReady(done), Routes.homeMe), isNull);
  });

  test('ready on /join or /share/<code> -> null', () {
    expect(redirectFor(const SessionReady(done), Routes.join), isNull);
    expect(
      redirectFor(const SessionReady(done), Routes.sharePath('ABCD2345')),
      isNull,
    );
    expect(redirectFor(const SessionReady(done), '/joined'), Routes.home);
  });

  test('ready user may open /room/x/manage', () {
    expect(
      redirectFor(const SessionReady(done), Routes.roomManagePath('x')),
      isNull,
    );
    expect(redirectFor(const SessionReady(done), '/roomy'), Routes.home);
  });

  test('needsOnboarding on /join -> /onboarding/lang', () {
    expect(
      redirectFor(const SessionNeedsOnboarding(fresh), Routes.join),
      Routes.onbLang,
    );
  });
}
