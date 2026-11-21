import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/core/clock.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/application/join_controller.dart';
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

import '../../helpers/fakes.dart';

const me = Me(id: 'u1', onboarded: true);

const outcome = JoinOutcome(
  roomId: 'r9',
  memberCount: 2,
  capacity: 5,
  members: [
    RoomMember(userId: 'u9', seatNo: 1, role: RoomRole.owner),
    RoomMember(userId: 'u1', seatNo: 2, role: RoomRole.member),
  ],
  rewards: [],
);

const room9 = Room(
  id: 'r9',
  isOwner: false,
  status: RoomStatus.open,
  memberCount: 2,
  capacity: 5,
  members: [],
);

const own = Room(
  id: 'own',
  isOwner: true,
  status: RoomStatus.open,
  memberCount: 1,
  capacity: 5,
  members: [],
);

void main() {
  late MockInviteRepository invites;
  late MockRoomRepository rooms;
  late FakeSessionController session;
  late DateTime now;

  setUp(() {
    invites = MockInviteRepository();
    rooms = MockRoomRepository();
    now = DateTime.utc(2026, 11, 21, 10);
    when(() => rooms.listMine()).thenAnswer((_) async => [own]);
  });

  ProviderContainer make() {
    session = FakeSessionController(const SessionReady(me));
    final c = ProviderContainer.test(
      overrides: [
        sessionControllerProvider.overrideWith(() => session),
        roomRepositoryProvider.overrideWithValue(rooms),
        inviteRepositoryProvider.overrideWithValue(invites),
        clockProvider.overrideWithValue(() => now),
      ],
    )..listen(joinControllerProvider, (_, _) {});
    return c;
  }

  JoinController ctl(ProviderContainer c) =>
      c.read(joinControllerProvider.notifier);
  JoinState st(ProviderContainer c) => c.read(joinControllerProvider);

  void failWith(String code, [Map<String, Object?> details = const {}]) {
    when(() => invites.join(any()))
        .thenThrow(AppFailure(code, status: 429, details: details));
  }

  test('setInput normalizes and canSubmit only at 8 valid chars', () {
    final c = make();
    ctl(c).setInput('abcd-23');
    expect(st(c).input, 'ABCD23');
    expect(st(c).canSubmit(now), isFalse);

    ctl(c).setInput('abcd-2345');
    expect(st(c).input, 'ABCD2345');
    expect(st(c).canSubmit(now), isTrue);
  });

  test('paste extracts link code', () {
    final c = make();
    ctl(c).paste('Join me https://petbridge.example.com/j/ABCD2345 !');
    expect(st(c).input, 'ABCD2345');
  });

  test('prefill ignores invalid param', () {
    final c = make();
    ctl(c).prefill('abc');
    expect(st(c).input, '');
    ctl(c).prefill('ABCD2345');
    expect(st(c).input, 'ABCD2345');
  });

  test('success stores outcome, selects room and refreshes rooms', () async {
    when(() => invites.join('ABCD2345')).thenAnswer((_) async => outcome);
    final c = make();
    await c.read(roomsProvider.future);
    when(() => rooms.listMine()).thenAnswer((_) async => [own, room9]);

    ctl(c).setInput('ABCD2345');
    await ctl(c).submit();

    expect(st(c).result, same(outcome));
    expect(st(c).failure, isNull);
    expect(st(c).submitting, isFalse);
    expect(c.read(selectedRoomIdProvider), 'r9');
    expect(c.read(roomsProvider).value?.map((r) => r.id), ['own', 'r9']);
    expect(c.read(selectedRoomProvider)?.id, 'r9');
  });

  test('failure keeps input', () async {
    failWith('CODE_INVALID');
    final c = make();
    ctl(c).setInput('ABCD2345');
    await ctl(c).submit();

    expect(st(c).input, 'ABCD2345');
    expect(st(c).failure?.code, 'CODE_INVALID');
    expect(st(c).isBlocked(now), isFalse);
  });

  test('cooldown blocks until retry_after elapses', () async {
    failWith('CODE_COOLDOWN', {'retry_after_seconds': 1800});
    final c = make();
    ctl(c).setInput('ABCD2345');
    await ctl(c).submit();

    expect(st(c).isBlocked(now), isTrue);
    expect(st(c).remaining(now), const Duration(minutes: 30));
    expect(st(c).canSubmit(now), isFalse);

    now = now.add(const Duration(seconds: 1800));
    expect(st(c).isBlocked(now), isFalse);
    expect(st(c).remaining(now), Duration.zero);
    expect(st(c).canSubmit(now), isTrue);
  });

  test('RATE_LIMITED without retry_after does not block', () async {
    failWith('RATE_LIMITED');
    final c = make();
    ctl(c).setInput('ABCD2345');
    await ctl(c).submit();

    expect(st(c).failure?.code, 'RATE_LIMITED');
    expect(st(c).isBlocked(now), isFalse);
  });

  test('RATE_LIMITED with retry_after blocks', () async {
    failWith('RATE_LIMITED', {'retry_after_seconds': 60});
    final c = make();
    ctl(c).setInput('ABCD2345');
    await ctl(c).submit();

    expect(st(c).remaining(now), const Duration(minutes: 1));
  });

  test('leave clears input but keeps cooldown', () async {
    failWith('CODE_COOLDOWN', {'retry_after_seconds': 1800});
    final c = make();
    ctl(c).setInput('ABCD2345');
    await ctl(c).submit();

    ctl(c).leave();

    expect(st(c).input, '');
    expect(st(c).failure, isNull);
    expect(st(c).result, isNull);
    expect(st(c).isBlocked(now), isTrue);
  });

  test('server cooldown starts countdown on a fresh controller', () async {
    failWith('CODE_COOLDOWN', {'retry_after_seconds': 900});
    final c = make();
    expect(st(c).blockedUntil, isNull);

    ctl(c).setInput('ABCD2345');
    await ctl(c).submit();

    expect(st(c).remaining(now), const Duration(minutes: 15));
  });

  test('submit ignored while submitting', () async {
    final gate = Completer<JoinOutcome>();
    when(() => invites.join(any())).thenAnswer((_) => gate.future);
    final c = make();
    ctl(c).setInput('ABCD2345');

    final first = ctl(c).submit();
    expect(st(c).submitting, isTrue);
    await ctl(c).submit();
    gate.complete(outcome);
    await first;

    verify(() => invites.join(any())).called(1);
  });

  test('submit ignored while blocked or invalid', () async {
    final c = make();
    ctl(c).setInput('ABC');
    await ctl(c).submit();
    verifyNever(() => invites.join(any()));
  });

  test('join state cleared when session changes', () async {
    failWith('CODE_COOLDOWN', {'retry_after_seconds': 1800});
    final c = make();
    ctl(c).setInput('ABCD2345');
    await ctl(c).submit();
    expect(st(c).blockedUntil, isNotNull);

    session.current = const SessionReady(Me(id: 'u2', onboarded: true));

    expect(st(c).blockedUntil, isNull);
    expect(st(c).input, '');
  });

  test('user switch during submit drops the result quietly', () async {
    final gate = Completer<JoinOutcome>();
    when(() => invites.join(any())).thenAnswer((_) => gate.future);
    final c = make();
    ctl(c).setInput('ABCD2345');
    final pending = ctl(c).submit();

    session.current = const SessionReady(Me(id: 'u2', onboarded: true));
    gate.complete(outcome);
    await pending;

    expect(st(c).result, isNull);
    expect(st(c).submitting, isFalse);
  });
}
