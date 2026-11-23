import 'package:petbridge/core/realtime/ws_frame.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_live.dart';

/// Side effects the coordinator must carry out after a reduction.
sealed class RoomEffect {
  const new(this.roomId);
  final String roomId;
}

/// Send `room.sub` again to get a fresh snapshot.
class Resubscribe extends RoomEffect {
  const new(super.roomId);
}

/// Start the 1 s timer; call [gapTimedOut] when it fires with a gap open.
class StartGapTimer extends RoomEffect {
  const new(super.roomId);
}

/// The member list changed (the REST room list may be stale).
class MembershipChanged extends RoomEffect {
  const new(super.roomId);
}

class ReduceResult {
  const new(this.state, [this.effects = const []]);

  final RoomLive? state;
  final List<RoomEffect> effects;
}

/// A seq gap of this many missing events or more triggers a resubscribe
/// instead of waiting.
const _maxBufferedGap = 20;

const _handled = {'member.joined', 'member.left', 'presence.update'};

typedef _Applied = ({RoomLive state, List<RoomEffect> effects});

/// Pure reducer: no clock, no I/O. Unknown frame types are returned as is.
ReduceResult reduceRoom(RoomLive? state, WsFrame frame) {
  if (frame.t == 'room.snapshot') return _snapshot(state, frame);
  if (state == null || !_handled.contains(frame.t)) {
    return ReduceResult(state);
  }

  final seq = frame.seq;
  if (seq == null) {
    final applied = _apply(state, frame);
    return ReduceResult(applied.state, applied.effects);
  }
  if (seq <= state.lastSeq) return ReduceResult(state);
  if (seq == state.lastSeq + 1) return _applyInOrder(state, frame);

  final missing = seq - state.lastSeq - 1;
  if (missing >= _maxBufferedGap) {
    return ReduceResult(state.copyWith(buffered: const {}), [
      Resubscribe(state.roomId),
    ]);
  }
  final firstGap = state.buffered.isEmpty;
  return ReduceResult(
    state.copyWith(buffered: {...state.buffered, seq: frame}),
    [if (firstGap) StartGapTimer(state.roomId)],
  );
}

/// The gap timer fired and the gap is still open: drop the buffer and ask
/// for a fresh snapshot.
ReduceResult gapTimedOut(RoomLive state) => ReduceResult(
  state.copyWith(buffered: const {}),
  [Resubscribe(state.roomId)],
);

ReduceResult _applyInOrder(RoomLive state, WsFrame first) {
  final effects = <RoomEffect>[];
  var current = state;
  var frame = first;
  while (true) {
    final applied = _apply(current, frame);
    effects.addAll(applied.effects);
    final seq = frame.seq!;
    final buffered = {...current.buffered}
      ..removeWhere((key, _) => key <= seq);
    current = applied.state.copyWith(lastSeq: seq, buffered: buffered);
    final next = buffered[seq + 1];
    if (next == null) break;
    frame = next;
  }
  return ReduceResult(current, effects);
}

ReduceResult _snapshot(RoomLive? previous, WsFrame frame) {
  final d = frame.d;
  final room = d['room'];
  final seq = d['seq'];
  if (room is! Map<String, Object?> || seq is! num) {
    return ReduceResult(previous);
  }
  final roomId = d['room_id'] ?? room['id'];
  final rawMembers = room['members'];
  if (roomId is! String || rawMembers is! List<Object?>) {
    return ReduceResult(previous);
  }
  final members = _sorted([
    for (final raw in rawMembers)
      if (raw is Map<String, Object?>) ?_parseMember(raw),
  ]);
  final capacity = room['capacity'];
  return ReduceResult(
    RoomLive(
      roomId: roomId,
      lastSeq: seq.toInt(),
      status: _status(room['status']),
      memberCount: members.length,
      capacity: capacity is num ? capacity.toInt() : members.length,
      isOwner: room['is_owner'] == true,
      members: members,
    ),
  );
}

_Applied _apply(RoomLive state, WsFrame frame) {
  final d = frame.d;
  switch (frame.t) {
    case 'member.joined':
      final raw = d['member'];
      final member = raw is Map<String, Object?> ? _parseMember(raw) : null;
      if (member == null) return (state: state, effects: const []);
      final members = _sorted([
        for (final m in state.members)
          if (m.userId != member.userId) m,
        member,
      ]);
      return (
        state: _withMembers(state, members),
        effects: [MembershipChanged(state.roomId)],
      );
    case 'member.left':
      final id = d['user_id'];
      if (id is! String) return (state: state, effects: const []);
      final members = [
        for (final m in state.members)
          if (m.userId != id) m,
      ];
      return (
        state: _withMembers(state, members),
        effects: [MembershipChanged(state.roomId)],
      );
    case 'presence.update':
      final id = d['user_id'];
      final presence = _presence(d['status']);
      return (
        state: state.copyWith(
          members: [
            for (final m in state.members)
              if (m.userId == id) m.copyWith(presence: presence) else m,
          ],
        ),
        effects: const [],
      );
  }
  return (state: state, effects: const []);
}

RoomLive _withMembers(RoomLive state, List<LiveMember> members) {
  var status = state.status;
  if (status == RoomStatus.open && members.length >= state.capacity) {
    status = RoomStatus.full;
  } else if (status == RoomStatus.full && members.length < state.capacity) {
    status = RoomStatus.open;
  }
  return state.copyWith(
    members: members,
    memberCount: members.length,
    status: status,
  );
}

List<LiveMember> _sorted(List<LiveMember> members) =>
    [...members]..sort((a, b) => a.seatNo.compareTo(b.seatNo));

LiveMember? _parseMember(Map<String, Object?> m) {
  final id = m['user_id'];
  final seat = m['seat_no'];
  if (id is! String || seat is! num) return null;
  final nickname = m['nickname'];
  final petType = m['pet_type'];
  return LiveMember(
    userId: id,
    nickname: nickname is String ? nickname : null,
    petType: petType is String ? petType : null,
    seatNo: seat.toInt(),
    role: m['role'] == 'owner' ? RoomRole.owner : RoomRole.member,
    presence: _presence(m['presence']),
  );
}

Presence _presence(Object? raw) => switch (raw) {
  'online' => Presence.online,
  'offline' => Presence.offline,
  _ => Presence.unknown,
};

RoomStatus _status(Object? raw) => switch (raw) {
  'full' => RoomStatus.full,
  'closed' => RoomStatus.closed,
  _ => RoomStatus.open,
};
