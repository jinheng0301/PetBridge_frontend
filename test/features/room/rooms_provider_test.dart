import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

import '../../helpers/fakes.dart';

Room room(String id, {required int count, bool own = false}) => Room(
  id: id,
  isOwner: own,
  status: RoomStatus.open,
  memberCount: count,
  capacity: 5,
  members: const [],
);

void main() {
  const me = Me(id: 'u1', onboarded: true);

  group('roomModeFor', () {
    test('no rooms is solo', () => expect(roomModeFor([]), RoomMode.solo));
    test('own room alone is solo', () {
      expect(roomModeFor([room('a', count: 1, own: true)]), RoomMode.solo);
    });
    test('own room with a guest is in room', () {
      expect(roomModeFor([room('a', count: 2, own: true)]), RoomMode.inRoom);
    });
    test('joined room is in room', () {
      expect(
        roomModeFor([room('a', count: 1, own: true), room('b', count: 3)]),
        RoomMode.inRoom,
      );
    });
  });

  group('defaultRoomFor', () {
    test('prefers the first room with company', () {
      expect(
        defaultRoomFor([room('a', count: 1, own: true), room('b', count: 3)])
            ?.id,
        'b',
      );
      expect(
        defaultRoomFor([room('a', count: 2, own: true), room('b', count: 3)])
            ?.id,
        'a',
      );
    });
    test('empty list has none', () => expect(defaultRoomFor([]), isNull));
  });

  group('roomsProvider', () {
    late MockRoomRepository repo;
    late FakeSessionController session;

    ProviderContainer make(Session initial) {
      session = FakeSessionController(initial);
      return ProviderContainer.test(
        overrides: [
          sessionControllerProvider.overrideWith(() => session),
          roomRepositoryProvider.overrideWithValue(repo),
        ],
      );
    }

    setUp(() => repo = MockRoomRepository());

    test('fetches when session is ready', () async {
      when(() => repo.listMine())
          .thenAnswer((_) async => [room('a', count: 2, own: true)]);
      final c = make(const SessionReady(me));

      final rooms = await c.read(roomsProvider.future);

      expect(rooms.single.id, 'a');
      expect(c.read(roomModeProvider), RoomMode.inRoom);
    });

    test('rooms cleared when session leaves ready', () async {
      when(() => repo.listMine())
          .thenAnswer((_) async => [room('a', count: 2, own: true)]);
      final c = make(const SessionReady(me))..listen(roomsProvider, (_, _) {});
      await c.read(roomsProvider.future);

      session.current = const SessionUnauthenticated();
      final rooms = await c.read(roomsProvider.future);

      expect(rooms, isEmpty);
      expect(c.read(roomModeProvider), RoomMode.solo);
      verify(() => repo.listMine()).called(1);
    });

    test('does not fetch before onboarding', () async {
      final c = make(const SessionNeedsOnboarding(me));

      expect(await c.read(roomsProvider.future), isEmpty);
      verifyNever(() => repo.listMine());
    });

    test('refresh failure keeps previous rooms', () async {
      var calls = 0;
      when(() => repo.listMine()).thenAnswer((_) async {
        if (calls++ == 0) return [room('a', count: 2, own: true)];
        throw const AppFailure(AppFailure.network);
      });
      final c = make(const SessionReady(me))..listen(roomsProvider, (_, _) {});
      await c.read(roomsProvider.future);

      await expectLater(
        c.read(roomsProvider.notifier).refresh(),
        throwsA(isA<AppFailure>()),
      );

      expect(c.read(roomsProvider).value?.single.id, 'a');
      expect(c.read(roomsProvider).hasError, isFalse);
    });

    test('selected room falls back when it disappears', () async {
      var rooms = [room('a', count: 1, own: true), room('b', count: 3)];
      when(() => repo.listMine()).thenAnswer((_) async => rooms);
      final c = make(const SessionReady(me))
        ..listen(selectedRoomProvider, (_, _) {});
      await c.read(roomsProvider.future);

      c.read(selectedRoomIdProvider.notifier).select('b');
      expect(c.read(selectedRoomProvider)?.id, 'b');

      rooms = [room('a', count: 1, own: true)];
      await c.read(roomsProvider.notifier).refresh();

      expect(c.read(selectedRoomProvider)?.id, 'a');
    });
  });
}
