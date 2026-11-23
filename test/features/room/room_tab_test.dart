import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/app/app.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/realtime/ws_client.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';
import 'package:petbridge/features/room/application/realtime_coordinator.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/data/room_repository.dart';
import 'package:petbridge/features/room/presentation/room_scene.dart';
import 'package:petbridge/features/room/presentation/room_tab.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';
import 'fake_ws_client.dart';

const me = Me(
  id: 'u1',
  onboarded: true,
  nickname: 'Aki',
  mbti: 'ENFP',
  petType: 'happy_shiba',
);

RoomMember member(
  String id,
  int seat, {
  String? nickname,
  RoomRole role = RoomRole.member,
}) => RoomMember(
  userId: id,
  seatNo: seat,
  role: role,
  nickname: nickname ?? id,
  petType: 'thinker_owl',
);

Room ownRoom(List<RoomMember> members, {int capacity = 5}) => Room(
  id: 'own',
  isOwner: true,
  status: members.length >= capacity ? RoomStatus.full : RoomStatus.open,
  memberCount: members.length,
  capacity: capacity,
  members: members,
);

Room otherRoom(List<RoomMember> members) => Room(
  id: 'other',
  isOwner: false,
  status: RoomStatus.open,
  memberCount: members.length,
  capacity: 5,
  members: members,
);

Finder pet(String userId) => find.byKey(Key('room-pet-$userId'));

