import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/storage/prefs_store.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/onboarding/application/onboarding_controller.dart';
import 'package:petbridge/features/onboarding/application/ui_locale.dart';
import 'package:petbridge/features/onboarding/data/onboarding_repository.dart';

import '../../helpers/fakes.dart';

void main() {
  late MockOnboardingRepository repo;
  late FakeSessionController session;
  late MockPrefsStore prefs;

  setUp(() {
    repo = MockOnboardingRepository();
    session = FakeSessionController(
      const SessionNeedsOnboarding(Me(id: 'u1', onboarded: false)),
    );
    prefs = stubPrefs();
  });

  ProviderContainer makeContainer() => ProviderContainer.test(
    overrides: [
      onboardingRepositoryProvider.overrideWithValue(repo),
      deviceTimeZoneProvider.overrideWithValue(() async => 'Asia/Tokyo'),
      sessionControllerProvider.overrideWith(() => session),
      prefsStoreProvider.overrideWithValue(prefs),
      systemLocaleProvider.overrideWithValue(const Locale('en', 'US')),
    ],
  );

  void stubComplete(Future<void> Function() answer) => when(
    () => repo.complete(
      nativeLang: any(named: 'nativeLang'),
      mbti: any(named: 'mbti'),
      nickname: any(named: 'nickname'),
      ageBand: any(named: 'ageBand'),
      tz: any(named: 'tz'),
    ),
  ).thenAnswer((_) => answer());

  /// A container whose draft is complete (teen, ENFP, ja, "  Aki ").
  Future<ProviderContainer> filled() async {
    final c = makeContainer();
    final n = c.read(onboardingControllerProvider.notifier);
    await n.setLanguage('ja');
    n
      ..setMbti('ENFP')
      ..setNickname('  Aki ')
      ..setAge(AgeChoice.teen);
    return c;
  }

  test('submit sends mapped age band and tz', () async {
    stubComplete(() async {});
    final c = await filled();

    await c.read(onboardingControllerProvider.notifier).submit();

    verify(
      () => repo.complete(
        nativeLang: 'ja',
        mbti: 'ENFP',
        nickname: 'Aki',
        ageBand: '13_17',
        tz: 'Asia/Tokyo',
      ),
    ).called(1);
  });

  test('submit success refreshes session', () async {
    stubComplete(() async {});
    final c = await filled();

    await c.read(onboardingControllerProvider.notifier).submit();

    expect(session.calls, ['refreshMe']);
    final s = c.read(onboardingControllerProvider);
    expect(s.submitting, isFalse);
    expect(s.failure, isNull);
  });

  test('VALIDATION_FAILED marks fields', () async {
    stubComplete(
      () async => throw const AppFailure(
        'VALIDATION_FAILED',
        status: 400,
        details: {
          'fields': ['nickname'],
        },
      ),
    );
    final c = await filled();

    await c.read(onboardingControllerProvider.notifier).submit();

    final s = c.read(onboardingControllerProvider);
    expect(s.badFields, {'nickname'});
    expect(s.failure?.code, 'VALIDATION_FAILED');
    expect(session.calls, isEmpty);

    c.read(onboardingControllerProvider.notifier).setNickname('Aki2');
    expect(c.read(onboardingControllerProvider).badFields, isEmpty);
  });

  test('network failure keeps draft and allows retry', () async {
    var calls = 0;
    stubComplete(() async {
      if (calls++ == 0) throw const AppFailure(AppFailure.network);
    });
    final c = await filled();
    final n = c.read(onboardingControllerProvider.notifier);

    await n.submit();
    var s = c.read(onboardingControllerProvider);
    expect(s.failure?.code, AppFailure.network);
    expect(s.draft.nickname, '  Aki ');
    expect(s.draft.age, AgeChoice.teen);

    await n.submit();
    s = c.read(onboardingControllerProvider);
    expect(s.failure, isNull);
    expect(calls, 2);
    expect(session.calls, ['refreshMe']);
  });

  test('draft survives back navigation', () async {
    final c = makeContainer();
    // A page watching the controller, then leaving (its listener closes).
    final sub = c.listen(onboardingControllerProvider, (_, _) {});
    c.read(onboardingControllerProvider.notifier)
      ..setNickname('Aki')
      ..setAge(AgeChoice.adult);
    sub.close();
    await Future<void>.delayed(Duration.zero);

    final s = c.read(onboardingControllerProvider);
    expect(s.draft.nickname, 'Aki');
    expect(s.draft.age, AgeChoice.adult);
  });

  test('submit is ignored while submitting', () async {
    final gate = Completer<void>();
    stubComplete(() => gate.future);
    final c = await filled();
    final n = c.read(onboardingControllerProvider.notifier);

    final first = n.submit();
    expect(c.read(onboardingControllerProvider).submitting, isTrue);
    await n.submit();
    gate.complete();
    await first;

    verify(
      () => repo.complete(
        nativeLang: any(named: 'nativeLang'),
        mbti: any(named: 'mbti'),
        nickname: any(named: 'nickname'),
        ageBand: any(named: 'ageBand'),
        tz: any(named: 'tz'),
      ),
    ).called(1);
  });

  test('under13 is never submitted', () async {
    final c = await filled();
    c.read(onboardingControllerProvider.notifier).setAge(AgeChoice.under13);

    await c.read(onboardingControllerProvider.notifier).submit();

    verifyZeroInteractions(repo);
  });

  test('setLanguage switches the UI language and remembers it', () async {
    final c = makeContainer();
    expect(c.read(uiLocaleProvider), const Locale('en'));

    await c.read(onboardingControllerProvider.notifier).setLanguage('zh-Hant');

    expect(
      c.read(uiLocaleProvider),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
    verify(() => prefs.setUiLocale('zh-Hant')).called(1);
  });

  test('logout clears the draft and the UI language', () async {
    final c = await filled();
    c.listen(uiLocaleProvider, (_, _) {});

    session.current = const SessionUnauthenticated();

    expect(c.read(onboardingControllerProvider).draft.nickname, '');
    expect(c.read(onboardingControllerProvider).draft.nativeLang, isNull);
    expect(c.read(uiLocaleProvider), const Locale('en'));
  });
}
