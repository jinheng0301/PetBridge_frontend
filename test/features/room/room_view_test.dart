import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/room/application/realtime_coordinator.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_live.dart';
import 'package:petbridge/features/room/application/room_view.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

import '../../helpers/fakes.dart';

void main() {
  const me = Me(id: 'u1', onboarded: true);
  const listed = Room(
    id: 'own',
    isOwner: true,
    status: RoomStatus.open,
    memberCount: 2,
    capacity: 5,
    members: [
      RoomMember(userId: 'u1', seatNo: 1, role: RoomRole.owner, nickname: 'A'),
      RoomMember(userId: 'u2', seatNo: 2, role: RoomRole.member),
    ],
  );

  late ProviderContainer c;

  setUp(() async {
    final repo = MockRoomRepository();
    when(repo.listMine).thenAnswer((_) async => [listed]);
    c = ProviderContainer.test(
      overrides: [
        sessionControllerProvider.overrideWith(
          () => FakeSessionController(const SessionReady(me)),
        ),
        roomRepositoryProvider.overrideWithValue(repo),
        wsClientProvider.overrideWithValue(null),
      ],
    )..listen(roomViewProvider('own'), (_, _) {});
    await c.read(roomsProvider.future);
  });

  test('falls back to rooms list with unknown presence', () {
    final view = c.read(roomViewProvider('own'))!;

    expect(view.roomId, 'own');
    expect(view.isOwner, isTrue);
    expect(view.memberCount, 2);
    expect(view.capacity, 5);
    expect(view.members.map((m) => m.userId), ['u1', 'u2']);
    expect(view.members.first.nickname, 'A');
    expect(view.members.first.role, RoomRole.owner);
    expect(view.members.map((m) => m.presence), [
      Presence.unknown,
      Presence.unknown,
    ]);
    expect(c.read(roomViewProvider('missing')), isNull);
  });

  test('prefers live state once snapshot arrived', () {
    c
        .read(roomLiveProvider('own').notifier)
        .set(
          const RoomLive(
            roomId: 'own',
            lastSeq: 3,
            status: RoomStatus.open,
            memberCount: 3,
            capacity: 5,
            isOwner: true,
            members: [
              LiveMember(
                userId: 'u1',
                seatNo: 1,
                role: RoomRole.owner,
                presence: Presence.online,
              ),
              LiveMember(
                userId: 'u2',
                seatNo: 2,
                role: RoomRole.member,
                presence: Presence.offline,
              ),
              LiveMember(
                userId: 'u3',
                seatNo: 3,
                role: RoomRole.member,
                presence: Presence.online,
              ),
            ],
          ),
        );

    final view = c.read(roomViewProvider('own'))!;

    expect(view.memberCount, 3);
    expect(view.members.map((m) => (m.userId, m.presence)), [
      ('u1', Presence.online),
      ('u2', Presence.offline),
      ('u3', Presence.online),
    ]);
  });
}
