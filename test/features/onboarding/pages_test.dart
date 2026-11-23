import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/app/app.dart';
import 'package:petbridge/app/router/app_router.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/storage/prefs_store.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/onboarding/application/onboarding_controller.dart';
import 'package:petbridge/features/onboarding/application/ui_locale.dart';
import 'package:petbridge/features/onboarding/data/onboarding_repository.dart';
import 'package:petbridge/features/onboarding/presentation/pages/mbti_page.dart';
import 'package:petbridge/features/onboarding/presentation/pages/too_young_page.dart';
import 'package:petbridge/features/room/application/realtime_coordinator.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  late MockOnboardingRepository repo;
  late ProviderContainer container;

  setUp(() => repo = MockOnboardingRepository());

  GoRouter router() => container.read(routerProvider);
  OnboardingController onb() =>
      container.read(onboardingControllerProvider.notifier);

  /// Pumps the real app with a session that needs onboarding; it lands on
  /// the language page.
  Future<void> pumpOnboarding(
    WidgetTester tester, {
    Locale system = const Locale('en', 'US'),
  }) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(
              const SessionNeedsOnboarding(Me(id: 'u1', onboarded: false)),
            ),
          ),
          onboardingRepositoryProvider.overrideWithValue(repo),
          deviceTimeZoneProvider.overrideWithValue(() async => 'UTC'),
          prefsStoreProvider.overrideWithValue(stubPrefs()),
          systemLocaleProvider.overrideWithValue(system),
          // No real socket in widget tests.
          wsClientProvider.overrideWithValue(null),
        ],
        child: const PetBridgeApp(),
      ),
    );
    await tester.pumpAndSettle();
    container = ProviderScope.containerOf(
      tester.element(find.byType(PetBridgeApp)),
    );
  }

  Future<void> open(WidgetTester tester, String location) async {
    unawaited(router().push(location));
    await tester.pumpAndSettle();
  }

  FilledButton primaryButton(WidgetTester tester, [Key? key]) =>
      tester.widget<FilledButton>(
        find.descendant(
          of: key == null ? find.byType(Scaffold).last : find.byKey(key),
          matching: find.byType(FilledButton),
        ),
      );

  bool tileSelected(WidgetTester tester, String key) =>
      tester.widget<ListTile>(find.byKey(ValueKey(key))).selected;

  Future<void> fillProfile(WidgetTester tester, AgeChoice age) async {
    await tester.enterText(find.byKey(const ValueKey('nickname')), 'Aki');
    await tester.tap(find.byKey(ValueKey('age-${age.name}')));
    await tester.pumpAndSettle();
  }

  testWidgets('lang page preselects resolved system language', (tester) async {
    await pumpOnboarding(tester, system: const Locale('zh', 'TW'));

    expect(tileSelected(tester, 'lang-zh-Hant'), isTrue);
    expect(tileSelected(tester, 'lang-en'), isFalse);
  });

  testWidgets('picking a language switches the UI language', (tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.byKey(const ValueKey('lang-ja')));
    await tester.pumpAndSettle();

    expect(find.text('次へ'), findsOneWidget);
    expect(container.read(onboardingControllerProvider).draft.nativeLang, 'ja');
  });

  testWidgets('mbti page continue disabled until a type is picked', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    await tester.tap(find.text(en.common_continue));
    await tester.pumpAndSettle();
    expect(find.byType(MbtiPage), findsOneWidget);

    expect(primaryButton(tester).onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('mbti-ENFP')));
    await tester.pumpAndSettle();

    expect(primaryButton(tester).onPressed, isNotNull);
  });

  testWidgets('quiz result flips a dimension and confirms', (tester) async {
    await pumpOnboarding(tester);
    await open(tester, Routes.onbMbti);
    await tester.tap(find.text(en.onb_mbti_not_sure));
    await tester.pumpAndSettle();

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const ValueKey('quiz-a')));
      await tester.pumpAndSettle();
    }
    for (final letter in ['E', 'S', 'T', 'J']) {
      expect(find.text(letter), findsOneWidget);
    }

    await tester.tap(find.byKey(const ValueKey('flip-tf')));
    await tester.pumpAndSettle();
    expect(find.text('F'), findsOneWidget);
    expect(find.text('T'), findsNothing);

    await tester.tap(find.text(en.onb_quiz_result_confirm));
    await tester.pumpAndSettle();

    expect(find.byType(MbtiPage), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const ValueKey('mbti-ESFJ')))
          .selected,
      isTrue,
    );
  });

  testWidgets('reveal shows pet for chosen MBTI', (tester) async {
    await pumpOnboarding(tester);
    onb().setMbti('ENFP');
    await open(tester, Routes.onbReveal);

    expect(find.text(en.pet_happy_shiba_name), findsOneWidget);
    expect(find.text(en.pet_happy_shiba_intro), findsOneWidget);
  });

  testWidgets('under13 routes to too-young page and does not submit', (
    tester,
  ) async {
    await pumpOnboarding(tester);
    await open(tester, Routes.onbProfile);
    await fillProfile(tester, AgeChoice.under13);

    await tester.tap(find.text(en.onb_submit));
    await tester.pumpAndSettle();

    expect(find.byType(TooYoungPage), findsOneWidget);
    expect(find.text(en.common_logout), findsOneWidget);
    verifyZeroInteractions(repo);
  });

  testWidgets('submit button disabled while submitting', (tester) async {
    final gate = Completer<void>();
    when(
      () => repo.complete(
        nativeLang: any(named: 'nativeLang'),
        mbti: any(named: 'mbti'),
        nickname: any(named: 'nickname'),
        ageBand: any(named: 'ageBand'),
        tz: any(named: 'tz'),
      ),
    ).thenAnswer((_) => gate.future);
    await pumpOnboarding(tester);
    await onb().setLanguage('en');
    onb().setMbti('ENFP');
    await open(tester, Routes.onbProfile);
    await fillProfile(tester, AgeChoice.adult);

    await tester.tap(find.text(en.onb_submit));
    await tester.pump();

    expect(primaryButton(tester, const ValueKey('submit')).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();
    expect(
      primaryButton(tester, const ValueKey('submit')).onPressed,
      isNotNull,
    );
  });

  testWidgets('nickname error shown inline', (tester) async {
    await pumpOnboarding(tester);
    await open(tester, Routes.onbProfile);

    await tester.enterText(find.byKey(const ValueKey('nickname')), 'a' * 21);
    await tester.pumpAndSettle();
    expect(find.text(en.onb_nickname_err_too_long), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('nickname')), '   ');
    await tester.pumpAndSettle();
    expect(find.text(en.onb_nickname_err_empty), findsOneWidget);
  });

  testWidgets('server VALIDATION_FAILED on nickname is shown inline', (
    tester,
  ) async {
    when(
      () => repo.complete(
        nativeLang: any(named: 'nativeLang'),
        mbti: any(named: 'mbti'),
        nickname: any(named: 'nickname'),
        ageBand: any(named: 'ageBand'),
        tz: any(named: 'tz'),
      ),
    ).thenThrow(
      const AppFailure(
        'VALIDATION_FAILED',
        status: 400,
        details: {
          'fields': ['nickname'],
          'message': 'server text',
        },
      ),
    );
    await pumpOnboarding(tester);
    await onb().setLanguage('en');
    onb().setMbti('ENFP');
    await open(tester, Routes.onbProfile);
    await fillProfile(tester, AgeChoice.adult);

    await tester.tap(find.text(en.onb_submit));
    await tester.pumpAndSettle();

    expect(find.text(en.onb_nickname_err_server), findsOneWidget);
    expect(find.text(en.err_VALIDATION_FAILED), findsOneWidget);
    expect(find.textContaining('server text'), findsNothing);
  });

  testWidgets('draft survives back navigation', (tester) async {
    await pumpOnboarding(tester);
    onb().setMbti('ENFP');
    await open(tester, Routes.onbReveal);
    await tester.tap(find.text(en.common_continue));
    await tester.pumpAndSettle();
    await fillProfile(tester, AgeChoice.adult);

    router().pop();
    await tester.pumpAndSettle();
    expect(find.text(en.pet_happy_shiba_name), findsOneWidget);
    await tester.tap(find.text(en.common_continue));
    await tester.pumpAndSettle();

    expect(find.text('Aki'), findsOneWidget);
    expect(tileSelected(tester, 'age-adult'), isTrue);
  });
}
