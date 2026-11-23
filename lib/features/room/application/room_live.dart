import 'package:petbridge/core/realtime/ws_frame.dart';
import 'package:petbridge/features/room/application/room.dart';

enum Presence { online, offline, unknown }

/// A member of a room as seen over the realtime channel.
class LiveMember {
  const new({
    required this.userId,
    required this.seatNo,
    required this.role,
    required this.presence,
    this.nickname,
    this.petType,
  });

  final String userId;
  final String? nickname;
  final String? petType;
  final int seatNo;
  final RoomRole role;
  final Presence presence;

  LiveMember copyWith({Presence? presence}) => LiveMember(
    userId: userId,
    nickname: nickname,
    petType: petType,
    seatNo: seatNo,
    role: role,
    presence: presence ?? this.presence,
  );
}

/// In-memory live state of one room. `lastSeq` is never persisted.
class RoomLive {
  const new({
    required this.roomId,
    required this.lastSeq,
    required this.status,
    required this.memberCount,
    required this.capacity,
    required this.isOwner,
    required this.members,
    this.buffered = const {},
  });

  final String roomId;
  final int lastSeq;
  final RoomStatus status;
  final int memberCount;
  final int capacity;
  final bool isOwner;

  /// Sorted by seat.
  final List<LiveMember> members;

  /// Frames with a seq beyond `lastSeq + 1`, waiting for the gap to fill.
  final Map<int, WsFrame> buffered;

  RoomLive copyWith({
    int? lastSeq,
    RoomStatus? status,
    int? memberCount,
    List<LiveMember>? members,
    Map<int, WsFrame>? buffered,
  }) => RoomLive(
    roomId: roomId,
    lastSeq: lastSeq ?? this.lastSeq,
    status: status ?? this.status,
    memberCount: memberCount ?? this.memberCount,
    capacity: capacity,
    isOwner: isOwner,
    members: members ?? this.members,
    buffered: buffered ?? this.buffered,
  );
}
