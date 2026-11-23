import 'dart:async';

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
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/data/room_repository.dart';
import 'package:petbridge/features/room/presentation/room_manage_page.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

const me = Me(id: 'u1', onboarded: true, nickname: 'Aki');

RoomMember member(String id, int seat, {RoomRole? role, String? nickname}) =>
    RoomMember(
      userId: id,
      seatNo: seat,
      role: role ?? RoomRole.member,
      nickname: nickname ?? id,
      petType: 'thinker_owl',
    );

Room room(List<RoomMember> members, {bool own = true}) => Room(
  id: 'own',
  isOwner: own,
  status: RoomStatus.open,
  memberCount: members.length,
  capacity: 5,
  members: members,
);

void main() {
  late MockRoomRepository repo;
  late MockInviteRepository invites;
  late GoRouter router;

  final aki = member('u1', 1, role: RoomRole.owner, nickname: 'Aki');
  final bo = member('u2', 2, nickname: 'Bo');

  setUp(() {
    repo = MockRoomRepository();
    invites = MockInviteRepository();
    when(() => invites.listCodes()).thenAnswer((_) async => []);
  });

  Future<void> pump(WidgetTester tester) async {
    router = GoRouter(
      initialLocation: Routes.roomManagePath('own'),
      routes: [
        GoRoute(path: Routes.home, builder: (_, _) => const Text('ROOM-TAB')),
        GoRoute(
          path: Routes.roomManage,
          builder: (_, s) => RoomManagePage(roomId: s.pathParameters['id']!),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(const SessionReady(me)),
          ),
          roomRepositoryProvider.overrideWithValue(repo),
          inviteRepositoryProvider.overrideWithValue(invites),
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

  Finder dialogButton(String label) =>
      find.descendant(of: find.byType(AlertDialog), matching: find.text(label));

  Finder dissolveButton() =>
      find.widgetWithText(FilledButton, en.manage_dissolve);

  testWidgets('manage page lists members with remove except owner', (
    tester,
  ) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        room([aki, bo]),
      ],
    );
    await pump(tester);

    expect(find.text(en.manage_title), findsOneWidget);
    expect(find.text('Aki'), findsOneWidget);
    expect(find.text('Bo'), findsOneWidget);
    expect(find.text(en.manage_owner), findsOneWidget);
    expect(find.text(en.manage_remove), findsOneWidget);
  });

  testWidgets('dissolve disabled when alone', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        room([aki]),
      ],
    );
    await pump(tester);

    expect(tester.widget<FilledButton>(dissolveButton()).onPressed, isNull);
  });

  testWidgets('dissolve confirms, calls dissolve and returns to room tab', (
    tester,
  ) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        room([aki, bo]),
      ],
    );
    when(() => repo.dissolve('own')).thenAnswer((_) async {});
    await pump(tester);

    await tester.tap(dissolveButton());
    await tester.pumpAndSettle();
    expect(find.text(en.manage_dissolve_confirm_title), findsOneWidget);
    verifyNever(() => repo.dissolve(any()));

    await tester.tap(dialogButton(en.manage_dissolve));
    await tester.pumpAndSettle();

    verify(() => repo.dissolve('own')).called(1);
    expect(find.text('ROOM-TAB'), findsOneWidget);
  });

  testWidgets('removing a member asks to confirm then calls remove', (
    tester,
  ) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        room([aki, bo]),
      ],
    );
    when(() => repo.removeMember('own', 'u2')).thenAnswer((_) async {});
    await pump(tester);

    await tester.tap(find.text(en.manage_remove));
    await tester.pumpAndSettle();
    expect(find.text(en.manage_remove_confirm_body('Bo')), findsOneWidget);

    await tester.tap(dialogButton(en.manage_remove));
    await tester.pumpAndSettle();
    verify(() => repo.removeMember('own', 'u2')).called(1);
  });

  testWidgets('remove confirm uses pet name when nickname is empty', (
    tester,
  ) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        room([aki, member('u2', 2, nickname: '')]),
      ],
    );
    await pump(tester);

    final owl = petName(en, 'thinker_owl');
    expect(find.text(owl), findsOneWidget);
    await tester.tap(find.text(en.manage_remove));
    await tester.pumpAndSettle();
    expect(find.text(en.manage_remove_confirm_body(owl)), findsOneWidget);
  });

  testWidgets('non-owner room redirects to room tab', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        room([aki, bo], own: false),
      ],
    );
    await pump(tester);

    expect(find.text('ROOM-TAB'), findsOneWidget);
  });

  testWidgets('unknown room redirects to room tab', (tester) async {
    when(() => repo.listMine()).thenAnswer((_) async => []);
    await pump(tester);

    expect(find.text('ROOM-TAB'), findsOneWidget);
  });

  testWidgets('failure shows snackbar and re-enables button', (tester) async {
    when(() => repo.listMine()).thenAnswer(
      (_) async => [
        room([aki, bo]),
      ],
    );
    final gate = Completer<void>();
    when(() => repo.dissolve('own')).thenAnswer((_) => gate.future);
    await pump(tester);

    await tester.tap(dissolveButton());
    await tester.pumpAndSettle();
    await tester.tap(dialogButton(en.manage_dissolve));
    await tester.pump();
    await tester.pump();

    expect(tester.widget<FilledButton>(dissolveButton()).onPressed, isNull);

    gate.completeError(const AppFailure(AppFailure.network));
    await tester.pumpAndSettle();

    expect(find.text(en.err_NETWORK), findsOneWidget);
    expect(tester.widget<FilledButton>(dissolveButton()).onPressed, isNotNull);
    expect(find.text('ROOM-TAB'), findsNothing);
  });
}
