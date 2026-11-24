import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/app/app.dart';
import 'package:petbridge/core/storage/prefs_store.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/auth/presentation/login_page.dart';
import 'package:petbridge/features/home/presentation/me_tab.dart';
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';
import 'package:petbridge/features/room/application/realtime_coordinator.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeSessionController session;
  late MockRoomRepository rooms;
  late MockInviteRepository invites;

  const me = Me(
    id: 'u1',
    onboarded: true,
    nickname: 'Aki',
    mbti: 'ENFP',
    petType: 'happy_shiba',
  );

  late StreamController<KickNotice> kicks;

  setUp(() => kicks = StreamController<KickNotice>.broadcast());
  tearDown(() => kicks.close());

  Future<void> pumpHome(WidgetTester tester, {bool fakeKicks = false}) async {
    final coordinator = MockCoordinator();
    when(() => coordinator.kicks).thenAnswer((_) => kicks.stream);
    session = FakeSessionController(const SessionReady(me));
    rooms = MockRoomRepository();
    when(() => rooms.listMine()).thenAnswer((_) async => []);
    invites = MockInviteRepository();
    when(() => invites.listCodes()).thenAnswer((_) async => []);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith(() => session),
          prefsStoreProvider.overrideWithValue(stubPrefs()),
          roomRepositoryProvider.overrideWithValue(rooms),
          inviteRepositoryProvider.overrideWithValue(invites),
          // No real socket in widget tests.
          wsClientProvider.overrideWithValue(null),
          if (fakeKicks)
            realtimeCoordinatorProvider.overrideWithValue(coordinator),
        ],
        child: const PetBridgeApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows four tabs in order', (tester) async {
    await pumpHome(tester);

    final labels = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .map((d) => d.label)
        .toList();
    expect(labels, [
      en.home_tab_room,
      en.home_tab_chat,
      en.home_tab_bag,
      en.home_tab_me,
    ]);
  });

  testWidgets('chat tab shows coming soon', (tester) async {
    await pumpHome(tester);

    for (final tab in [en.home_tab_chat]) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(tab),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(en.home_coming_soon), findsOneWidget, reason: tab);
    }
  });

  testWidgets('me tab shows nickname, MBTI and pet', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text(en.home_tab_me).last);
    await tester.pumpAndSettle();

    expect(find.byType(MeTab), findsOneWidget);
    expect(find.text('Aki'), findsOneWidget);
    expect(find.text('ENFP'), findsOneWidget);
    expect(find.byType(PetView), findsOneWidget);
    // The drawn pet has no text; the name is in the "Pet" row.
    expect(find.text(en.pet_happy_shiba_name), findsOneWidget);
  });

  testWidgets('logout returns to login', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text(en.home_tab_me).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(en.common_logout));
    await tester.pumpAndSettle();

    expect(session.calls, ['logout']);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('refreshes rooms on resume', (tester) async {
    await pumpHome(tester);
    clearInteractions(rooms);

    const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pumpAndSettle();

    verify(() => rooms.listMine()).called(1);
  });

  testWidgets('refreshes codes on resume', (tester) async {
    await pumpHome(tester);
    clearInteractions(invites);

    const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pumpAndSettle();

    verify(() => invites.listCodes()).called(1);
  });

  for (final reason in [KickReason.kicked, KickReason.dissolved]) {
    testWidgets('${reason.name} shows left notice', (tester) async {
      await pumpHome(tester, fakeKicks: true);

      kicks.add(KickNotice('r1', reason));
      await tester.pump();
      await tester.pump();

      expect(find.text(en.room_left_notice), findsOneWidget);
    });
  }

  testWidgets('left shows nothing', (tester) async {
    await pumpHome(tester, fakeKicks: true);

    kicks.add(const KickNotice('r1', KickReason.left));
    await tester.pump();
    await tester.pump();

    expect(find.text(en.room_left_notice), findsNothing);
  });
}

class MockCoordinator extends Mock implements RealtimeCoordinator;