void main() {
  late MockRoomRepository repo;
  late FakeWsClient ws;
  late GoRouter router;

  setUp(() {
    repo = MockRoomRepository();
    // Ready from the start: no "reconnecting" timer is left pending.
    ws = FakeWsClient()..moveTo(WsConnState.ready);
  });

  Future<void> pump(WidgetTester tester) async {
    router = GoRouter(
      initialLocation: Routes.home,
      routes: [
        GoRoute(path: Routes.home, builder: (_, _) => const RoomTab()),
        GoRoute(path: Routes.join, builder: (_, _) => const Text('JOIN')),
        GoRoute(path: Routes.homeBag, builder: (_, _) => const Text('BAG')),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(const SessionReady(me)),
          ),
          roomRepositoryProvider.overrideWithValue(repo),
          wsClientProvider.overrideWithValue(ws),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  ProviderContainer container(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(RoomTab)));

  final aki = member('u1', 1, nickname: 'Aki', role: RoomRole.owner);

  testWidgets('solo shows card with join and invite', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki]),
      ],
    );
    await pump(tester);

    expect(find.byType(RoomScene), findsOneWidget);
    expect(find.byType(PetView), findsOneWidget);
    expect(find.byKey(const Key('room-solo-card')), findsOneWidget);
    expect(find.text(en.room_solo_card), findsOneWidget);
    // The card offers the invite; the empty seats are plain cushions.
    expect(find.text(en.room_seat_invite), findsNothing);

    await tester.tap(find.text(en.room_join_button));
    await tester.pumpAndSettle();
    expect(find.text('JOIN'), findsOneWidget);

    router.go(Routes.home);
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.room_invite));
    await tester.pumpAndSettle();
    expect(find.text('BAG'), findsOneWidget);
  });

  testWidgets('own room empty seat opens bag', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki, member('u2', 2), member('u3', 3)]),
      ],
    );
    await pump(tester);

    expect(find.byKey(const Key('room-solo-card')), findsNothing);
    expect(find.text(en.room_seat_invite), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('room-seat-invite-4')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.homeBag);
    expect(find.text('BAG'), findsOneWidget);
  });

  testWidgets('friend room empty seat has no invite', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        otherRoom([member('u9', 1, role: RoomRole.owner), member('u1', 2)]),
      ],
    );
    await pump(tester);

    expect(find.byKey(const Key('room-cushion-3')), findsOneWidget);
    expect(find.text(en.room_seat_invite), findsNothing);
    expect(find.byKey(const Key('room-solo-card')), findsNothing);
  });

  testWidgets('reconnecting pill follows provider', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki, member('u2', 2)]),
      ],
    );
    await pump(tester);
    expect(find.byKey(const Key('room-reconnecting')), findsNothing);

    container(tester).read(wsReconnectingProvider.notifier).set(true);
    await tester.pump();
    expect(find.byKey(const Key('room-reconnecting')), findsOneWidget);
    expect(find.text(en.room_reconnecting), findsOneWidget);

    container(tester).read(wsReconnectingProvider.notifier).set(false);
    await tester.pump();
    expect(find.byKey(const Key('room-reconnecting')), findsNothing);
  });

  testWidgets('tapping another pet sends pet.tap and plays once', (
    tester,
  ) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki, member('u2', 2)]),
      ],
    );
    await pump(tester);

    await tester.tap(pet('u2'));
    await tester.pump();

    expect(
      ws.sent.where((f) => f.t == 'pet.tap').map((f) => f.d['target_user_id']),
      ['u2'],
    );
    expect(tester.widget<PetView>(pet('u2')).cuteTick, 1);
  });

  testWidgets('tapping own pet sends nothing and plays once', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki, member('u2', 2)]),
      ],
    );
    await pump(tester);

    await tester.tap(pet('u1'));
    await tester.pump();

    expect(ws.sent.where((f) => f.t == 'pet.tap'), isEmpty);
    expect(tester.widget<PetView>(pet('u1')).cuteTick, 1);
  });

  testWidgets('incoming pet.action plays on the target', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki, member('u2', 2)]),
      ],
    );
    await pump(tester);

    ws.push('pet.action', {
      'room_id': 'own',
      'target_user_id': 'u1',
      'from_user_id': 'u2',
    });
    await tester.pumpAndSettle();

    expect(tester.widget<PetView>(pet('u1')).cuteTick, 1);
  });

  testWidgets('top bar shows title and count, switches between rooms', (
    tester,
  ) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki, member('u2', 2, nickname: 'Bo'), member('u3', 3)]),
        otherRoom([
          member('u9', 1, nickname: 'Hikari', role: RoomRole.owner),
          member('u1', 2),
          member('u7', 3),
          member('u8', 4),
        ]),
      ],
    );
    await pump(tester);

    expect(find.text(en.room_title_mine), findsOneWidget);
    expect(find.text('3/5'), findsOneWidget);
    expect(find.byKey(const Key('room-switch-arrow')), findsOneWidget);
    expect(find.text('Bo'), findsOneWidget);

    await tester.tap(find.byKey(const Key('room-switch')));
    await tester.pumpAndSettle();

    expect(find.text(en.room_title_of('Hikari')), findsOneWidget);
    expect(find.text('4/5'), findsOneWidget);
    expect(find.text('Bo'), findsNothing);
    expect(find.text('Hikari'), findsOneWidget);

    await tester.tap(find.byKey(const Key('room-switch')));
    await tester.pumpAndSettle();
    expect(find.text(en.room_title_mine), findsOneWidget);
  });

  testWidgets('one room has no switch arrow', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki, member('u2', 2)]),
      ],
    );
    await pump(tester);

    expect(find.byKey(const Key('room-switch-arrow')), findsNothing);
    await tester.tap(find.byKey(const Key('room-switch')));
    await tester.pumpAndSettle();
    expect(find.text(en.room_title_mine), findsOneWidget);
  });

  testWidgets('first load failure shows retry', (tester) async {
    var calls = 0;
    when(() => repo.listMine()).thenAnswer((_) async {
      if (calls++ == 0) throw const AppFailure(AppFailure.network);
      return [
        ownRoom([aki]),
      ];
    });
    await pump(tester);

    expect(find.text(en.err_NETWORK), findsOneWidget);
    await tester.tap(find.text(en.common_retry));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('room-solo-card')), findsOneWidget);
  });

  testWidgets('long owner nickname is ellipsized in the title', (tester) async {
    final long = 'H' * 40;
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        otherRoom([
          member('u9', 1, nickname: long, role: RoomRole.owner),
          member('u1', 2),
        ]),
      ],
    );
    await pump(tester);

    expect(tester.takeException(), isNull);
    final title = tester.widget<Text>(find.byKey(const Key('room-title')));
    expect(title.data, en.room_title_of(long));
    expect(title.overflow, TextOverflow.ellipsis);
  });
}
