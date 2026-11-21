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
import 'package:petbridge/features/invite/presentation/bag_tab.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

const me = Me(id: 'u1', onboarded: true);
final now = DateTime.utc(2026, 11, 21, 10);

InviteCode code(
  String c,
  CodeStatus status, {
  Duration left = const Duration(days: 6, hours: 2),
}) => InviteCode(
  code: c,
  status: status,
  expiresAt: now.add(left),
  roomId: 'own',
  roomMemberCount: 3,
  roomCapacity: 5,
);

Room ownRoom({int count = 1, int? regenLeft}) => Room(
  id: 'own',
  isOwner: true,
  status: count >= 5 ? RoomStatus.full : RoomStatus.open,
  memberCount: count,
  capacity: 5,
  members: const [],
  regenRemainingToday: regenLeft,
);

void main() {
  late MockInviteRepository invites;
  late MockRoomRepository rooms;

  setUp(() {
    invites = MockInviteRepository();
    rooms = MockRoomRepository();
    when(() => rooms.listMine()).thenAnswer((_) async => [ownRoom()]);
  });

  Future<void> pump(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: Routes.homeBag,
      routes: [
        GoRoute(path: Routes.homeBag, builder: (_, _) => const BagTab()),
        GoRoute(path: Routes.join, builder: (_, _) => const Text('JOIN')),
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
    await tester.pumpAndSettle();
  }

  void listing(List<InviteCode> codes) =>
      when(() => invites.listCodes()).thenAnswer((_) async => codes);

  ButtonStyleButton regenButton(WidgetTester tester) =>
      tester.widget<ButtonStyleButton>(
        find.ancestor(
          of: find.text(en.bag_regen),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );

  testWidgets('shows four status labels and room count', (tester) async {
    listing([
      code('AAAA2345', CodeStatus.unused),
      code('BBBB2345', CodeStatus.used),
      code('CCCC2345', CodeStatus.expired),
      code('DDDD2345', CodeStatus.voided),
    ]);
    await pump(tester);

    expect(find.text('AAAA-2345'), findsOneWidget);
    for (final label in [
      en.bag_status_unused,
      en.bag_status_used,
      en.bag_status_expired,
      en.bag_status_void,
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text(en.bag_room_count(3, 5)), findsNWidgets(4));
  });

  testWidgets('unused shows remaining validity and share', (tester) async {
    listing([code('AAAA2345', CodeStatus.unused)]);
    await pump(tester);

    expect(find.text(en.bag_days_left(6)), findsOneWidget);
    await tester.tap(find.text(en.bag_share));
    await tester.pumpAndSettle();
    expect(find.text('SHARE AAAA2345'), findsOneWidget);
  });

  testWidgets('remaining under a day shows hours, under an hour soon', (
    tester,
  ) async {
    listing([
      code('AAAA2345', CodeStatus.unused, left: const Duration(hours: 5)),
      code('BBBB2345', CodeStatus.unused, left: const Duration(minutes: 20)),
    ]);
    await pump(tester);

    expect(find.text(en.bag_hours_left(5)), findsOneWidget);
    expect(find.text(en.bag_expiring), findsOneWidget);
  });

  testWidgets('used has no share button', (tester) async {
    listing([code('BBBB2345', CodeStatus.used)]);
    await pump(tester);

    expect(find.text(en.bag_share), findsNothing);
    expect(find.text(en.bag_days_left(6)), findsNothing);
  });

  testWidgets('regen disabled with hint when own room is full', (tester) async {
    listing([]);
    when(() => rooms.listMine())
        .thenAnswer((_) async => [ownRoom(count: 5, regenLeft: 0)]);
    await pump(tester);

    expect(regenButton(tester).onPressed, isNull);
    expect(find.text(en.bag_regen_full), findsOneWidget);
    expect(find.text(en.bag_regen_none_left), findsNothing);
  });

  testWidgets('regen remaining line hidden while regenRemainingToday is null', (
    tester,
  ) async {
    listing([]);
    await pump(tester);

    expect(regenButton(tester).onPressed, isNotNull);
    expect(find.textContaining('today'), findsNothing);
  });

  testWidgets('regen disabled when regenRemainingToday is 0', (tester) async {
    listing([]);
    when(() => rooms.listMine())
        .thenAnswer((_) async => [ownRoom(regenLeft: 0)]);
    await pump(tester);

    expect(regenButton(tester).onPressed, isNull);
    expect(find.text(en.bag_regen_none_left), findsOneWidget);
  });

  testWidgets('shows regen remaining count', (tester) async {
    listing([]);
    when(() => rooms.listMine())
        .thenAnswer((_) async => [ownRoom(regenLeft: 2)]);
    await pump(tester);

    expect(find.text(en.bag_regen_remaining(2)), findsOneWidget);
    expect(regenButton(tester).onPressed, isNotNull);
  });

  testWidgets('regen failure shows reason text', (tester) async {
    listing([]);
    when(() => invites.regen('own')).thenThrow(
      const AppFailure(
        'CODE_ISSUE_LIMIT',
        status: 409,
        details: {'reason': 'enough_unused'},
      ),
    );
    await pump(tester);

    await tester.tap(find.text(en.bag_regen));
    await tester.pumpAndSettle();

    expect(find.text(en.bag_regen_enough_unused), findsOneWidget);
  });

  testWidgets('regen success shows snackbar and new code on top', (
    tester,
  ) async {
    var codes = [code('AAAA2345', CodeStatus.unused)];
    when(() => invites.listCodes()).thenAnswer((_) async => codes);
    when(() => invites.regen('own')).thenAnswer((_) async {
      codes = [code('NEWW2345', CodeStatus.unused), ...codes];
      return IssuedCode(code: 'NEWW2345', expiresAt: now);
    });
    await pump(tester);

    await tester.tap(find.text(en.bag_regen));
    await tester.pumpAndSettle();

    expect(find.text(en.bag_regen_done), findsOneWidget);
    final first = tester.getTopLeft(find.text('NEWW-2345'));
    final second = tester.getTopLeft(find.text('AAAA-2345'));
    expect(first.dy, lessThan(second.dy));
  });

  testWidgets('empty list shows empty state', (tester) async {
    listing([]);
    await pump(tester);
    expect(find.text(en.bag_empty), findsOneWidget);
  });

  testWidgets('first load failure shows retry', (tester) async {
    var calls = 0;
    when(() => invites.listCodes()).thenAnswer((_) async {
      if (calls++ == 0) throw const AppFailure(AppFailure.network);
      return [];
    });
    await pump(tester);

    expect(find.text(en.err_NETWORK), findsOneWidget);
    await tester.tap(find.text(en.common_retry));
    await tester.pumpAndSettle();
    expect(find.text(en.bag_empty), findsOneWidget);
  });

  testWidgets('top-right opens join', (tester) async {
    listing([]);
    await pump(tester);

    await tester.tap(find.text(en.bag_join));
    await tester.pumpAndSettle();
    expect(find.text('JOIN'), findsOneWidget);
  });
}
