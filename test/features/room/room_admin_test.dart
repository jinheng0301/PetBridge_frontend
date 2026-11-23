import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/invite/application/codes_provider.dart';
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_admin.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

import '../../helpers/fakes.dart';

Room _room(String id, {bool own = false}) => Room(
  id: id,
  isOwner: own,
  status: RoomStatus.open,
  memberCount: 2,
  capacity: 5,
  members: const [],
);

void main() {
  late MockRoomRepository repo;
  late MockInviteRepository invites;
  late ProviderContainer c;

  setUp(() {
    repo = MockRoomRepository();
    invites = MockInviteRepository();
    when(() => invites.listCodes()).thenAnswer((_) async => []);
    when(() => repo.listMine())
        .thenAnswer((_) async => [_room('own', own: true), _room('other')]);
    c = ProviderContainer.test(
      overrides: [
        sessionControllerProvider.overrideWith(
          () => FakeSessionController(
            const SessionReady(Me(id: 'u1', onboarded: true)),
          ),
        ),
        roomRepositoryProvider.overrideWithValue(repo),
        inviteRepositoryProvider.overrideWithValue(invites),
      ],
    )..listen(roomsProvider, (_, _) {});
  });

  Future<void> primed() async {
    await c.read(roomsProvider.future);
    await c.read(codesProvider.future);
    clearInteractions(repo);
    clearInteractions(invites);
  }

  test('remove refreshes rooms', () async {
    when(() => repo.removeMember('own', 'u2')).thenAnswer((_) async {});
    await primed();

    await c.read(roomAdminProvider).remove('own', 'u2');

    verify(() => repo.removeMember('own', 'u2')).called(1);
    verify(() => repo.listMine()).called(1);
    verifyNever(() => invites.listCodes());
  });

  test('dissolve refreshes rooms and codes', () async {
    when(() => repo.dissolve('own')).thenAnswer((_) async {});
    await primed();

    await c.read(roomAdminProvider).dissolve('own');

    verify(() => repo.dissolve('own')).called(1);
    verify(() => repo.listMine()).called(1);
    verify(() => invites.listCodes()).called(1);
  });

  test('leave selects own room', () async {
    when(() => repo.leave('other')).thenAnswer((_) async {});
    await primed();
    c.read(selectedRoomIdProvider.notifier).select('other');

    await c.read(roomAdminProvider).leave('other');

    verify(() => repo.listMine()).called(1);
    expect(c.read(selectedRoomIdProvider), 'own');
  });

  test('ROOM_NOT_FOUND is treated as already gone', () async {
    when(() => repo.leave('other'))
        .thenThrow(const AppFailure('ROOM_NOT_FOUND', status: 404));
    await primed();

    await c.read(roomAdminProvider).leave('other');

    verify(() => repo.listMine()).called(1);
    expect(c.read(selectedRoomIdProvider), 'own');
  });

  test('OWNER_CANNOT_LEAVE is rethrown', () async {
    when(() => repo.leave('own'))
        .thenThrow(const AppFailure('OWNER_CANNOT_LEAVE', status: 409));
    await primed();

    await expectLater(
      c.read(roomAdminProvider).leave('own'),
      throwsA(
        isA<AppFailure>().having((f) => f.code, 'code', 'OWNER_CANNOT_LEAVE'),
      ),
    );
    verifyNever(() => repo.listMine());
  });

  test('refresh failure after remove still succeeds', () async {
    when(() => repo.removeMember('own', 'u2')).thenAnswer((_) async {});
    await primed();
    when(() => repo.listMine()).thenThrow(const AppFailure('NETWORK'));

    await c.read(roomAdminProvider).remove('own', 'u2');

    verify(() => repo.listMine()).called(1);
  });

  test('dissolve refreshes codes even if rooms refresh fails', () async {
    when(() => repo.dissolve('own')).thenAnswer((_) async {});
    await primed();
    when(() => repo.listMine()).thenThrow(const AppFailure('NETWORK'));

    await c.read(roomAdminProvider).dissolve('own');

    verify(() => invites.listCodes()).called(1);
  });

  test('leave still selects own room when refresh fails', () async {
    when(() => repo.leave('other')).thenAnswer((_) async {});
    await primed();
    when(() => repo.listMine()).thenThrow(const AppFailure('NETWORK'));

    await c.read(roomAdminProvider).leave('other');

    expect(c.read(selectedRoomIdProvider), 'own');
  });
}
