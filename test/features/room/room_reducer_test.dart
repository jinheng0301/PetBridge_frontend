import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/realtime/ws_frame.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_live.dart';
import 'package:petbridge/features/room/application/room_reducer.dart';

Map<String, Object?> _member(
  String id,
  int seat, {
  String role = 'member',
  String presence = 'online',
  String? nickname,
}) => {
  'user_id': id,
  'nickname': nickname ?? id,
  'pet_type': 'cat',
  'seat_no': seat,
  'role': role,
  'presence': presence,
};

WsFrame _snapshot(int seq, {List<Map<String, Object?>>? members}) {
  final list = members ?? [_member('a', 1, role: 'owner')];
  return WsFrame(
    'room.snapshot',
    d: {
      'room_id': 'r1',
      'seq': seq,
      'room': {
        'status': 'open',
        'member_count': list.length,
        'capacity': 4,
        'is_owner': true,
        'members': list,
      },
    },
  );
}

WsFrame _joined(String id, int seat, {int? seq}) =>
    WsFrame('member.joined', seq: seq, d: {'member': _member(id, seat)});

WsFrame _left(String id, {int? seq}) =>
    WsFrame('member.left', seq: seq, d: {'user_id': id});

RoomLive _live({int lastSeq = 5}) =>
    reduceRoom(null, _snapshot(lastSeq)).state!;

void main() {
  test('snapshot replaces state and sets lastSeq', () {
    final old = _live(lastSeq: 50);
    final r = reduceRoom(old, _snapshot(3));
    expect(r.state!.lastSeq, 3);
    expect(r.state!.roomId, old.roomId);
    expect(r.state!.members.single.role, RoomRole.owner);
    expect(r.state!.memberCount, 1);
    expect(r.state!.capacity, 4);
    expect(r.state!.isOwner, isTrue);
    expect(r.state!.status, RoomStatus.open);
    expect(r.state!.buffered, isEmpty);
  });

  test('event with seq <= lastSeq is dropped', () {
    final s = _live();
    final r = reduceRoom(s, _joined('b', 2, seq: 5));
    expect(r.state, same(s));
    expect(r.effects, isEmpty);
  });

  test('next seq applies and advances', () {
    final r = reduceRoom(_live(), _joined('b', 2, seq: 6));
    expect(r.state!.lastSeq, 6);
    expect(r.state!.members.map((m) => m.userId), ['a', 'b']);
  });

  test('gap under 20 buffers and asks for timer', () {
    final s = _live();
    final r1 = reduceRoom(s, _joined('c', 3, seq: 7));
    expect(r1.state!.lastSeq, 5);
    expect(r1.state!.members, hasLength(1));
    expect(r1.state!.buffered.keys, [7]);
    expect(r1.effects.whereType<StartGapTimer>(), hasLength(1));

    final r2 = reduceRoom(r1.state, _joined('b', 2, seq: 6));
    expect(r2.state!.lastSeq, 7);
    expect(r2.state!.members.map((m) => m.userId), ['a', 'b', 'c']);
    expect(r2.state!.buffered, isEmpty);
  });

  test('gap of 20 or more resubscribes', () {
    final r = reduceRoom(_live(), _joined('b', 2, seq: 26));
    expect(r.effects.single, isA<Resubscribe>());
    expect(r.state!.lastSeq, 5);
    expect(r.state!.buffered, isEmpty);
  });

  test('gapTimedOut resubscribes and clears buffer', () {
    final buffered = reduceRoom(_live(), _joined('c', 3, seq: 7)).state!;
    final r = gapTimedOut(buffered);
    expect(r.state!.buffered, isEmpty);
    expect(r.effects.single, isA<Resubscribe>());
    expect((r.effects.single as Resubscribe).roomId, buffered.roomId);
  });

  test('member.joined upserts by user id', () {
    final s = reduceRoom(_live(), _joined('b', 2, seq: 6)).state!;
    final r = reduceRoom(s, _joined('b', 2, seq: 7));
    expect(r.state!.members, hasLength(2));
    expect(r.state!.memberCount, 2);
    expect(r.effects.whereType<MembershipChanged>(), hasLength(1));
  });

  test('member.left removes or ignores', () {
    final s = reduceRoom(_live(), _joined('b', 2, seq: 6)).state!;
    final r = reduceRoom(s, _left('b', seq: 7));
    expect(r.state!.members.map((m) => m.userId), ['a']);
    expect(r.state!.memberCount, 1);
    expect(r.effects.whereType<MembershipChanged>(), hasLength(1));

    final again = reduceRoom(r.state, _left('b', seq: 8));
    expect(again.state!.members, hasLength(1));
    expect(again.state!.memberCount, 1);
    expect(again.state!.lastSeq, 8);
  });

  test('event without seq applies without touching lastSeq', () {
    final s = _live();
    final p = reduceRoom(
      s,
      const WsFrame(
        'presence.update',
        d: {'user_id': 'a', 'status': 'offline'},
      ),
    );
    expect(p.state!.members.single.presence, Presence.offline);
    expect(p.state!.lastSeq, 5);

    final j = reduceRoom(s, _joined('b', 2));
    expect(j.state!.members, hasLength(2));
    expect(j.state!.lastSeq, 5);
    expect(j.effects.single, isA<MembershipChanged>());
  });

  test('events before any snapshot are ignored', () {
    final r = reduceRoom(null, _joined('b', 2, seq: 1));
    expect(r.state, isNull);
    expect(r.effects, isEmpty);
  });

  test('unknown type is ignored', () {
    final s = _live();
    final r = reduceRoom(s, const WsFrame('pet.petted', seq: 6));
    expect(r.state, same(s));
    expect(r.effects, isEmpty);
  });
}
