import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/app/app.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/data/room_repository.dart';
import 'package:petbridge/features/room/presentation/room_tab.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

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

void main() {
  late MockRoomRepository repo;
  late GoRouter router;

  setUp(() => repo = MockRoomRepository());

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

  final aki = member('u1', 1, nickname: 'Aki', role: RoomRole.owner);

  testWidgets('solo shows own pet and join button', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki]),
      ],
    );
    await pump(tester);

    expect(find.byType(PetView), findsOneWidget);
    expect(find.text('Aki · ENFP'), findsOneWidget);
    expect(find.text(en.room_locked_title), findsOneWidget);

    await tester.tap(find.text(en.room_join_button));
    await tester.pumpAndSettle();
    expect(find.text('JOIN'), findsOneWidget);
  });

  testWidgets('in room lists members by seat with owner tag', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki]),
        otherRoom([
          member('u9', 1, nickname: 'Hikari', role: RoomRole.owner),
          member('u1', 2, nickname: 'Aki'),
          member('u5', 3, nickname: 'Minsu'),
        ]),
      ],
    );
    await pump(tester);

    final names = tester
        .widgetList<Text>(find.byKey(const Key('member-name')))
        .map((t) => t.data)
        .toList();
    expect(names, ['Hikari', en.room_me, 'Minsu']);
    expect(find.text(en.room_owner_tag), findsOneWidget);
    expect(find.text('ENFP'), findsNothing);
  });

  testWidgets('own room with space shows free seats and invite', (
    tester,
  ) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki, member('u2', 2), member('u3', 3)]),
      ],
    );
    await pump(tester);

    expect(find.text(en.room_free_seats(2)), findsOneWidget);
    await tester.tap(find.text(en.room_invite));
    await tester.pumpAndSettle();
    expect(find.text('BAG'), findsOneWidget);
  });

  testWidgets('joined room has no invite button', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        otherRoom([member('u9', 1, role: RoomRole.owner), member('u1', 2)]),
      ],
    );
    await pump(tester);

    expect(find.text(en.room_invite), findsNothing);
  });

  testWidgets('two rooms show a switcher', (tester) async {
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

    expect(find.byType(SegmentedButton<String>), findsOneWidget);
    expect(find.textContaining('3/5'), findsWidgets);
    expect(find.textContaining('4/5'), findsWidgets);
    expect(find.text('Bo'), findsOneWidget);

    await tester.tap(find.textContaining(en.room_title_of('Hikari')).first);
    await tester.pumpAndSettle();

    expect(find.text('Bo'), findsNothing);
    expect(find.text('Hikari'), findsOneWidget);
  });

  testWidgets('one room hides the switcher', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        ownRoom([aki, member('u2', 2)]),
      ],
    );
    await pump(tester);

    expect(find.byType(SegmentedButton<String>), findsNothing);
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

    expect(find.text(en.room_locked_title), findsOneWidget);
  });

  testWidgets('long owner nickname is ellipsized', (tester) async {
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
    expect(title.data, contains(long));
    expect(title.overflow, TextOverflow.ellipsis);
  });
}
