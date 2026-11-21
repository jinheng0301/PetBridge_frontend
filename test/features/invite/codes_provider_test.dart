import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/application/codes_provider.dart';
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

const me = Me(id: 'u1', onboarded: true);

InviteCode code(String c) => InviteCode(
  code: c,
  status: CodeStatus.unused,
  expiresAt: DateTime.utc(2026, 12),
  roomId: 'own',
  roomMemberCount: 1,
  roomCapacity: 5,
);

const own = Room(
  id: 'own',
  isOwner: true,
  status: RoomStatus.open,
  memberCount: 1,
  capacity: 5,
  members: [],
);

const other = Room(
  id: 'other',
  isOwner: false,
  status: RoomStatus.open,
  memberCount: 3,
  capacity: 5,
  members: [],
);

void main() {
  late MockInviteRepository invites;
  late MockRoomRepository rooms;
  late FakeSessionController session;

  setUp(() {
    invites = MockInviteRepository();
    rooms = MockRoomRepository();
    when(() => rooms.listMine()).thenAnswer((_) async => [other, own]);
  });

  ProviderContainer make() {
    session = FakeSessionController(const SessionReady(me));
    return ProviderContainer.test(
      overrides: [
        sessionControllerProvider.overrideWith(() => session),
        roomRepositoryProvider.overrideWithValue(rooms),
        inviteRepositoryProvider.overrideWithValue(invites),
      ],
    )..listen(codesProvider, (_, _) {});
  }

  test('codes cleared when session leaves ready', () async {
    when(() => invites.listCodes()).thenAnswer((_) async => [code('AAAA2345')]);
    final c = make();
    expect(await c.read(codesProvider.future), hasLength(1));

    session.current = const SessionUnauthenticated();

    expect(await c.read(codesProvider.future), isEmpty);
    verify(() => invites.listCodes()).called(1);
  });

  test('refresh failure keeps previous codes', () async {
    var calls = 0;
    when(() => invites.listCodes()).thenAnswer((_) async {
      if (calls++ == 0) return [code('AAAA2345')];
      throw const AppFailure(AppFailure.network);
    });
    final c = make();
    await c.read(codesProvider.future);

    await expectLater(
      c.read(codesProvider.notifier).refresh(),
      throwsA(isA<AppFailure>()),
    );
    expect(c.read(codesProvider).value?.single.code, 'AAAA2345');
    expect(c.read(codesProvider).hasError, isFalse);
  });

  test('regen uses own room id and refreshes codes and rooms', () async {
    var listed = [code('AAAA2345')];
    when(() => invites.listCodes()).thenAnswer((_) async => listed);
    when(() => invites.regen('own')).thenAnswer(
      (_) async => IssuedCode(code: 'NEWW2345', expiresAt: DateTime.utc(2027)),
    );
    final c = make()..listen(roomsProvider, (_, _) {});
    await c.read(codesProvider.future);
    await c.read(roomsProvider.future);
    clearInteractions(rooms);

    listed = [code('NEWW2345'), code('AAAA2345')];
    final issued = await c.read(codesProvider.notifier).regen();

    expect(issued.code, 'NEWW2345');
    verify(() => invites.regen('own')).called(1);
    expect(c.read(codesProvider).value?.first.code, 'NEWW2345');
    verify(() => rooms.listMine()).called(1);
  });

  test('regen failure is rethrown', () async {
    when(() => invites.listCodes()).thenAnswer((_) async => []);
    when(() => invites.regen(any())).thenThrow(
      const AppFailure('CODE_ISSUE_LIMIT', details: {'reason': 'daily_limit'}),
    );
    final c = make();

    await expectLater(
      c.read(codesProvider.notifier).regen(),
      throwsA(isA<AppFailure>()),
    );
  });

  group('regenFailureText', () {
    final l = en;
    String text(String reason) => regenFailureText(
      l,
      AppFailure('CODE_ISSUE_LIMIT', details: {'reason': reason}),
    );

    test('maps each reason', () {
      expect(text('room_full'), l.bag_regen_room_full);
      expect(text('enough_unused'), l.bag_regen_enough_unused);
      expect(text('daily_limit'), l.bag_regen_daily_limit);
      expect(text('lifetime_limit'), l.bag_regen_lifetime_limit);
    });

    test('unknown reason and other codes use generic text', () {
      expect(text('mystery'), l.err_CODE_ISSUE_LIMIT);
      expect(
        regenFailureText(l, const AppFailure(AppFailure.network)),
        l.err_NETWORK,
      );
    });
  });
}
