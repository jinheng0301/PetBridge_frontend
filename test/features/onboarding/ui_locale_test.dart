import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/core/storage/prefs_store.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/onboarding/application/ui_locale.dart';

import '../../helpers/fakes.dart';

void main() {
  const ja = Locale('ja');
  const en = Locale('en');

  ({ProviderContainer c, FakeSessionController session, MockPrefsStore prefs})
  make(Session initial, {String? saved}) {
    final session = FakeSessionController(initial);
    final prefs = stubPrefs(saved);
    final c = ProviderContainer.test(
      overrides: [
        sessionControllerProvider.overrideWith(() => session),
        prefsStoreProvider.overrideWithValue(prefs),
        systemLocaleProvider.overrideWithValue(const Locale('en', 'US')),
      ],
    )..listen(uiLocaleProvider, (_, _) {});
    return (c: c, session: session, prefs: prefs);
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  const onboardedJa = SessionReady(
    Me(id: 'u1', onboarded: true, nativeLang: 'ja'),
  );

  test('saved choice wins over native_lang', () async {
    final t = make(onboardedJa, saved: 'ko');
    await settle();

    expect(t.c.read(uiLocaleProvider), const Locale('ko'));
  });

  test('falls back to native_lang from /me at start', () async {
    final t = make(onboardedJa);
    await settle();

    expect(t.c.read(uiLocaleProvider), ja);
    verify(() => t.prefs.setUiLocale('ja')).called(1);
  });

  test('logging back in restores native_lang', () async {
    final t = make(const SessionUnauthenticated());
    await settle();
    expect(t.c.read(uiLocaleProvider), en);

    t.session.current = onboardedJa;
    await settle();

    expect(t.c.read(uiLocaleProvider), ja);
  });

  test('a new user without native_lang keeps the system language', () async {
    final t = make(const SessionUnauthenticated());
    await settle();

    t.session.current = const SessionNeedsOnboarding(
      Me(id: 'u1', onboarded: false),
    );
    await settle();

    expect(t.c.read(uiLocaleProvider), en);
    verifyNever(() => t.prefs.setUiLocale(any()));
  });
}
