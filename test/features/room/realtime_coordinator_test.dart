import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/core/clock.dart';
import 'package:petbridge/core/realtime/ws_client.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/features/room/application/realtime_coordinator.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_live.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

import '../../helpers/fakes.dart';
import 'fake_ws_client.dart';

Room room(String id, {bool own = false}) => Room(
  id: id,
  isOwner: own,
  status: RoomStatus.open,
  memberCount: 2,
  capacity: 5,
  members: const [],
);

Map<String, Object?> member(String userId, int seat) => {
  'user_id': userId,
  'seat_no': seat,
  'role': seat == 1 ? 'owner' : 'member',
  'presence': 'online',
  'nickname': userId,
};

Map<String, Object?> snapshot(String roomId, {int seq = 1}) => {
  'room_id': roomId,
  'seq': seq,
  'room': {
    'id': roomId,
    'status': 'open',
    'member_count': 2,
    'capacity': 5,
    'is_owner': roomId == 'own',
    'members': [member('u1', 1), member('u2', 2)],
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const me = Me(id: 'u1', onboarded: true);
  final t0 = DateTime.utc(2026, 11, 23, 12);

  late MockRoomRepository repo;
  late MockInviteRepository invites;
  late FakeSessionController session;
  late List<FakeWsClient> clients;
  late List<Room> listed;

  FakeWsClient client() => clients.last;

  setUp(() {
    repo = MockRoomRepository();
    invites = MockInviteRepository();
    clients = [];
    listed = [room('own', own: true), room('other')];
    when(() => repo.listMine()).thenAnswer((_) async => listed);
    when(() => invites.listCodes()).thenAnswer((_) async => []);
  });

  /// A container with the coordinator alive and the rooms loaded; the
  /// socket is not `ready` yet.
  ProviderContainer make(FakeAsync async) {
    session = FakeSessionController(const SessionReady(me));
    final c = ProviderContainer.test(
      overrides: [
        sessionControllerProvider.overrideWith(() => session),
        roomRepositoryProvider.overrideWithValue(repo),
        inviteRepositoryProvider.overrideWithValue(invites),
        clockProvider.overrideWithValue(() => t0.add(async.elapsed)),
        wsClientFactoryProvider.overrideWithValue(() {
          final client = FakeWsClient();
          clients.add(client);
          return client;
        }),
      ],
    )..listen(realtimeCoordinatorProvider, (_, _) {});
    async.flushMicrotasks();
    return c;
  }

  void ready(FakeAsync async) {
    client().moveTo(WsConnState.ready);
    async.flushMicrotasks();
  }

  /// [make] then [ready], with the repository calls so far forgotten.
  ProviderContainer makeReady(FakeAsync async) {
    final c = make(async);
    ready(async);
    clearInteractions(repo);
    clearInteractions(invites);
    return c;
  }

  void push(FakeAsync async, String t, Map<String, Object?> d, {int? seq}) {
    client().push(t, d, seq: seq);
    async.flushMicrotasks();
  }

  String subIdFor(String roomId) => client().sent
      .lastWhere((f) => f.t == 'room.sub' && f.d['room_id'] == roomId)
      .id!;

  void lifecycle(WidgetsBinding binding, List<AppLifecycleState> states) =>
      states.forEach(binding.handleAppLifecycleStateChanged);

  const toBackground = [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ];
  const toForeground = [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ];

  test('subscribes every listed room when ready', () {
    fakeAsync((async) {
      make(async);
      expect(client().calls, ['start']);
      expect(client().sent, isEmpty);

      ready(async);

      expect(client().sentRooms('room.sub'), ['own', 'other']);
    });
  });

  test('unsubscribes a room that left the list', () {
    fakeAsync((async) {
      final c = makeReady(async);
      push(async, 'room.snapshot', snapshot('other'));
      expect(c.read(roomLiveProvider('other')), isNotNull);

      listed = [room('own', own: true)];
      c.read(roomsProvider.notifier).refresh().ignore();
      async.flushMicrotasks();

      expect(client().sentRooms('room.unsub'), ['other']);
      expect(c.read(roomLiveProvider('other')), isNull);

      listed = [room('own', own: true), room('new')];
      c.read(roomsProvider.notifier).refresh().ignore();
      async.flushMicrotasks();
      expect(client().sentRooms('room.sub'), ['own', 'other', 'new']);
    });
  });

  test('snapshot fills roomLiveProvider', () {
    fakeAsync((async) {
      final c = makeReady(async);
      expect(c.read(roomLiveProvider('own')), isNull);

      push(async, 'room.snapshot', snapshot('own', seq: 7));

      final live = c.read(roomLiveProvider('own'))!;
      expect(live.lastSeq, 7);
      expect(live.isOwner, isTrue);
      expect(live.members.map((m) => m.userId), ['u1', 'u2']);
      expect(live.members.first.presence, Presence.online);
    });
  });

  test('member.joined triggers one merged rooms refresh', () {
    fakeAsync((async) {
      final c = makeReady(async);
      push(async, 'room.snapshot', snapshot('own'));
      for (var seq = 2; seq <= 4; seq++) {
        push(async, 'member.joined', {
          'room_id': 'own',
          'member': member('u$seq', seq),
        }, seq: seq);
        async.elapse(const Duration(milliseconds: 100));
      }
      expect(c.read(roomLiveProvider('own'))!.memberCount, 4);

      async.elapse(const Duration(milliseconds: 199));
      verifyNever(() => repo.listMine());
      async.elapse(const Duration(milliseconds: 1));
      verify(() => repo.listMine()).called(1);

      async.elapse(const Duration(seconds: 2));
      verifyNever(() => repo.listMine());
    });
  });

  test('resubscribe requests within 1s are merged', () {
    fakeAsync((async) {
      makeReady(async);
      async.elapse(const Duration(seconds: 2));

      for (var i = 0; i < 3; i++) {
        push(async, 'resync', {'room_id': 'own'});
        async.elapse(const Duration(milliseconds: 100));
      }
      // The ready sub, then the first resync at once.
      expect(client().sentRooms('room.sub'), ['own', 'other', 'own']);

      async.elapse(const Duration(milliseconds: 699));
      expect(client().sentRooms('room.sub'), hasLength(3));
      async.elapse(const Duration(milliseconds: 1));
      // The other two in one, a second after the first.
      expect(client().sentRooms('room.sub'), ['own', 'other', 'own', 'own']);

      async.elapse(const Duration(seconds: 3));
      expect(client().sentRooms('room.sub'), hasLength(4));
    });
  });

  test('gap timer resubscribes after 1s', () {
    fakeAsync((async) {
      final c = makeReady(async);
      push(async, 'room.snapshot', snapshot('own'));
      async.elapse(const Duration(seconds: 2));

      push(async, 'member.joined', {
        'room_id': 'own',
        'member': member('u3', 3),
      }, seq: 3);
      push(async, 'member.joined', {
        'room_id': 'own',
        'member': member('u4', 4),
      }, seq: 4);
      expect(c.read(roomLiveProvider('own'))!.buffered, hasLength(2));

      async.elapse(const Duration(milliseconds: 999));
      expect(client().sentRooms('room.sub'), ['own', 'other']);
      async.elapse(const Duration(milliseconds: 1));

      // One timer per gap, so one resubscribe.
      expect(client().sentRooms('room.sub'), ['own', 'other', 'own']);
      expect(c.read(roomLiveProvider('own'))!.buffered, isEmpty);
      async.elapse(const Duration(seconds: 3));
      expect(client().sentRooms('room.sub'), hasLength(3));
    });
  });

  test('gap filled in time does not resubscribe', () {
    fakeAsync((async) {
      final c = makeReady(async);
      push(async, 'room.snapshot', snapshot('own'));
      push(async, 'member.left', {'room_id': 'own', 'user_id': 'u2'}, seq: 3);
      async.elapse(const Duration(milliseconds: 500));
      push(async, 'member.joined', {
        'room_id': 'own',
        'member': member('u3', 3),
      }, seq: 2);
      expect(c.read(roomLiveProvider('own'))!.lastSeq, 3);

      async.elapse(const Duration(seconds: 2));

      expect(client().sentRooms('room.sub'), ['own', 'other']);
    });
  });

  test('pet.action reaches petActions of its room', () {
    fakeAsync((async) {
      final c = makeReady(async);
      final coordinator = c.read(realtimeCoordinatorProvider);
      final other = <PetAction>[];
      final own = <PetAction>[];
      coordinator.petActions('other').listen(other.add);
      coordinator.petActions('own').listen(own.add);

      push(async, 'pet.action', {
        'room_id': 'other',
        'from_user_id': 'u2',
        'target_user_id': 'u3',
        'action': 'tap',
      });

      expect(own, isEmpty);
      expect(other.single.targetUserId, 'u3');
      expect(other.single.fromUserId, 'u2');
    });
  });

  test('tapPet emits local action and sends pet.tap', () {
    fakeAsync((async) {
      final c = makeReady(async);
      final coordinator = c.read(realtimeCoordinatorProvider);
      final actions = <PetAction>[];
      coordinator.petActions('other').listen(actions.add);

      expect(coordinator.tapPet('other', 'u2'), isTrue);
      async.flushMicrotasks();

      expect(actions.single.targetUserId, 'u2');
      expect(actions.single.fromUserId, isNull);
      final tap = client().sent.last;
      expect(tap.t, 'pet.tap');
      expect(tap.d, {'room_id': 'other', 'target_user_id': 'u2'});
    });
  });

  test('tapping own pet plays locally only', () {
    fakeAsync((async) {
      final c = makeReady(async);
      final coordinator = c.read(realtimeCoordinatorProvider);
      final actions = <PetAction>[];
      coordinator.petActions('own').listen(actions.add);

      expect(coordinator.tapPet('own', 'u1'), isFalse);
      async.flushMicrotasks();

      expect(actions.single.targetUserId, 'u1');
      expect(client().sentRooms('pet.tap'), isEmpty);
    });
  });

  test('same target within 500ms sends once', () {
    fakeAsync((async) {
      final c = makeReady(async);
      final coordinator = c.read(realtimeCoordinatorProvider);
      final actions = <PetAction>[];
      coordinator.petActions('other').listen(actions.add);

      expect(coordinator.tapPet('other', 'u2'), isTrue);
      async.elapse(const Duration(milliseconds: 499));
      expect(coordinator.tapPet('other', 'u2'), isFalse);
      async.elapse(const Duration(milliseconds: 1));
      expect(coordinator.tapPet('other', 'u2'), isTrue);
      async.flushMicrotasks();

      expect(actions, hasLength(3));
      expect(client().sentRooms('pet.tap'), hasLength(2));
    });
  });

  test('taps across pets are capped at two per second', () {
    fakeAsync((async) {
      final c = makeReady(async);
      final coordinator = c.read(realtimeCoordinatorProvider);
      final actions = <PetAction>[];
      coordinator.petActions('other').listen(actions.add);

      expect(coordinator.tapPet('other', 'u2'), isTrue);
      async.elapse(const Duration(milliseconds: 600));
      expect(coordinator.tapPet('other', 'u3'), isTrue);
      expect(coordinator.tapPet('other', 'u4'), isFalse);
      async.elapse(const Duration(milliseconds: 399));
      expect(coordinator.tapPet('other', 'u5'), isFalse);
      async.elapse(const Duration(milliseconds: 1));
      // The first tap is a second old now; the second one still counts.
      expect(coordinator.tapPet('other', 'u5'), isTrue);
      expect(coordinator.tapPet('other', 'u6'), isFalse);
      async.flushMicrotasks();

      expect(actions, hasLength(6));
      expect(
        [
          for (final f in client().sent)
            if (f.t == 'pet.tap') f.d['target_user_id'],
        ],
        ['u2', 'u3', 'u5'],
      );
    });
  });

  test('room.kicked clears room, selects own room and emits notice', () {
    fakeAsync((async) {
      final c = makeReady(async);
      final kicks = <KickNotice>[];
      c.read(realtimeCoordinatorProvider).kicks.listen(kicks.add);
      c.read(selectedRoomIdProvider.notifier).select('other');
      push(async, 'room.snapshot', snapshot('other'));

      listed = [room('own', own: true)];
      push(async, 'room.kicked', {'room_id': 'other', 'reason': 'kicked'});

      expect(c.read(roomLiveProvider('other')), isNull);
      expect(c.read(selectedRoomIdProvider), 'own');
      expect(client().sentRooms('room.unsub'), ['other']);
      expect(kicks.single.roomId, 'other');
      expect(kicks.single.reason, KickReason.kicked);

      async.elapse(const Duration(milliseconds: 500));
      verify(() => repo.listMine()).called(1);
      expect(c.read(roomsProvider).value!.map((r) => r.id), ['own']);

      // Late frames for the room are dropped, and not unsubscribed twice.
      push(async, 'room.snapshot', snapshot('other'));
      expect(c.read(roomLiveProvider('other')), isNull);
      expect(client().sentRooms('room.unsub'), ['other']);
    });
  });

  test('left kick emits notice with reason left', () {
    fakeAsync((async) {
      final c = makeReady(async);
      final kicks = <KickNotice>[];
      c.read(realtimeCoordinatorProvider).kicks.listen(kicks.add);

      push(async, 'room.kicked', {'room_id': 'other', 'reason': 'left'});
      push(async, 'room.kicked', {'room_id': 'own', 'reason': 'dissolved'});

      expect(kicks.map((k) => (k.roomId, k.reason)), [
        ('other', KickReason.left),
        ('own', KickReason.dissolved),
      ]);
    });
  });

  test('ROOM_NOT_FOUND on sub acts as kicked without notice', () {
    fakeAsync((async) {
      final c = makeReady(async);
      final kicks = <KickNotice>[];
      c.read(realtimeCoordinatorProvider).kicks.listen(kicks.add);
      c.read(selectedRoomIdProvider.notifier).select('other');
      push(async, 'room.snapshot', snapshot('other'));

      push(async, 'error', {
        'ref': subIdFor('other'),
        'code': 'ROOM_NOT_FOUND',
      });
      async.elapse(const Duration(milliseconds: 500));

      expect(c.read(roomLiveProvider('other')), isNull);
      expect(c.read(selectedRoomIdProvider), 'own');
      expect(client().sentRooms('room.unsub'), ['other']);
      verify(() => repo.listMine()).called(1);
      expect(kicks, isEmpty);
    });
  });

  test('RATE_LIMITED on sub retries after 1s', () {
    fakeAsync((async) {
      makeReady(async);

      push(async, 'error', {'ref': subIdFor('own'), 'code': 'RATE_LIMITED'});
      async.elapse(const Duration(milliseconds: 999));
      expect(client().sentRooms('room.sub'), ['own', 'other']);
      async.elapse(const Duration(milliseconds: 1));

      expect(client().sentRooms('room.sub'), ['own', 'other', 'own']);
    });
  });

  test('resync without room_id resubscribes all', () {
    fakeAsync((async) {
      makeReady(async);
      async.elapse(const Duration(seconds: 2));

      push(async, 'resync', {});

      expect(client().sentRooms('room.sub'), ['own', 'other', 'own', 'other']);
    });
  });

  test('code.invalidated refreshes codes', () {
    fakeAsync((async) {
      makeReady(async);

      push(async, 'code.invalidated', {
        'room_id': 'own',
        'reason': 'room_full',
      });

      verify(() => invites.listCodes()).called(1);
    });
  });

  test('frames for unlisted room are dropped', () {
    fakeAsync((async) {
      final c = makeReady(async);
      final actions = <PetAction>[];
      c
          .read(realtimeCoordinatorProvider)
          .petActions('ghost')
          .listen(actions.add);

      push(async, 'room.snapshot', snapshot('ghost'));
      push(async, 'presence.update', {
        'room_id': 'ghost',
        'user_id': 'u2',
        'status': 'offline',
      });
      push(async, 'pet.action', {
        'room_id': 'ghost',
        'from_user_id': 'u2',
        'target_user_id': 'u1',
        'action': 'tap',
      });

      expect(c.read(roomLiveProvider('ghost')), isNull);
      expect(actions, isEmpty);
      // One unsub for the stray subscription, not one per frame.
      expect(client().sentRooms('room.unsub'), ['ghost']);
    });
  });

  test('session leaving ready stops client and clears live rooms', () {
    fakeAsync((async) {
      final c = makeReady(async);
      push(async, 'room.snapshot', snapshot('own'));
      final first = client();

      session.current = const SessionUnauthenticated();
      async.flushMicrotasks();
      c.read(realtimeCoordinatorProvider);
      async.flushMicrotasks();

      expect(first.disposed, isTrue);
      expect(c.read(wsClientProvider), isNull);
      expect(c.read(roomLiveProvider('own')), isNull);

      listed = [room('mine2', own: true)];
      session.current = const SessionReady(Me(id: 'u9', onboarded: true));
      async.flushMicrotasks();
      c.read(realtimeCoordinatorProvider);
      async.flushMicrotasks();

      expect(clients, hasLength(2));
      expect(client().calls, ['start']);
      ready(async);
      expect(client().sentRooms('room.sub'), ['mine2']);
      expect(first.sentRooms('room.sub'), ['own', 'other']);
    });
  });

  test('reconnecting shows only after 3s', () {
    fakeAsync((async) {
      final c = makeReady(async);
      expect(c.read(wsReconnectingProvider), isFalse);

      client().moveTo(WsConnState.disconnected);
      async.elapse(const Duration(milliseconds: 2999));
      expect(c.read(wsReconnectingProvider), isFalse);
      client().moveTo(WsConnState.connecting);
      async.elapse(const Duration(milliseconds: 1));
      expect(c.read(wsReconnectingProvider), isTrue);

      ready(async);
      expect(c.read(wsReconnectingProvider), isFalse);
    });
  });

  test('paused closes and hides notice, resumed reconnects and refreshes', () {
    fakeAsync((async) {
      final binding = TestWidgetsFlutterBinding.instance;
      final c = makeReady(async);

      lifecycle(binding, toBackground);
      async.elapse(const Duration(seconds: 5));
      expect(client().calls, ['start', 'pause']);
      expect(c.read(wsReconnectingProvider), isFalse);

      lifecycle(binding, toForeground);
      async.flushMicrotasks();
      expect(client().calls, ['start', 'pause', 'resume']);
      verify(() => repo.listMine()).called(1);

      async.elapse(const Duration(seconds: 3));
      expect(c.read(wsReconnectingProvider), isTrue);
      ready(async);
      expect(c.read(wsReconnectingProvider), isFalse);
    });
  });

  test('inactive alone does not close the socket', () {
    fakeAsync((async) {
      final binding = TestWidgetsFlutterBinding.instance;
      makeReady(async);

      lifecycle(binding, const [
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]);
      async.flushMicrotasks();

      expect(client().calls, isNot(contains('pause')));
    });
  });
}
