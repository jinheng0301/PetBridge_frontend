import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/app/app.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/clock.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/features/invite/presentation/join_page.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

const me = Me(id: 'u1', onboarded: true);

JoinOutcome outcome({List<IssuedCode> rewards = const []}) => JoinOutcome(
  roomId: 'r9',
  memberCount: 2,
  capacity: 5,
  members: const [
    RoomMember(
      userId: 'u9',
      seatNo: 1,
      role: RoomRole.owner,
      nickname: 'Hikari',
    ),
    RoomMember(userId: 'u1', seatNo: 2, role: RoomRole.member),
  ],
  rewards: rewards,
);

void main() {
  late MockInviteRepository invites;
  late MockRoomRepository rooms;
  late DateTime now;
  late List<MethodCall> platformCalls;
  late ProviderContainer container;
  var clipboard = '';

  setUp(() {
    invites = MockInviteRepository();
    rooms = MockRoomRepository();
    now = DateTime.utc(2026, 11, 21, 10);
    platformCalls = [];
    clipboard = '';
    when(() => rooms.listMine()).thenAnswer((_) async => []);
  });

  Future<void> pump(
    WidgetTester tester, {
    String location = Routes.join,
  }) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        platformCalls.add(call);
        if (call.method == 'Clipboard.getData') return {'text': clipboard};
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: Routes.join,
          builder: (_, s) =>
              JoinPage(initialCode: s.uri.queryParameters['code']),
        ),
        GoRoute(path: Routes.home, builder: (_, _) => const Text('HOME')),
        GoRoute(
          path: '${Routes.share}/:code',
          builder: (_, s) => Text('SHARE ${s.pathParameters['code']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(const SessionReady(me)),
          ),
          roomRepositoryProvider.overrideWithValue(rooms),
          inviteRepositoryProvider.overrideWithValue(invites),
          clockProvider.overrideWithValue(() => now),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    await tester.pumpAndSettle();
  }

  Finder field() => find.byType(TextField);
  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(field()).controller!.text;
  FilledButton submitButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, en.join_submit),
  );

  Future<void> submit(WidgetTester tester) async {
    await tester.pump();
    await tester.tap(find.text(en.join_submit));
    await tester.pumpAndSettle();
  }

  void failWith(String code, [Map<String, Object?> details = const {}]) {
    when(() => invites.join(any()))
        .thenThrow(AppFailure(code, status: 400, details: details));
  }

  testWidgets('join button disabled until 8 valid chars', (tester) async {
    await pump(tester);
    expect(submitButton(tester).onPressed, isNull);

    await tester.enterText(field(), 'abcd234');
    await tester.pump();
    expect(submitButton(tester).onPressed, isNull);

    await tester.enterText(field(), 'abcd2345');
    await tester.pump();
    expect(submitButton(tester).onPressed, isNotNull);
  });

  testWidgets('field shows XXXX-XXXX', (tester) async {
    await pump(tester);
    await tester.enterText(field(), 'ab cd-23 45');
    await tester.pump();
    expect(fieldText(tester), 'ABCD-2345');
  });

  testWidgets('paste button fills from clipboard', (tester) async {
    await pump(tester);
    clipboard = 'see https://petbridge.example.com/j/WXYZ6789';
    await tester.tap(find.text(en.join_paste));
    await tester.pumpAndSettle();
    expect(fieldText(tester), 'WXYZ-6789');
  });

  testWidgets('does not read clipboard on open', (tester) async {
    await pump(tester);
    expect(
      platformCalls.where((c) => c.method == 'Clipboard.getData'),
      isEmpty,
    );
  });

  testWidgets('prefills valid code param', (tester) async {
    await pump(tester, location: '${Routes.join}?code=ABCD2345');
    expect(fieldText(tester), 'ABCD-2345');
  });

  testWidgets('ignores invalid code param', (tester) async {
    await pump(tester, location: '${Routes.join}?code=abcd2345');
    expect(fieldText(tester), '');
  });

  testWidgets('error text shown under field and input kept', (tester) async {
    failWith('ROOM_FULL');
    await pump(tester);
    await tester.enterText(field(), 'ABCD2345');
    await submit(tester);

    expect(find.text(en.err_ROOM_FULL), findsOneWidget);
    expect(fieldText(tester), 'ABCD-2345');
  });

  testWidgets('ALREADY_MEMBER offers go to room', (tester) async {
    failWith('ALREADY_MEMBER', {'room_id': 'r7'});
    await pump(tester);
    await tester.enterText(field(), 'ABCD2345');
    await submit(tester);

    expect(find.text(en.err_ALREADY_MEMBER), findsOneWidget);
    await tester.tap(find.text(en.join_go_room));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(container.read(selectedRoomIdProvider), 'r7');
  });

  testWidgets('cooldown disables field, paste and button and shows mm:ss', (
    tester,
  ) async {
    failWith('CODE_COOLDOWN', {'retry_after_seconds': 1800});
    await pump(tester);
    await tester.enterText(field(), 'ABCD2345');
    await submit(tester);

    expect(find.text(en.join_retry_in('30:00')), findsOneWidget);
    expect(tester.widget<TextField>(field()).enabled, isFalse);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, en.join_paste))
          .onPressed,
      isNull,
    );
    expect(submitButton(tester).onPressed, isNull);

    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(en.join_retry_in('29:59')), findsOneWidget);

    now = now.add(const Duration(seconds: 1799));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('29:'), findsNothing);
    expect(find.text(en.err_CODE_COOLDOWN), findsNothing);
    expect(tester.widget<TextField>(field()).enabled, isTrue);
    expect(submitButton(tester).onPressed, isNotNull);
  });

  testWidgets('RATE_LIMITED without Retry-After only shows text', (
    tester,
  ) async {
    failWith('RATE_LIMITED');
    await pump(tester);
    await tester.enterText(field(), 'ABCD2345');
    await submit(tester);

    expect(find.text(en.err_RATE_LIMITED), findsOneWidget);
    expect(submitButton(tester).onPressed, isNotNull);
  });

  testWidgets('success with rewards shows gift and share', (tester) async {
    when(() => invites.join(any())).thenAnswer(
      (_) async => outcome(
        rewards: [
          IssuedCode(code: 'GIFT2345', expiresAt: DateTime.utc(2026, 12, 21)),
        ],
      ),
    );
    await pump(tester);
    await tester.enterText(field(), 'ABCD2345');
    await submit(tester);

    expect(find.text(en.join_success_title), findsOneWidget);
    expect(
      find.text(en.join_success_body(en.room_title_of('Hikari'))),
      findsOneWidget,
    );
    expect(find.text(en.join_reward_title), findsOneWidget);
    expect(find.text('GIFT-2345'), findsOneWidget);

    await tester.tap(find.text(en.join_share));
    await tester.pumpAndSettle();
    expect(find.text('SHARE GIFT2345'), findsOneWidget);
  });

  testWidgets('success without rewards hides gift', (tester) async {
    when(() => invites.join(any())).thenAnswer((_) async => outcome());
    await pump(tester);
    await tester.enterText(field(), 'ABCD2345');
    await submit(tester);

    expect(find.text(en.join_success_title), findsOneWidget);
    expect(find.text(en.join_reward_title), findsNothing);
    expect(find.text(en.join_share), findsNothing);

    await tester.tap(find.text(en.join_go_room));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(container.read(selectedRoomIdProvider), 'r9');
  });

  testWidgets('leaving the page clears input but keeps cooldown', (
    tester,
  ) async {
    failWith('CODE_COOLDOWN', {'retry_after_seconds': 60});
    await pump(tester);
    await tester.enterText(field(), 'ABCD2345');
    await submit(tester);

    GoRouter.of(tester.element(field())).go(Routes.home);
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.text('HOME'))).go(Routes.join);
    await tester.pumpAndSettle();

    expect(fieldText(tester), '');
    expect(find.text(en.join_retry_in('01:00')), findsOneWidget);
  });
}
